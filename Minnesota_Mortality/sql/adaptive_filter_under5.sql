-- synthetic_population
--WITH synthetic_population as
--(
--SELECT p.sp_hh_id, hh.geom as geom, p.sex, p.age, 1 as value, p.race
--FROM synthetic_households hh INNER JOIN synthetic_people p ON hh.household_id = p.sp_hh_id
--WHERE p.age <= 4 AND p.age >= 0 --##########################################################################################################
--), 

---- people
--people as
--(
--SELECT z.zcta5ce10::integer as zcta_id, t.gid as tract_id, p.sp_hh_id as person_id, p.geom, p.sex, p.age, p.race, p.value
--FROM synthetic_population p
--INNER JOIN mn_zcta_wgs84 z ON ST_Within(p.geom, z.geom)
--INNER JOIN mn_census_tracts t ON ST_Within(p.geom, t.geom)
--INNER JOIN mn_county_wgs84 c ON ST_Within(c.geom, p.geom) 
--and now use counties, which has 2 geometries, one geom_26915, the other geom and using 4326
--), 

CREATE TABLE adaptive_filter_under5_initial AS
-- base_population
WITH base_population as ------------------------------------------------------------------------------------ Start query to be changed ? ---------
(
SELECT
  SUM(a.total_under5) as est_pop_under5_year_2011, SUM(b.total_under5) as est_pop_under5_year_2012,  --####################################################
	SUM(c.total_under5) as est_pop_under5_year_2013, SUM(d.total_under5) as est_pop_under5_year_2014, 
	SUM(e.total_under5) as est_pop_under5_year_2015
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
), 

-- deaths
deaths as
(
SELECT decd_dth_yr as yr, COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr >= 0 --####################################################################################################################
AND decd_age_yr <= 4
GROUP BY decd_dth_yr
), 

-- death_pivot
death_pivot as
--change by adding secondary when (aka and): when d.yr = 2011 and d.age = 5
(
SELECT 1 as rec_id,
CASE WHEN d.yr = 2011 THEN d.num_deaths ELSE 0 END as deaths_2011, --###########################################################################
CASE WHEN d.yr = 2012 THEN d.num_deaths ELSE 0 END as deaths_2012,
CASE WHEN d.yr = 2013 THEN d.num_deaths ELSE 0 END as deaths_2013,
CASE WHEN d.yr = 2014 THEN d.num_deaths ELSE 0 END as deaths_2014,
CASE WHEN d.yr = 2015 THEN d.num_deaths ELSE 0 END as deaths_2015
FROM deaths d
), 

-- total_deaths
total_deaths as
(
SELECT sum(deaths_2011) as deaths_2011, --????????????????????????????????????? Summing all the 2011 etc deaths into deaths_2011 ???????????????
sum(deaths_2012) as deaths_2012,
sum(deaths_2013) as deaths_2013,
sum(deaths_2014) as deaths_2014,
sum(deaths_2015) as deaths_2015
FROM death_pivot
GROUP BY rec_id
),

-- death_rates
death_rates as
(
SELECT 
  deaths_2011/est_pop_under5_year_2011 as expected_death_rate_under5_2011, --######################################################################
  deaths_2012/est_pop_under5_year_2012 as expected_death_rate_under5_2012,
  deaths_2013/est_pop_under5_year_2013 as expected_death_rate_under5_2013,
  deaths_2014/est_pop_under5_year_2014 as expected_death_rate_under5_2014,
  deaths_2015/est_pop_under5_year_2015 as expected_death_rate_under5_2015
  
  /*
  est_pop_5_9_year_2012*deaths_2012 as expected_deaths_5_9_2012, 
  est_pop_5_9_year_2013*deaths_2013 as expected_deaths_5_9_2013,
  est_pop_5_9_year_2014*deaths_2014 as expected_deaths_5_9_2014, 
  est_pop_5_9_year_2015*deaths_2015 as expected_deaths_5_9_2015
  */
  -- add the rest of the columns
FROM base_population bp, total_deaths
), 

