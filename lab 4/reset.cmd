@echo off
setlocal
cd /d "%~dp0"
echo [lab4] Removing containers, network and volumes...
docker compose down -v --remove-orphans
