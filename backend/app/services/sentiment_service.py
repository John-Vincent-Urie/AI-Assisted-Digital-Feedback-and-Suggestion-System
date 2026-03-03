from app.schemas.mood import MoodAnalyzeResponse

KEYWORD_TO_EMOTION = {
    "happy": "happy",
    "joy": "happy",
    "sad": "sad",
    "down": "sad",
    "angry": "angry",
    "mad": "angry",
    "stress": "stressed",
    "stressed": "stressed",
    "calm": "calm",
    "lonely": "lonely",
    "romantic": "romantic",
    "nostalgic": "nostalgic",
    "motivation": "motivational",
    "fear": "fearful",
    "depress": "depressing",
}


def classify_text(text: str) -> MoodAnalyzeResponse:
    normalized = text.lower().strip()
    emotion = "mixed"
    confidence = 0.55

    for keyword, detected_emotion in KEYWORD_TO_EMOTION.items():
        if keyword in normalized:
            emotion = detected_emotion
            confidence = 0.82
            break

    return MoodAnalyzeResponse(emotion=emotion, confidence=confidence)
