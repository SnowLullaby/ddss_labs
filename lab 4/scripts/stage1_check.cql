CONSISTENCY QUORUM;
SERIAL CONSISTENCY SERIAL;

TRUNCATE lab4.reservations;

INSERT INTO lab4.reservations (room_id, guest_name)
VALUES (1, 'Alice')
IF NOT EXISTS;

INSERT INTO lab4.reservations (room_id, guest_name)
VALUES (1, 'Bob')
IF NOT EXISTS;

SELECT * FROM lab4.reservations WHERE room_id = 1;

-- Data synchronization check for the lab:
-- with replication_factor = 3, CONSISTENCY ALL requires all three replicas to answer.
CONSISTENCY ALL;
SELECT * FROM lab4.reservations WHERE room_id = 1;
