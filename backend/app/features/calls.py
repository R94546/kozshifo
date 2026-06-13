"""IP-telephony call log API (TZ Modul 9).

POST /calls/ingest is the PBX webhook seam (Asterisk dialplan curl / AMI
bridge): no user auth — the PBX proves itself with the X-PBX-Key shared
secret (503 while ``settings.pbx_api_key`` is unset, 401 on mismatch).
Each call is auto-linked to a patient by normalized phone digits at ingest
time; GET /calls is the staff-facing journal behind the dynamic
``calls.read`` permission.
"""
from __future__ import annotations

import re
import secrets
from datetime import datetime, timezone
from typing import Annotated

from fastapi import APIRouter, Depends, Header, HTTPException, Query, status
from sqlalchemy import func, or_, select
from sqlalchemy.orm import Session

from app.core.audit import record_audit
from app.core.config import settings
from app.core.database import get_db
from app.core.deps import require_permission
from app.models.call import CallRecord
from app.models.patient import Patient
from app.schemas.call import CallIngest, CallOut
from app.schemas.common import Page

router = APIRouter(prefix="/calls", tags=["calls"])

# Below this many digits the number is too ambiguous to auto-link (extensions,
# short codes); above it we compare by the Uzbek subscriber part (last 9):
# +998 90 111-22-33 and 901112233 are the same line.
_MIN_MATCH_DIGITS = 7
_SUFFIX_DIGITS = 9


def _digits(value: str) -> str:
    """Normalize a phone to digits only (strip +, spaces, dashes, parens…)."""
    return re.sub(r"\D", "", value)


def _require_pbx_key(
    x_pbx_key: Annotated[str | None, Header(alias="X-PBX-Key")] = None,
) -> None:
    if not settings.pbx_api_key:
        raise HTTPException(
            status.HTTP_503_SERVICE_UNAVAILABLE,
            "PBX integration is disabled (pbx_api_key is not configured)",
        )
    # compare_digest raises TypeError on non-ASCII str (FastAPI latin-1-decodes
    # headers) → encode both sides so a junk key returns 401, not a 500.
    if x_pbx_key is None or not secrets.compare_digest(
        x_pbx_key.encode(), settings.pbx_api_key.encode()
    ):
        raise HTTPException(status.HTTP_401_UNAUTHORIZED, "Invalid PBX key")


def _match_patient(db: Session, digits: str) -> Patient | None:
    """Auto-link: first patient whose phone digits end with the call's last 9.

    Pragmatic v1 choice: Patient.phone stores free-form input, so we normalize
    it *in the query* with nested replace() over the usual separators and
    suffix-match with LIKE — a scan, not an index hit. CallRecord.phone_normalized
    is indexed for the journal search; if this matcher ever shows in profiles,
    the v2 upgrade is a persisted, indexed ``phone_normalized`` on Patient.
    Oldest matching patient wins (deterministic "first match").
    """
    if len(digits) < _MIN_MATCH_DIGITS:
        return None
    suffix = digits[-_SUFFIX_DIGITS:]
    normalized = Patient.phone
    for junk in ("+", " ", "-", "(", ")", "."):
        normalized = func.replace(normalized, junk, "")
    stmt = (
        select(Patient)
        .where(Patient.phone.is_not(None), normalized.like(f"%{suffix}"))
        .order_by(Patient.created_at.asc())
        .limit(1)
    )
    return db.execute(stmt).scalars().first()


@router.post("/ingest", response_model=CallOut, dependencies=[Depends(_require_pbx_key)])
def ingest_call(payload: CallIngest, db: Annotated[Session, Depends(get_db)]) -> CallRecord:
    """PBX webhook: store one finished call, auto-linking the patient by phone."""
    digits = _digits(payload.phone)
    if not digits:
        raise HTTPException(status.HTTP_422_UNPROCESSABLE_ENTITY, "phone must contain digits")

    # Store UTC; a naive timestamp from the PBX is taken as UTC by contract.
    started_at = payload.started_at
    if started_at.tzinfo is None:
        started_at = started_at.replace(tzinfo=timezone.utc)
    else:
        started_at = started_at.astimezone(timezone.utc)

    patient = _match_patient(db, digits)
    record = CallRecord(
        direction=payload.direction,
        phone=payload.phone,
        phone_normalized=digits,
        started_at=started_at,
        duration_seconds=payload.duration_seconds,
        recording_url=payload.recording_url,
        note=payload.note,
        patient_id=patient.id if patient else None,
    )
    db.add(record)
    db.flush()
    record_audit(
        db, action="create", entity_type="call_record", entity_id=record.id,
        branch_id=patient.branch_id if patient else None,
        summary=(
            f"{'Incoming' if payload.direction == 'in' else 'Outgoing'} call {payload.phone}"
            + (f" → patient {patient.full_name}" if patient else " (no patient match)")
        ),
    )
    db.commit()
    db.refresh(record)
    return record


@router.get("", response_model=Page[CallOut],
            dependencies=[Depends(require_permission("calls.read"))])
def list_calls(
    db: Annotated[Session, Depends(get_db)],
    date_from: datetime | None = Query(None, description="started_at >= (UTC)"),
    date_to: datetime | None = Query(None, description="started_at <= (UTC)"),
    q: str | None = Query(None, description="Phone digits fragment or patient name"),
    offset: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=200),
) -> Page[CallOut]:
    stmt = select(CallRecord).outerjoin(Patient, CallRecord.patient_id == Patient.id)
    if date_from is not None:
        stmt = stmt.where(CallRecord.started_at >= date_from)
    if date_to is not None:
        stmt = stmt.where(CallRecord.started_at <= date_to)
    if q and q.strip():
        term = q.strip()
        like = f"%{term}%"
        conds = [Patient.first_name.ilike(like), Patient.last_name.ilike(like)]
        digits = _digits(term)
        if digits:
            conds.append(CallRecord.phone_normalized.like(f"%{digits}%"))
        stmt = stmt.where(or_(*conds))
    total = db.execute(select(func.count()).select_from(stmt.subquery())).scalar_one()
    rows = db.execute(
        stmt.order_by(CallRecord.started_at.desc()).offset(offset).limit(limit)
    ).scalars().all()
    return Page(items=[CallOut.model_validate(r) for r in rows], total=total, offset=offset, limit=limit)
