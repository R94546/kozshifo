"""Finance module (TZ Modul 8): expenses, percent payroll, cash reports, CSV.

Money is asserted as decimal STRINGS — the platform wire convention.
Date/month keys are derived from the payment's own created_at (UTC) so the
tests stay correct across timezones and month boundaries.
"""
from __future__ import annotations

from decimal import Decimal

from tests.conftest import API

_EXPENSES = f"{API}/finance/expenses"
_PAYROLL = f"{API}/finance/payroll"
_REPORTS = f"{API}/finance/reports"


def _login(client, email: str, password: str) -> dict[str, str]:
    resp = client.post(f"{API}/auth/login", data={"username": email, "password": password})
    assert resp.status_code == 200, resp.text
    return {"Authorization": f"Bearer {resp.json()['access_token']}"}


def _make_doctor(client, auth, email: str, salary_percent: str | None = None) -> dict:
    user = client.post(
        f"{API}/users", headers=auth,
        json={"email": email, "full_name": f"Доктор {email.split('@')[0]}",
              "password": "Doctor!2026", "role_names": ["Doctor"]},
    )
    assert user.status_code == 201, user.text
    user = user.json()
    if salary_percent is not None:
        resp = client.patch(f"{API}/users/{user['id']}", headers=auth,
                            json={"salary_percent": salary_percent})
        assert resp.status_code == 200, resp.text
        user = resp.json()
    return user


def _paid_visit(client, auth, *, doctor_id: str | None = None, method: str = "cash") -> tuple[dict, dict]:
    """Open a fully-paid visit (one CONS service, 150000) without queue side effects."""
    branch_id = client.get(f"{API}/branches", headers=auth).json()[0]["id"]
    patient = client.post(
        f"{API}/patients", headers=auth,
        json={"first_name": "Тест", "last_name": "Финанс", "branch_id": branch_id},
    ).json()
    services = client.get(f"{API}/services", headers=auth).json()["items"]
    consult = next(s for s in services if s["code"] == "CONS")
    body = {"patient_id": patient["id"], "branch_id": branch_id,
            "items": [{"service_id": consult["id"], "quantity": 1}]}
    if doctor_id is not None:
        body["doctor_id"] = doctor_id
    visit = client.post(f"{API}/visits", headers=auth, json=body).json()
    pay = client.post(
        f"{API}/payments", headers=auth,
        json={"visit_id": visit["id"], "amount": visit["balance"],
              "method": method, "issue_queue_ticket": False},
    )
    assert pay.status_code == 201, pay.text
    return visit, pay.json()["payment"]


# ════════════════════════════════════════════════════════════════════════════
# Expenses
# ════════════════════════════════════════════════════════════════════════════


def test_expense_create_list_delete(client, auth):
    branch_id = client.get(f"{API}/branches", headers=auth).json()[0]["id"]
    created = client.post(
        _EXPENSES, headers=auth,
        json={"category": "Аренда", "amount": "500000", "expense_date": "2026-06-01",
              "note": "Офис, июнь"},
    )
    assert created.status_code == 201, created.text
    exp = created.json()
    assert exp["kind"] == "regular"
    assert exp["amount"] == "500000.00"  # decimal string, 2dp from Numeric(12,2)
    assert exp["branch_id"] == branch_id  # defaulted to the actor's branch
    assert exp["created_by_name"] == "Директор клиники"

    listed = client.get(_EXPENSES, headers=auth,
                        params={"category": "Аренда", "date_from": "2026-06-01",
                                "date_to": "2026-06-01"}).json()
    assert listed["total"] >= 1
    row = next(e for e in listed["items"] if e["id"] == exp["id"])
    assert row["created_by_name"] == "Директор клиники"

    deleted = client.delete(f"{_EXPENSES}/{exp['id']}", headers=auth)
    assert deleted.status_code == 200, deleted.text
    listed = client.get(_EXPENSES, headers=auth, params={"category": "Аренда"}).json()
    assert all(e["id"] != exp["id"] for e in listed["items"])


def test_expense_validation(client, auth):
    # Blank category and non-positive amounts never reach the database.
    assert client.post(_EXPENSES, headers=auth,
                       json={"category": "  ", "amount": "10", "expense_date": "2026-06-01"},
                       ).status_code == 422
    assert client.post(_EXPENSES, headers=auth,
                       json={"category": "Прочее", "amount": "0", "expense_date": "2026-06-01"},
                       ).status_code == 422


def test_expense_requires_permission(client, auth):
    # The Doctor role carries no expenses.* permissions.
    doctor = _make_doctor(client, auth, "fin.rbac@kozshifo.uz")
    doc_auth = _login(client, "fin.rbac@kozshifo.uz", "Doctor!2026")
    assert client.get(_EXPENSES, headers=doc_auth).status_code == 403
    denied = client.post(_EXPENSES, headers=doc_auth,
                         json={"category": "Прочее", "amount": "10", "expense_date": "2026-06-01"})
    assert denied.status_code == 403
    assert doctor["id"]  # silence unused warning


