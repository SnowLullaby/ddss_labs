@echo off
setlocal
cd /d "%~dp0"
echo [stage2] Initializing schema...
docker compose exec cassandra-1 cqlsh -f /lab/scripts/init_schema.cql
echo [stage2] Running parallel LWT race...
docker compose exec cassandra-1 bash /lab/scripts/lwt_race.sh
