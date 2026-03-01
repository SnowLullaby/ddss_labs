#!/bin/sh

PGDATA="$HOME/ejl64"

# сеть/порт
echo "port = 9437" >> "$PGDATA/postgresql.conf"
echo "listen_addresses = '*'" >> "$PGDATA/postgresql.conf"

# OLTP
echo "max_connections = 1200" >> "$PGDATA/postgresql.conf"
echo "shared_buffers = 4GB" >> "$PGDATA/postgresql.conf"
echo "temp_buffers = 1MB" >> "$PGDATA/postgresql.conf"
echo "work_mem = 1MB" >> "$PGDATA/postgresql.conf"
echo "checkpoint_timeout = 15min" >> "$PGDATA/postgresql.conf"
echo "effective_cache_size = 12GB" >> "$PGDATA/postgresql.conf"
echo "fsync = on" >> "$PGDATA/postgresql.conf"
echo "commit_delay = 2000" >> "$PGDATA/postgresql.conf"

#логи
echo "log_destination = 'csvlog'" >> "$PGDATA/postgresql.conf"
echo "logging_collector = on" >> "$PGDATA/postgresql.conf"
echo "log_directory = 'log'" >> "$PGDATA/postgresql.conf"
echo "log_filename = 'postgresql-%Y-%m-%d_%H%M%S.csv'" >> "$PGDATA/postgresql.conf"
echo "log_min_messages = error" >> "$PGDATA/postgresql.conf"
echo "log_checkpoints = on" >> "$PGDATA/postgresql.conf"
echo "log_connections = on" >> "$PGDATA/postgresql.conf"

# pg_hba.conf
: > "$PGDATA/pg_hba.conf"
echo "local all all peer" >> "$PGDATA/pg_hba.conf"
echo "host  all all 0.0.0.0/0 ident" >> "$PGDATA/pg_hba.conf"
echo "host  all all ::/0      ident" >> "$PGDATA/pg_hba.conf"
