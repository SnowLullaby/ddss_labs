#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
export PAGER=cat
TOKEN="RESTORE_STAGE3_$(date +%s)"

printf '== Pgpool nodes after restore ==\n'
psql -P pager=off -x -h pgpool -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;"

printf '== Replication state on restored primary A ==\n'
psql -P pager=off -x -h pg_a -p 5432 -U postgres -d postgres -c "SELECT application_name, state, sync_state FROM pg_stat_replication ORDER BY application_name;"

printf '== Recovery status of all nodes ==\n'
echo "pg_a_recovery=$(psql -P pager=off -t -A -h pg_a -p 5432 -U postgres -d postgres -c "SELECT pg_is_in_recovery();")"
echo "pg_b_recovery=$(psql -P pager=off -t -A -h pg_b -p 5432 -U postgres -d postgres -c "SELECT pg_is_in_recovery();")"
echo "pg_c_recovery=$(psql -P pager=off -t -A -h pg_c -p 5432 -U postgres -d postgres -c "SELECT pg_is_in_recovery();")"

printf '== Test write through pgpool after full restore ==\n'
psql -v ON_ERROR_STOP=1 -P pager=off -h pgpool -p 9999 -U postgres -d appdb <<SQL
BEGIN;
INSERT INTO customers (full_name, city) VALUES ('${TOKEN}', 'Stage3');
INSERT INTO orders (customer_id, product_name, amount)
SELECT id, 'Stage3 restore check', 3333.00 FROM customers WHERE full_name = '${TOKEN}';
COMMIT;
SQL

printf '== Verify synchronous standby B ==\n'
echo "rows_on_b=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_b -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")"
echo "orders_on_b=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_b -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM orders WHERE product_name = 'Stage3 restore check' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');")"

printf '== Verify delayed standby C immediately ==\n'
echo "rows_on_c_now=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")"
echo "orders_on_c_now=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM orders WHERE product_name = 'Stage3 restore check' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');")"

printf '== Waiting 12 seconds for delayed standby C ==\n'
sleep 12

echo "rows_on_c_after_delay=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")"
echo "orders_on_c_after_delay=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM orders WHERE product_name = 'Stage3 restore check' AND customer_id IN (SELECT id FROM customers WHERE full_name = '${TOKEN}');")"

printf '== All customers on A ==\n'
psql -P pager=off -h pg_a -p 5432 -U postgres -d appdb -c "SELECT * FROM customers ORDER BY id;"

printf '== All customers on B ==\n'
psql -P pager=off -h pg_b -p 5432 -U postgres -d appdb -c "SELECT * FROM customers ORDER BY id;"

printf '== All customers on C ==\n'
psql -P pager=off -h pg_c -p 5432 -U postgres -d appdb -c "SELECT * FROM customers ORDER BY id;"
