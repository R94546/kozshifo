"""Lead-source analytics: where this period's patients came from (CRM channels)."""
from __future__ import annotations

import datetime

from tests.conftest import API

_PATIENTS = f"{API}/patients"
_LEAD = f"{API}/dashboard/lead-sources"

_CANONICAL = {"instagram", "telegram", "google", "referral",
              "banner", "walk_in", "other", "unknown"}


def _login(client, email: str, password: str) -> dict[str, str]:
    resp = client.post(f"{API}/auth/login", data={"username": email, "password": password})
    assert resp.status_code == 200, resp.text
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


def test_lead_source_counts(client, auth):
    # Three patients with sources + one without (folds into "unknown").
    for src in ("instagram", "instagram", "telegram"):
        client.post(_PATIENTS, headers=auth,
                    json={"last_name": "L", "first_name": "S", "lead_source": src})
    client.post(_PATIENTS, headers=auth, json={"last_name": "L", "first_name": "N"})

    today = datetime.date.today().isoformat()
    report = client.get(_LEAD, headers=auth, params={"date_from": today, "date_to": today})
    assert report.status_code == 200, report.text
    body = report.json()

    by = {r["source"]: r["count"] for r in body["sources"]}
    # Every canonical channel + unknown is present (zeros included).
    assert set(by) == _CANONICAL
    # Our patients are counted (>=, the session DB may hold others created today).
    assert by["instagram"] >= 2
    assert by["telegram"] >= 1
    assert by["unknown"] >= 1
    # Labels are filled and total reconciles with the per-source counts.
    assert all(r["label"] for r in body["sources"])
    assert body["total"] == sum(r["count"] for r in body["sources"])
    # Sorted by count desc.
    counts = [r["count"] for r in body["sources"]]
    assert counts == sorted(counts, reverse=True)


def test_lead_sources_requires_dashboard_view(client):
    # The seeded Doctor has no dashboard.view → 403.
    doctor = _login(client, "vrach@kozshifo.uz", "Vrach!2026")
    assert client.get(_LEAD, headers=doctor).status_code == 403


def test_lead_sources_bad_range(client, auth):
    assert client.get(_LEAD, headers=auth,
                      params={"date_from": "2026-06-10", "date_to": "2026-06-01"}).status_code == 422
