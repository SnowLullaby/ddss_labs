@echo off
setlocal

docker cp .\scripts\cleanup_primary_disk.sh lab3_pg_a:/tmp/cleanup_primary_disk.sh >nul
if errorlevel 1 exit /b %errorlevel%

docker compose -f "..\task1\docker-compose.yml" exec pg_a bash /tmp/cleanup_primary_disk.sh
if errorlevel 1 exit /b %errorlevel%
