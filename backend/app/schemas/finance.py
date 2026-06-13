"""Finance DTOs (TZ Modul 8): expenses, percent-based payroll, cash reports."""
from __future__ import annotations

from datetime import date, datetime
from decimal import Decimal
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

# Calendar month on the wire: "YYYY-MM" (payroll period / monthly report key).
MONTH_PATTERN = r"^\d{4}-(0[1-9]|1[0-2])$"


class ExpenseCreate(BaseModel):
    category: str = Field(max_length=64)
    amount: Decimal = Field(gt=0)
    expense_date: date
    note: str | None = Field(default=None, max_length=512)
    # Defaults to the current user's branch (400 if neither is set).
    branch_id: UUID | None = None

    @field_validator("category")
    @classmethod
    def _category_not_blank(cls, value: str) -> str:
        value = value.strip()
        if not value:
            raise ValueError("category must not be blank")
        return value


class ExpenseOut(BaseModel):
    id: UUID
    branch_id: UUID
    category: str
    amount: Decimal
    expense_date: date
    note: str | None
    kind: str  # regular | payroll
    payroll_user_id: UUID | None
    payroll_month: str | None
    created_by_name: str | None
    created_at: datetime


class PayrollRow(BaseModel):
    """One eligible employee's percent-payroll line for a month."""

    user_id: UUID
    full_name: str
    salary_percent: Decimal
    revenue: Decimal  # completed payments of the month on visits where they are the doctor
    salary: Decimal  # revenue * salary_percent / 100, 0.01-quantized (live, recomputed)
    paid: bool  # a payout Expense(kind="payroll") exists for this month
    paid_at: datetime | None
    paid_amount: Decimal | None  # amount actually booked at payout (frozen); None if unpaid


class PayrollPayoutIn(BaseModel):
    user_id: UUID
    month: str = Field(pattern=MONTH_PATTERN)


class CashReport(BaseModel):
    """Cash-flow aggregate over one day or one month.

    `income_by_method` always carries the four canonical buckets
    (cash / card / qr / transfer), zero-filled.
    net = income_total - refund_total - expense_total.
    """

    income_by_method: dict[str, Decimal]
    income_total: Decimal
    refund_total: Decimal
    expense_total: Decimal
    net: Decimal


class DailyReport(CashReport):
    date: date


class MonthlyReport(CashReport):
    month: str
    # Isolated payroll spend (subset of expense_total). NULL for callers without
    # payroll.read — the cash report itself only needs expenses.read, but the
    # salary figure stays behind the payroll wall.
    payroll_total: Decimal | None
