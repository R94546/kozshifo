# ULTRA PROMPT — Epic 2: Ophthalmology EMR (Form 025-8) + Medical Devices
### Maximum-rigor edition. Hand this entire file to a coding agent.

> This prompt assumes the **kozshifo** monorepo. It is engineered so a capable
> agent ships a complete, tested, production-grade vertical slice **without
> re-deriving context**. Follow it top to bottom. Do not skip Phase 0.

---

## 0. HOW TO USE THIS PROMPT
Execute the phases **in order**: `0 Reconnaissance → 1 Comprehension gate →
2 Build (epic by epic) → 3 Self-verification → 4 Report`. You may not write
feature code until Phase 1 is posted. Commit at the checkpoints in §11.

## 1. ROLE & MINDSET
You are the autonomous **senior engineering team** for **KO'Z SHIFO**, a medical
ERP/HIS for an eye clinic: CTO + Principal Engineer + HIS Architect + Database
Architect + Lead QA. Operate at staff-engineer level: study before you build,
reuse the established patterns, make defensible decisions autonomously, and prove
your work with tests. Optimize for correctness, consistency with the existing
codebase, and zero regressions — not speed.

## 2. PRIME DIRECTIVE / QUALITY BAR
1. **Consistency over novelty.** Match the existing architecture exactly. If you
   introduce a new pattern, justify it in your decision log (§12).
2. **Everything you ship is tested and green** (backend `pytest`, Flutter
   `analyze` + `test` + `build web`). Untested code is not done.
3. **No regressions.** The 6 existing backend tests and 4 Flutter tests must stay green.
4. **Match the real-world domain exactly** (`docs/DOMAIN.md` is authoritative —
   the patient card is a *legal* document, MoH Form 025-8).
5. **Leave the map updated** so the next agent stays oriented (`AGENTS.md` §1/§7,
   `PLATFORM.md` matrix).

---

## 3. PHASE 0 — MANDATORY RECONNAISSANCE (read before any code)
You will be tempted to skip this. Don't — it is the cheapest way to avoid
wrong-pattern rework.

### 3.1 Establish a green baseline (run these, paste results in your first report)
```bash
git log --oneline -12
# Backend baseline:
cd backend && python -m venv .venv
./.venv/Scripts/python.exe -m pip install -r requirements.txt      # Windows path
./.venv/Scripts/python.exe -m pytest -q                            # expect: 6 passed
# Flutter baseline (repo root):
flutter pub get && flutter analyze && flutter test                 # expect: clean, 4 passed
```
If the baseline is not green, **stop and report** — do not build on a broken base.

### 3.2 Files you MUST read (study all of them; know why each matters)
**Orientation & domain (read first, fully):**
`AGENTS.md` · `PLATFORM.md` · `README.md` · `backend/README.md` · `docs/DOMAIN.md` · `CLAUDE.md`

**Backend — the patterns you will copy:**
- App wiring: `backend/app/main.py`, `backend/app/api.py`, `backend/app/seed.py`
- Core: `backend/app/core/`{`config.py`,`database.py`,`security.py`,`deps.py`,
  `repository.py`,`audit.py`,`permissions.py`,`sequences.py`}
- Models (copy style): `backend/app/models/`{`base.py`,`__init__.py`,`patient.py`,
  `visit.py`,`catalog.py`,`user.py`,`rbac.py`,`branch.py`}
- Schemas: `backend/app/schemas/`{`common.py`,`patient.py`,`visit.py`,`catalog.py`}
- Features (copy style): `backend/app/features/`{`patients.py`,`visits.py`,
  `catalog.py`,`roles.py`} — note routing, `require_permission`, audit, commit/refresh.
- Tests (copy style): `backend/tests/`{`conftest.py`,`test_patient_journey.py`}

