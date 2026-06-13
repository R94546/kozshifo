"""Single source of the business calendar date and local↔UTC day windows.

Stock-expiry decisions (FEFO usability, dashboard deficit/expiring KPIs,
StockBatch.expired) must all agree on what "today" is — mixing UTC and
server-local dates made the dashboard disagree with the engine for ~5 hours
around midnight on UTC+5 hosts. Server-local date is the business convention.

Cash reports face the mirror problem: payment timestamps are stored UTC, but a
clinic's "day" / "month" is local. The ``*_bounds_utc`` helpers convert a local
calendar day/month into the UTC instant window to filter those timestamps, so a
day's takings and that day's expenses (filtered on a local DATE) reconcile.
"""
from __future__ import annotations

from datetime import date, datetime, time, timedelta, timezone


def business_today() -> date:
    return date.today()


def current_business_month() -> str:
    """The current local month as ``YYYY-MM`` (payroll close boundary)."""
    today = business_today()
    return f"{today.year:04d}-{today.month:02d}"


def local_day_bounds_utc(d: date) -> tuple[datetime, datetime]:
    """[start, end) UTC instants covering the local calendar day ``d``."""
    start = datetime.combine(d, time.min).astimezone(timezone.utc)
    end = datetime.combine(d + timedelta(days=1), time.min).astimezone(timezone.utc)
    return start, end


def local_month_bounds_utc(month: str) -> tuple[datetime, datetime]:
    """[start, end) UTC instants covering the local calendar month ``YYYY-MM``."""
    year, mon = int(month[:4]), int(month[5:7])
    start = datetime.combine(date(year, mon, 1), time.min).astimezone(timezone.utc)
    nxt = date(year + 1, 1, 1) if mon == 12 else date(year, mon + 1, 1)
    end = datetime.combine(nxt, time.min).astimezone(timezone.utc)
    return start, end
