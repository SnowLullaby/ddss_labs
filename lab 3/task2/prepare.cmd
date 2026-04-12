@echo off
setlocal

docker cp .\scripts\stage2_prepare.sh lab3_client:/tmp/stage2_prepare.sh >nul
if errorlevel 1 exit /b %errorlevel%

docker compose -f "..\task1\docker-compose.yml" exec client bash /tmp/stage2_prepare.sh
if errorlevel 1 exit /b %errorlevel%
