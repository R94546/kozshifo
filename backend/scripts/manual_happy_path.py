"""Manual §9.3 happy-path exercise against a live server (Swagger equivalent).

create patient -> visit -> PUT exam -> POST refraction result ->
apply-refraction -> GET exam -> card.pdf -> GET devices.
Run:  ./.venv/Scripts/python.exe scripts/manual_happy_path.py
"""
from __future__ import annotations

import sys

import httpx

BASE = "http://127.0.0.1:8000/api/v1"


def main() -> int:
    client = httpx.Client(timeout=15)
    token = client.post(f"{BASE}/auth/login", data={
        "username": "director@kozshifo.uz", "password": "Director!2026",
    }).json()["access_token"]
    client.headers["Authorization"] = f"Bearer {token}"
    print("[1] login OK")

    branch_id = client.get(f"{BASE}/branches").json()[0]["id"]
    patient = client.post(f"{BASE}/patients", json={
        "first_name": "Ручной", "last_name": "Прогон", "phone": "+998900000001",
        "branch_id": branch_id, "workplace": "Завод №1", "dispensary_here": "Уч. №7",
    }).json()
    print(f"[2] patient {patient['mrn']} (workplace={patient['workplace']})")

    visit = client.post(f"{BASE}/visits", json={
        "patient_id": patient["id"], "branch_id": branch_id,
    }).json()
    print(f"[3] visit {visit['visit_no']}")

    exam = client.put(f"{BASE}/visits/{visit['id']}/exam", json={
        "exam_date": "2026-06-12", "complaints": "Туман вдали", "anamnesis": "Миопия 5 лет",
        "od_va": "0.5", "os_va": "0.6", "iop_od": "15.5", "iop_os": "16.0",
        "cornea": "прозрачная", "lens": "прозрачный",
        "diagnosis": "Миопия OU", "icd10": "H52.1", "recommendations": "очки",
    })
    assert exam.status_code == 200, exam.text
    print(f"[4] exam upserted id={exam.json()['id'][:8]}…")

    devices = client.get(f"{BASE}/devices").json()["items"]
    serials = {d["serial_no"]: d for d in devices}
    assert "2103540749" in serials and "53789467" in serials, serials.keys()
    rmk = serials["2103540749"]
    print(f"[5] devices seeded: {[d['model'] for d in devices]}")

    result = client.post(f"{BASE}/devices/{rmk['id']}/results", json={
        "result_type": "refraction", "visit_id": visit["id"],
        "payload": {"od": {"sph": "-1.25", "cyl": "-0.50", "axis": 170},
                    "os": {"sph": "-1.00", "cyl": "-0.25", "axis": 10}},
    })
    assert result.status_code == 201, result.text
    print(f"[6] RMK-700 refraction result {result.json()['id'][:8]}…")

    applied = client.post(f"{BASE}/visits/{visit['id']}/exam/apply-refraction",
                          params={"result_id": result.json()["id"]})
    assert applied.status_code == 200, applied.text
    a = applied.json()
    assert a["od_sph"] == "-1.25" and a["os_axis"] == 10, a
    print(f"[7] apply-refraction: OD sph {a['od_sph']} cyl {a['od_cyl']} ax {a['od_axis']} / "
          f"OS sph {a['os_sph']} cyl {a['os_cyl']} ax {a['os_axis']}")

    fetched = client.get(f"{BASE}/visits/{visit['id']}/exam").json()
    assert fetched["diagnosis"] == "Миопия OU" and fetched["od_sph"] == "-1.25"
    print("[8] GET exam: manual fields + device refraction merged")

    pdf = client.get(f"{BASE}/visits/{visit['id']}/exam/card.pdf")
    assert pdf.status_code == 200 and pdf.headers["content-type"].startswith("application/pdf")
    out = "manual_card_check.pdf"
    with open(out, "wb") as f:
        f.write(pdf.content)
    print(f"[9] card.pdf {len(pdf.content)} bytes -> {out}")

    history = client.get(f"{BASE}/patients/{patient['id']}/exams").json()
    assert len(history) == 1
    print("[10] exam history OK — happy path complete")
    return 0


if __name__ == "__main__":
    sys.exit(main())
