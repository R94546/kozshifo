# Integration design — Hikvision face terminal → staff attendance

Technical design for connecting a **Hikvision face-recognition access-control
terminal** (MinMoe family, e.g. DS-K1T6xx / DS-K1T3xx) to the KO'Z SHIFO
backend. Source study: *iVMS-4200 Client User Manual V3.10.0* (chapters 3, 14,
15, 16) cross-referenced with Hikvision **ISAPI** (HTTP/REST).

> **Status: design only.** Nothing here is built yet. This document is the
> contract the implementation must satisfy. Firmware-dependent values (event
> type codes, exact JSON keys) are marked **[verify on device]** — confirm
> against the real terminal before relying on them.

---

## 1. Confirmed decisions

| Decision | Choice | Consequence |
|----------|--------|-------------|
| **Deployment topology** | Backend runs **on the owner's on-prem server, same LAN as the terminal** | Direct ISAPI works both ways; **no relay/bridge agent needed**. Device → backend push and backend → device provisioning are plain LAN HTTP. |
| **Primary use case** | **Staff time & attendance** only | Reuse the existing `attendance` module + `AttendanceEvent`. No door-access or patient-recognition tables in this slice. |
| **Integration path** | **Direct ISAPI** (not iVMS-4200, not HCNetSDK) | iVMS-4200 is a human desktop client; the device's own REST API is the machine interface. |
| **Next step** | This design doc, then code | — |

Out of scope for this slice (revisit later): door/elevator control, patient
identification, multi-terminal person-binding table, cross-controller
anti-passback.

---

## 2. What the device is, and why not iVMS-4200

`iVMS-4200` is Hikvision's **Windows desktop client** for operators — it manages
devices, enrolls persons, and shows live access records (manual §14, §15.8.3).
It is **not** the integration surface for a server. Two reasons we bypass it:

1. It is a GUI app that must run on an always-on Windows PC; it is not a service.
2. Its only machine-to-machine output is the **third-party DB sync** (manual
   §16.2.7) which writes the timesheet into an external **MySQL / SQLServer** —
   not our PostgreSQL, and attendance-only with polling lag.

The terminal itself exposes **ISAPI** over HTTP(S) and can **push events**. That
is the path we use. iVMS-4200 stays useful as an *operator console* for ad-hoc
tasks (enrolling a face by hand, viewing live records) but is not in the
production data path.

### Ports (Hikvision defaults — confirm on the unit)
| Port | Use |
|------|-----|
| `80` / `443` | ISAPI HTTP / HTTPS — provisioning + polling + device web UI |
| `8000` | Hikvision SDK service port (not used by us) |
| backend `:8000` (or chosen) | **Our** webhook the device pushes events to |

---

## 3. Architecture — two flows on one LAN

```
                Clinic LAN (owner's server)
  ┌───────────────────────────────────────────────────────────┐
  │                                                            │
  │  Hikvision face terminal          kozshifo backend         │
  │  ┌──────────────────┐  ISAPI out  ┌─────────────────────┐  │
  │  │ face / card / PIN │◀────────────│ hikvision.py client │  │  provisioning
  │  │ employeeNo store  │             │  enroll_user/face   │  │  (backend → device)
  │  └──────────────────┘             └─────────────────────┘  │
  │           │  HTTP push (event)          ▲                  │
  │           └────────────────────────────▶│ POST /access-    │  events
  │              AccessControllerEvent+JPEG  │ control/event    │  (device → backend)
  │                                          ▼                  │
  │                                   AttendanceEvent → Postgres│
  └───────────────────────────────────────────────────────────┘
```

- **Provisioning (backend → device):** when a staff user is created/updated,
  the backend pushes the person (`employeeNo`, name, validity) and their face
  photo onto the terminal over ISAPI. Fire-and-forget, best-effort.
- **Events (device → backend):** on every face match the terminal POSTs the
  event (+ captured JPEG) to our webhook. We map `employeeNo → User` and write
  an `AttendanceEvent(source="faceid")`, reusing the in/out logic already in
  [`features/attendance.py`](../backend/app/features/attendance.py).
