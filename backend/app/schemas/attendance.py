"""Attendance DTOs (TZ Modul 1 — Face ID kirish-chiqish nazorati)."""
from __future__ import annotations

from datetime import date, datetime
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, model_validator


class PunchIn(BaseModel):
    """Unattended Face ID terminal webhook body.

    The terminal identifies the employee by our user id or by email —
    whichever the integrator mapped faces to. `direction` is normally
    omitted: the server auto-toggles in/out based on the last event today.
    """

    user_id: UUID | None = None
    email: str | None = None
    direction: Literal["in", "out"] | None = None

    @model_validator(mode="after")
    def _require_identity(self) -> "PunchIn":
        if self.user_id is None and not (self.email or "").strip():
            raise ValueError("Either user_id or email is required")
        return self


class AttendanceEventCreate(BaseModel):
    """Manual punch keyed in by an administrator (corrections, forgot-badge)."""

    user_id: UUID
    direction: Literal["in", "out"]
    occurred_at: datetime
    note: str | None = Field(None, max_length=255)


class AttendanceEventOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    user_id: UUID
    user_full_name: str | None = None  # flattened from the ORM relationship
    branch_id: UUID | None
    direction: str
    occurred_at: datetime
    source: str
    note: str | None
    recorded_by_id: UUID | None
    created_at: datetime


class AttendanceDay(BaseModel):
    """One reconstructed working day (multiple in/out pairs are normal — lunch)."""

    day: date
    first_in: datetime | None
    last_out: datetime | None
    worked_minutes: int  # sum of closed in->out pairs; trailing open "in" adds 0
    late: bool  # first_in local time > settings.work_day_start


class AttendanceUserReport(BaseModel):
    user_id: UUID
    full_name: str
    days: list[AttendanceDay]
    days_present: int
    days_absent: int  # non-Sunday days in range (up to today) with zero events
    total_minutes: int
    late_count: int


class AttendanceReport(BaseModel):
    date_from: date
    date_to: date
    work_day_start: str  # "HH:MM" — the lateness threshold used
    users: list[AttendanceUserReport]
