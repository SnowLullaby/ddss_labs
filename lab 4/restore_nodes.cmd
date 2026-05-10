@echo off
setlocal
cd /d "%~dp0"
echo [lab4] Restoring cassandra-2 and cassandra-3...
docker compose up -d cassandra-2 cassandra-3
echo [lab4] Waiting for cluster readiness...
docker compose exec cassandra-1 bash /lab/scripts/wait_for_cluster.sh