- **Reconciliation (backend → device, periodic):** a poller pulls `AcsEvent`
  since a cursor to backfill anything missed while the backend was down.

---

## 4. ISAPI surface (concrete)

Auth: **HTTP Digest**, device admin account. All calls take `?format=json`.
Wrap in `httpx.Client(auth=httpx.DigestAuth(user, pwd), timeout=5)`.

### 4.1 Provisioning — enroll a person
`POST /ISAPI/AccessControl/UserInfo/Record?format=json`
```json
{ "UserInfo": {
    "employeeNo": "<stable code>",
    "name": "Ivan Petrov",
    "userType": "normal",
    "Valid": { "enable": true, "beginTime": "2026-01-01T00:00:00",
               "endTime": "2030-12-31T23:59:59" },
    "doorRight": "1",
    "RightPlan": [ { "doorNo": 1, "planTemplateNo": "1" } ]
} }
```
Update = `PUT .../UserInfo/Modify?format=json`. Delete =
`PUT .../UserInfo/Delete?format=json` with `{ "UserInfoDelCond": { "EmployeeNoList": [ { "employeeNo": "..." } ] } }`.

### 4.2 Provisioning — bind a face photo
Newer firmware (face library): `POST /ISAPI/Intelligent/FDLib/FaceDataRecord?format=json`
as multipart — a JSON part `{ "faceLibType":"blackFD", "FDID":"1", "FPID":"<employeeNo>" }`
plus the JPEG part. **[verify on device]** — some models use
`POST /ISAPI/AccessControl/CaptureFaceData` (live capture) or accept the face
inline on `UserInfo/Record`. Confirm which the unit supports.

### 4.3 Events — pull (reconciliation)
`POST /ISAPI/AccessControl/AcsEvent?format=json`
```json
{ "AcsEventCond": {
    "searchID": "<uuid>", "searchResultPosition": 0, "maxResults": 30,
    "major": 5, "minor": 0,
    "startTime": "2026-06-13T00:00:00+05:00",
    "endTime":   "2026-06-13T23:59:59+05:00" } }
```
Page with `searchResultPosition` until `responseStatusStrg = "OK"` (no more).

### 4.4 Events — push (primary)
Device web UI → **Network → Advanced → HTTP Listening** (a.k.a.
*Notification / Alarm Host / Event-and-Alarm Push*). Set:
- Destination IP = backend server LAN IP, Port = backend port, URL = our path.
- Protocol HTTP (or HTTPS if cert installed).

The terminal then POSTs `multipart/form-data` per event: a JSON part
(`AccessControllerEvent`, see §5) and a `Picture` JPEG part.

---

## 5. Event payload & mapping

Representative `AccessControllerEvent` (keys vary slightly by firmware
**[verify on device]**):

