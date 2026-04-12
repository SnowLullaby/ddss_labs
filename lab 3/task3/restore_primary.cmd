@echo off
setlocal

if exist current_primary.txt del /f /q current_primary.txt >nul 2>nul

echo [1/3] Detecting current primary through pgpool...
docker compose -f "..\task1\docker-compose.yml" exec -T client bash -s < .\scripts\detect_current_primary.sh > current_primary.txt
if errorlevel 1 exit /b %errorlevel%

set /p CURRENT_PRIMARY=<current_primary.txt
del /f /q current_primary.txt >nul 2>nul

if "%CURRENT_PRIMARY%"=="" (
  echo ERROR: could not determine current primary
  exit /b 1
)

echo Current primary is %CURRENT_PRIMARY%

echo [2/3] Rejoining pg_a to %CURRENT_PRIMARY% with pg_rewind...
docker compose -f "..\task1\docker-compose.yml" exec -T -u postgres ^
  -e PRIMARY_HOST=%CURRENT_PRIMARY% ^
  -e REPLICATION_SLOT= ^
  -e STANDBY_NAME=pg_a_restore ^
  -e APPLY_DELAY=0s ^
  pg_a bash -s < .\scripts\rejoin_with_rewind.sh
if errorlevel 1 exit /b %errorlevel%

echo [3/3] Checking that pg_a is back as standby...
docker compose -f "..\task1\docker-compose.yml" exec -T client bash -lc "PGPASSWORD=postgres psql -P pager=off -x -h pg_a -p 5432 -U postgres -d postgres -c 'SELECT pg_is_in_recovery() AS a_is_in_recovery;'"
if errorlevel 1 exit /b %errorlevel%

echo Done. Then run:
echo restore_topology.cmd
