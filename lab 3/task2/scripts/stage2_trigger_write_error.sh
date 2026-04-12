#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
TOKEN="DISK_FULL_$(date +%s)"

printf '== Attempting large write through pgpool after disk fill ==\n'
set +e
output=$(psql -v ON_ERROR_STOP=1 -P pager=off -h pgpool -p 9999 -U postgres -d appdb 2>&1 <<SQL
BEGIN;
INSERT INTO customers (full_name, city)
SELECT '${TOKEN}_' || g || repeat('X', 2048),
       repeat('Y', 2048)
FROM generate_series(1, 5000) AS g;
COMMIT;
SQL
)
rc=$?
set -e

printf '%s\n' "$output"
echo "psql_exit_code=$rc"
