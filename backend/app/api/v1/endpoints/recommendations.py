from fastapi import APIRouter
from pydantic import BaseModel, Field

from app.services.data_store import store
from app.services.sentiment_service import classify_text
from app.services.spotify_service import mock_recommendations

router = APIRouter()


class RecommendationRequest(BaseModel):
    emotion: str | None = Field(default=None, min_length=2, max_length=30)
    text: str | None = None
    user_email: str | None = None


@router.post("/generate")
def generate_recommendations(payload: RecommendationRequest) -> dict[str, object]:
    emotion = payload.emotion
    if not emotion and payload.text:
        emotion = classify_text(payload.text).emotion
    if not emotion:
        emotion = "mixed"

    tracks = mock_recommendations(emotion)
    session = store.add_recommendation_session(
        user_email=payload.user_email,
        emotion=emotion,
        tracks=tracks,
        mood_text=payload.text,
    )
    return {
        "session_id": session["id"],
        "emotion": emotion,
        "tracks": tracks,
        "created_at": session["created_at"],
    }


@router.get("/history")
def recommendation_history(user_email: str | None = None) -> dict[str, list[object]]:
    return {"sessions": store.recommendation_history(user_email)}
