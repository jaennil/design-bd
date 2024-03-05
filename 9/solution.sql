-- 1
SELECT DISTINCT departure_city, arrival_city
FROM routes
NATURAL JOIN aircrafts
WHERE model = 'Boeing 777-300';

-- 2
SELECT departure_city, arrival_city
FROM routes
	NATURAL JOIN aircrafts
WHERE model = 'Boeing 777-300' AND
	departure_city < arrival_city
UNION
SELECT arrival_city, departure_city
FROM routes
	NATURAL JOIN aircrafts
WHERE model = 'Boeing 777-300' AND
	departure_city > arrival_city;

-- 3
SELECT DISTINCT arrival_city, COUNT(*) OVER (
	PARTITION BY arrival_city, departure_city) count
FROM routes
WHERE departure_city = 'Moscow' AND
	array_length(days_of_week, 1) = 7
ORDER BY count DESC
LIMIT 5;

-- 4
SELECT days_description.string day_of_week, count
FROM (
	SELECT unnest(days_of_week) AS day_of_week, COUNT(*) count
	FROM routes
	WHERE departure_city = 'Moscow'
	GROUP BY day_of_week
)
NATURAL JOIN (
	SELECT
		unnest(ARRAY[1,2,3,4,5,6,7]) day_of_week,
		unnest(ARRAY['monday', 'tuesday', 'wednesday', 'thursday', 'friday', 'saturday', 'sunday']) string
) days_description;

-- 5
SELECT departure_city, arrival_city, MAX(amount), MIN(amount)
FROM flights_v
NATURAL JOIN ticket_flights
GROUP BY departure_city, arrival_city
ORDER BY departure_city, arrival_city;

-- 6
SELECT departure_city, arrival_city
FROM flights_v
NATURAL LEFT JOIN ticket_flights
GROUP BY departure_city, arrival_city
HAVING COUNT(amount) = 0;

-- 7
SELECT SPLIT_PART(passenger_name, ' ', 1) firstname, COUNT(*)
FROM tickets
GROUP BY firstname;

-- 8
SELECT COUNT(*)
FROM (SELECT DISTINCT city FROM airports) a
JOIN (SELECT DISTINCT city FROM airports) b
ON a.city <> b.city;

-- 9
SELECT COUNT(*)
FROM bookings
WHERE total_amount > (
	SELECT AVG(total_amount) FROM bookings
);

-- 10
SELECT *
FROM routes
WHERE departure_city IN (
	SELECT city:
	FROM airports
	WHERE timezone ~ 'Asia/Krasnoyarsk'
)
AND arrival_city IN (
	SELECT city
	FROM airports
	WHERE timezone ~ 'Asia/Krasnoyarsk'
);

-- 11
SELECT *
FROM airports
WHERE coordinates[0] IN (
	(SELECT MAX(coordinates[0]) FROM airports),
	(SELECT MIN(coordinates[0]) FROM airports)
);

-- 12
SELECT city
FROM airports
WHERE NOT EXISTS (
	SELECT 1
	FROM routes
	WHERE departure_city = 'Moscow'
		AND arrival_city = airports.city
	)
	AND city <> 'Moscow';

-- 13
SELECT
	DISTINCT model,
	COUNT(*) FILTER(WHERE fare_conditions='Business') OVER (
		PARTITION BY aircraft_code
	) business,
	COUNT(*) FILTER(WHERE fare_conditions='Comfort') OVER (
		PARTITION BY aircraft_code
	) comfort,
	COUNT(*) FILTER(WHERE fare_conditions='Economy') OVER (
		PARTITION BY aircraft_code
	) economy
FROM seats
NATURAL JOIN aircrafts;

-- 14
SELECT city, airport_code, airport_name
FROM (
	SELECT city
	FROM airports
	GROUP BY city
	HAVING COUNT(airport_name) > 1
)
NATURAL JOIN airports;

-- 15
SELECT departure_airport, departure_city, COUNT(*)
FROM routes
GROUP BY departure_city, departure_airport
HAVING departure_airport IN (
	SELECT airport_code
	FROM airports
	WHERE coordinates[0] > 150
);

-- 16
SELECT flight_id, passengers::numeric / seats_amount::numeric
FROM
(
	SELECT flight_id, COUNT(seats) seats_amount
	FROM flights
	NATURAL JOIN aircrafts
	NATURAL JOIN seats
	GROUP BY flight_id
)
JOIN (
	SELECT flight_id, COUNT(ticket_no) passengers
	FROM flights
	NATURAL JOIN ticket_flights
	GROUP BY flight_id
) USING(flight_id);