**Flutter — the patterns you will copy:**
- App: `lib/main.dart`, `lib/app/`{`app.dart`,`theme.dart`,`router.dart`}
- Core: `lib/core/network/`{`dio_client.dart`,`api_exception.dart`,`page.dart`},
  `lib/core/storage/token_storage.dart`, `lib/core/utils/formatters.dart`,
  `lib/core/widgets/`{`app_shell.dart`,`async_value_widget.dart`},
  `lib/core/constants/api_constants.dart`
- A full feature (copy this exact shape): `lib/features/patients/`{`domain/patient.dart`,
  `data/patients_repository.dart`,`presentation/patients_screen.dart`} and
  `lib/features/auth/`{`domain/auth_user.dart`,`data/auth_repository.dart`,
  `application/auth_controller.dart`,`presentation/login_screen.dart`}
- Codegen config: `build.yaml`, `pubspec.yaml`

### 3.3 COMPREHENSION GATE (answer ALL in your first report, before coding)
Demonstrate you studied the code by answering, citing file:line:
1. End-to-end, what are the **exact steps to add a backend feature** (model →
   `models/__init__.py` → schema → `features/x.py` → register in `api.py` →
   permission codes in `core/permissions.py` → seed → test)?
2. How does `require_permission(...)` resolve access? Where are permission **codes**
   defined, and how is the `Doctor` role granted them?
3. How and **when** is `record_audit(...)` called? Does it commit separately or with the change?
4. How is **money/decimal** serialized to the client, and how does the Flutter side parse it?
5. How does **Freezed codegen** work here (what does `build.yaml` do), what command
   regenerates, and what is the **`build_runner`/`objective_c` gotcha** (AGENTS.md §6)?
6. In Flutter, how is a screen wired into **GoRouter** (`lib/app/router.dart`) and the
   **nav shell** (`lib/core/widgets/app_shell.dart`)? What Riverpod provider types are used for reads vs. auth?
7. How are **human IDs** (MRN/visit/receipt) generated (`core/sequences.py`)?
8. How do **Visit / VisitItem / total / balance** work, so an `EyeExam` attaches correctly to a visit?

Only after posting these answers may you proceed to Phase 2.

---

## 4. GROUND TRUTH (inputs — match exactly)
Authoritative source: **`docs/DOMAIN.md`**. Summary:
- **Two real devices to seed:** Supore **RMK-700** auto-refractometer (S/N 2103540749,
  asset CP-RMK-700A00749) → outputs refraction SPH/CYL/AXIS per eye; **CAS-2000BER**
  ophthalmic **A/B ultrasound** (S/N 53789467) → A-scan biometry + B-scan images.
- **Patient card = MoH Form 025-8** «Амбулатор тиббий карта» (Order №777, 2017-12-25):
  cover identity + «ОКУЛИСТ КУРИГИ» eye exam + Ташхис/Тавсия/Шифокор. Field-by-field
  mapping and clinical value types are in `docs/DOMAIN.md` §2 — use it verbatim.

---

## 5. SCOPE

### 5.A — EMR backend (Ophthalmology exam, Form 025-8)
**A1. Extend `Patient`** (cover, DOMAIN §2.1): add nullable `workplace`,
`dispensary_here`, `dispensary_other`. Update `schemas/patient.py` (`PatientCreate`,
`PatientUpdate`, `PatientOut`) and audit on change. `mrn` == «Бемор коди».

**A2. New model `EyeExam`** (`models/exam.py`, one-to-one with `Visit`):
- Keys/meta: `id`, `visit_id` (FK→visits, **unique**), `patient_id` (FK), `doctor_id`
  (FK→users, nullable), `exam_date` (Date), timestamps.
- Subjective: `complaints` (Text), `anamnesis` (Text).
- Refraction per eye — `od_va`/`os_va` (String, uncorrected Visus, e.g. `"0.6"`),
  `od_sph`/`os_sph`/`od_cyl`/`os_cyl` (`Numeric(4,2)`, signed, nullable),
  `od_axis`/`os_axis` (Integer 0–180, nullable), `od_va_cc`/`os_va_cc` (String, corrected VA).
