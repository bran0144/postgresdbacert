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


-- Base table - organized storage that contains data, ETL process
-- Temporary table - organized storage that contains data - loaded through query (transcient) 
    -- process, data from existing base tables
-- Views - not data storage - its a stored query that contains directions and definitions 
-- Standard view - combine commonly joined tables, computed columns, show partial data in a table
-- Materialized view - cross between standview and temporary tables
    -- stored query that contains data that comes from a refresh process
    -- faster than standard views 
-- temp tables can speed up slow queries
-- views are better for complicated logic or calculated fields
-- materialized view speeds up the slower performance of standard views


SELECT DISTINCT table_type
FROM information_schema.tables 
WHERE table_catalog = 'olympics_aqi'; 

SELECT *
FROM information_schema.tables 
WHERE table_catalog = 'olympics_aqi' 
AND table_name = 'annual_aqi';

-- Database storage types
  -- row oriented storage - retains relationship between columns
      -- one row stored in same location
      -- fast to append or delete whole records
      -- quick to return all columns
      -- slow to return all rows
      -- reducing rows: WHERE, INNER JOIN, DISTINCT, LIMIT
  -- column oriented storage - retains relationship between rows
  -- postgres inherently uses row oriented storage
-- Row oriented db methods
  -- partitions, indexes, 

EXPLAIN
SELECT *
FROM daily_aqi;

EXPLAIN
SELECT *
FROM daily_aqi
LIMIT 10;

EXPLAIN
SELECT * 
FROM daily_aqi
WHERE state_code = 15; -- Hawaii state code

SELECT county_name
  , aqi
  , category
  , aqi_date
FROM daily_aqi_partitioned
WHERE state_code = 15
ORDER BY aqi;

-- Using and creating Indexes
-- Uses sorted column keys to improve search
-- references a data location
-- looks for a pointer
-- faster queries
-- PG_TABLES - similar to information_schema - specific to Postgres
  -- metadata about db

CREATE INDEX recipe_index
ON cookbook (recipe);

CREATE INDEX CONCURRENTLY recipe_index
ON cookbook (recipe, serving_size);

-- CONCURRENTLY prevents the table from being locked while index is being built
-- Indexes are useful for:
  -- large tables
  -- common filter conditions
  -- primary keys
  -- tables that get a lot of queries
-- Avoid indexes on:
  -- small tables
  -- columns with many nulls
  -- frequently updated tables
    -- index will become fragmented
    -- writes data in two places

SELECT tablename
 , indexname
FROM pg_indexes;

SELECT indexname
FROM pg_indexes
WHERE tablename = 'daily_aqi'; -- Filter condition

CREATE INDEX defining_parameter_index 
 ON daily_aqi (defining_parameter); -- Define the index creation

SELECT indexname -- Check for the index
FROM pg_indexes
WHERE tablename = 'daily_aqi';

SELECT category
  , COUNT(*) as record_cnt
  , SUM(no_sites) as aqi_monitoring_site_cnt
FROM daily_aqi
WHERE category <> 'Good'
AND state_code = 15 -- Filter to Hawaii
GROUP BY category;

EXPLAIN
SELECT category
  , COUNT(*) as record_cnt
  , SUM(no_sites) as aqi_monitoring_site_cnt
FROM daily_aqi
WHERE defining_parameter = 'SO2'
AND category <> 'Good'
AND state_code = 15 -- Filter to Hawaii
GROUP BY  category;

CREATE INDEX defining_parameter_index ON daily_aqi (defining_parameter); 

EXPLAIN
SELECT category
  , COUNT(*) as record_cnt
  , SUM(no_sites) as aqi_monitoring_site_cnt
FROM daily_aqi
WHERE defining_parameter = 'SO2'
AND category <> 'Good'
AND state_code = 15 -- Hawaii
GROUP BY  category;

-- Column oriented storage
  -- good for analytics(counts, averages, calculations, reporting, aggregations)
  -- fast to perform column calculations
  -- quick to return all rows
-- Transactional focus
  -- slow to return all columns
  -- slow to load data
  -- fast insert and delete of records
-- Examples of column oriented
  -- Citrus Data, Greenplum, Amazon redshit
  -- Oracle In Memory Cloud Store, Clickhouse, apache Druid, CrateDB

-- Reducing columns returned can improve performance 
  -- Use SELECT * sparingly
  -- Use information schema to explore data

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_catalog = "schema_name"
AND table_name = "zoo_animals";

-- for column oriented
SELECT MIN(age), MAX(age)
FROM zoo_animals
WHERE species = 'zebra';

-- for row oriented
SELECT *
FROM zoo_animals
WHERE species = 'zebra'
ORDER BY age;

-- Examine metadata about daily_aqi
SELECT column_name , data_type , is_nullable
FROM information_schema.columns
WHERE table_catalog = 'olympics_aqi'
AND table_name = 'daily_aqi' -- Limit to a specific table
;