-- expected_deaths
expected_deaths as
(
SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race,
p.value * expected_death_rate_under5_2011 as num_deaths_2011,  --################################################################################
p.value * expected_death_rate_under5_2012 as num_deaths_2012,
p.value * expected_death_rate_under5_2013 as num_deaths_2013,
p.value * expected_death_rate_under5_2014 as num_deaths_2014,
p.value * expected_death_rate_under5_2015 as num_deaths_2015
FROM death_rates, synth_people p -- synth people is the table made of what would have been the first two queries, this originally said FROM death_rates, people p
WHERE p.age >=0 and p.age <=4 --#####################################################################################################################
),

-- person_deaths
person_deaths as
(
SELECT p.zcta_id, p.tract_id, p.person_id, p.geom, p.sex, p.age, p.race,
(p.num_deaths_2011 + p.num_deaths_2012 + p.num_deaths_2013 + p.num_deaths_2014 + p.num_deaths_2015) as total_deaths
FROM expected_deaths p
),

-- geog_unit_deaths
geog_unit_deaths as
(
SELECT tract_id, sum(total_deaths) as total_deaths
FROM person_deaths
GROUP BY tract_id
),

--the_population
the_population as
(
SELECT g.tract_id,  ST_Centroid(t.geom) as geom, g.total_deaths
FROM geog_unit_deaths g 
INNER JOIN mn_census_tracts t ON (g.tract_id = t.gid)
), 

-- grid
grid as
(
SELECT g.gid, geom
FROM grid_5000 g
--LIMIT 200  ---------------------- limit is only for testing, to get results quick. If used in final, would only do NW corner of state or some such
), 

-- grid_person_join
grid_person_join as
(
SELECT gid, g.geom, tp.tract_id, ST_Distance(g.geom, ST_Transform(tp.geom,26915)) as distance, tp.total_deaths
FROM grid g CROSS JOIN the_population tp
), 

-- grid_people
grid_people as
(
SELECT gid, geom, distance, sum(total_deaths) OVER w as total_deaths
FROM grid_person_join
WINDOW w AS (PARTITION BY gid, geom ORDER BY distance ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW )
), 

--buffer_definition
buffer_definition as
(
SELECT gid, geom, min(distance) as min_buffer_distance
FROM grid_people
WHERE total_deaths >= 50 ------------------------------------------------------- For having 50 deaths in each buffer
GROUP BY gid, geom
),

-- filter_expected
filter_expected as
(
SELECT b.gid, b.geom, b.min_buffer_distance, sum(gpj.total_deaths) as expected_deaths
FROM grid_person_join gpj 
INNER JOIN buffer_definition b ON gpj.gid = b.gid
WHERE gpj.distance <= b.min_buffer_distance
GROUP BY b.gid, b.geom, b.min_buffer_distance
), 

-- observed
observed as
(
SELECT d.decd_res_zip5 as zip, z.geom, COUNT(1) as observed_deaths
FROM disparities.decd d 
INNER JOIN mn_zcta_wgs84 z ON z.zcta5ce10::integer = d.decd_res_zip5::integer -- almost certainly what's giving me the invalid input syntax for integer: 'NA'
WHERE decd_age_yr >= 0 --#####################################################################################################################
AND decd_age_yr <= 4
AND d.decd_res_zip5 <> 'NA' -- added b/c got a lot of 'NA' in 0-4 age range
GROUP BY zip, z.geom
),

-- filter_observed
filter_observed as
(
SELECT b.gid, count(o.observed_deaths) as number_of_zctas_used, sum(o.observed_deaths) as observed_deaths
FROM buffer_definition b
INNER JOIN observed o on ST_DWithin( b.geom,  ST_Transform(ST_Centroid(o.geom), 26915), b.min_buffer_distance) 
GROUP BY b.gid, b.geom
)

-- main query
--except as a table: CREATE TABLE AS SELECT,then can copy to a csv
SELECT e.gid, e.geom, e.min_buffer_distance, e.expected_deaths, o.number_of_zctas_used, o.observed_deaths, o.observed_deaths/e.expected_deaths as ratio
FROM filter_expected e 
INNER JOIN filter_observed o ON e.gid=o.gid