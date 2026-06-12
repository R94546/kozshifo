"""Temp: richer two-track demo for the 2x2 TV screenshot."""
import httpx

API = "http://127.0.0.1:8000/api/v1"
c = httpx.Client(base_url=API, timeout=20)
token = c.post("/auth/login", data={"username": "director@kozshifo.uz",
                                    "password": "Director!2026"}).json()["access_token"]
c.headers["Authorization"] = f"Bearer {token}"
branch_id = c.get("/branches").json()[0]["id"]
svc = c.get("/services").json()["items"][0]

names = [("Алимов", "Бек"), ("Каримова", "Дилноза"), ("Юсупов", "Тимур"),
         ("Расулова", "Нилюфар"), ("Ахмедов", "Шерзод")]
tickets = []
for last, first in names:
    p = c.post("/patients", json={"first_name": first, "last_name": last,
                                  "branch_id": branch_id}).json()
    v = c.post("/visits", json={"patient_id": p["id"], "branch_id": branch_id,
                                "items": [{"service_id": svc["id"], "quantity": 1}]}).json()
    pay = c.post("/payments", json={"visit_id": v["id"], "amount": v["balance"]}).json()
    tickets.append(pay["queue_ticket_number"])

# Прогнать двоих через диагностику -> в очереди врача появятся V-талоны.
for _ in range(2):
    called = c.post("/queue/call-next",
                    json={"branch_id": branch_id, "room": "Каб. 2",
                          "track": "diagnostic"}).json()
    c.post(f"/queue/{called['id']}/done")

# Текущий вызов диагностики.
c.post("/queue/call-next", json={"branch_id": branch_id, "room": "Каб. 2",
                                 "track": "diagnostic"})
print("seeded:", tickets)
