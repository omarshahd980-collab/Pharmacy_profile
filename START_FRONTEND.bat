@echo off
setlocal EnableExtensions
cd /d "%~dp0"
where py >nul 2>&1
if errorlevel 1 (
  echo [ERROR] Python Launcher (py) is not installed or not on PATH.
  pause
  exit /b 1
)
powershell -NoProfile -ExecutionPolicy Bypass -Command "try { $r=Invoke-WebRequest -UseBasicParsing -Uri 'http://127.0.0.1:5500/' -TimeoutSec 2; if ($r.StatusCode -eq 200) { Write-Host '[OK] Frontend is already running.'; exit 0 } } catch {}; exit 1" >nul 2>&1
if not errorlevel 1 (
  echo [OK] Frontend is already running on http://127.0.0.1:5500
  pause
  exit /b 0
)
py -3 -m http.server 5500 --bind 127.0.0.1 --directory "%~dp0frontend"
