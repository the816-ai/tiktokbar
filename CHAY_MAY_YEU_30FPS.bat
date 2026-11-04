@echo off
setlocal EnableExtensions
chcp 65001 >nul
title CHAY SAN BAR CHE DO MAY YEU 30FPS (SIEU MUOT)

set "ROOT=%~dp0"
set "BRIDGE_DIR=%ROOT%TikTokBridge"
set "BRIDGE_PORT=3000"

:: Tat ban Unity 3D neu dang chay ngam gay nang may
taskkill /F /IM TIKTOK_LIVE_BAR.exe >nul 2>&1

set "BRIDGE_READY="
for /f "usebackq delims=" %%r in (powershell -NoProfile -Command "try { $h = Invoke-RestMethod -Uri 'http://127.0.0.1:%BRIDGE_PORT%/api/health' -TimeoutSec 2; if ($h.status -eq 'ok') { 'YES' } } catch {}" ) do set "BRIDGE_READY=%%r"

if not defined BRIDGE_READY (
    start "TikTok Bridge Server" /D "%BRIDGE_DIR%" cmd /k "npm start"
    ping 127.0.0.1 -n 4 >nul
)

start "" "http://127.0.0.1:%BRIDGE_PORT%/bar.html?lite=1"
start "" "http://127.0.0.1:%BRIDGE_PORT%/control.html"
exit /b 0
