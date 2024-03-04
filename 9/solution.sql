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