| JSON key | Meaning | Maps to |
|----------|---------|---------|
| `employeeNoString` | person ID on device | `User.faceid_employee_no` → `User.id` |
| `name` | person name | (debug only; don't trust over the FK) |
| `majorEventType` / `subEventType` | what happened | filter: **face-auth success** only |
| `currentVerifyMode` | method (face/card/fp/PIN) | store for audit |
| `attendanceStatus` | `checkIn`/`checkOut`/`breakIn`/`breakOut` if device in T&A mode | → `direction` (else auto-toggle) |
| `time` | ISO-8601 **with offset** e.g. `2026-06-13T09:01:07+05:00` | → `occurred_at` (convert to UTC) |
| `serialNo` | per-device event sequence | idempotency key |
| `Picture` part | captured face JPEG | saved under `upload_dir` |

**Face-auth success filter [verify on device]:** commonly `majorEventType=5`
(event) with a face sub-type, or `subEventType=75` ("face authenticated").
Different firmware uses different codes — capture a few real events first and
pin the exact filter.

**Direction (in/out):**
1. If `attendanceStatus` is present (device configured with check-in/out, manual
   §16.2.2) → use it directly.
2. Otherwise → reuse the existing **auto-toggle**: if the user's last event today
   is `in`, this is `out`, else `in` ([`attendance.py:127`](../backend/app/features/attendance.py)).

Recommendation: configure the terminal's attendance status so direction is
explicit; keep auto-toggle as the fallback.

---

## 6. Data model changes

Minimal — reuse `AttendanceEvent`. Two additions:

### 6.1 `User.faceid_employee_no`
```python
# models/user.py
faceid_employee_no: Mapped[str | None] = mapped_column(
    String(32), unique=True, index=True, nullable=True
)
```
The mapping key between our user and the device person. Generation rule:
a short stable code (e.g. zero-padded incremental, or first 8 of the UUID hex).
Alembic migration adds the column (nullable, unique).

> If we later add **multiple terminals with independent person namespaces** or
> patient recognition, replace this column with a `DevicePersonBinding`
> (`device_id`, `user_id`, `employee_no`) table. For one clinic with a shared
> person namespace, the column is enough.

### 6.2 `Device` row for the terminal
No schema change — reuse [`models/device.py`](../backend/app/models/device.py):
```
device_type      = "access_control"
connection_type  = "isapi"
model            = "DS-K1T..."   serial_no = <plate>
settings (JSON)  = { "host": "192.168.x.x", "port": 80,
                     "credentials_ref": "env:HIKVISION_DEVICE",
                     "door_no": 1 }
```
Credentials live in env, **not** in the JSON (the JSON holds only a reference).

### 6.3 Captured JPEG
Saved to `settings.upload_dir` (same place as B-scan files). Optionally store
the path on a note/extra field; not required for the timesheet itself.

---

## 7. Config / settings (`core/config.py`)

Following the existing `attendance_api_key` pattern — endpoints answer **503**
while unset (integration disabled):

```python
hikvision_event_token: str | None = None      # secret in the webhook URL path
hikvision_device_host: str | None = None       # e.g. "192.168.1.50"
hikvision_device_port: int = 80
hikvision_device_user: str | None = None
hikvision_device_password: str | None = None
hikvision_allowed_ips: list[str] = []          # device source-IP allowlist
```
Production guard: if `environment=production` and the integration is enabled,
require non-empty token + credentials.

---

## 8. Webhook security

The terminal can't easily attach custom auth headers, so defense in depth:

1. **Secret path token** — webhook is `POST /access-control/event/{token}`;
   compared with `hikvision_event_token` via `secrets.compare_digest`.
2. **Source-IP allowlist** — `hikvision_allowed_ips` checked against the device
   IP (behind the on-prem reverse proxy, read the real client IP correctly).
3. **HTTPS** on the LAN if a cert is installed on the device (manual §21.11).
4. Newer firmware can add an `Authorization` header to the push — use it if
   available, but treat 1+2 as the baseline.

---

## 9. Backend module layout (files to add/change)

| File | Change |
|------|--------|
| `core/devices/hikvision.py` | **new** — ISAPI client: `enroll_user`, `upload_face`, `delete_user`, `poll_events`, `open_door`. `httpx.DigestAuth`. |
| `features/access_control.py` | **new** — `POST /access-control/event/{token}` webhook adapter: parse multipart → `AccessControllerEvent` → map → `AttendanceEvent`. Save JPEG. |
| `schemas/access_control.py` | **new** — Pydantic model for the parsed event. |
| `models/user.py` | add `faceid_employee_no`. |
| `core/config.py` | add settings from §7. |
| `features/users.py` | on create/update, fire-and-forget provisioning (daemon thread, like `core/notify.py`). |
| `api.py` | register the new router. |
| `alembic/versions/xxxx_*.py` | migration: `users.faceid_employee_no`. |
| `core/scheduling` (or daemon loop) | optional reconciliation poller calling `poll_events`. |

Provisioning runs in a **daemon thread** (the project's established
fire-and-forget pattern — see [`core/notify.py`](../backend/app/core/notify.py));
a device outage degrades to "not yet enrolled", never a 500 on user save.

---

## 10. Device-side setup checklist (from the manual)

1. **Activate** the terminal and set admin password (manual §3.1).
2. Set a **static LAN IP** on the device, same subnet as the backend server.
3. **Authentication mode = Face** (manual §16.2.2) so only face events are
   emitted (or `All` if card/PIN also wanted).
4. Enable **HTTP Listening / Notification** → backend IP:port + secret path
   (§4.4). Pick the access/attendance event types.
5. (If using check-in/out) configure **attendance status** on the reader so
   `attendanceStatus` is populated.
6. Confirm time zone = clinic TZ and **NTP** is set (event timestamps must be
   correct — we convert their offset to UTC).
7. Backend pushes persons + faces via ISAPI (§4.1–4.2); verify they appear in
   the device's person list (manual §14.4 "Get Person Information from Device"
   can cross-check).

