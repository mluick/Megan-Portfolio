BEGIN;
--ddl for American Community Survey zcta population data by age and sex

-- 2011
DROP TABLE IF EXISTS zcta_age_sex_2011;

CREATE TABLE zcta_age_sex_2011(
zcta	integer,
total_total_pop	integer,
male_total_pop	integer,
female_total_pop	integer,
total_under5	double precision,
male_under5	double precision,
female_under5	double precision,
total_5_9	double precision,
male_5_9	double precision,
female_5_9	double precision,
total_10_14	double precision,
male_10_14	double precision,
female_10_14	double precision,
total_15_19	double precision,
male_15_19	double precision,
female_15_19	double precision,
total_20_24	double precision,
male_20_24	double precision,
female_20_24	double precision,
total_25_29	double precision,
male_25_29	double precision,
female_25_29	double precision,
total_30_34	double precision,
male_30_34	double precision,
female_30_34	double precision,
total_35_39	double precision,
male_35_39	double precision,
female_35_39	double precision,
total_40_44	double precision,
male_40_44	double precision,
female_40_44	double precision,
total_45_49	double precision,
male_45_49	double precision,
female_45_49	double precision,
total_50_54	double precision,
male_50_54	double precision,
female_50_54	double precision,
total_55_59	double precision,
male_55_59	double precision,
female_55_59	double precision,
total_60_64	double precision,
male_60_64	double precision,
female_60_64	double precision,
total_65_69	double precision,
male_65_69	double precision,
female_65_69	double precision,
total_70_74	double precision,
male_70_74	double precision,
female_70_74	double precision,
total_75_79	double precision,
male_75_79	double precision,
female_75_79	double precision,
total_80_84	double precision,
male_80_84	double precision,
female_80_84	double precision,
total_85andover	double precision,
male_85andover	double precision,
female_85andover	double precision
);

\COPY zcta_age_sex_2011 FROM 'C:\Users\luick006\Documents\GitHub\disparities_mapping\data\acs_zcta_age_sex_pop_usable\ACS_2011_age_sex.csv' WITH CSV HEADER;
--CREATE INDEX zcta_age_sex_2011_index ON zcta_age_sex_2011 USING BTREE(zcta);

-- 2012
DROP TABLE IF EXISTS zcta_age_sex_2012;

CREATE TABLE zcta_age_sex_2012(
zcta	integer,
total_total_pop	integer,
male_total_pop	integer,
female_total_pop	integer,
total_under5	double precision,
male_under5	double precision,
female_under5	double precision,
total_5_9	double precision,
male_5_9	double precision,
female_5_9	double precision,
total_10_14	double precision,
male_10_14	double precision,
female_10_14	double precision,
total_15_19	double precision,
male_15_19	double precision,
female_15_19	double precision,
total_20_24	double precision,
male_20_24	double precision,
female_20_24	double precision,
total_25_29	double precision,
male_25_29	double precision,
female_25_29	double precision,
total_30_34	double precision,
male_30_34	double precision,
female_30_34	double precision,
total_35_39	double precision,
male_35_39	double precision,
female_35_39	double precision,
total_40_44	double precision,
male_40_44	double precision,
female_40_44	double precision,
total_45_49	double precision,
male_45_49	double precision,
female_45_49	double precision,
total_50_54	double precision,
male_50_54	double precision,
female_50_54	double precision,
total_55_59	double precision,
male_55_59	double precision,
female_55_59	double precision,
total_60_64	double precision,
male_60_64	double precision,
female_60_64	double precision,
total_65_69	double precision,
male_65_69	double precision,
female_65_69	double precision,
total_70_74	double precision,
male_70_74	double precision,
female_70_74	double precision,
total_75_79	double precision,
male_75_79	double precision,
female_75_79	double precision,
total_80_84	double precision,
male_80_84	double precision,
female_80_84	double precision,
total_85andover	double precision,
male_85andover	double precision,
female_85andover	double precision
);

\COPY zcta_age_sex_2012 FROM 'C:\Users\luick006\Documents\GitHub\disparities_mapping\data\acs_zcta_age_sex_pop_usable\ACS_2012_age_sex.csv' WITH CSV HEADER;

-- 2013
DROP TABLE IF EXISTS zcta_age_sex_2013;

