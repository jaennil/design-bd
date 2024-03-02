-- 1
SELECT name
FROM equestrians_horses
JOIN horses USING(horse_id)
WHERE equestrian_id = 1;

-- 2
SELECT equestrian_id, COUNT(horse_id)
FROM horses
JOIN equestrians_horses USING(horse_id)
GROUP BY equestrian_id;

-- 3
SELECT
	horses.name horse_name,
	jockeys.firstname jockey_firstname,
	jockeys.lastname jockey_lastname,
	place,
	competitors_races.time
FROM competitions
JOIN races USING (competition_id)
JOIN competitors_races USING(race_id)
JOIN competitors USING(competitor_id)
JOIN horses USING(horse_id)
JOIN jockeys USING(jockey_id)
WHERE competition_id = 1;

-- 4
SELECT
	horses.name horse_name,
	jockeys.firstname jockey_firstname,
	jockeys.lastname jockey_lastname,
	place,
	competitors_races.time
FROM competitions
JOIN races USING (competition_id)
JOIN competitors_races USING(race_id)
JOIN competitors USING(competitor_id)
JOIN horses USING(horse_id)
JOIN jockeys USING(jockey_id)
WHERE competition_id = 1 AND place=1;

-- 5
SELECT
	DISTINCT name, gender_id, age
FROM horses
JOIN competitors USING(horse_id)
JOIN competitors_races USING(competitor_id);

-- 6
SELECT jockeys.jockey_id, MIN(time)
FROM jockeys
JOIN competitors USING(jockey_id)
JOIN competitors_races USING(competitor_id)
GROUP BY jockeys.jockey_id;

-- 7
SELECT hippodrome_id, jockey_id, MIN(competitors_races.time)
FROM jockeys
JOIN competitors USING(jockey_id)
JOIN competitors_races USING(competitor_id)
JOIN races USING(race_id)
JOIN competitions USING(competition_id)
JOIN hippodromes USING(hippodrome_id)
GROUP BY hippodrome_id, jockey_id;

-- 8
SELECT jockeys.firstname,
	jockeys.lastname,
	jockeys.address,
	jockeys.age,
	jockeys.rating
FROM jockeys
JOIN competitors USING(jockey_id)
JOIN competitors_races USING(competitor_id)
JOIN races USING(race_id)
WHERE competition_id = 1
AND competitors_races.time <
(SELECT AVG(competitors_races.time)
	FROM competitors_races
	JOIN races USING(race_id)
	WHERE competition_id = 1)\G

-- 9
SELECT jockey_id, time
FROM competitors
JOIN competitors_races USING(competitor_id)
JOIN
	(SELECT jockey_id, AVG(TIME_TO_SEC(time)) avgtime
	FROM competitors_races
	JOIN competitors USING(competitor_id)
	JOIN jockeys USING(jockey_id)
	GROUP BY jockey_id) c_jockeys
USING(jockey_id)
WHERE TIME_TO_SEC(time) < c_jockeys.avgtime;

-- 10
SELECT hippodrome_id, COUNT(competition_id) amount
FROM hippodromes
JOIN competitions USING(hippodrome_id)
GROUP BY hippodrome_id
HAVING amount > 1;
