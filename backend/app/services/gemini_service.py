import httpx
from typing import Any

from app.core.config import settings

_GEMINI_API_BASE = "https://generativelanguage.googleapis.com/v1beta/models"

_PLACEHOLDER_VALUES = {
    "",
    "your_gemini_api_key",
    "replace_with_gemini_api_key",
    "changeme",
}


def _normalized(value: str | None) -> str:
    return (value or "").strip()


def _is_placeholder(value: str | None) -> bool:
    normalized = _normalized(value).lower()
    return normalized in _PLACEHOLDER_VALUES or normalized.startswith("your_")


def gemini_configured() -> bool:
    return not _is_placeholder(settings.gemini_api_key)


def _build_prompt(
    mood_text: str,
    emotion: str,
    tracks: list[dict[str, Any]],
) -> str:
    preview_tracks = tracks[:3]
    tracks_text = ", ".join(
        [
            f"{track.get('track_name', 'Unknown')} by {track.get('artist_name', 'Unknown')}"
            for track in preview_tracks
        ]
    )
    if not tracks_text:
        tracks_text = "No tracks available yet"

    return (
        "You are EmoTune, a supportive music wellbeing assistant. "
        "Write a short and caring feedback message for the user. "
        "Use 2 to 3 sentences only, under 80 words, simple language, no diagnosis, "
        "no medical claims, and no crisis instructions unless the user clearly asks for help.\n\n"
        f"User mood text: {mood_text}\n"
        f"Detected emotion: {emotion}\n"
        f"Suggested tracks: {tracks_text}\n"
        "Feedback:"
    )


def _extract_generated_text(payload: dict[str, Any]) -> str:
    candidates = payload.get("candidates")
    if not isinstance(candidates, list):
        raise httpx.HTTPError("Gemini response missing candidates.")

    for candidate in candidates:
        if not isinstance(candidate, dict):
            continue
        content = candidate.get("content")
        if not isinstance(content, dict):
            continue
        parts = content.get("parts")
        if not isinstance(parts, list):
            continue
        text_parts: list[str] = []
        for part in parts:
            if not isinstance(part, dict):
                continue
            text = part.get("text")
            if isinstance(text, str) and text.strip():
                text_parts.append(text.strip())
        if text_parts:
            return "\n".join(text_parts)

    raise httpx.HTTPError("Gemini response did not include text output.")


def generate_feedback(
    mood_text: str,
    emotion: str,
    tracks: list[dict[str, Any]],
) -> str:
    if not gemini_configured():
        raise RuntimeError("Gemini API key is not configured.")

    model = _normalized(settings.gemini_model) or "gemini-2.5-flash"
    url = f"{_GEMINI_API_BASE}/{model}:generateContent"

    payload = {
        "contents": [
            {
                "role": "user",
                "parts": [{"text": _build_prompt(mood_text, emotion, tracks)}],
            }
        ],
        "generationConfig": {
            "temperature": 0.7,
            "maxOutputTokens": 220,
        },
    }

    response = httpx.post(
        url,
        headers={
            "Content-Type": "application/json",
            "x-goog-api-key": settings.gemini_api_key,
        },
        json=payload,
        timeout=30.0,
    )
    response.raise_for_status()

    feedback = _extract_generated_text(response.json()).strip()
    if not feedback:
        raise httpx.HTTPError("Gemini returned empty feedback.")
    return feedback


def fallback_feedback(
    mood_text: str,
    emotion: str,
    tracks: list[dict[str, Any]],
) -> str:
    if mood_text.strip():
        return (
            f"Thank you for sharing how you feel. Your mood looks {emotion}, "
            "so I prepared a playlist to match your pace today. "
            "Take it one step at a time and use these songs as a small reset."
        )

    return (
        "I prepared a playlist based on your current mood. "
        "Play a few tracks and check if your energy feels a little better."
    )


def parse_gemini_http_error(error: Exception) -> str:
    if isinstance(error, httpx.HTTPStatusError):
        status_code = error.response.status_code
        try:
            payload = error.response.json()
            if isinstance(payload, dict):
                details = payload.get("error")
                if isinstance(details, dict):
                    message = details.get("message")
                    if isinstance(message, str) and message.strip():
                        return message.strip()
        except Exception:
            pass
        return f"gemini_http_{status_code}"

    if isinstance(error, httpx.RequestError):
        return "gemini_network_error"

    return "gemini_request_failed"
