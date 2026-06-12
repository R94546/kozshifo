"""Notification log: read-only journal of fired events (low stock etc.).

Rows are created by app.core.notify (fire-and-forget, post-commit) — this
router only exposes them, newest first.
"""
from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.database import get_db
from app.core.deps import require_permission
from app.models.notification import Notification
from app.schemas.notification import NotificationOut

router = APIRouter(prefix="/notifications", tags=["Notifications"])


@router.get("", response_model=list[NotificationOut],
            dependencies=[Depends(require_permission("notifications.read"))])
def list_notifications(
    db: Annotated[Session, Depends(get_db)],
    event: str | None = Query(None, description="Filter by event code, e.g. low_stock"),
    limit: int = Query(50, ge=1, le=200),
) -> list[Notification]:
    stmt = select(Notification)
    if event:
        stmt = stmt.where(Notification.event == event)
    stmt = stmt.order_by(Notification.created_at.desc()).limit(limit)
    return list(db.execute(stmt).scalars().all())
