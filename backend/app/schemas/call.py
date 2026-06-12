"""Call-log DTOs (IP telephony, TZ Modul 9)."""
from __future__ import annotations

from datetime import datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class CallIngest(BaseModel):
    """Webhook body the PBX (Asterisk dialplan / AMI bridge) POSTs per call."""

    direction: Literal["in", "out"] = "in"
    phone: str = Field(min_length=1, max_length=32)
    started_at: datetime
    duration_seconds: int = Field(0, ge=0)
    recording_url: str | None = Field(None, max_length=512)
    note: str | None = Field(None, max_length=512)


class CallPatientBrief(BaseModel):
    """Just enough to render 'who called' in the journal row."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    last_name: str
    first_name: str


class CallOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    direction: str
    phone: str
    started_at: datetime
    duration_seconds: int
    recording_url: str | None
    note: str | None
    patient: CallPatientBrief | None
