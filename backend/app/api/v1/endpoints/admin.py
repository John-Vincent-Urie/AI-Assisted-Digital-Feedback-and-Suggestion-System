from fastapi import APIRouter

from app.services.data_store import store

router = APIRouter()


@router.get("/dashboard")
def dashboard_summary() -> dict[str, object]:
    return store.dashboard_summary()
