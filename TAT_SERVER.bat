@echo off
chcp 65001 >nul
echo Dang tat TikTok Bridge Server va Game 3D...
taskkill /F /IM TIKTOK_LIVE_BAR.exe >nul 2>&1
taskkill /F /IM OngChuMMO_Live.exe >nul 2>&1
powershell -NoProfile -Command "Get-CimInstance Win32_Process -Filter \"Name = 'node.exe'\" | Where-Object { $_.CommandLine -like '*server.js*' -or $_.CommandLine -like '*TikTokBridge*' } | ForEach-Object { Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue }"
echo Da tat hoan toan Server va Game!
timeout /t 2 >nul