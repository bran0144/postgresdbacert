-- Exercises

-- Athlete count by country and region
SELECT reg.region
  , reg.country
  , COUNT(DISTINCT ath.athlete_id) AS no_athletes -- Athletes can compete in multiple events
FROM athletes ath
INNER JOIN oregions reg
  ON reg.olympic_cc = ath.country_code
GROUP BY reg.region, reg.country
ORDER BY no_athletes;


SELECT reg.region, reg.country
  , COUNT(DISTINCT ath.athlete_id) AS no_athletes
FROM regions reg
LEFT JOIN athletes ath
  ON reg.olympic_cc = ath.country_code
GROUP BY reg.region, reg.country
ORDER BY no_athletes DESC;

SELECT reg.region, reg.country
  , COUNT(DISTINCT ath.athlete_id) AS no_athletes
FROM athletes ath
RIGHT JOIN regions reg
  ON ath.country_code = reg.olympic_cc
GROUP BY reg.region, reg.country
ORDER BY no_athletes DESC;

SELECT reg.region, reg.country
  , COUNT(DISTINCT ath.athlete_id) AS no_athletes
FROM athletes ath
INNER JOIN regions reg
  ON ath.country_code = reg.olympic_cc
GROUP BY reg.region, reg.country
ORDER BY no_athletes DESC;

SELECT reg.region
  , ath.season
  , COUNT(DISTINCT ath.athlete_id) AS no_athletes
  , COUNT(DISTINCT reg.olympic_cc) AS no_countries
  , COUNT(DISTINCT ath.athlete_id)/COUNT(DISTINCT reg.olympic_cc) AS athletes_per_country
FROM athletes ath
INNER JOIN oregions reg
  ON ath.country_code = reg.olympic_cc
GROUP BY reg.region, ath.season -- Group by region and season
ORDER BY reg.region, athletes_per_country;

-- Subqueries and CTE's
-- subqueries can be in SELECT, FROM, WHERE
-- CTE's in WITH statements

-- Exercises:
-- Countries cold enough for snow year-round
SELECT country_code
  , country
  , COUNT (DISTINCT athlete_id) AS winter_athletes -- Athletes can compete in multiple events 
FROM athletes
WHERE country_code IN (SELECT olympic_cc FROM oclimate WHERE temp_annual < 0)
AND season = 'Winter'
GROUP BY country_code, country;

WITH south_cte AS -- CTE
(
  SELECT region
    , ROUND(AVG(temp_06),2) AS avg_winter_temp
    , ROUND(AVG(precip_06),2) AS avg_winter_precip
  FROM oclimate
  WHERE region IN ('Africa','South America','Australia and Oceania')
  GROUP BY region
)

SELECT south.region, south.avg_winter_temp, south.avg_winter_precip
  , COUNT(DISTINCT ath.athlete_id)
FROM south_cte as south
INNER JOIN athletes_recent ath
  ON south.region = ath.region
  AND ath.season = 'Winter'
GROUP BY south.region, south.avg_winter_temp, south.avg_winter_precip
ORDER BY south.avg_winter_temp;

-- Climate by country with Olympian athletes
SELECT country
  , temp_06
  , precip_06
FROM climate
WHERE region = 'Africa'
AND olympic_cc IN (SELECT DISTINCT country_code FROM athletes_wint)
ORDER BY temp_06;

WITH countries_cte AS -- CTE
(
    SELECT olympic_cc
      , country
      , temp_06
      , precip_06
    FROM climate
    WHERE region = 'Africa'
)

SELECT DISTINCT cte.country
  , cte.temp_06
  , cte.precip_06
FROM athletes_wint AS wint
INNER JOIN countries_cte AS cte
  ON wint.country_code = cte.olympic_cc
ORDER BY temp_06;

-- Temp tables
-- CREATE TEMP TABLE name AS
-- available during database session
-- available in multiple queries
-- CTE's are only available for that one query
-- only available to you as the user
-- typically, large tables are slow
-- temp tables can be made much faster
-- views can be slow, they only contain directions to data
-- temp acutally contains data and stores it temporarily
-- running ANALYZE after creating a temp table helps to make it run faster
--  it helps to mkae the execution plan

-- Exercises:

-- Create a temp table of Canadians
CREATE TEMP TABLE canadians AS
    SELECT *
    FROM athletes_recent
    WHERE country_code = 'CAN'
    AND season = 'Winter'; -- The table has both summer and winter athletes

-- Find the most popular sport
SELECT sport
  , COUNT(DISTINCT athlete_id) as no_athletes
FROM canadians
GROUP BY sport 
ORDER BY no_athletes DESC;

-- Create temp countries table
CREATE TEMP TABLE countries AS
    SELECT DISTINCT o.region, a.country_code, o.country
    FROM athletes a
    INNER JOIN oregions o
      ON a.country_code = o.olympic_cc;
      
ANALYZE countries; -- Collect the statistics

-- Count the entries
SELECT COUNT(*) FROM countries;

-- SQL has a logical order of operations
-- FROM, WHERE, GROUP BY, aggregates (SUM, COUNT), SELECT

-- Exercises:

