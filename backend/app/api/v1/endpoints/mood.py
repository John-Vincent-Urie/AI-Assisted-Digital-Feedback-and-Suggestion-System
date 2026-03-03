from fastapi import APIRouter

from app.schemas.mood import MoodAnalyzeRequest, MoodAnalyzeResponse
from app.services.data_store import store
from app.services.sentiment_service import classify_text

router = APIRouter()


@router.post("/analyze", response_model=MoodAnalyzeResponse)
def analyze_mood(payload: MoodAnalyzeRequest) -> MoodAnalyzeResponse:
    result = classify_text(payload.text)
    store.add_mood_entry(
        user_email=payload.user_email,
        text=payload.text,
        emotion=result.emotion,
        confidence=result.confidence,
    )
    return result
