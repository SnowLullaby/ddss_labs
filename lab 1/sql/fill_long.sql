SET ROLE soup;

DROP TABLE IF EXISTS pay;
DROP TABLE IF EXISTS client;

CREATE TABLE client (
  id   serial PRIMARY KEY,
  name text NOT NULL
);

CREATE TABLE pay (
  id      serial PRIMARY KEY,
  client  int NOT NULL REFERENCES client(id),
  payload text NOT NULL
);

INSERT INTO client(name)
SELECT 'lp' || g FROM generate_series(1, 20) g;

BEGIN; INSERT INTO pay(client, payload) VALUES (1, repeat('l', 24000)); COMMIT;
BEGIN; INSERT INTO pay(client, payload) VALUES (2, repeat('l', 24000)); COMMIT;
BEGIN; INSERT INTO pay(client, payload) VALUES (3, repeat('l', 24000)); COMMIT;
BEGIN; INSERT INTO pay(client, payload) VALUES (4, repeat('l', 24000)); COMMIT;
BEGIN; INSERT INTO pay(client, payload) VALUES (5, repeat('l', 24000)); COMMIT;

SET temp_tablespaces = 'uvx79';
CREATE TEMP TABLE bucket(x int);

SET temp_tablespaces = 'hqj18';
CREATE TEMP TABLE stash(x int);

INSERT INTO bucket SELECT count(*) FROM pay;
INSERT INTO stash SELECT sum(length(payload)) FROM pay;

SELECT count(*) AS buckets FROM bucket;
SELECT count(*) AS stashes FROM stash;

SELECT count(*) AS clients FROM client;
SELECT count(*) AS payments FROM pay;

RESET ROLE;