SELECT country_code
  , COUNT(athlete_id) as medals_count
FROM athletes_recent
WHERE medal IS NOT NULL
AND year = 2016
GROUP BY country_code
ORDER BY medals_count DESC;

SELECT country_code
  , COUNT(DISTINCT athlete_id) as medals_count
FROM athletes_recent
WHERE medal IS NOT NULL
AND year = 2016
GROUP BY country_code
ORDER BY medals_count DESC;

-- FILTERING on the WHERE clause
-- WHERE clauses can speed the query (fewer records)
-- EXPLAIN before your query will show the execution plan
-- the best WHERE filters: shorter length, smaller storage = better performance
-- numeric filters are faster than text filters
-- (IN or ARRAY) are faster than OR

-- Exercises:
SELECT COUNT(*)
FROM athletes_wint 
WHERE age = 11
OR age = 12;

-- better:
SELECT *
FROM athletes_wint 
WHERE age IN (11,12);

SELECT games
  , name
  , age
FROM athletes_wint
WHERE games IN ('1960 Winter', '2010 Winter')
ORDER BY games;

SELECT games
  , name
  , age
FROM athletes_wint
WHERE year IN (1960,2010)
ORDER BY games;

SELECT *
FROM athletes_wint
WHERE age < 16;

-- Filtering while joining
-- Joins combine data, but can also limit data (inner joins)

-- Exercises:
SELECT dem.olympic_cc, reg.country, dem.gdp, dem.population
FROM demographics dem
LEFT JOIN oregions reg
  ON dem.olympic_cc = reg.olympic_cc
  AND region = 'Africa'
WHERE dem.year = 2014
AND dem.gdp IS NOT NULL
ORDER BY dem.gdp DESC; 

SELECT dem.olympic_cc, reg.country, dem.gdp, dem.population
FROM demographics dem
LEFT JOIN oregions reg
  ON dem.olympic_cc = reg.olympic_cc
WHERE dem.year = 2014
AND region = 'Africa'
AND dem.gdp IS NOT NULL
ORDER BY dem.gdp DESC;

SELECT dem.olympic_cc, reg.country, dem.gdp, dem.population
FROM demographics dem
INNER JOIN oregions reg
  ON dem.olympic_cc = reg.olympic_cc
  AND reg.region = 'Africa'
WHERE dem.year = 2014
AND dem.gdp IS NOT NULL
ORDER BY dem.gdp DESC;

SELECT DISTINCT ath.name, dem.country, dem.gdp
FROM athletes_wint ath
INNER JOIN odemographics dem
  ON ath.country_code = dem.olympic_cc 
WHERE ath.year = 2014
ORDER BY dem.gdp DESC;

-- When to aggregate data?
-- Data granularity
--  Some tables only need one unique identifier (like id#)
--  Others require more than 1 (say city and state)
-- Joining different granularities
SELECT g.id, g.game, g.first_yr, COUNT(platform) AS no_platforms
FROM video_games g 
INNER JOIN game_platforms p 
  ON g.id = p.game_id
GROUP BY g.id, g.game, g.first_yr

-- this will duplicate the data 
-- to fix, you need to change granularity
SELECT game_id, COUNT(platform) as no_platforms
FROM game_platforms
GROUP BY game_id

-- this now has only 1 game per game platform
-- can now use a CTE to change granularity and join without duplicates

WITH platforms_cte AS
  (SELECT game_id, COUNT(platform) as no_platforms
    FROM game_platforms
    GROUP BY game_id)
SELECT g.id, g.game
FROM video_games g 
INNER JOIN platforms_cte cte
  ON g.id = cte.game_id

-- Exercises:
-- Count the number of athletes by country
SELECT country_code
  , year
  , COUNT(athlete_id) AS no_athletes
FROM athletes
GROUP BY country_code, year;

-- Number of competing athletes
WITH athletes as (
  SELECT country_code, year, COUNT(athlete_id) AS no_athletes
  FROM athletes
  GROUP BY country_code, year
)

SELECT demos.country, ath.year, ath.no_athletes
    , demos.gdp_rank
    , demos.population_rank
FROM athletes ath
INNER JOIN demographics_rank demos  
  ON ath.country_code = demos.olympic_cc -- Country
  AND ath.year = demos.year -- Year
ORDER BY ath.no_athletes DESC;

SELECT year
  , season
  , COUNT(DISTINCT athlete_id) AS no_athletes
FROM athletes
WHERE country_code = 'RSA'
GROUP BY year, season

-- South African athletes by year
WITH athletes_cte AS
(
    SELECT year
      , season
      , COUNT(DISTINCT athlete_id) AS no_athletes
    FROM athletes
    WHERE country_code = 'RSA' -- South Africa filter
    GROUP BY year, season
)

SELECT ath.year
  , ath.season
  , ath.no_athletes
  , demos.gdp_rounded
  , demos.gdp_rank
  , demos.population_rounded
  , demos.population_rank
FROM athletes_cte ath
INNER JOIN demographics_rank demos
  ON ath.year = demos.year
  AND demos.olympic_cc = 'RSA' -- Filter to South Africa
ORDER BY ath.season, ath.year;