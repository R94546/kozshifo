"""Patient registration — structured CRM fields round-trip and validate.

The form is NOT a paper copy: gender / lead_source are enums (bad input → 422),
the rest persist through create + update.
"""
from __future__ import annotations

from tests.conftest import API

_PATIENTS = f"{API}/patients"


def test_create_patient_with_all_crm_fields(client, auth):
    body = {
        "last_name": "Алиев",
        "first_name": "Бек",
        "middle_name": "Рустамович",
        "birth_date": "1990-05-17",
        "gender": "male",
        "phone": "+998 90 111 22 33",
        "phone2": "+998 91 000 00 00",
        "email": "bek@example.uz",
        "address": "Ташкент, Чиланзар 5",
        "passport": "AA1234567",
        "pinfl": "12345678901234",
        "lead_source": "instagram",
        "workplace": "ООО Рога и Копыта",
        "profession": "Инженер",
    }
    created = client.post(_PATIENTS, headers=auth, json=body)
    assert created.status_code == 201, created.text
    p = created.json()
    # Every field round-trips.
    for key, value in body.items():
        assert p[key] == value, f"{key}: {p[key]!r} != {value!r}"
    assert p["full_name"] == "Алиев Бек Рустамович"

    fetched = client.get(f"{_PATIENTS}/{p['id']}", headers=auth).json()
    assert fetched["lead_source"] == "instagram"
    assert fetched["pinfl"] == "12345678901234"


def test_update_patient_crm_fields(client, auth):
    p = client.post(_PATIENTS, headers=auth,
                    json={"last_name": "Каримов", "first_name": "Тест"}).json()
    upd = client.patch(f"{_PATIENTS}/{p['id']}", headers=auth,
                       json={"lead_source": "referral", "pinfl": "99998888777766",
                             "gender": "female"})
    assert upd.status_code == 200, upd.text
    body = upd.json()
    assert body["lead_source"] == "referral"
    assert body["pinfl"] == "99998888777766"
    assert body["gender"] == "female"


def test_invalid_enum_values_are_rejected(client, auth):
    base = {"last_name": "Х", "first_name": "Y"}
    bad_source = client.post(_PATIENTS, headers=auth, json={**base, "lead_source": "vk"})
    assert bad_source.status_code == 422
    bad_gender = client.post(_PATIENTS, headers=auth, json={**base, "gender": "unknown"})
    assert bad_gender.status_code == 422
