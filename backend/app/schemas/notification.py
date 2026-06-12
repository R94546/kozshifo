"""Notification DTOs."""
from __future__ import annotations

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict


class NotificationOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    event: str
    channel: str
    title: str
    body: str | None
    status: str
    error: str | None
    ref_type: str | None
    ref_id: UUID | None
    branch_id: UUID | None
    created_at: datetime
