import base64
import secrets
import time
from typing import Any
from urllib.parse import urlencode

import httpx

from app.core.config import settings

SPOTIFY_AUTHORIZE_URL = "https://accounts.spotify.com/authorize"
SPOTIFY_TOKEN_URL = "https://accounts.spotify.com/api/token"
SPOTIFY_PROFILE_URL = "https://api.spotify.com/v1/me"
SPOTIFY_SEARCH_URL = "https://api.spotify.com/v1/search"

STATE_TTL_SECONDS = 600
_APP_TOKEN_SAFETY_WINDOW_SECONDS = 60
_state_store: dict[str, float] = {}
_app_token_cache: dict[str, Any] = {"access_token": None, "expires_at": 0.0}

_PLACEHOLDER_VALUES = {
    "",
    "your_spotify_client_id",
    "your_spotify_client_secret",
    "replace_with_spotify_client_id",
    "replace_with_spotify_client_secret",
    "changeme",
}

_EMOTION_QUERIES: dict[str, list[str]] = {
    "happy": ["happy pop", "feel good hits", "upbeat dance"],
    "sad": ["sad acoustic", "melancholy piano", "heartbreak songs"],
    "angry": ["angry rock", "heavy metal", "intense workout"],
    "stressed": ["lofi chill", "calming instrumental", "ambient focus"],
    "calm": ["calm acoustic", "chill vibes", "peaceful piano"],
    "lonely": ["lonely indie", "night drive", "soft emotional songs"],
    "romantic": ["romantic ballad", "love songs", "r&b slow jam"],
    "nostalgic": ["throwback classics", "2000s hits", "nostalgic playlist"],
    "motivational": ["motivation mix", "power anthems", "gym energy"],
    "fearful": ["soothing meditation", "anxiety relief music", "ambient calm"],
    "depressing": ["healing songs", "comfort music", "hopeful acoustic"],
    "mixed": ["mood mix", "indie mix", "today's top hits"],
}


def _cleanup_state_store() -> None:
    now = time.time()
    expired = [state for state, expiry in _state_store.items() if expiry < now]
    for state in expired:
        _state_store.pop(state, None)


def _normalized(value: str | None) -> str:
    return (value or "").strip()


def _is_placeholder(value: str | None) -> bool:
    normalized = _normalized(value).lower()
    return normalized in _PLACEHOLDER_VALUES or normalized.startswith("your_")


def spotify_client_configured() -> bool:
    client_id = _normalized(settings.spotify_client_id)
    client_secret = _normalized(settings.spotify_client_secret)
    if _is_placeholder(client_id) or _is_placeholder(client_secret):
        return False
    return True


def ensure_spotify_client_configured() -> None:
    if spotify_client_configured():
        return
    raise RuntimeError(
        "Spotify credentials are missing or still set to placeholder values. "
        "Set SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET in backend/.env, then "
        "recreate the api container."
    )


def create_oauth_state() -> str:
    _cleanup_state_store()
    state = secrets.token_urlsafe(24)
    _state_store[state] = time.time() + STATE_TTL_SECONDS
    return state


def consume_oauth_state(state: str) -> bool:
    _cleanup_state_store()
    expiry = _state_store.pop(state, None)
    if expiry is None:
        return False
    return expiry >= time.time()


def build_authorize_url(state: str) -> str:
    ensure_spotify_client_configured()
    params = {
        "client_id": settings.spotify_client_id,
        "response_type": "code",
        "redirect_uri": settings.spotify_redirect_uri,
        "scope": settings.spotify_scope,
        "state": state,
        "show_dialog": "true",
    }
    return f"{SPOTIFY_AUTHORIZE_URL}?{urlencode(params)}"


def _build_basic_auth_header() -> dict[str, str]:
    ensure_spotify_client_configured()
    credentials = f"{settings.spotify_client_id}:{settings.spotify_client_secret}"
    encoded_credentials = base64.b64encode(credentials.encode("utf-8")).decode("utf-8")
    return {
        "Authorization": f"Basic {encoded_credentials}",
        "Content-Type": "application/x-www-form-urlencoded",
    }


def exchange_code_for_tokens(code: str) -> dict[str, Any]:
    headers = _build_basic_auth_header()
    data = {
        "grant_type": "authorization_code",
        "code": code,
        "redirect_uri": settings.spotify_redirect_uri,
    }

    response = httpx.post(
        SPOTIFY_TOKEN_URL,
        headers=headers,
        data=data,
        timeout=20.0,
    )
    response.raise_for_status()
    return response.json()


def refresh_access_token(refresh_token: str) -> dict[str, Any]:
    headers = _build_basic_auth_header()
    data = {
        "grant_type": "refresh_token",
        "refresh_token": refresh_token,
    }

    response = httpx.post(
        SPOTIFY_TOKEN_URL,
        headers=headers,
        data=data,
        timeout=20.0,
    )
    response.raise_for_status()
    return response.json()


