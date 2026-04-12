#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres
export PAGER=cat
TOKEN="STAGE2_PREP_$(date +%s)"

printf '== Pgpool nodes before failure ==\n'
psql -P pager=off -x -h pgpool -p 9999 -U postgres -d postgres -c "SHOW pool_nodes;"

printf '== Replication state on primary ==\n'
psql -P pager=off -x -h pg_a -p 5432 -U postgres -d postgres -c "SELECT application_name, state, sync_state FROM pg_stat_replication ORDER BY application_name;"

printf '== Client session 1: write through pgpool ==\n'
PGAPPNAME=session_writer psql -v ON_ERROR_STOP=1 -P pager=off -h pgpool -p 9999 -U postgres -d appdb <<SQL
BEGIN;
INSERT INTO customers (full_name, city) VALUES ('${TOKEN}', 'Saint Petersburg');
INSERT INTO orders (customer_id, product_name, amount)
SELECT id, 'Stage2 precheck', 5000.00 FROM customers WHERE full_name = '${TOKEN}';
COMMIT;
SQL

printf '== Client session 2: read through pgpool ==\n'
rows_via_pgpool=$(PGAPPNAME=session_reader_a psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pgpool -p 9999 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")
echo "rows_via_pgpool=$rows_via_pgpool"

printf '== Client session 3: direct read from synchronous standby B ==\n'
rows_on_b=$(PGAPPNAME=session_reader_b psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_b -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")
echo "rows_on_b=$rows_on_b"

printf '== Direct read from delayed standby C (0 before delay) ==\n'
rows_on_c_now=$(psql -v ON_ERROR_STOP=1 -P pager=off -t -A -h pg_c -p 5432 -U postgres -d appdb -c "SELECT count(*) FROM customers WHERE full_name = '${TOKEN}';")
echo "rows_on_c_now=$rows_on_c_now"
