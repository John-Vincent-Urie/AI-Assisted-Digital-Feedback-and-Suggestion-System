from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    app_env: str = "development"
    api_port: int = 8000

    db_host: str = "db"
    db_port: int = 3306
    db_name: str = "emotune"
    db_user: str = "emotune"
    db_password: str = "emotune123"

    spotify_client_id: str = ""
    spotify_client_secret: str = ""
    spotify_redirect_uri: str = "http://127.0.0.1:8000/api/v1/auth/spotify/callback"
    spotify_scope: str = (
        "user-read-email user-read-private user-top-read "
        "user-read-playback-state user-modify-playback-state"
    )
    frontend_base_url: str = "http://127.0.0.1:8080"

    gemini_api_key: str = ""
    gemini_model: str = "gemini-2.5-flash"

    jwt_secret: str = "replace_with_secure_value"

    model_config = SettingsConfigDict(env_file=".env", extra="ignore")


settings = Settings()
