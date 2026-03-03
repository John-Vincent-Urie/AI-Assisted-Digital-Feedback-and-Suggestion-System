from urllib.parse import urlencode

import httpx
from fastapi import APIRouter, Header, HTTPException, Query, status
from fastapi.responses import RedirectResponse
from pydantic import BaseModel, EmailStr

from app.core.config import settings
from app.services.data_store import store
from app.services.spotify_service import (
    build_authorize_url,
    consume_oauth_state,
    create_oauth_state,
    exchange_code_for_tokens,
    fetch_spotify_profile,
)

router = APIRouter()


class RegisterRequest(BaseModel):
    email: EmailStr
    password: str
    display_name: str | None = None


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


@router.post("/register")
def register(payload: RegisterRequest) -> dict[str, str]:
    try:
        user = store.register_user(
            email=payload.email,
            password=payload.password,
            display_name=payload.display_name,
        )
    except ValueError as exc:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="Email already exists.",
        ) from exc

    return {
        "message": "Registration successful.",
        "email": user["email"],
        "display_name": user["display_name"],
    }


@router.post("/login")
def login(payload: LoginRequest) -> dict[str, str]:
    user = store.authenticate_user(payload.email, payload.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password.",
        )
    return {
        "message": "Login successful.",
        "email": user["email"],
        "display_name": user["display_name"],
    }


def _spotify_configured() -> bool:
    return bool(settings.spotify_client_id and settings.spotify_client_secret)


def _frontend_callback_url(params: dict[str, str]) -> str:
    query = urlencode(params)
    # Flutter web default route strategy uses hash route.
    return f"{settings.frontend_base_url}/#/spotify-callback?{query}"


@router.get("/spotify/login")
def spotify_login() -> RedirectResponse:
    if not _spotify_configured():
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Spotify credentials are not configured on the backend.",
        )
    state = create_oauth_state()
    authorize_url = build_authorize_url(state)
    return RedirectResponse(
        url=authorize_url,
        status_code=status.HTTP_307_TEMPORARY_REDIRECT,
    )


@router.get("/spotify/callback")
def spotify_callback(
    code: str | None = Query(default=None),
    state: str | None = Query(default=None),
    error: str | None = Query(default=None),
) -> RedirectResponse:
    if error:
        return RedirectResponse(
            url=_frontend_callback_url({"error": error}),
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
        )

    if not code or not state:
        return RedirectResponse(
            url=_frontend_callback_url({"error": "missing_code_or_state"}),
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
        )

    if not consume_oauth_state(state):
        return RedirectResponse(
            url=_frontend_callback_url({"error": "invalid_state"}),
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
        )

    try:
        tokens = exchange_code_for_tokens(code)
        access_token = tokens.get("access_token")
        refresh_token = tokens.get("refresh_token", "")
        expires_in = str(tokens.get("expires_in", ""))

        if not access_token:
            return RedirectResponse(
                url=_frontend_callback_url({"error": "missing_access_token"}),
                status_code=status.HTTP_307_TEMPORARY_REDIRECT,
            )

        profile = fetch_spotify_profile(access_token)
    except httpx.HTTPError:
        return RedirectResponse(
            url=_frontend_callback_url({"error": "spotify_exchange_failed"}),
            status_code=status.HTTP_307_TEMPORARY_REDIRECT,
        )

    params = {
        "access_token": access_token,
        "refresh_token": refresh_token,
        "expires_in": expires_in,
        "spotify_id": str(profile.get("id", "")),
        "display_name": str(profile.get("display_name", "")),
        "email": str(profile.get("email", "")),
    }
    return RedirectResponse(
        url=_frontend_callback_url(params),
        status_code=status.HTTP_307_TEMPORARY_REDIRECT,
    )


@router.get("/spotify/me")
def spotify_me(authorization: str | None = Header(default=None)) -> dict:
    if not authorization or not authorization.lower().startswith("bearer "):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token.",
        )

    token = authorization.split(" ", 1)[1].strip()
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Missing bearer token.",
        )

    try:
        return fetch_spotify_profile(token)
    except httpx.HTTPError as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"Spotify profile fetch failed: {exc}",
        ) from exc
