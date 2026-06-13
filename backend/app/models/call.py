"""IP-telephony call log (TZ Modul 9).

Rows arrive from the PBX via the ingest webhook (features/calls.py); the
recording itself stays on the PBX/disk — we keep a URL. Patients are
auto-matched by normalized phone digits at ingest time.
"""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import ForeignKey, Integer, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.core.types import UTCDateTime
from app.models.base import TimestampMixin, UUIDPKMixin


class CallRecord(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "call_records"

    direction: Mapped[str] = mapped_column(String(8), default="in", nullable=False)  # in | out
    phone: Mapped[str] = mapped_column(String(32), nullable=False)
    phone_normalized: Mapped[str] = mapped_column(String(32), index=True, nullable=False)
    started_at: Mapped[datetime] = mapped_column(
        UTCDateTime, index=True, nullable=False
    )
    duration_seconds: Mapped[int] = mapped_column(Integer, default=0, nullable=False)
    recording_url: Mapped[str | None] = mapped_column(String(512), nullable=True)
    handled_by_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    patient_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("patients.id", ondelete="SET NULL"), index=True, nullable=True
    )
    note: Mapped[str | None] = mapped_column(String(512), nullable=True)

    patient: Mapped["Patient | None"] = relationship(lazy="joined")  # noqa: F821
    handled_by: Mapped["User | None"] = relationship(lazy="joined")  # noqa: F821
