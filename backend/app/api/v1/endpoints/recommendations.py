import httpx
from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from app.services.data_store import store
from app.services.gemini_service import (
    fallback_feedback,
    gemini_configured,
    generate_feedback,
    parse_gemini_http_error,
)
from app.services.sentiment_service import classify_text
from app.services.spotify_service import (
    build_spotify_recommendations,
    mock_recommendations,
    parse_spotify_http_error,
    spotify_client_configured,
)

router = APIRouter()


class RecommendationRequest(BaseModel):
    emotion: str | None = Field(default=None, min_length=2, max_length=30)
    text: str | None = None
    user_email: str | None = None
    spotify_access_token: str | None = None


def _has_token(token: str | None) -> bool:
    return bool((token or "").strip())


def _append_warning(current: str, extra: str) -> str:
    extra_message = extra.strip()
    if not extra_message:
        return current
    if not current:
        return extra_message
    return f"{current} {extra_message}"


@router.post("/generate")
def generate_recommendations(payload: RecommendationRequest) -> dict[str, object]:
    emotion = payload.emotion
    if not emotion and payload.text:
        emotion = classify_text(payload.text).emotion
    if not emotion:
        emotion = "mixed"

    source = "mock"
    warning = ""

    should_attempt_spotify = _has_token(payload.spotify_access_token) or spotify_client_configured()

    tracks: list[dict[str, object]] = []
    if should_attempt_spotify:
        try:
            tracks = build_spotify_recommendations(
                emotion,
                user_access_token=payload.spotify_access_token,
                limit=12,
            )
            source = "spotify"
        except RuntimeError as exc:
            warning = _append_warning(warning, str(exc))
        except httpx.HTTPError as exc:
            detail = parse_spotify_http_error(exc)
            if _has_token(payload.spotify_access_token):
                raise HTTPException(
                    status_code=status.HTTP_502_BAD_GATEWAY,
                    detail=f"Spotify request failed: {detail}",
                ) from exc
            warning = _append_warning(warning, f"Spotify request failed ({detail}).")

    if not tracks:
        tracks = mock_recommendations(emotion)

    ai_feedback = fallback_feedback(payload.text or "", emotion, tracks)
    ai_source = "fallback"

    if (payload.text or "").strip():
        if gemini_configured():
            try:
                ai_feedback = generate_feedback(payload.text or "", emotion, tracks)
                ai_source = "gemini"
            except (httpx.HTTPError, RuntimeError) as exc:
                warning = _append_warning(
                    warning,
                    f"Gemini feedback unavailable ({parse_gemini_http_error(exc)}).",
                )
        else:
            warning = _append_warning(
                warning,
                "Gemini API key is not configured, using fallback feedback.",
            )

    session = store.add_recommendation_session(
        user_email=payload.user_email,
        emotion=emotion,
        tracks=tracks,
        mood_text=payload.text,
        ai_feedback=ai_feedback,
    )
    response: dict[str, object] = {
        "session_id": session["id"],
        "emotion": emotion,
        "tracks": tracks,
        "source": source,
        "ai_feedback": ai_feedback,
        "ai_source": ai_source,
        "created_at": session["created_at"],
    }
    if warning:
        response["warning"] = warning
    return response


@router.get("/history")
def recommendation_history(user_email: str | None = None) -> dict[str, list[object]]:
    return {"sessions": store.recommendation_history(user_email)}