-- 17
SELECT seat_no, passenger_name, fare_conditions
FROM ticket_flights
NATURAL JOIN tickets
NATURAL JOIN boarding_passes
WHERE flight_id = 2;

-- 18
CREATE OR REPLACE FUNCTION booking(book_no bookings.book_ref%type)
	returns table (
		book_ref bookings.book_ref%type,
		book_date bookings.book_date%type,
		total_amount bookings.total_amount%type
	)
	language plpgsql
	AS
	$$
	begin
		return query
			SELECT bookings.book_ref, bookings.book_date, bookings.total_amount
			FROM bookings
			WHERE bookings.book_ref = book_no;
	end;
	$$
;

SELECT * FROM booking('000004');

-- 19
CREATE OR REPLACE PROCEDURE create_booking(source_city airports.city%TYPE, destination_city airports.city%TYPE, date DATE)
LANGUAGE plpgsql
AS $$
DECLARE
	flight_id INT;
	new_book_ref VARCHAR(6);
BEGIN
		
	SELECT INTO new_book_ref concat('_', (SELECT COUNT(*)%100000 FROM bookings));

	SELECT f1.flight_id
	INTO flight_id
	FROM flights_v f1, flights_v f2
	WHERE f1.departure_city = destination_city AND
		f1.arrival_city = f2.departure_city AND
		f2.arrival_city = destination_city AND
		date_trunc('day', f1.scheduled_departure) = date AND
		f2.scheduled_departure >= f1.scheduled_arrival
	ORDER BY f1.scheduled_departure, f2.scheduled_departure
	LIMIT 1;

	IF flight_id IS NOT NULL THEN
		INSERT INTO bookings(book_ref, book_date, total_amount)
		VALUES (new_book_ref, bookings.now(), 0);
		RETURN;
	END IF;

	SELECT f1.flight_id
	INTO flight_id
    FROM flights_v f1, flights_v f2, flights_v f3
    WHERE f1.departure_city = source_city AND
		f1.arrival_city = f2.departure_city AND
		f2.arrival_city = f3.departure_city AND
		f3.arrival_city = destination_city AND
		date_trunc('day', f1.scheduled_departure = date) AND
		f2.scheduled_departure >= f1.scheduled_arrival AND
		f3.scheduled_departure >= f2.scheduled_arrival
    ORDER BY f1.scheduled_departure, f2.scheduled_departure, f3.scheduled_departure
    LIMIT 1;
	
	IF flight_id IS NOT NULL THEN
		INSERT INTO bookings(book_ref, book_date, total_amount)
		VALUES (new_book_ref, bookings.now(), 0);
		RETURN;
	END IF;

	RAISE EXCEPTION 'route not found';
END;
$$;

CALL create_booking('Moscow', 'St. Petersburg', bookings.now()::DATE);
-- 20
CREATE OR REPLACE PROCEDURE add_passenger(p_book_ref bookings.book_ref%TYPE, p_name tickets.passenger_name%TYPE)
LANGUAGE plpgsql
AS $$
DECLARE
	v_flight_id flights.flight_id%TYPE;
	aircraft_seats INT;
	occupied_seats INT;
	v_ticket_no tickets.ticket_no%TYPE;
	v_passenger_id tickets.passenger_id%TYPE;
BEGIN

	SELECT flight_id
	INTO v_flight_id
	FROM bookings
		NATURAL JOIN tickets
		NATURAL JOIN ticket_flights
	WHERE book_ref = p_book_ref
	LIMIT 1;

	SELECT COUNT(seat_no)
	INTO aircraft_seats
	FROM flights
		NATURAL JOIN aircrafts
		NATURAL JOIN seats
	WHERE flight_id = v_flight_id;

	SELECT COUNT(ticket_no)
	INTO occupied_seats
	FROM ticket_flights
	WHERE flight_id = v_flight_id;

	IF aircraft_seats <= occupied_seats THEN
		RAISE EXCEPTION 'no seats available';
		RETURN;
	END IF;

	SELECT concat('_', (SELECT LPAD(RIGHT(COUNT(*)::TEXT, 12), 12, '0') FROM tickets))
	INTO v_ticket_no;

	SELECT concat('_', (SELECT LPAD(RIGHT(COUNT(*)::TEXT, 19), 19, '0') FROM tickets))
	INTO v_passenger_id;

	INSERT INTO tickets(ticket_no, book_ref, passenger_id, passenger_name)
	VALUES (v_ticket_no, p_book_ref, v_passenger_id, p_name);

END;
$$;

CALL add_passenger('000004', 'DUBROVSKIH NIKITA EVGENEVICH');

\x
SELECT * FROM tickets WHERE passenger_name ~ 'DUBROVSKIH';

-- 21

