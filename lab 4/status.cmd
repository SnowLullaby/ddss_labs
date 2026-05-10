@echo off
setlocal
cd /d "%~dp0"
echo [lab4] Docker containers:
docker compose ps
echo.
echo [lab4] Cassandra nodetool status:
docker compose exec cassandra-1 nodetool status
echo.
echo [lab4] Schema agreement check:
docker compose exec cassandra-1 nodetool describecluster