# ════════════════════════════════════════════════════════════════════════════
# Payroll
# ════════════════════════════════════════════════════════════════════════════


def test_payroll_math_through_the_api(client, auth):
    doctor = _make_doctor(client, auth, "fin.payroll@kozshifo.uz", salary_percent="30")
    assert doctor["salary_percent"] == "30.00"

    _, payment = _paid_visit(client, auth, doctor_id=doctor["id"], method="card")
    month = payment["created_at"][:7]

    resp = client.get(_PAYROLL, headers=auth, params={"month": month})
    assert resp.status_code == 200, resp.text
    row = next(r for r in resp.json() if r["user_id"] == doctor["id"])
    assert row["full_name"] == doctor["full_name"]
    assert row["salary_percent"] == "30.00"
    assert row["revenue"] == "150000.00"  # CONS price, decimal string
    assert row["salary"] == "45000.00"   # 30% of 150000
    assert row["paid"] is False
    assert row["paid_at"] is None

    # A refund is a status flip on the payment row -> it drops OUT of the
    # doctor's revenue (completed-only sum). Mirrors payments.py semantics.
    _, refunded_payment = _paid_visit(client, auth, doctor_id=doctor["id"])
    assert client.post(f"{API}/payments/{refunded_payment['id']}/refund",
                       headers=auth).status_code == 200
    row = next(r for r in client.get(_PAYROLL, headers=auth, params={"month": month}).json()
               if r["user_id"] == doctor["id"])
    assert row["revenue"] == "150000.00"  # unchanged by the refunded visit

    # Month format is validated.
    assert client.get(_PAYROLL, headers=auth, params={"month": "2026-13"}).status_code == 422
    assert client.get(_PAYROLL, headers=auth, params={"month": "junk"}).status_code == 422


def test_payroll_payout_flow(client, auth):
    doctor = _make_doctor(client, auth, "fin.payout@kozshifo.uz", salary_percent="25")
    _, payment = _paid_visit(client, auth, doctor_id=doctor["id"])
    month = payment["created_at"][:7]

    payout = client.post(f"{_PAYROLL}/payout", headers=auth,
                         json={"user_id": doctor["id"], "month": month})
    assert payout.status_code == 201, payout.text
    expense = payout.json()
    assert expense["kind"] == "payroll"
    assert expense["category"] == "Зарплата"
    assert expense["amount"] == "37500.00"  # 25% of 150000
    assert expense["payroll_user_id"] == doctor["id"]
    assert expense["payroll_month"] == month
    assert "25" in expense["note"] and month in expense["note"]

    # Payroll now shows the row as paid.
    row = next(r for r in client.get(_PAYROLL, headers=auth, params={"month": month}).json()
               if r["user_id"] == doctor["id"])
    assert row["paid"] is True
    assert row["paid_at"] is not None

    # Idempotency: the unique (user, month) constraint turns a repeat into 409.
    again = client.post(f"{_PAYROLL}/payout", headers=auth,
                        json={"user_id": doctor["id"], "month": month})
    assert again.status_code == 409

    # Payroll rows cannot be deleted through the expense API.
    assert client.delete(f"{_EXPENSES}/{expense['id']}", headers=auth).status_code == 409

    # The payout lands in the reports as an ordinary outflow.
    d = expense["expense_date"]
    daily = client.get(f"{_REPORTS}/daily", headers=auth, params={"d": d}).json()
    assert Decimal(daily["expense_total"]) >= Decimal("37500.00")
    monthly = client.get(f"{_REPORTS}/monthly", headers=auth, params={"month": d[:7]}).json()
    assert Decimal(monthly["payroll_total"]) >= Decimal("37500.00")

    # payroll.read does not grant payouts: the seeded Cashier can read…
    kassa = _login(client, "kassa@kozshifo.uz", "Kassa!2026")
    assert client.get(_PAYROLL, headers=kassa, params={"month": month}).status_code == 200
    # …but not pay out (payroll.manage missing).
    denied = client.post(f"{_PAYROLL}/payout", headers=kassa,
                         json={"user_id": doctor["id"], "month": month})
    assert denied.status_code == 403


def test_payroll_payout_rejects_zero_salary_and_no_percent(client, auth):
    with_pct = _make_doctor(client, auth, "fin.zero@kozshifo.uz", salary_percent="40")
    # No revenue in a long-gone month -> nothing to pay.
    resp = client.post(f"{_PAYROLL}/payout", headers=auth,
                       json={"user_id": with_pct["id"], "month": "2020-01"})
    assert resp.status_code == 400

    no_pct = _make_doctor(client, auth, "fin.nopct@kozshifo.uz")
    resp = client.post(f"{_PAYROLL}/payout", headers=auth,
                       json={"user_id": no_pct["id"], "month": "2020-01"})
    assert resp.status_code == 400


