from pydantic import BaseModel, Field


class MoodAnalyzeRequest(BaseModel):
    text: str = Field(min_length=1, max_length=1000)
    user_email: str | None = None


class MoodAnalyzeResponse(BaseModel):
    emotion: str
    confidence: float