- Tonometry: `iop_od`/`iop_os` (`Numeric(4,1)`, nullable, mmHg).
- Biomicroscopy/structures (Text, nullable, **form order**): `orbit`, `eyeball`,
  `eyelids`, `conjunctiva`, `lacrimal`, `cornea`, `anterior_chamber`, `iris`,
  `pupil`, `lens`, `vitreous`, `fundus`.
- A/B scan: `ab_scan_note` (Text). (Attached scan files come via `DeviceResult` in 5.C.)
- Conclusion: `diagnosis` (Text), `icd10` (String, nullable), `recommendations` (Text).
- Register in `models/__init__.py`.

**A3. Schemas** (`schemas/exam.py`): `EyeExamUpsert` (all fields optional except none
required beyond what makes sense), `EyeExamOut`. **Validation:** axis ∈ [0,180]
(`Field(ge=0, le=180)`); sph/cyl sane range (e.g. [-30,30]); reject otherwise → 422.

**A4. Feature** (`features/exams.py`, router `tags=["EMR"]`):
- `PUT /api/v1/visits/{visit_id}/exam` → **upsert** (create if absent, else update).
  404 if visit missing. Set `doctor_id` = current user if not provided. `record_audit`.
- `GET /api/v1/visits/{visit_id}/exam` → 404 if none.
- `GET /api/v1/patients/{patient_id}/exams` → list, newest first.
- Permissions: `exams.read`, `exams.write`. Add to `core/permissions.py` `PERMISSIONS`
  and grant `exams.read`+`exams.write` to `Doctor`, `exams.read` to `Reception`/`Director`.
- Register router in `api.py`.

**Example contract:**
```http
PUT /api/v1/visits/{visit_id}/exam
{ "exam_date":"2026-06-12","complaints":"...","anamnesis":"...",
  "od_va":"0.6","od_sph":"-1.25","od_cyl":"-0.50","od_axis":170,"od_va_cc":"1.0",
  "os_va":"0.7","os_sph":"-1.00","os_cyl":"-0.25","os_axis":10,"os_va_cc":"1.0",
  "iop_od":"16.0","iop_os":"17.0",
  "cornea":"прозрачная","lens":"прозрачный","fundus":"ДЗН бледно-розовый ...",
  "diagnosis":"Миопия слабой степени OU","icd10":"H52.1","recommendations":"очковая коррекция" }
→ 200 EyeExamOut { id, visit_id, patient_id, doctor_id, ...all fields..., created_at, updated_at }
```

**A5. Print Form 025-8 (first-class deliverable):**
`GET /api/v1/visits/{visit_id}/exam/card.pdf` → server-rendered PDF of the official
card (cover identity + «ОКУЛИСТ КУРИГИ» + Ташхис/Тавсия/Шифокор) with the «KO'Z SHIFO»
header and the «025-8 / Приказ №777» footer. Use `reportlab` or `weasyprint`
(add to `requirements.txt`). Permission `exams.read`. If you must stage it, ship a
working minimal layout now and note polish in `PLATFORM.md` — do not leave a 501 stub.

### 5.B — EMR Flutter (Doctor module, `lib/features/doctor/`)
- Freezed `EyeExam` model (snake_case JSON), `DoctorRepository` (Dio), Riverpod providers.
- **Patient card screen** rendering fields in **Form 025-8 order**: complaints, anamnesis,
  Visus OD/OS (va + sph/cyl/axis + corrected va), IOP OD/OS, the 12 structure fields,
  diagnosis + ICD-10, recommendations. Save via `PUT /visits/{id}/exam`; show success/error.
- Read-only **exam history** for the patient (`GET /patients/{id}/exams`).
- Gate editing on `exams.write` (`user.can('exams.write')`); read-only otherwise.
- Entry points: a "Карта" action from a visit and from the patients list. Register the
  route in `lib/app/router.dart` and (if top-level) a nav destination in `app_shell.dart`.
- "Печать 025-8" button → open/download `card.pdf`.

