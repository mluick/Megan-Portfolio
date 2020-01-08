-- create choropleths for zctas
--have to use slightly different versions of the queries for pgAdmin and ArcGIS Pro


-- under 5 (pgAdmin version)
-- count deaths in state for age group
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr < 5
), 
-- sum total population of state within age group
pop as(
SELECT SUM(a.total_under5) + 
	SUM(b.total_under5) +
	SUM(c.total_under5) + 
	SUM(d.total_under5) +
	SUM(e.total_under5)
		as total_age_pop
FROM zcta_age_sex_2011 as a
	INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
	INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
	INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
	INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
-- rate = deaths/population (no longer pop*5)
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
-- apply calculated rate to population of each zcta (find expected deaths)
expected as (
SELECT a.zcta,
	(a.total_under5 + b.total_under5 + c.total_under5 + d.total_under5 + e.total_under5
	)*r.age_rate as expected_deaths
FROM zcta_age_sex_2011 as a
	INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
	INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
	INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
	INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
	, rate r
),
-- number of observed deaths
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
WHERE decd_age_yr < 5
GROUP BY zip
)
-- observed/expected
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
	(o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM zip_code_tabulation_areas z 
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0;



-- under 5 (arcpro version)
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr < 5
), 
pop as(
SELECT SUM(total_under5) as total_under_5
FROM disparities_mapping.public.zcta_age_sex_2011
),
rate as(
SELECT d.num_deaths::double precision/(p.total_under_5::double precision*5) as rate_under_5
FROM deaths d, pop p
),
expected as(
SELECT a.zcta,
	((a.total_under5)*r.rate_under_5) as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 a, rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
WHERE decd_age_yr < 5
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
	(o.observed_deaths/(e.expected_deaths * 5)) as ratio, z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0

-- arcpro alter age
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr < 5
), 
pop as(
SELECT (SUM(a.total_under5) + 
	SUM(b.total_under5) +
	SUM(c.total_under5) + 
	SUM(d.total_under5) +
	SUM(e.total_under5))
		as total_age_pop
FROM disparities_mapping.public.zcta_age_sex_2011 as a
	INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
	INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
	INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
	INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as rate_under_5
FROM deaths d, pop p
),
expected as(
SELECT a.zcta,
	((a.total_under5)*r.rate_under_5) as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 a, rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr < 5
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
	(o.observed_deaths/(e.expected_deaths * 5)) as ratio, 
	z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z INNER JOIN observed o ON o.zip = z.zcta5ce10
INNER JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0
ORDER BY zcta



-- 5 TO 19 (pgAdmin)
-- count deaths in state for age group
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr >= 5
AND decd_age_yr <= 15
),
-- sum total population of state within age group
pop as(
SELECT
    SUM(a.total_5_9) + SUM(b.total_5_9) + SUM(c.total_5_9) + SUM(d.total_5_9) + SUM(e.total_5_9) +
    SUM(a.total_10_14) + SUM(b.total_10_14) + SUM(c.total_10_14) + SUM(d.total_10_14) + SUM(e.total_10_14) +
    SUM(a.total_15_19) + SUM(b.total_15_19) + SUM(c.total_15_19) + SUM(d.total_15_19) + SUM(e.total_15_19)
   as total_age_pop
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
-- rate = deaths/population (no longer pop*5)
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
-- apply calculated rate to population of each zcta (find expected deaths)
expected as (
SELECT a.zcta, (
    a.total_5_9 + b.total_5_9 + c.total_5_9 + d.total_5_9 + e.total_5_9 +
    a.total_10_14 + b.total_10_14 + c.total_10_14 + d.total_10_14 + e.total_10_14 +
    a.total_15_19 + b.total_15_19 + c.total_15_19 + d.total_15_19 + e.total_15_19
   )*r.age_rate as expected_deaths
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
-- number of observed deaths
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
WHERE decd_age_yr >= 5
AND decd_age_yr <= 15
GROUP BY zip
)
-- observed/expected
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0;

-- 5 to 19 (arcpro)

WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 5
AND decd_age_yr <= 15
),
pop as(
SELECT
    SUM(a.total_5_9) + SUM(b.total_5_9) + SUM(c.total_5_9) + SUM(d.total_5_9) + SUM(e.total_5_9) +
    SUM(a.total_10_14) + SUM(b.total_10_14) + SUM(c.total_10_14) + SUM(d.total_10_14) + SUM(e.total_10_14) +
    SUM(a.total_15_19) + SUM(b.total_15_19) + SUM(c.total_15_19) + SUM(d.total_15_19) + SUM(e.total_15_19)
   as total_age_pop
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
expected as (
SELECT a.zcta, (
    a.total_5_9 + b.total_5_9 + c.total_5_9 + d.total_5_9 + e.total_5_9 +
    a.total_10_14 + b.total_10_14 + c.total_10_14 + d.total_10_14 + e.total_10_14 +
    a.total_15_19 + b.total_15_19 + c.total_15_19 + d.total_15_19 + e.total_15_19
   )*r.age_rate as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 5
AND decd_age_yr <= 15
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0



-- 20 to 39 (pgAdmin)
-- count deaths in state for age group
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr >= 20
AND decd_age_yr <= 35
),
-- sum total population of state within age group
pop as(
SELECT
    SUM(a.total_20_24) + SUM(b.total_20_24) + SUM(c.total_20_24) + SUM(d.total_20_24) + SUM(e.total_20_24) +
    SUM(a.total_25_29) + SUM(b.total_25_29) + SUM(c.total_25_29) + SUM(d.total_25_29) + SUM(e.total_25_29) +
    SUM(a.total_30_34) + SUM(b.total_30_34) + SUM(c.total_30_34) + SUM(d.total_30_34) + SUM(e.total_30_34) +
    SUM(a.total_35_39) + SUM(b.total_35_39) + SUM(c.total_35_39) + SUM(d.total_35_39) + SUM(e.total_35_39)
   as total_age_pop
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
-- rate = deaths/population (no longer pop*5)
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
-- apply calculated rate to population of each zcta (find expected deaths)
expected as (
SELECT a.zcta, (
    a.total_20_24 + b.total_20_24 + c.total_20_24 + d.total_20_24 + e.total_20_24 +
    a.total_25_29 + b.total_25_29 + c.total_25_29 + d.total_25_29 + e.total_25_29 +
    a.total_30_34 + b.total_30_34 + c.total_30_34 + d.total_30_34 + e.total_30_34 +
    a.total_35_39 + b.total_35_39 + c.total_35_39 + d.total_35_39 + e.total_35_39
   )*r.age_rate as expected_deaths
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
-- number of observed deaths
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
WHERE decd_age_yr >= 20
AND decd_age_yr <= 35
GROUP BY zip
)
-- observed/expected
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0;


-- 20 to 39 (arcpro)

WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 20
AND decd_age_yr <= 35
),
pop as(
SELECT
    SUM(a.total_20_24) + SUM(b.total_20_24) + SUM(c.total_20_24) + SUM(d.total_20_24) + SUM(e.total_20_24) +
    SUM(a.total_25_29) + SUM(b.total_25_29) + SUM(c.total_25_29) + SUM(d.total_25_29) + SUM(e.total_25_29) +
    SUM(a.total_30_34) + SUM(b.total_30_34) + SUM(c.total_30_34) + SUM(d.total_30_34) + SUM(e.total_30_34) +
    SUM(a.total_35_39) + SUM(b.total_35_39) + SUM(c.total_35_39) + SUM(d.total_35_39) + SUM(e.total_35_39)
   as total_age_pop
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
expected as (
SELECT a.zcta, (
    a.total_20_24 + b.total_20_24 + c.total_20_24 + d.total_20_24 + e.total_20_24 +
    a.total_25_29 + b.total_25_29 + c.total_25_29 + d.total_25_29 + e.total_25_29 +
    a.total_30_34 + b.total_30_34 + c.total_30_34 + d.total_30_34 + e.total_30_34 +
    a.total_35_39 + b.total_35_39 + c.total_35_39 + d.total_35_39 + e.total_35_39
   )*r.age_rate as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 20
AND decd_age_yr <= 35
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0


-- 40 to 59 (pgAdmin)
-- count deaths in state for age group
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr >= 40
AND decd_age_yr <= 55
),
-- sum total population of state within age group
pop as(
SELECT
    SUM(a.total_40_44) + SUM(b.total_40_44) + SUM(c.total_40_44) + SUM(d.total_40_44) + SUM(e.total_40_44) +
    SUM(a.total_45_49) + SUM(b.total_45_49) + SUM(c.total_45_49) + SUM(d.total_45_49) + SUM(e.total_45_49) +
    SUM(a.total_50_54) + SUM(b.total_50_54) + SUM(c.total_50_54) + SUM(d.total_50_54) + SUM(e.total_50_54) +
    SUM(a.total_55_59) + SUM(b.total_55_59) + SUM(c.total_55_59) + SUM(d.total_55_59) + SUM(e.total_55_59)
   as total_age_pop
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
-- rate = deaths/population (no longer pop*5)
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
-- apply calculated rate to population of each zcta (find expected deaths)
expected as (
SELECT a.zcta, (
    a.total_40_44 + b.total_40_44 + c.total_40_44 + d.total_40_44 + e.total_40_44 +
    a.total_45_49 + b.total_45_49 + c.total_45_49 + d.total_45_49 + e.total_45_49 +
    a.total_50_54 + b.total_50_54 + c.total_50_54 + d.total_50_54 + e.total_50_54 +
    a.total_55_59 + b.total_55_59 + c.total_55_59 + d.total_55_59 + e.total_55_59
   )*r.age_rate as expected_deaths
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
-- number of observed deaths
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
WHERE decd_age_yr >= 40
AND decd_age_yr <= 55
GROUP BY zip
)
-- observed/expected
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0;



-- 40 to 59 (arcpro)
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 40
AND decd_age_yr <= 55
),
pop as(
SELECT
    SUM(a.total_40_44) + SUM(b.total_40_44) + SUM(c.total_40_44) + SUM(d.total_40_44) + SUM(e.total_40_44) +
    SUM(a.total_45_49) + SUM(b.total_45_49) + SUM(c.total_45_49) + SUM(d.total_45_49) + SUM(e.total_45_49) +
    SUM(a.total_50_54) + SUM(b.total_50_54) + SUM(c.total_50_54) + SUM(d.total_50_54) + SUM(e.total_50_54) +
    SUM(a.total_55_59) + SUM(b.total_55_59) + SUM(c.total_55_59) + SUM(d.total_55_59) + SUM(e.total_55_59)
   as total_age_pop
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
expected as (
SELECT a.zcta, (
    a.total_40_44 + b.total_40_44 + c.total_40_44 + d.total_40_44 + e.total_40_44 +
    a.total_45_49 + b.total_45_49 + c.total_45_49 + d.total_45_49 + e.total_45_49 +
    a.total_50_54 + b.total_50_54 + c.total_50_54 + d.total_50_54 + e.total_50_54 +
    a.total_55_59 + b.total_55_59 + c.total_55_59 + d.total_55_59 + e.total_55_59
   )*r.age_rate as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 40
AND decd_age_yr <= 55
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0



-- over 60 (pgAdmin)
-- count deaths in state for age group
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr >= 60
),
-- sum total population of state within age group
pop as(
SELECT
    SUM(a.total_60_64) + SUM(b.total_60_64) + SUM(c.total_60_64) + SUM(d.total_60_64) + SUM(e.total_60_64) +
    SUM(a.total_65_69) + SUM(b.total_65_69) + SUM(c.total_65_69) + SUM(d.total_65_69) + SUM(e.total_65_69) +
    SUM(a.total_70_74) + SUM(b.total_70_74) + SUM(c.total_70_74) + SUM(d.total_70_74) + SUM(e.total_70_74) +
    SUM(a.total_75_79) + SUM(b.total_75_79) + SUM(c.total_75_79) + SUM(d.total_75_79) + SUM(e.total_75_79) +
    SUM(a.total_80_84) + SUM(b.total_80_84) + SUM(c.total_80_84) + SUM(d.total_80_84) + SUM(e.total_80_84) +
    SUM(a.total_85andover) + SUM(b.total_85andover) + SUM(c.total_85andover) + SUM(d.total_85andover) + SUM(e.total_85andover)
   as total_age_pop
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
-- rate = deaths/population (no longer pop*5)
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
-- apply calculated rate to population of each zcta (find expected deaths)
expected as (
SELECT a.zcta, (
    a.total_60_64 + b.total_60_64 + c.total_60_64 + d.total_60_64 + e.total_60_64 +
    a.total_65_69 + b.total_65_69 + c.total_65_69 + d.total_65_69 + e.total_65_69 +
    a.total_70_74 + b.total_70_74 + c.total_70_74 + d.total_70_74 + e.total_70_74 +
    a.total_75_79 + b.total_75_79 + c.total_75_79 + d.total_75_79 + e.total_75_79 +
    a.total_80_84 + b.total_80_84 + c.total_80_84 + d.total_80_84 + e.total_80_84 +
    a.total_85andover + b.total_85andover + c.total_85andover + d.total_85andover + e.total_85andover
   )*r.age_rate as expected_deaths
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
-- number of observed deaths
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
WHERE decd_age_yr >= 60
GROUP BY zip
)
-- observed/expected
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0;


-- over 60 (arcpro)

WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 60
),
pop as(
SELECT
    SUM(a.total_60_64) + SUM(b.total_60_64) + SUM(c.total_60_64) + SUM(d.total_60_64) + SUM(e.total_60_64) +
    SUM(a.total_65_69) + SUM(b.total_65_69) + SUM(c.total_65_69) + SUM(d.total_65_69) + SUM(e.total_65_69) +
    SUM(a.total_70_74) + SUM(b.total_70_74) + SUM(c.total_70_74) + SUM(d.total_70_74) + SUM(e.total_70_74) +
    SUM(a.total_75_79) + SUM(b.total_75_79) + SUM(c.total_75_79) + SUM(d.total_75_79) + SUM(e.total_75_79) +
    SUM(a.total_80_84) + SUM(b.total_80_84) + SUM(c.total_80_84) + SUM(d.total_80_84) + SUM(e.total_80_84) +
    SUM(a.total_85andover) + SUM(b.total_85andover) + SUM(c.total_85andover) + SUM(d.total_85andover) + SUM(e.total_85andover)
   as total_age_pop
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
expected as (
SELECT a.zcta, (
    a.total_60_64 + b.total_60_64 + c.total_60_64 + d.total_60_64 + e.total_60_64 +
    a.total_65_69 + b.total_65_69 + c.total_65_69 + d.total_65_69 + e.total_65_69 +
    a.total_70_74 + b.total_70_74 + c.total_70_74 + d.total_70_74 + e.total_70_74 +
    a.total_75_79 + b.total_75_79 + c.total_75_79 + d.total_75_79 + e.total_75_79 +
    a.total_80_84 + b.total_80_84 + c.total_80_84 + d.total_80_84 + e.total_80_84 +
    a.total_85andover + b.total_85andover + c.total_85andover + d.total_85andover + e.total_85andover
   )*r.age_rate as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr >= 60
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0


-- overall (pgAdmin)
-- count deaths in state for age group
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities.decd
WHERE decd_age_yr is not null
),
-- sum total population of state within age group
pop as(
SELECT
    SUM(a.total_total_pop) + SUM(b.total_total_pop) + SUM(c.total_total_pop) + SUM(d.total_total_pop) + SUM(e.total_total_pop)
   as total_age_pop
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
-- rate = deaths/population (no longer pop*5)
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
-- apply calculated rate to population of each zcta (find expected deaths)
expected as (
SELECT a.zcta, (
    a.total_total_pop + b.total_total_pop + c.total_total_pop + d.total_total_pop + e.total_total_pop
   )*r.age_rate as expected_deaths
FROM zcta_age_sex_2011 as a
   INNER JOIN zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
-- number of observed deaths
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities.decd
GROUP BY zip
)
-- observed/expected
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0;


-- overall (arcpro)
WITH deaths as(
SELECT COUNT(1) as num_deaths
FROM disparities_mapping.disparities.decd
WHERE decd_age_yr is not null
),
pop as(
SELECT
    SUM(a.total_total_pop) + SUM(b.total_total_pop) + SUM(c.total_total_pop) + SUM(d.total_total_pop) + SUM(e.total_total_pop)
   as total_age_pop
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
),
rate as(
SELECT d.num_deaths::double precision/(p.total_age_pop::double precision) as age_rate
FROM deaths d, pop p
),
expected as (
SELECT a.zcta, (
    a.total_total_pop + b.total_total_pop + c.total_total_pop + d.total_total_pop + e.total_total_pop
   )*r.age_rate as expected_deaths
FROM disparities_mapping.public.zcta_age_sex_2011 as a
   INNER JOIN disparities_mapping.public.zcta_age_sex_2012 as b ON a.zcta = b.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2013 as c ON a.zcta = c.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2014 as d ON a.zcta = d.zcta
   INNER JOIN disparities_mapping.public.zcta_age_sex_2015 as e ON a.zcta = e.zcta
   , rate r
),
observed as(
SELECT COUNT(1) as observed_deaths, decd_res_zip5 as zip
FROM disparities_mapping.disparities.decd
GROUP BY zip
)
SELECT z.zcta5ce10 as zcta, e.expected_deaths, o.observed_deaths,
    (o.observed_deaths/e.expected_deaths) as ratio, z.geom
FROM disparities_mapping.public.zip_code_tabulation_areas z
LEFT JOIN observed o ON o.zip = z.zcta5ce10
LEFT JOIN expected e ON e.zcta = z.zcta5ce10::int
WHERE e.expected_deaths <> 0




