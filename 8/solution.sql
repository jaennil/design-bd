ALTER DATABASE demo SET bookings.lang = en;

-- 1.1
SELECT *
FROM aircrafts
WHERE model LIKE 'Airbus%';
-- 1.2
SELECT *
FROM aircrafts
WHERE model ~ '^Airbus';

-- 2
SELECT *
FROM aircrafts
WHERE model !~ '^(Airbus|Boeing)';

-- 3
SELECT *
FROM airports
WHERE airport_name ~ '^.{3}$';
--
SELECT *
FROM airports_data
WHERE airport_name->>'ru' ~ '^.{3}$';

-- 4
SELECT *
FROM aircrafts
WHERE model !~ '300$';

-- 5
SELECT *
FROM aircrafts
WHERE range BETWEEN 3000 AND 6000
ORDER BY range DESC;

-- 6
SELECT *, ROUND(range / 1.609, 2) range_in_miles
FROM aircrafts
WHERE range BETWEEN 3000 AND 6000
ORDER BY range DESC;

-- 7
SELECT DISTINCT timezone
FROM airports;

-- 8
SELECT *
FROM airports
ORDER BY coordinates[0] DESC
LIMIT 3;

-- 9
SELECT *
FROM airports
ORDER BY coordinates[0] DESC
LIMIT 3
OFFSET 3;

-- 10
SELECT *,
	CASE
		WHEN range < 2000 THEN 'Ближнемагистральный'
		WHEN range < 5000 THEN 'Среднемагистральный'
		ELSE 'Дальномагистральный'
	END AS class
FROM aircrafts;

-- 11.1
SELECT DISTINCT seats.*
FROM aircrafts
JOIN seats USING(aircraft_code)
WHERE model ~ '^Cessna 208 Caravan$';
-- 11.2
SELECT DISTINCT seats.*
FROM aircrafts, seats
WHERE seats.aircraft_code = aircrafts.aircraft_code
AND model ~ '^Cessna 208 Caravan$';

-- 12
SELECT * FROM flights_v;

-- 13
SELECT model, COUNT(routes.aircraft_code)
FROM aircrafts
LEFT JOIN routes USING(aircraft_code)
GROUP BY aircraft_code, model;

-- 14
SELECT COUNT(*)
FROM flights
JOIN ticket_flights USING(flight_id)
LEFT JOIN boarding_passes USING(flight_id, ticket_no)
WHERE flights.status ~ '^(Arrived|Departed)$'
AND boarding_passes.boarding_no IS NULL;

-- 15
UPDATE boarding_passes
SET seat_no = '9A'
WHERE flight_id = 2
	AND seat_no = '1C';

SELECT flights.flight_id,
	seats.fare_conditions actual_fare_condition,
	ticket_flights.fare_conditions,
	boarding_passes.seat_no,
	ticket_flights.ticket_no,
	boarding_passes.boarding_no
FROM boarding_passes
	JOIN ticket_flights USING(ticket_no, flight_id)
	JOIN tickets USING(ticket_no)
	JOIN flights USING(flight_id)
	JOIN seats USING(seat_no, aircraft_code)
WHERE ticket_flights.fare_conditions != seats.fare_conditions;

-- 16
SELECT min_sum, max_sum, COUNT(bookings)
FROM bookings
	RIGHT JOIN (VALUES 
			(0, 100000),
			(100000, 200000),
			(200000, 300000),
			(300000, 400000),
			(400000, 500000),
			(500000, 600000),
			(600000, 700000),
			(700000, 800000),
			(800000, 900000),
			(900000, 1000000),
			(1000000, 1100000),
			(1100000, 1200000),
			(1200000, 1300000))
		AS distribution (min_sum, max_sum)
		ON total_amount >= min_sum AND
			total_amount < max_sum
GROUP BY min_sum, max_sum
ORDER BY min_sum;

-- 17
SELECT arrival_city
FROM routes
WHERE departure_city = 'Moscow'
UNION
SELECT arrival_city
FROM routes
WHERE departure_city = 'St. Petersburg';

-- 18
SELECT arrival_city
FROM routes
WHERE departure_city = 'Moscow'
INTERSECT
SELECT arrival_city
FROM routes
WHERE departure_city = 'St. Petersburg';

-- 19
SELECT arrival_city
FROM routes
WHERE departure_city = 'St. Petersburg'
EXCEPT
SELECT arrival_city
FROM routes
WHERE departure_city = 'Moscow';

-- 20
SELECT arrival_city, COUNT(*)
FROM routes
WHERE departure_city = 'Moscow'
GROUP BY arrival_city;

-- 21
SELECT array_length(days_of_week, 1) days_per_week, COUNT(*) routes_amount
FROM routes
GROUP BY days_per_week;

-- 22
SELECT departure_city, COUNT(*)
FROM routes
GROUP BY departure_city
HAVING COUNT(*) >= 15;

-- 23
SELECT city, COUNT(*)
FROM airports
GROUP BY city
HAVING COUNT(*) > 1;

-- 24
SELECT
	book_ref,
	book_date,
	EXTRACT(MONTH FROM book_date),
	EXTRACT(DAY FROM book_date),
	COUNT(*) OVER (
		PARTITION BY date_trunc('month', book_date) ORDER BY book_date
	)
FROM bookings
	NATURAL JOIN tickets
	NATURAL JOIN ticket_flights
WHERE flight_id = 2
ORDER BY book_date;
