"""Staff attendance punches (TZ Modul 1 — Face ID kirish-chiqish nazorati).

Raw event log: every recognition (or manual entry) is one row. A "day" is
reconstructed by pairing in/out events chronologically — multiple in/out
pairs per day are expected (lunch breaks). Reports live in features/attendance.
"""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import ForeignKey, String, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.core.types import UTCDateTime
from app.models.base import TimestampMixin, UUIDPKMixin


class AttendanceEvent(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "attendance_events"

    user_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="RESTRICT"), index=True, nullable=False
    )
    branch_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("branches.id", ondelete="SET NULL"), nullable=True
    )
    direction: Mapped[str] = mapped_column(String(8), nullable=False)  # in | out
    occurred_at: Mapped[datetime] = mapped_column(
        UTCDateTime, index=True, nullable=False
    )
    source: Mapped[str] = mapped_column(String(16), default="manual", nullable=False)  # faceid|manual
    note: Mapped[str | None] = mapped_column(String(255), nullable=True)
    # Who keyed in a manual punch (NULL for device-originated events).
    recorded_by_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )

    user: Mapped["User"] = relationship(foreign_keys=[user_id], lazy="joined")  # noqa: F821