def get_app_access_token() -> str:
    ensure_spotify_client_configured()

    now = time.time()
    cached_token = _app_token_cache.get("access_token")
    cached_expiry = float(_app_token_cache.get("expires_at") or 0.0)
    if cached_token and cached_expiry - _APP_TOKEN_SAFETY_WINDOW_SECONDS > now:
        return str(cached_token)

    response = httpx.post(
        SPOTIFY_TOKEN_URL,
        headers=_build_basic_auth_header(),
        data={"grant_type": "client_credentials"},
        timeout=20.0,
    )
    response.raise_for_status()

    payload = response.json()
    access_token = str(payload.get("access_token") or "")
    expires_in = int(payload.get("expires_in") or 3600)
    if not access_token:
        raise httpx.HTTPError("Spotify token response did not include access_token.")

    _app_token_cache["access_token"] = access_token
    _app_token_cache["expires_at"] = time.time() + max(expires_in, 60)
    return access_token


def fetch_spotify_profile(access_token: str) -> dict[str, Any]:
    headers = {"Authorization": f"Bearer {access_token}"}
    response = httpx.get(SPOTIFY_PROFILE_URL, headers=headers, timeout=20.0)
    response.raise_for_status()
    return response.json()


def _track_to_recommendation(track: dict[str, Any]) -> dict[str, Any]:
    artists = track.get("artists") or []
    artist_names = [
        str(artist.get("name"))
        for artist in artists
        if isinstance(artist, dict) and artist.get("name")
    ]

    album = track.get("album") if isinstance(track.get("album"), dict) else {}
    images = album.get("images") if isinstance(album.get("images"), list) else []
    image_url = ""
    if images and isinstance(images[0], dict):
        image_url = str(images[0].get("url") or "")

    external_urls = (
        track.get("external_urls") if isinstance(track.get("external_urls"), dict) else {}
    )

    return {
        "spotify_track_id": str(track.get("id") or ""),
        "track_name": str(track.get("name") or ""),
        "artist_name": ", ".join(artist_names),
        "album_name": str(album.get("name") or ""),
        "album_image_url": image_url,
        "spotify_url": str(external_urls.get("spotify") or ""),
        "preview_url": str(track.get("preview_url") or ""),
    }


def search_tracks(
    access_token: str,
    query: str,
    *,
    limit: int = 10,
    market: str | None = None,
) -> list[dict[str, Any]]:
    params: dict[str, str | int] = {
        "q": query,
        "type": "track",
        "limit": max(1, min(limit, 50)),
    }
    if market:
        params["market"] = market

    response = httpx.get(
        SPOTIFY_SEARCH_URL,
        headers={"Authorization": f"Bearer {access_token}"},
        params=params,
        timeout=20.0,
    )
    response.raise_for_status()

    payload = response.json()
    items = payload.get("tracks", {}).get("items", [])
    if not isinstance(items, list):
        return []

    return [_track_to_recommendation(track) for track in items if isinstance(track, dict)]


def _queries_for_emotion(emotion: str) -> list[str]:
    normalized_emotion = emotion.strip().lower()
    if normalized_emotion in _EMOTION_QUERIES:
        return _EMOTION_QUERIES[normalized_emotion]
    if normalized_emotion:
        return [f"{normalized_emotion} mood", f"{normalized_emotion} songs"]
    return _EMOTION_QUERIES["mixed"]


def build_spotify_recommendations(
    emotion: str,
    *,
    user_access_token: str | None = None,
    limit: int = 10,
) -> list[dict[str, Any]]:
    access_token = _normalized(user_access_token) or get_app_access_token()

    results: list[dict[str, Any]] = []
    seen_track_ids: set[str] = set()

    per_query_limit = max(6, min(limit, 20))
    for query in _queries_for_emotion(emotion):
        tracks = search_tracks(access_token, query, limit=per_query_limit)
        for track in tracks:
            track_id = str(track.get("spotify_track_id") or "")
            if not track_id or track_id in seen_track_ids:
                continue
            seen_track_ids.add(track_id)
            results.append(track)
            if len(results) >= limit:
                return results

    return results


def parse_spotify_http_error(error: Exception) -> str:
    if isinstance(error, httpx.HTTPStatusError):
        response = error.response
        status_code = response.status_code
        message = f"spotify_http_{status_code}"

        try:
            payload = response.json()
        except Exception:
            payload = None

        if isinstance(payload, dict):
            raw_error = payload.get("error")
            if isinstance(raw_error, str):
                description = payload.get("error_description")
                if isinstance(description, str) and description:
                    return f"{raw_error}: {description}"
                return raw_error

            if isinstance(raw_error, dict):
                spotify_message = raw_error.get("message")
                if isinstance(spotify_message, str) and spotify_message:
                    return spotify_message

        return message

    if isinstance(error, httpx.RequestError):
        return "spotify_network_error"

    return "spotify_request_failed"


def mock_recommendations(emotion: str) -> list[dict[str, Any]]:
    return [
        {
            "spotify_track_id": f"{emotion}-track-001",
            "track_name": f"{emotion.title()} Track 1",
            "artist_name": "EmoTune Demo Artist",
            "album_name": "EmoTune Demo Album",
            "album_image_url": "",
            "spotify_url": "",
            "preview_url": "",
        },
        {
            "spotify_track_id": f"{emotion}-track-002",
            "track_name": f"{emotion.title()} Track 2",
            "artist_name": "EmoTune Demo Artist",
            "album_name": "EmoTune Demo Album",
            "album_image_url": "",
            "spotify_url": "",
            "preview_url": "",
        },
    ]
