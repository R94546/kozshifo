"""Patient DTOs."""
from __future__ import annotations

from datetime import date
from typing import Literal
from uuid import UUID

from pydantic import BaseModel, ConfigDict

# CRM lead source (where the patient came from) — canonical wire vocabulary.
# UI labels (RU): Instagram / Telegram / Google / Рекомендация / Баннер /
# Проходил мимо / Другое.
LeadSource = Literal[
    "instagram", "telegram", "google", "referral", "banner", "walk_in", "other"
]
Gender = Literal["male", "female", "other"]


class PatientCreate(BaseModel):
    first_name: str
    last_name: str
    middle_name: str | None = None
    birth_date: date | None = None
    gender: Gender | None = None
    phone: str | None = None
    phone2: str | None = None
    email: str | None = None
    address: str | None = None
    passport: str | None = None
    pinfl: str | None = None
    lead_source: LeadSource | None = None
    workplace: str | None = None
    profession: str | None = None
    dispensary_here: str | None = None
    dispensary_other: str | None = None
    notes: str | None = None
    branch_id: UUID | None = None
    mrn: str | None = None  # auto-generated if omitted


class PatientUpdate(BaseModel):
    first_name: str | None = None
    last_name: str | None = None
    middle_name: str | None = None
    birth_date: date | None = None
    gender: Gender | None = None
    phone: str | None = None
    phone2: str | None = None
    email: str | None = None
    address: str | None = None
    passport: str | None = None
    pinfl: str | None = None
    lead_source: LeadSource | None = None
    workplace: str | None = None
    profession: str | None = None
    dispensary_here: str | None = None
    dispensary_other: str | None = None
    notes: str | None = None


class PatientOut(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    mrn: str
    first_name: str
    last_name: str
    middle_name: str | None
    full_name: str
    birth_date: date | None
    gender: str | None
    phone: str | None
    phone2: str | None
    email: str | None
    address: str | None
    passport: str | None
    pinfl: str | None
    lead_source: str | None
    workplace: str | None
    profession: str | None
    dispensary_here: str | None
    dispensary_other: str | None
    notes: str | None
    branch_id: UUID | None
