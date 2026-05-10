@echo off
setlocal
cd /d "%~dp0"
echo [stage3] Initializing schema...
docker compose exec cassandra-1 cqlsh -f /lab/scripts/init_schema.cql
echo [stage3] Running ordinary writes vs LWT writes benchmark...
docker compose exec cassandra-1 bash /lab/scripts/benchmark_writes.sh
