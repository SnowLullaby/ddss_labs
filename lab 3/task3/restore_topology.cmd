@echo off
setlocal

echo [1/5] Stopping pgpool during topology repair...
docker compose -f "..\task1\docker-compose.yml" stop pgpool
if errorlevel 1 exit /b %errorlevel%

echo [2/5] Promoting pg_a back to primary and creating slots...
docker compose -f "..\task1\docker-compose.yml" exec -T -u postgres pg_a bash -s < .\scripts\promote_pg_a_and_create_slots.sh
if errorlevel 1 exit /b %errorlevel%

echo [3/5] Rejoining pg_b to pg_a with pg_rewind...
docker compose -f "..\task1\docker-compose.yml" exec -T -u postgres ^
  -e PRIMARY_HOST=pg_a ^
  -e REPLICATION_SLOT=slot_b ^
  -e STANDBY_NAME=pg_b ^
  -e APPLY_DELAY=0s ^
  pg_b bash -s < .\scripts\rejoin_with_rewind.sh
if errorlevel 1 exit /b %errorlevel%

echo [4/5] Rejoining pg_c to pg_a with pg_rewind...
docker compose -f "..\task1\docker-compose.yml" exec -T -u postgres ^
  -e PRIMARY_HOST=pg_a ^
  -e REPLICATION_SLOT=slot_c ^
  -e STANDBY_NAME=pg_c ^
  -e APPLY_DELAY=10s ^
  pg_c bash -s < .\scripts\rejoin_with_rewind.sh
if errorlevel 1 exit /b %errorlevel%

echo [5/5] Starting pgpool again...
docker compose -f "..\task1\docker-compose.yml" up -d pgpool
if errorlevel 1 exit /b %errorlevel%

echo Done. Wait a bit, then run:
echo verify_stage3.cmd
