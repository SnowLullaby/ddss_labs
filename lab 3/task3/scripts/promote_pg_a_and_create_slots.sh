#!/usr/bin/env bash
set -euo pipefail

export PGPASSWORD=postgres

psql -v ON_ERROR_STOP=1 -U postgres -d postgres -c "SELECT pg_promote(wait_seconds => 60);"

until psql -tAc "select not pg_is_in_recovery()" -U postgres -d postgres | grep -qx t; do
  sleep 1
done

psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<'SQL'
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'slot_b') THEN
    PERFORM pg_create_physical_replication_slot('slot_b');
  END IF;

  IF NOT EXISTS (SELECT 1 FROM pg_replication_slots WHERE slot_name = 'slot_c') THEN
    PERFORM pg_create_physical_replication_slot('slot_c');
  END IF;
END $$;
SQL
