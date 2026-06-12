# Firebase — состояние и handoff для будущего агента

> Статус на 2026-06-13: **ПОДКЛЮЧЕНО** (приложение связано с проектом).
> План владельца: Firebase — облачная инфраструктура «до прихода собственного
> сервера»; когда физический сервер прибудет, БАЗА ДАННЫХ переезжает на него
> (см. «Когда придёт сервер» ниже).

## Что уже сделано (коммит этого файла)

- Firebase-проект владельца: **`kozshifo-32e6f`** (CLI авторизован на этой машине).
- `flutterfire configure --project=kozshifo-32e6f --platforms=web,android,windows`
  выполнен → сгенерирован `lib/firebase_options.dart` (закоммичен — это
  публичные client-ключи), зарегистрированы приложения:
  - web `1:379102232982:web:4ce7c6f3c58b10fe6f5db7`
  - android `1:379102232982:android:34c29ce0acfc70336f5db7`
  - windows `1:379102232982:web:7069b12e88475b476f5db7`
- `firebase_core` добавлен в pubspec (**build_runner проверен — жив**, гейт
  AGENTS.md §6 пройден). Инициализация в `lib/main.dart` — best-effort
  try/catch: недоступный Firebase никогда не блокирует запуск клиники.
- Повторная привязка/обновление конфигов: `flutterfire configure --project=kozshifo-32e6f`.

## Что НЕ сделано (следующие шаги, по команде владельца)

1. **FCM push-уведомления**: `flutter pub add firebase_messaging` (СНАЧАЛА
   прогнать `dart run build_runner build` — §6!), приём токена на клиенте,
   endpoint регистрации токенов (новая таблица `user_device_tokens` +
   alembic-ревизия: server_default на NOT NULL непустых таблиц, именованные
   FK в batch-режиме), серверная отправка `firebase-admin` в
   `backend/requirements.txt` как ТРЕТИЙ канал в `backend/app/core/notify.py`
   (копировать паттерн `_deliver_telegram`: строка status="queued" → доставка
   в daemon-потоке; service-account JSON ТОЛЬКО через env + прод-гард в
   `config._production_guards`, как SECRET_KEY).
2. **Hosting** web-сборки (`firebase deploy` из `build/web`) — если владелец
   решит публиковать web-клиент через Firebase Hosting; CORS_ORIGINS бэкенда
   дополнить доменом хостинга.

## Когда придёт собственный сервер (план переезда БД)

1. На сервере: Docker-хост → `docker compose up --build` (repo-root compose:
   api + Postgres 16; обязательные env: SECRET_KEY, SEED_DIRECTOR_PASSWORD —
   compose падает без них, приложение перепроверяет на старте).
2. Перенос данных: текущая dev-БД — SQLite (`backend/kozshifo.db`);
   прод-схему создаёт `alembic upgrade head` (ревизии полные, `alembic check`
   чист). Данные мигрировать дампом SQLite → Postgres (или начать с чистого
   сида — решает владелец; сид идемпотентен).
3. Flutter-клиенты: `--dart-define=API_BASE_URL=https://<сервер>` (см.
   `lib/core/constants/api_constants.dart`); ТВ-табло: `http://<сервер>:8000/tv/<branch_id>`.
4. Firebase остаётся для push/hosting — БД в Firebase НЕ живёт (бэкенд —
   FastAPI+Postgres, это архитектурное решение платформы).

## Точки кода (карта)

| Точка | Файл |
|---|---|
| Firebase init | `lib/main.dart` (best-effort) |
| Сгенерированные ключи | `lib/firebase_options.dart` (regenerate: flutterfire configure) |
| Шов провайдеров уведомлений | `backend/app/core/notify.py` |
| События, которые уже шлются | low_stock (`core/notify.check_low_stock`), критичные инсайты (`features/dashboard._notify_critical_insights`) |
| env-настройки | `backend/app/core/config.py`, `backend/.env.example`, `docker-compose.yml` |