-- Query Lifecycle
  -- Parser - sends query to DB, checks syntax, translates SQL into machine readable code
  -- Planner/Optimizer - assess and optimize query tasks, uses db status to create query plan
      -- calculates costs and chooses the best plan
  -- Executor - returns query results - follows query plan and executes the query

-- Query Planner adjusts with SQL structure changes
  -- generates plan trees with nodes corresponding to steps
  -- can visualize with EXPLAIN
  -- estimates cost of each tree (using stats from pg_tables)
  -- optimization is based on time

SELECT * FROM pg_class
WHERE relname = 'mytable'

SELECT * FROM pg_stats
WHERE table_name = 'mytable'

-- Query plans are read bottom to top

SELECT * -- Index indicator column
FROM pg_class
WHERE relname = 'daily_aqi';

SELECT *
FROM pg_stats
WHERE tablename = 'daily_aqi'
AND attname = 'category';

EXPLAIN
SELECT * 
FROM daily_aqi;

CREATE INDEX good_index 
ON annual_aqi(good);

EXPLAIN
SELECT state_name, county_name, aqi_year, good
FROM annual_aqi
WHERE good > 327 -- 90% of the year
AND aqi_year IN (2017,2018);

SELECT COUNT(category)
FROM daily_aqi
WHERE state_code = 15 -- Hawaii state code
AND no_sites > 1;

EXPLAIN
SELECT *
FROM daily_aqi
WHERE state_code = 15 -- Hawaii state code
AND no_sites > 1;

EXPLAIN
SELECT *
FROM daily_aqi_partitioned
WHERE state_code = 15 -- partitioned on state code
AND no_sites > 1;

-- EXPLAIN
  -- optional parameters
    -- VERBOSE - shows columns for each plan node, shows table schema and aliases
    -- ANALYZE - actually runs the query (and outputs into ms instead of unitless time estimates)
      -- includes planning and execution run times

EXPLAIN VERBOSE
SELECT *
FROM country_demos;

EXPLAIN ANALYZE
SELECT *
FROM country_demos;

SELECT country
 , region
 , MAX(population) - MIN(population) as population_change
FROM country_pop 
GROUP BY country, region;

EXPLAIN ANALYZE
SELECT country
 , region
 , MAX(population) - MIN(population) as population_change
FROM country_pop 
GROUP BY country, region;

SELECT country
 , region
 , MAX(population) - MIN(population) as population_change
FROM country_pop  
GROUP BY country, region
ORDER BY population_change DESC;

EXPLAIN ANALYZE
SELECT country
 , region
 , MAX(population) - MIN(population) as population_change
FROM country_pop 
GROUP BY country, region
ORDER BY population_change DESC;

SELECT old.country
, old.region
, old.population_1990
, new.population_2017
, 100*((new.population_2017 - old.population_1990)/new.population_2017::float) as population_growth
FROM pop_1990 old
INNER JOIN pop_2017 new 
USING(country)
ORDER BY population_growth DESC

-- Top row and rows with arrows actually get executed
-- As long as subqueries occur in SELECT or WHERE clauses, they query planner treats them the same as joins

-- Subquery
EXPLAIN ANALYZE
SELECT city
, sex
, COUNT(DISTINCT athlete_id) as no_athletes
, AVG(age) as avg_age
FROM athletes_summ
WHERE country_code IN (SELECT olympic_cc FROM demographics WHERE gdp > 10000 and year = 2016)
AND year = 2016
GROUP BY city, sex;

-- Note the initial step in the query plan

-- Common Table Expression (CTE)
EXPLAIN ANALYZE
WITH gdp AS -- From the demographics table
(
  SELECT olympic_cc FROM demographics WHERE gdp > 10000 and year = 2016
)
SELECT a.city, a.sex
  , COUNT(DISTINCT a.athlete_id) as no_athletes
  , AVG(a.age) as avg_age
FROM athletes_summ a
INNER JOIN gdp
  ON a.country_code = gdp.olympic_cc
WHERE a.year = 2016
GROUP BY a.city, a.sex;

SELECT city, sex, COUNT(DISTINCT athlete_id), AVG(age) AS avg_age
FROM athletes_summ
WHERE city IN ('Rio de Janeiro','Beijing')
GROUP BY city, sex;

-- Read the query plan with the text city filter
EXPLAIN ANALYZE
SELECT city, sex, COUNT(DISTINCT athlete_id), AVG(age) AS avg_age
FROM athletes_summ
WHERE city IN ('Rio de Janeiro','Beijing')
GROUP BY city, sex;

-- Find the execution time with a numeric year filter
EXPLAIN ANALYZE
SELECT city, sex, COUNT(DISTINCT athlete_id), AVG(age) AS avg_age
FROM athletes_summ
WHERE year IN (2016,2008) -- Filter by year
GROUP BY city, sex;

