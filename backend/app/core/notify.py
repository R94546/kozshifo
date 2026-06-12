"""Notification seam: fire-and-forget event delivery.

Contract:
- Called AFTER the caller's business commit — never inside it. notify() owns
  its own (tiny) transaction for the notification rows.
- Notifications must NEVER break a business request: every code path here is
  wrapped so a Telegram outage, a DB hiccup or a programming error degrades to
  "no notification", not to a 500 on the write-off/operation that fired it.
- Always writes a channel="log" row (the in-system journal). If a Telegram bot
  token + chat id are configured, additionally pushes the message and records a
  channel="telegram" row with sent/failed status.
"""
from __future__ import annotations

import logging
import uuid
from datetime import datetime, timedelta, timezone
from decimal import Decimal
from typing import Iterable

import httpx
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.stock import on_hand
from app.models.inventory import Product
from app.models.notification import Notification

logger = logging.getLogger(__name__)

_TELEGRAM_TIMEOUT_S = 5.0
_LOW_STOCK_DEBOUNCE = timedelta(hours=24)


def _send_telegram(title: str, body: str | None) -> None:
    """Push one message to the configured chat. Raises on any failure."""
    url = f"https://api.telegram.org/bot{settings.telegram_bot_token}/sendMessage"
    response = httpx.post(
        url,
        json={"chat_id": settings.telegram_chat_id, "text": f"{title}\n{body or ''}"},
        timeout=_TELEGRAM_TIMEOUT_S,
    )
    response.raise_for_status()


def notify(
    db: Session,
    *,
    event: str,
    title: str,
    body: str | None = None,
    ref_type: str | None = None,
    ref_id: uuid.UUID | None = None,
    branch_id: uuid.UUID | None = None,
) -> list[Notification]:
    """Record an event (and push it to Telegram when configured). COMMITS itself.

    Returns the created Notification rows; returns [] and swallows the error if
    anything at all goes wrong — a notification failure must never surface as a
    failure of the business request that triggered it.
    """
    try:
        rows: list[Notification] = [
            Notification(
                event=event, channel="log", title=title, body=body,
                status="sent", ref_type=ref_type, ref_id=ref_id, branch_id=branch_id,
            )
        ]

        if settings.telegram_bot_token and settings.telegram_chat_id:
            tg_status, tg_error = "sent", None
            try:
                _send_telegram(title, body)
            except Exception as exc:  # network/HTTP/anything — record, don't raise
                tg_status, tg_error = "failed", str(exc)[:512]
                logger.warning("Telegram notification failed: %s", exc)
            rows.append(
                Notification(
                    event=event, channel="telegram", title=title, body=body,
                    status=tg_status, error=tg_error,
                    ref_type=ref_type, ref_id=ref_id, branch_id=branch_id,
                )
            )

        db.add_all(rows)
        db.commit()
        return rows
    except Exception:  # last resort: notifications never break the request
        logger.exception("notify() failed for event %s", event)
        try:
            db.rollback()
        except Exception:
            pass
        return []


def check_low_stock(
    db: Session,
    product_ids: Iterable[uuid.UUID],
    branch_id: uuid.UUID,
) -> None:
    """Fire a low_stock notification for each active product at/below min_stock.

    Anti-spam: at most one low_stock notification per (product, branch) per
    24 hours. Called after the business commit; swallows every error.
    """
    try:
        since = datetime.now(timezone.utc) - _LOW_STOCK_DEBOUNCE
        for product_id in dict.fromkeys(product_ids):  # de-dup, keep order
            product = db.get(Product, product_id)
            if product is None or not product.is_active:
                continue
            remaining = on_hand(db, product_id, branch_id)
            if remaining > Decimal(product.min_stock):
                continue
            already = db.execute(
                select(Notification.id)
                .where(
                    Notification.event == "low_stock",
                    Notification.ref_id == product_id,
                    Notification.branch_id == branch_id,
                    Notification.created_at >= since,
                )
                .limit(1)
            ).scalar_one_or_none()
            if already is not None:
                continue
            notify(
                db,
                event="low_stock",
                title=f"Дефицит: {product.name}",
                body=f"Остаток {remaining} {product.unit} (минимум {product.min_stock})",
                ref_type="product",
                ref_id=product_id,
                branch_id=branch_id,
            )
    except Exception:  # never break the business request
        logger.exception("check_low_stock() failed")
        try:
            db.rollback()
        except Exception:
            pass