def test_salary_percent_validation_on_user_update(client, auth):
    doctor = _make_doctor(client, auth, "fin.pct@kozshifo.uz")
    bad = client.patch(f"{API}/users/{doctor['id']}", headers=auth,
                       json={"salary_percent": "101"})
    assert bad.status_code == 422
    bad = client.patch(f"{API}/users/{doctor['id']}", headers=auth,
                       json={"salary_percent": "-1"})
    assert bad.status_code == 422
    ok = client.patch(f"{API}/users/{doctor['id']}", headers=auth,
                      json={"salary_percent": "12.5"})
    assert ok.status_code == 200
    assert ok.json()["salary_percent"] == "12.50"
    # Explicit null clears percent-based pay.
    cleared = client.patch(f"{API}/users/{doctor['id']}", headers=auth,
                           json={"salary_percent": None})
    assert cleared.status_code == 200
    assert cleared.json()["salary_percent"] is None


# ════════════════════════════════════════════════════════════════════════════
# Cash reports
# ════════════════════════════════════════════════════════════════════════════


def test_daily_report_methods_expenses_and_refunds(client, auth):
    _, payment = _paid_visit(client, auth, method="qr")
    d = payment["created_at"][:10]  # the payment's own UTC business day
    amount = Decimal(payment["amount"])

    created = client.post(_EXPENSES, headers=auth,
                          json={"category": "Коммуналка", "amount": "10000", "expense_date": d})
    assert created.status_code == 201, created.text

    body = client.get(f"{_REPORTS}/daily", headers=auth, params={"d": d}).json()
    assert body["date"] == d
    assert set(body["income_by_method"]) >= {"cash", "card", "qr", "transfer"}
    assert Decimal(body["income_by_method"]["qr"]) >= amount
    assert Decimal(body["expense_total"]) >= Decimal("10000.00")
    # Internal consistency (shared DB may hold other rows from this session).
    assert Decimal(body["income_total"]) == sum(
        Decimal(v) for v in body["income_by_method"].values())
    assert Decimal(body["net"]) == (Decimal(body["income_total"])
                                    - Decimal(body["refund_total"])
                                    - Decimal(body["expense_total"]))

    # Refund = status flip: the till keeps the day's inflow AND books the
    # outflow, so a same-day pay+refund nets to zero instead of double-dipping.
    before = client.get(f"{_REPORTS}/daily", headers=auth, params={"d": d}).json()
    _, refunded = _paid_visit(client, auth, method="cash")
    assert client.post(f"{API}/payments/{refunded['id']}/refund",
                       headers=auth).status_code == 200
    after = client.get(f"{_REPORTS}/daily", headers=auth, params={"d": d}).json()
    refund_amount = Decimal(refunded["amount"])
    assert Decimal(after["income_total"]) == Decimal(before["income_total"]) + refund_amount
    assert Decimal(after["refund_total"]) == Decimal(before["refund_total"]) + refund_amount
    assert Decimal(after["net"]) == Decimal(before["net"])  # zero net effect


def test_monthly_report_shape(client, auth):
    _, payment = _paid_visit(client, auth, method="transfer")
    month = payment["created_at"][:7]
    body = client.get(f"{_REPORTS}/monthly", headers=auth, params={"month": month}).json()
    assert body["month"] == month
    assert Decimal(body["income_by_method"]["transfer"]) >= Decimal(payment["amount"])
    assert Decimal(body["net"]) == (Decimal(body["income_total"])
                                    - Decimal(body["refund_total"])
                                    - Decimal(body["expense_total"]))
    assert "payroll_total" in body
    assert client.get(f"{_REPORTS}/monthly", headers=auth,
                      params={"month": "2026-1"}).status_code == 422


# ════════════════════════════════════════════════════════════════════════════
# CSV exports
# ════════════════════════════════════════════════════════════════════════════


def test_csv_exports(client, auth):
    # Expenses CSV: BOM + attachment + header row.
    resp = client.get(f"{_EXPENSES}.csv", headers=auth)
    assert resp.status_code == 200, resp.text
    assert resp.content.startswith(b"\xef\xbb\xbf")
    assert "attachment" in resp.headers["content-disposition"]
    header = resp.text.lstrip("\ufeff").splitlines()[0]
    assert header.startswith("expense_date,category,amount")

    resp = client.get(f"{_PAYROLL}.csv", headers=auth, params={"month": "2026-06"})
    assert resp.status_code == 200, resp.text
    assert resp.content.startswith(b"\xef\xbb\xbf")

    resp = client.get(f"{_REPORTS}/daily.csv", headers=auth, params={"d": "2026-06-01"})
    assert resp.status_code == 200, resp.text
    assert resp.content.startswith(b"\xef\xbb\xbf")

    # CSV twins share the JSON endpoint's permission gate.
    doc_auth = _login(client, "vrach@kozshifo.uz", "Vrach!2026")
    assert client.get(f"{_EXPENSES}.csv", headers=doc_auth).status_code == 403
