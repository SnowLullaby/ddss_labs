@echo off
setlocal

docker compose -f "..\task1\docker-compose.yml" exec -T client bash -s < .\scripts\verify_stage3.sh
if errorlevel 1 exit /b %errorlevel%
