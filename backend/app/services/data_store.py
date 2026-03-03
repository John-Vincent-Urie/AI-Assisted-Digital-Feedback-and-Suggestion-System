from collections import Counter
from datetime import UTC, datetime, timedelta
from typing import Any


class InMemoryStore:
    def __init__(self) -> None:
        self._user_id = 1
        self._mood_id = 1
        self._session_id = 1

        self.users: list[dict[str, Any]] = []
        self.mood_entries: list[dict[str, Any]] = []
        self.recommendation_sessions: list[dict[str, Any]] = []

    def register_user(
        self,
        email: str,
        password: str,
        display_name: str | None = None,
        role: str = "user",
    ) -> dict[str, Any]:
        email_key = email.lower().strip()
        if any(user["email"] == email_key for user in self.users):
            raise ValueError("email_exists")

        user = {
            "id": self._user_id,
            "email": email_key,
            "password": password,
            "display_name": display_name or email_key.split("@")[0],
            "role": role,
            "created_at": datetime.now(UTC).isoformat(),
        }
        self.users.append(user)
        self._user_id += 1
        return user

    def authenticate_user(self, email: str, password: str) -> dict[str, Any] | None:
        email_key = email.lower().strip()
        for user in self.users:
            if user["email"] == email_key and user["password"] == password:
                return user
        return None

    def add_mood_entry(
        self,
        user_email: str | None,
        text: str,
        emotion: str,
        confidence: float,
    ) -> dict[str, Any]:
        entry = {
            "id": self._mood_id,
            "user_email": (user_email or "anonymous").lower().strip(),
            "text": text,
            "emotion": emotion,
            "confidence": confidence,
            "created_at": datetime.now(UTC).isoformat(),
        }
        self.mood_entries.append(entry)
        self._mood_id += 1
        return entry

    def add_recommendation_session(
        self,
        user_email: str | None,
        emotion: str,
        tracks: list[dict[str, Any]],
        mood_text: str | None = None,
        ai_feedback: str | None = None,
    ) -> dict[str, Any]:
        session = {
            "id": self._session_id,
            "user_email": (user_email or "anonymous").lower().strip(),
            "emotion": emotion,
            "mood_text": mood_text or "",
            "ai_feedback": ai_feedback or "",
            "tracks": tracks,
            "created_at": datetime.now(UTC).isoformat(),
        }
        self.recommendation_sessions.append(session)
        self._session_id += 1
        return session

    def recommendation_history(self, user_email: str | None = None) -> list[dict[str, Any]]:
        if not user_email:
            return list(reversed(self.recommendation_sessions))
        email_key = user_email.lower().strip()
        return list(
            reversed(
                [
                    session
                    for session in self.recommendation_sessions
                    if session["user_email"] == email_key
                ]
            )
        )

    def mood_distribution(self) -> list[dict[str, Any]]:
        counter = Counter(entry["emotion"] for entry in self.mood_entries)
        total = sum(counter.values())
        if total == 0:
            return []
        return [
            {
                "emotion": emotion,
                "count": count,
                "percentage": round((count / total) * 100, 2),
            }
            for emotion, count in counter.most_common()
        ]

    def dashboard_summary(self) -> dict[str, Any]:
        now = datetime.now(UTC)
        active_since = now - timedelta(hours=24)
        month_start = datetime(now.year, now.month, 1, tzinfo=UTC)

        active_users = {
            session["user_email"]
            for session in self.recommendation_sessions
            if datetime.fromisoformat(session["created_at"]) >= active_since
        }

        playlists_generated_this_month = sum(
            1
            for session in self.recommendation_sessions
            if datetime.fromisoformat(session["created_at"]) >= month_start
        )

        top_moods_counter = Counter(entry["emotion"] for entry in self.mood_entries)
        top_moods = [
            {"emotion": emotion, "count": count}
            for emotion, count in top_moods_counter.most_common(5)
        ]

        return {
            "active_users": len(active_users),
            "total_users": len(self.users),
            "playlists_generated_this_month": playlists_generated_this_month,
            "top_moods": top_moods,
        }


store = InMemoryStore()
