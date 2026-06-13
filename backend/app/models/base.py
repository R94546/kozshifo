"""Shared ORM mixins: UUID primary keys and created/updated timestamps."""
from __future__ import annotations

import uuid
from datetime import datetime

from sqlalchemy import Uuid, func
from sqlalchemy.orm import Mapped, mapped_column

from app.core.types import UTCDateTime


class UUIDPKMixin:
    id: Mapped[uuid.UUID] = mapped_column(Uuid, primary_key=True, default=uuid.uuid4)


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(
        UTCDateTime, server_default=func.now(), nullable=False
    )
    updated_at: Mapped[datetime] = mapped_column(
        UTCDateTime, server_default=func.now(), onupdate=func.now(), nullable=False
    )