---

## 11. Error handling & idempotency

- **Idempotency:** dedupe on `(device serialNo, employeeNo, time)` — the device
  may retransmit. A unique-ish natural key or a small "seen events" guard.
- **Unknown employeeNo:** event for a person we don't have → log + skip (don't
  500; the device keeps pushing). Surface as a notification so an admin enrolls.
- **Clock skew:** trust the device `time` (NTP-synced) over server receipt time;
  always store UTC via `UTCDateTime`.
- **Backend downtime:** events pushed while down are lost from push → the
  reconciliation poller (§4.3) backfills from `AcsEvent`.
- **Provisioning failure:** retry with backoff in the daemon thread; mark the
  user as "not enrolled" so a later sweep retries.

---

## 12. Testing plan

| Test | What it proves |
|------|----------------|
| Fake ISAPI server (httpx mock) | `hikvision.py` builds correct Digest requests / parses responses |
| Multipart parse unit test | `AccessControllerEvent` + JPEG split correctly |
| Mapping test | `employeeNo` → correct `User`; unknown → skip, no 500 |
| Direction test | `attendanceStatus` path **and** auto-toggle fallback |
| Idempotency test | duplicate push → one `AttendanceEvent` |
| TZ test | `+05:00` event stored as correct UTC; timesheet groups by local day |
| Security test | wrong path token → 401; non-allowlisted IP → 403; unset config → 503 |
| End-to-end (on the real unit) | enroll → smile at terminal → row appears in `/attendance/report` |

---

## 13. Task breakdown (Epic → Feature → DoD)

**Epic: Face-terminal staff attendance.**

1. **Mapping & migration** — `User.faceid_employee_no` + Alembic + admin UI field.
   *DoD:* column live, unique, editable in staff card.
2. **ISAPI client** — `core/devices/hikvision.py` with Digest auth.
   *DoD:* unit-tested against a fake server; can enroll + poll.
3. **Provisioning** — enroll user + face on user create/update (daemon thread).
   *DoD:* new staff appears on the device; failures don't break user save.
4. **Inbound webhook** — `POST /access-control/event/{token}` adapter → `AttendanceEvent`.
   *DoD:* secured (token+IP), idempotent, JPEG stored, 503 when unconfigured.
5. **Reconciliation poller** — periodic `AcsEvent` backfill.
   *DoD:* events missed during downtime are recovered, deduped.
6. **Device setup runbook** — §10 turned into a step-by-step ops doc.
   *DoD:* a non-developer can wire a new terminal from it.

---

## 14. Risks

| Risk | Mitigation |
|------|------------|
| Event type codes differ by firmware | **[verify on device]** — capture real events before locking the filter (§5). |
| Backend must be reachable on the LAN at a fixed IP | Static IP + reverse proxy on the owner's server (matches the planned DB migration on-prem). |
| Push lost during backend downtime | Reconciliation poller (§4.3). |
| Face library API varies (FDLib vs inline) | Detect/adapt at enroll time; **[verify on device]**. |
| Credential leakage | Creds in env only; JSON holds a reference; HTTPS on LAN if possible. |
| Person namespace collision (future multi-terminal) | Promote `faceid_employee_no` to a `DevicePersonBinding` table when needed. |

---

## 15. Open items to verify on the physical terminal

1. Exact `majorEventType`/`subEventType` for **face-auth success**.
2. Whether the unit supports `FDLib/FaceDataRecord` or inline face on `UserInfo`.
3. Whether `attendanceStatus` can be emitted (T&A mode) or we rely on auto-toggle.
4. HTTP Listening payload shape (multipart keys, picture part name).
5. Max persons / faces the model holds (capacity planning for staff count).
