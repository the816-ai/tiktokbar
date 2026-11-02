@echo off
setlocal EnableExtensions EnableDelayedExpansion
chcp 65001 >nul
title CAI DAT VA KHOI CHAY SAN BAR 3D LIVE (1-CLICK)

set "ROOT=%~dp0"
set "BRIDGE_DIR=%ROOT%TikTokBridge"
set "BRIDGE_PORT=3000"

echo ===========================================================
echo    SAN BAR 3D LIVE - TU DONG CAI DAT VA CHAY (1-CLICK)
echo ===========================================================
echo.

:: [1/4] Kiem tra va tu dong cai Node.js neu may chua co
where node >nul 2>&1
if errorlevel 1 (
    if exist "%ProgramFiles%\nodejs\node.exe" (
        set "PATH=%ProgramFiles%\nodejs;%PATH%"
    )
)

where node >nul 2>&1
if errorlevel 1 (
    echo [1/4] May chua co Node.js. Dang tu dong tai va cai Node.js LTS...
    where winget >nul 2>&1
    if not errorlevel 1 (
        winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements --silent
    ) else (
        echo Dang tai bo cai Node.js LTS truc tiep tu nodejs.org...
        powershell -NoProfile -ExecutionPolicy Bypass -Command "$msi = Join-Path $env:TEMP 'node-lts.msi'; Invoke-WebRequest -Uri 'https://nodejs.org/dist/v20.18.0/node-v20.18.0-x64.msi' -OutFile $msi; Start-Process msiexec.exe -ArgumentList '/i', $msi, '/qn', '/norestart' -Wait"
    )
    if exist "%ProgramFiles%\nodejs\node.exe" (
        set "PATH=%ProgramFiles%\nodejs;%PATH%"
    )
)

where node >nul 2>&1
if errorlevel 1 (
    echo [LOI] Khong the tu dong cai Node.js ^(can quyen Admin^).
    echo Hay nhap chuot phai vao file nay chon "Run as administrator" hoac cai tu https://nodejs.org/
    goto :failed
)
for /f "delims=" %%v in ('node -v') do echo [1/4] Node.js da san sang ^(%%v^).

:: [2/4] Kiem tra file .env va thu vien npm
if not exist "%BRIDGE_DIR%\.env" (
    if exist "%BRIDGE_DIR%\.env.example" (
        copy /Y "%BRIDGE_DIR%\.env.example" "%BRIDGE_DIR%\.env" >nul
    )
)

if not exist "%BRIDGE_DIR%\node_modules\express\package.json" (
    echo [2/4] Dang tu dong cai thu vien Node.js...
    pushd "%BRIDGE_DIR%"
    if exist package-lock.json (
        call npm ci
    ) else (
        call npm install
    )
    if errorlevel 1 (
        popd
        echo [LOI] Cai thu vien npm khong thanh cong.
        goto :failed
    )
    popd
) else (
    echo [2/4] Thu vien Node.js da co san.
)

:: [3/4] Dong bo anh san Bar sang o D: (neu co o D:) cho ban Unity 3D
echo [3/4] Dang dong bo tai nguyen San Bar...
if exist "D:\" (
    if exist "%ROOT%LiveAssets\nenamphu.png" (
        xcopy "%ROOT%LiveAssets" "D:\TIKTOK_LIVE_BAR\LiveAssets\" /E /I /Y >nul 2>&1
    )
)

:: [4/4] Khoi dong TikTok Bridge Server + Web San Bar + Game 3D
set "CONTROL_URL=http://127.0.0.1:%BRIDGE_PORT%/control.html"
set "BAR_URL=http://127.0.0.1:%BRIDGE_PORT%/bar.html"

call :bridge_is_ready
if defined BRIDGE_READY (
    echo [4/4] Server dang chay san tren cong %BRIDGE_PORT%.
    goto :launch_all
)

echo [4/4] Dang khoi dong TikTok Bridge Server...
start "TikTok Bridge Server" /D "%BRIDGE_DIR%" cmd /k "npm start"

set "BRIDGE_READY="
for /l %%i in (1,1,25) do (
    if not defined BRIDGE_READY (
        call :bridge_is_ready
        if not defined BRIDGE_READY ping 127.0.0.1 -n 2 >nul
    )
)

:launch_all
if exist "%ROOT%Build\TIKTOK_LIVE_BAR.exe" (
    start "" "%ROOT%Build\TIKTOK_LIVE_BAR.exe"
)
start "" "%BAR_URL%"
start "" "%CONTROL_URL%"

echo.
echo ===========================================================
echo   HOAN TAT! DA MO SAN BAR TREN WEB VA GAME 3D:
echo   - Web San Bar    : %BAR_URL%
echo   - Bang Dieu Khien: %CONTROL_URL%
echo   - Muon tat toan bo: Nhap dup file TAT_SERVER.bat
echo ===========================================================
exit /b 0

:bridge_is_ready
set "BRIDGE_READY="
for /f "usebackq delims=" %%r in (`powershell -NoProfile -Command "try { $h = Invoke-RestMethod -Uri 'http://127.0.0.1:%BRIDGE_PORT%/api/health' -TimeoutSec 2; if ($h.status -eq 'ok' -and $h.appId -eq 'ongchu-mmo-live-bridge') { 'YES' } } catch {}"`) do set "BRIDGE_READY=%%r"
exit /b 0

:failed
echo.
pause
exit /b 1