@echo off
rem KO'Z SHIFO — запуск backend одним кликом (http://127.0.0.1:8000, Swagger: /docs)
cd /d "%~dp0backend"
echo Starting KO'Z SHIFO backend on http://127.0.0.1:8000 ...
".venv\Scripts\python.exe" -m uvicorn app.main:app --port 8000
pause
