@echo off
setlocal EnableExtensions
cd /d "%~dp0backend"
call START_BACKEND.bat
exit /b %ERRORLEVEL%
