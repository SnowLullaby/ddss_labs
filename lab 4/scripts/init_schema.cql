CREATE KEYSPACE IF NOT EXISTS lab4
WITH replication = {
  'class': 'NetworkTopologyStrategy',
  'dc1': 3
};

CREATE TABLE IF NOT EXISTS lab4.reservations (
  room_id int PRIMARY KEY,
  guest_name text
);
