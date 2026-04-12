@echo off
setlocal

docker compose -f "..\task1\docker-compose.yml" logs --since 10m pg_a pgpool pg_b pg_c | findstr /I /C:"No space left on device" /C:"ERROR" /C:"FATAL" /C:"PANIC" /C:"terminating connection due to administrator command" /C:"could not"
