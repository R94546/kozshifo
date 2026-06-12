"""Clinic expenses — rashodlar (TZ Modul 8).

Every outflow is one Expense row; payroll payouts are expenses too
(kind="payroll") so the cash balance maths stays one query. A payroll payout
is idempotent per (employee, month) via the unique constraint.
"""
from __future__ import annotations

import uuid
from datetime import date
from decimal import Decimal

from sqlalchemy import Date, ForeignKey, Numeric, String, UniqueConstraint, Uuid
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.core.database import Base
from app.models.base import TimestampMixin, UUIDPKMixin


class Expense(UUIDPKMixin, TimestampMixin, Base):
    __tablename__ = "expenses"
    __table_args__ = (
        UniqueConstraint("payroll_user_id", "payroll_month", name="uq_expense_payroll_user_month"),
    )

    branch_id: Mapped[uuid.UUID] = mapped_column(
        Uuid, ForeignKey("branches.id", ondelete="RESTRICT"), index=True, nullable=False
    )
    category: Mapped[str] = mapped_column(String(64), index=True, nullable=False)
    amount: Mapped[Decimal] = mapped_column(Numeric(12, 2), nullable=False)
    expense_date: Mapped[date] = mapped_column(Date, index=True, nullable=False)
    note: Mapped[str | None] = mapped_column(String(512), nullable=True)
    created_by_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )

    kind: Mapped[str] = mapped_column(String(16), default="regular", nullable=False)  # regular|payroll
    payroll_user_id: Mapped[uuid.UUID | None] = mapped_column(
        Uuid, ForeignKey("users.id", ondelete="SET NULL"), nullable=True
    )
    payroll_month: Mapped[str | None] = mapped_column(String(7), nullable=True)  # YYYY-MM

    payroll_user: Mapped["User | None"] = relationship(  # noqa: F821
        foreign_keys=[payroll_user_id], lazy="joined"
    )