### 5.C — Devices backend (`features/devices.py`, `models/device.py`)
- **`Device`**: `name`, `device_type` (`ab_ultrasound|refractometer|other`), `model`,
  `manufacturer`, `serial_no` (**unique**), `asset_code`, `connection_type`
  (`manual|file|serial|usb|hl7|dicom`), `branch_id` (FK, nullable), `status`
  (`active|inactive|maintenance`), `manufacture_date` (Date, nullable), `settings` (JSON),
  `eu_rep`, `address`, `useful_life_years` (Int, nullable).
- **`DeviceResult`**: `device_id` (FK), `patient_id` (nullable), `visit_id` (nullable),
  `result_type` (`refraction|biometry|bscan_image|file`), `payload` (JSON), `file_path`
  (nullable), `measured_at` (DateTime), `source` (`manual|import`).
- **Adapter seam** (`core/devices/adapters.py`): a `DeviceAdapter` Protocol/ABC with
  `ManualEntryAdapter` and `FileImportAdapter` implemented; `SerialAdapter`,
  `Hl7Adapter`, `DicomAdapter` as documented **TODO stubs** (raise `NotImplementedError`).
  Do **not** implement real protocol I/O this epic.
- **Seed** the two real devices (DOMAIN §1) in `seed.py`, idempotent by `serial_no`.
- **API** (perms `devices.read`/`devices.manage`, `device_results.read`/`device_results.create`):
  - `GET/POST/PATCH /api/v1/devices`
  - `POST /api/v1/devices/{id}/results`  (manual entry or file)
  - `GET /api/v1/visits/{visit_id}/device-results`
  - `POST /api/v1/visits/{visit_id}/exam/apply-refraction?result_id=…` → copy the
    refraction `DeviceResult.payload` into the visit's `EyeExam` (od/os sph/cyl/axis);
    create the exam if absent. Audit. 422 if the result isn't a refraction.
- Add the new permission codes to `core/permissions.py` (+grant to roles sensibly).

**Refraction payload shape:**
```json
{ "od": {"sph":"-1.25","cyl":"-0.50","axis":170},
  "os": {"sph":"-1.00","cyl":"-0.25","axis":10} }
```

### 5.D — Devices Flutter
- Director **Devices screen** (`lib/features/devices/`): list seeded devices (status,
  serial, branch) + recent results.
- In the doctor card: **«Подтянуть из рефрактометра»** → `apply-refraction`, then refresh
  the exam form; **«A/B-скан»** section listing/preview of attached scan files for the visit.

---

## 6. CROSS-CUTTING CONVENTIONS (hard rules — see AGENTS.md §4–§6)
- **RBAC by permission *code*, never role name.** Director = superuser bypass.
- **Audit every mutation** via `record_audit(...)` inside the same transaction; commit once.
- **Money & clinical decimals** use SQLAlchemy `Numeric`, serialized as **strings**;
  never float. Parse with `Decimal`/string on the client.
- **Freezed:** JSON is snake_case (`build.yaml field_rename: snake`). After editing any
  `@freezed` model run `dart run build_runner build --delete-conflicting-outputs`.
  **Never add a dependency with native build hooks** (breaks build_runner — AGENTS.md §6).
- **DB:** SQLite dev; `create_all()` + idempotent seed on startup; Postgres via
  `DATABASE_URL`. New tables auto-create. (No Alembic this epic.)
- **Copy** `patients`/`visits` (backend) and `patients`/`auth` (Flutter) as templates.

## 7. TEST MATRIX (write these; names indicative)
Backend `backend/tests/test_eye_exam.py`:
- `test_upsert_creates_then_updates_exam` — PUT twice, second updates in place (same id).
- `test_axis_out_of_range_rejected` — `od_axis=200` → 422.
- `test_exam_requires_permission` — user without `exams.write` → 403; with → 200.
- `test_patient_exam_history_orders_newest_first`.
- `test_card_pdf_returns_pdf` — `card.pdf` → 200, `content-type: application/pdf`, non-empty.
Backend `backend/tests/test_devices.py`:
- `test_two_real_devices_seeded` — RMK-700 & CAS-2000BER present by serial.
- `test_post_refraction_result_and_apply_to_exam` — apply-refraction fills OD/OS sph/cyl/axis.
- `test_apply_non_refraction_result_rejected` → 422.
- `test_devices_rbac` — create/patch needs `devices.manage`.
Flutter `test/`:
- a unit test for the `EyeExam` model round-trip (fromJson/toJson) and any pure mapping helper.

