from fastapi import APIRouter

from app.services.data_store import store

router = APIRouter()


@router.get("/mood-distribution")
def mood_distribution() -> dict[str, list[dict[str, object]]]:
    return {"distribution": store.mood_distribution()}
