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

STATE_TTL_SECONDS = 600
_state_store: dict[str, float] = {}


def _cleanup_state_store() -> None:
    now = time.time()
    expired = [state for state, expiry in _state_store.items() if expiry < now]
    for state in expired:
        _state_store.pop(state, None)


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
    params = {
        "client_id": settings.spotify_client_id,
        "response_type": "code",
        "redirect_uri": settings.spotify_redirect_uri,
        "scope": settings.spotify_scope,
        "state": state,
        "show_dialog": "true",
    }
    return f"{SPOTIFY_AUTHORIZE_URL}?{urlencode(params)}"


def exchange_code_for_tokens(code: str) -> dict[str, Any]:
    credentials = f"{settings.spotify_client_id}:{settings.spotify_client_secret}"
    encoded_credentials = base64.b64encode(credentials.encode("utf-8")).decode("utf-8")
    headers = {
        "Authorization": f"Basic {encoded_credentials}",
        "Content-Type": "application/x-www-form-urlencoded",
    }
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


def fetch_spotify_profile(access_token: str) -> dict[str, Any]:
    headers = {"Authorization": f"Bearer {access_token}"}
    response = httpx.get(SPOTIFY_PROFILE_URL, headers=headers, timeout=20.0)
    response.raise_for_status()
    return response.json()


def mock_recommendations(emotion: str) -> list[dict[str, Any]]:
    # Placeholder until Spotify Web API integration is implemented.
    return [
        {
            "spotify_track_id": f"{emotion}-track-001",
            "track_name": f"{emotion.title()} Track 1",
            "artist_name": "EmoTune Demo Artist",
        },
        {
            "spotify_track_id": f"{emotion}-track-002",
            "track_name": f"{emotion.title()} Track 2",
            "artist_name": "EmoTune Demo Artist",
        },
    ]
