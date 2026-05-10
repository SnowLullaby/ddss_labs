#!/usr/bin/env bash
set -euo pipefail

CQLSH="cqlsh 127.0.0.1 9042"
RESULT_DIR="/tmp/lab4_stage2_results"
mkdir -p "$RESULT_DIR"
rm -f "$RESULT_DIR"/*.log

cat <<'CQL' | $CQLSH
CONSISTENCY QUORUM;
SERIAL CONSISTENCY SERIAL;
TRUNCATE lab4.reservations;
INSERT INTO lab4.reservations (room_id, guest_name)
VALUES (1, 'Alice')
IF NOT EXISTS;
SELECT * FROM lab4.reservations WHERE room_id = 1;
CQL

echo
echo '[stage2] Starting 12 parallel LWT updates for the same row.'
echo '[stage2] Every query tries to update guest_name only if it is still Alice.'
echo

START_MS="$(date +%s%3N)"
for i in $(seq 1 12); do
  (
    NAME="Guest_${i}"
    LOG="$RESULT_DIR/client_${i}.log"
    T1="$(date +%s%3N)"
    {
      echo "client=$i"
      echo "candidate=$NAME"
      echo "query=UPDATE lab4.reservations SET guest_name = '$NAME' WHERE room_id = 1 IF guest_name = 'Alice';"
      echo
      $CQLSH -e "CONSISTENCY QUORUM; SERIAL CONSISTENCY SERIAL; UPDATE lab4.reservations SET guest_name = '$NAME' WHERE room_id = 1 IF guest_name = 'Alice';"
      RC=$?
      echo
      echo "exit_code=$RC"
    } >"$LOG" 2>&1 || true
    T2="$(date +%s%3N)"
    echo "duration_ms=$((T2 - T1))" >>"$LOG"
  ) &
done
wait
END_MS="$(date +%s%3N)"

echo '[stage2] Results by client:'
for f in "$RESULT_DIR"/*.log; do
  echo '------------------------------------------------------------'
  cat "$f"
done

echo '------------------------------------------------------------'
echo "[stage2] total_duration_ms=$((END_MS - START_MS))"
echo

echo '[stage2] Final row value:'
$CQLSH -e "CONSISTENCY QUORUM; SELECT * FROM lab4.reservations WHERE room_id = 1;"

echo
echo '[stage2] One optional traced LWT request. The trace output shows extra coordination work for a CAS/LWT query.'
cat <<'CQL' | $CQLSH
CONSISTENCY QUORUM;
SERIAL CONSISTENCY SERIAL;
TRACING ON;
UPDATE lab4.reservations
SET guest_name = 'TraceGuest'
WHERE room_id = 1
IF guest_name = 'Alice';
TRACING OFF;
CQL
