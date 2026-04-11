#!/usr/bin/env bash
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username postgres --dbname postgres <<'SQL'
SET password_encryption = 'scram-sha-256';
ALTER ROLE postgres WITH PASSWORD 'postgres';
CREATE ROLE replicator WITH REPLICATION LOGIN PASSWORD 'replicator';
CREATE DATABASE appdb OWNER postgres;
SELECT pg_create_physical_replication_slot('slot_b');
SELECT pg_create_physical_replication_slot('slot_c');
SQL

psql -v ON_ERROR_STOP=1 --username postgres --dbname appdb <<'SQL'
CREATE TABLE customers (
    id BIGSERIAL PRIMARY KEY,
    full_name TEXT NOT NULL,
    city TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE orders (
    id BIGSERIAL PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES customers(id),
    product_name TEXT NOT NULL,
    amount NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

INSERT INTO customers (full_name, city)
VALUES ('Alice', 'Saint Petersburg'),
       ('Bob', 'Moscow');

INSERT INTO orders (customer_id, product_name, amount)
VALUES (1, 'Laptop', 120000.00),
       (2, 'Phone', 70000.00);
SQL

cp /etc/postgresql/custom/postgresql.conf "$PGDATA/postgresql.conf"
cp /etc/postgresql/custom/pg_hba.conf "$PGDATA/pg_hba.conf"
