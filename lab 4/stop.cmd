@echo off
setlocal
cd /d "%~dp0"
echo [lab4] Stopping Cassandra cluster...
docker compose stop
