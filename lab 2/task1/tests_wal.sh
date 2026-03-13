#!/bin/sh

psql -p 9437 -d postgres -c "SHOW wal_level;"
psql -p 9437 -d postgres -c "SHOW archive_mode;"
psql -p 9437 -d postgres -c "SHOW archive_command;"

psql -p 9437 -d longpinksoup -c "INSERT INTO client(name) VALUES ('wal_test');"
psql -p 9437 -d postgres -c "SELECT pg_switch_wal();"

sleep 2

psql -p 9437 -d postgres -c "SELECT archived_count, failed_count, last_archived_wal FROM pg_stat_archiver;"
ssh postgres1@pg155 'ls -1 ~/lr2_backups/wal | tail'