CREATE TABLE zcta_age_sex_2013(
zcta	integer,
total_total_pop	integer,
male_total_pop	integer,
female_total_pop	integer,
total_under5	double precision,
male_under5	double precision,
female_under5	double precision,
total_5_9	double precision,
male_5_9	double precision,
female_5_9	double precision,
total_10_14	double precision,
male_10_14	double precision,
female_10_14	double precision,
total_15_19	double precision,
male_15_19	double precision,
female_15_19	double precision,
total_20_24	double precision,
male_20_24	double precision,
female_20_24	double precision,
total_25_29	double precision,
male_25_29	double precision,
female_25_29	double precision,
total_30_34	double precision,
male_30_34	double precision,
female_30_34	double precision,
total_35_39	double precision,
male_35_39	double precision,
female_35_39	double precision,
total_40_44	double precision,
male_40_44	double precision,
female_40_44	double precision,
total_45_49	double precision,
male_45_49	double precision,
female_45_49	double precision,
total_50_54	double precision,
male_50_54	double precision,
female_50_54	double precision,
total_55_59	double precision,
male_55_59	double precision,
female_55_59	double precision,
total_60_64	double precision,
male_60_64	double precision,
female_60_64	double precision,
total_65_69	double precision,
male_65_69	double precision,
female_65_69	double precision,
total_70_74	double precision,
male_70_74	double precision,
female_70_74	double precision,
total_75_79	double precision,
male_75_79	double precision,
female_75_79	double precision,
total_80_84	double precision,
male_80_84	double precision,
female_80_84	double precision,
total_85andover	double precision,
male_85andover	double precision,
female_85andover	double precision
);

\COPY zcta_age_sex_2013 FROM 'C:\Users\luick006\Documents\GitHub\disparities_mapping\data\acs_zcta_age_sex_pop_usable\ACS_2013_age_sex.csv' WITH CSV HEADER;

-- 2014
DROP TABLE IF EXISTS zcta_age_sex_2014;

CREATE TABLE zcta_age_sex_2014(
zcta	integer,
total_total_pop	integer,
male_total_pop	integer,
female_total_pop	integer,
total_under5	double precision,
male_under5	double precision,
female_under5	double precision,
total_5_9	double precision,
male_5_9	double precision,
female_5_9	double precision,
total_10_14	double precision,
male_10_14	double precision,
female_10_14	double precision,
total_15_19	double precision,
male_15_19	double precision,
female_15_19	double precision,
total_20_24	double precision,
male_20_24	double precision,
female_20_24	double precision,
total_25_29	double precision,
male_25_29	double precision,
female_25_29	double precision,
total_30_34	double precision,
male_30_34	double precision,
female_30_34	double precision,
total_35_39	double precision,
male_35_39	double precision,
female_35_39	double precision,
total_40_44	double precision,
male_40_44	double precision,
female_40_44	double precision,
total_45_49	double precision,
male_45_49	double precision,
female_45_49	double precision,
total_50_54	double precision,
male_50_54	double precision,
female_50_54	double precision,
total_55_59	double precision,
male_55_59	double precision,
female_55_59	double precision,
total_60_64	double precision,
male_60_64	double precision,
female_60_64	double precision,
total_65_69	double precision,
male_65_69	double precision,
female_65_69	double precision,
total_70_74	double precision,
male_70_74	double precision,
female_70_74	double precision,
total_75_79	double precision,
male_75_79	double precision,
female_75_79	double precision,
total_80_84	double precision,
male_80_84	double precision,
female_80_84	double precision,
total_85andover	double precision,
male_85andover	double precision,
female_85andover	double precision
);

\COPY zcta_age_sex_2014 FROM 'C:\Users\luick006\Documents\GitHub\disparities_mapping\data\acs_zcta_age_sex_pop_usable\ACS_2014_age_sex.csv' WITH CSV HEADER;

-- 2015
DROP TABLE IF EXISTS zcta_age_sex_2015;

CREATE TABLE zcta_age_sex_2015(
zcta	integer,
total_total_pop	integer,
male_total_pop	integer,
female_total_pop	integer,
total_under5	double precision,
male_under5	double precision,
female_under5	double precision,
total_5_9	double precision,
male_5_9	double precision,
female_5_9	double precision,
total_10_14	double precision,
male_10_14	double precision,
female_10_14	double precision,
total_15_19	double precision,
male_15_19	double precision,
female_15_19	double precision,
total_20_24	double precision,
male_20_24	double precision,
female_20_24	double precision,
total_25_29	double precision,
male_25_29	double precision,
female_25_29	double precision,
total_30_34	double precision,
male_30_34	double precision,
female_30_34	double precision,
total_35_39	double precision,
male_35_39	double precision,
female_35_39	double precision,
total_40_44	double precision,
male_40_44	double precision,
female_40_44	double precision,
total_45_49	double precision,
male_45_49	double precision,
female_45_49	double precision,
total_50_54	double precision,
male_50_54	double precision,
female_50_54	double precision,
total_55_59	double precision,
male_55_59	double precision,
female_55_59	double precision,
total_60_64	double precision,
male_60_64	double precision,
female_60_64	double precision,
total_65_69	double precision,
male_65_69	double precision,
female_65_69	double precision,
total_70_74	double precision,
male_70_74	double precision,
female_70_74	double precision,
total_75_79	double precision,
male_75_79	double precision,
female_75_79	double precision,
total_80_84	double precision,
male_80_84	double precision,
female_80_84	double precision,
total_85andover	double precision,
male_85andover	double precision,
female_85andover	double precision
);

\COPY zcta_age_sex_2015 FROM 'C:\Users\luick006\Documents\GitHub\disparities_mapping\data\acs_zcta_age_sex_pop_usable\ACS_2015_age_sex.csv' WITH CSV HEADER;

END;