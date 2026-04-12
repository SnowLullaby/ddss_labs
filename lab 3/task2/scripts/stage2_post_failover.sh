#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
export PAGER=cat
TOKEN="POST_FAILOVER_$(date +%s)"

printf '== Pgpool nodes after failover ==\n'
psql -P pager=off -x -h pgpool -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;"

NEW_PRIMARY="pg_b"
if [ "$(psql -P pager=off -t -A -h pg_b -p 5432 -U postgres -d postgres -c "SELECT pg_is_in_recovery();")" = "t" ]; then
  NEW_PRIMARY="pg_c"
fi

printf '== Role check on new primary ==\n'
psql -P pager=off -x -h "$NEW_PRIMARY" -p 5432 -U postgres -d postgres -c "SELECT pg_is_in_recovery() AS is_in_recovery;"

printf '== Write through pgpool after failover ==\n'
psql -v ON_ERROR_STOP=1 -P pager=off -h pgpool -p 9999 -U postgres -d appdb <<SQL
BEGIN;
INSERT INTO customers (full_name, city) VALUES ('${TOKEN}', 'After failover');
INSERT INTO orders (customer_id, product_name, amount)
SELECT id, 'Post-failover write', 77.00 FROM customers WHERE full_name = '${TOKEN}';
COMMIT;
SQL

printf '== Verify data on new primary ==\n'
echo "rows_on_${NEW_PRIMARY}=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h "$NEW_PRIMARY" -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")"
echo "orders_on_${NEW_PRIMARY}=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h "$NEW_PRIMARY" -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM orders WHERE product_name = 'Post-failover write' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');")"
