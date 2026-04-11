#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
TOKEN="SYNC_ASYNC_DEMO_$(date +%s)"

echo "== Pgpool view =="
psql -h pgpool -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;"

echo "== Primary replication view =="
psql -h pg_a -p 5432 -U postgres -d postgres -c "SELECT application_name, state, sync_state, write_lag, flush_lag, replay_lag FROM pg_stat_replication ORDER BY application_name;"

echo "== Insert through Pgpool into primary A =="
psql -h pgpool -p 9999 -U postgres -d appdb <<SQL
BEGIN;
INSERT INTO customers (full_name, city)
VALUES ('${TOKEN}', 'Saint Petersburg');
INSERT INTO orders (customer_id, product_name, amount)
SELECT id, 'Mechanical Keyboard', 12500.00
FROM customers
WHERE full_name = '${TOKEN}';
COMMIT;
SQL

echo "== B should have the row immediately =="
psql -h pg_b -p 5432 -U postgres -d appdb -c "SELECT count(*) AS rows_on_b FROM customers WHERE full_name = '${TOKEN}';"
psql -h pg_b -p 5432 -U postgres -d appdb -c "SELECT count(*) AS orders_on_b FROM orders WHERE product_name = 'Mechanical Keyboard' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');"

echo "== C usually does NOT have it immediately =="
psql -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) AS rows_on_c_now FROM customers WHERE full_name = '${TOKEN}';"
psql -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) AS orders_on_c_now FROM orders WHERE product_name = 'Mechanical Keyboard' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');"

echo "== Waiting 12 seconds so delayed standby C can replay =="
sleep 12

psql -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) AS rows_on_c_after_delay FROM customers WHERE full_name = '${TOKEN}';"
psql -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) AS orders_on_c_after_delay FROM orders WHERE product_name = 'Mechanical Keyboard' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');"
