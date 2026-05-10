@echo off
setlocal
cd /d "%~dp0"
echo [stage4] Initializing schema and test row...
docker compose exec cassandra-1 cqlsh -f /lab/scripts/init_schema.cql
docker compose exec cassandra-1 cqlsh -e "CONSISTENCY QUORUM; SERIAL CONSISTENCY SERIAL; TRUNCATE lab4.reservations; INSERT INTO lab4.reservations (room_id, guest_name) VALUES (1, 'Alice') IF NOT EXISTS;"

echo.
echo [stage4] Current cluster status:
docker compose exec cassandra-1 nodetool status

echo.
echo [stage4] Stopping cassandra-3. Two replicas should remain alive, quorum is still available.
docker compose stop cassandra-3
docker compose exec cassandra-1 nodetool status

echo.
echo [stage4] LWT with 2 alive nodes. Expected: success or normal conditional result.
docker compose exec cassandra-1 cqlsh -e "CONSISTENCY QUORUM; SERIAL CONSISTENCY SERIAL; UPDATE lab4.reservations SET guest_name = 'Bob' WHERE room_id = 1 IF guest_name = 'Alice';"

echo.
echo [stage4] Stopping cassandra-2. Only one replica remains alive, quorum is unavailable.
docker compose stop cassandra-2
docker compose exec cassandra-1 nodetool status

echo.
echo [stage4] LWT with 1 alive node. Expected: Unavailable/timeout because quorum cannot be reached.
docker compose exec cassandra-1 cqlsh -e "CONSISTENCY QUORUM; SERIAL CONSISTENCY SERIAL; UPDATE lab4.reservations SET guest_name = 'Charlie' WHERE room_id = 1 IF guest_name = 'Bob';"

echo.
echo [stage4] Last relevant logs from cassandra-1:
docker compose logs --tail=120 cassandra-1 | findstr /I "UnavailableException unavailable timeout cas paxos quorum serial" || echo No matching log lines were found. The cqlsh error above is enough for the conclusion.