## 8. DEFINITION OF DONE (hard gate — paste command output in final report)
```bash
cd backend && ./.venv/Scripts/python.exe -m pytest -q     # ALL pass (old 6 + new) 
flutter analyze                                            # No issues found!
flutter test                                               # all pass
flutter build web --no-tree-shake-icons                    # √ Built build/web
```
- [ ] All four gates green; **no existing test broken**.
- [ ] Eye exam round-trips from the Flutter doctor card and re-opens with every field.
- [ ] `apply-refraction` from an RMK-700 result fills OD/OS sph/cyl/axis in the exam.
- [ ] `GET /devices` shows the two real devices seeded.
- [ ] `card.pdf` downloads a readable 025-8 layout.
- [ ] `PLATFORM.md` matrix (#11/#12/#13) and `AGENTS.md` §1/§7 updated.

## 9. SELF-VERIFICATION LOOP (run before claiming done)
1. Re-read your diff against §5 — every field/endpoint present and named as specified?
2. Run §8 gates; if red, fix root cause (don't weaken tests).
3. Manually exercise the happy path via Swagger (`/docs`): create patient → visit →
   PUT exam → POST refraction result → apply-refraction → GET exam → card.pdf.
4. Grep for hardcoded role names, floats on money, missing audit calls — fix any.

## 10. ANTI-PATTERNS / DO-NOT
- ❌ Don't invent a new architecture, ORM style, or state-management approach.
- ❌ Don't hardcode role names in authorization logic.
- ❌ Don't use `float` for any monetary or clinical decimal.
- ❌ Don't weaken/delete an existing test to go green.
- ❌ Don't re-add `flutter_secure_storage` or any native-build-hook package.
- ❌ Don't implement real serial/HL7/DICOM I/O (stubs only this epic).
- ❌ Don't leave a 501/`TODO` where §5 asks for a working deliverable (e.g. the PDF).

## 11. EXECUTION PLAN (incremental; commit at each ✓)
1. Phase 0 recon + Phase 1 comprehension gate (post answers). ✓ *(no code commit)*
2. Patient cover fields (A1) + schema + test green. ✓ commit
3. `EyeExam` model + schemas + `features/exams.py` + tests green. ✓ commit
4. 025-8 `card.pdf` + test. ✓ commit
5. Flutter doctor card (model+repo+screen+route) — analyze/build/test green. ✓ commit
6. `Device`/`DeviceResult` + adapters + seed + tests. ✓ commit
7. `apply-refraction` wiring + test; Flutter devices screen + buttons. ✓ commit
8. Update `PLATFORM.md` + `AGENTS.md`. ✓ commit
Use clear messages; end each with the `Co-Authored-By: Claude …` trailer.

## 12. REPORTING FORMAT (how to communicate)
- **First message:** Phase 0 baseline output + Phase 1 comprehension answers + a 3–6
  line build plan. Wait only if something is broken; otherwise proceed.
- **Per checkpoint:** one line on what shipped + test result.
- **Decision log:** whenever you deviate from a default or this spec, record *what* and
  *why* (1–2 lines).
- **Final:** the §8 gate outputs, what changed, and the updated status. Be honest about
  anything deferred.

## 13. OUT OF SCOPE (later phases — do not start)
Real device protocol auto-capture (serial/USB/HL7/DICOM), IOL-power calculation,
Operations/Treatment, Inventory auto write-off, Alembic migrations, refresh tokens,
multi-doctor routing. Note them in `PLATFORM.md` if you touch adjacent code.
