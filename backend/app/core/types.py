"""Custom SQLAlchemy column types."""
from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy import DateTime
from sqlalchemy.types import TypeDecorator


class UTCDateTime(TypeDecorator):
    """A timezone-aware DateTime that always reads back as aware UTC.

    SQLite drops tzinfo on storage, so plain ``DateTime(timezone=True)`` columns
    come back *naive* — and Pydantic then serializes them without an offset,
    which makes Flutter's ``.toLocal()`` a no-op (call/punch times shown 5h
    early on a UTC+5 host). This decorator normalizes on the way in (an aware
    value is converted to UTC; a naive value is assumed UTC) and re-attaches UTC
    on the way out, so every API datetime carries an offset on all backends.

    Schema-identical to ``DateTime(timezone=True)`` — applying it to existing
    columns needs no migration.
    """

    impl = DateTime(timezone=True)
    cache_ok = True

    def process_bind_param(self, value: datetime | None, dialect) -> datetime | None:
        if isinstance(value, datetime) and value.tzinfo is not None:
            return value.astimezone(timezone.utc)
        return value

    def process_result_value(self, value: datetime | None, dialect) -> datetime | None:
        if isinstance(value, datetime) and value.tzinfo is None:
            return value.replace(tzinfo=timezone.utc)
        return value
