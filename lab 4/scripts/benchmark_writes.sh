#!/usr/bin/env bash
set -euo pipefail

CQLSH="cqlsh 127.0.0.1 9042"
WORK_DIR="/tmp/lab4_stage3"
NORMAL_CQL="$WORK_DIR/ordinary_writes.cql"
LWT_CQL="$WORK_DIR/lwt_writes.cql"
mkdir -p "$WORK_DIR"

cat <<'CQL' | $CQLSH
CONSISTENCY QUORUM;
SERIAL CONSISTENCY SERIAL;
TRUNCATE lab4.reservations;
CQL

{
  echo 'CONSISTENCY QUORUM;'
  for i in $(seq 1 1000); do
    echo "INSERT INTO lab4.reservations (room_id, guest_name) VALUES ($i, 'ordinary_$i');"
  done
} > "$NORMAL_CQL"

{
  echo 'CONSISTENCY QUORUM;'
  echo 'SERIAL CONSISTENCY SERIAL;'
  for i in $(seq 1 1000); do
    echo "UPDATE lab4.reservations SET guest_name = 'lwt_$i' WHERE room_id = $i IF guest_name = 'ordinary_$i';"
  done
} > "$LWT_CQL"

echo '[stage3] Running 1000 ordinary writes...'
NORMAL_START="$(date +%s%3N)"
$CQLSH -f "$NORMAL_CQL" >/tmp/lab4_stage3_normal.log 2>&1
NORMAL_END="$(date +%s%3N)"

echo '[stage3] Running 1000 LWT writes...'
LWT_START="$(date +%s%3N)"
$CQLSH -f "$LWT_CQL" >/tmp/lab4_stage3_lwt.log 2>&1
LWT_END="$(date +%s%3N)"

NORMAL_MS=$((NORMAL_END - NORMAL_START))
LWT_MS=$((LWT_END - LWT_START))

echo
echo '[stage3] Client-side timing:'
printf 'ordinary_writes_ms=%s\n' "$NORMAL_MS"
printf 'lwt_writes_ms=%s\n' "$LWT_MS"
if [ "$NORMAL_MS" -gt 0 ]; then
  awk -v normal="$NORMAL_MS" -v lwt="$LWT_MS" 'BEGIN { printf "lwt_to_ordinary_ratio=%.2f\n", lwt / normal }'
fi

echo
echo '[stage3] Rows after benchmark:'
$CQLSH -e "CONSISTENCY QUORUM; SELECT COUNT(*) FROM lab4.reservations;"

echo
echo '[stage3] nodetool proxyhistograms:'
nodetool proxyhistograms
