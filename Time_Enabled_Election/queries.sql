-- STATE, pgadmin version
-- does take a while to run. Counties may not be feasible?
SELECT s.id, s.election_year, s.state_po, s.party, s.candidate_votes, s.total_votes, s.vote_percent, t.geom
FROM luick.state_winners as s, luick.tl_2019_us_state as t
WHERE s.state_po = t.stusps

--STATE, arcpro version
SELECT s.id, s.election_year, s.state_po, s.party, s.candidate_votes, s.total_votes, s.vote_percent, t.geom
FROM spatial_analytics.luick.state_winners as s, spatial_analytics.luick.tl_2019_us_state as t
WHERE s.state_po = t.stusps

-- COUNTY, pgadmin version
WITH concat_fp as (
SELECT CONCAT(statefp, countyfp)::int as full_fp, geom
FROM luick.tl_2019_us_county
)
SELECT c.id, c.election_year, c.fips, c.candidate, c.party, c.candidate_votes, c.total_votes, c.vote_percent, f.geom
FROM luick.county_winners as c, concat_fp as f
WHERE c.fips = f.full_fp

-- COUNTY, arcpro version
WITH concat_fp as (
SELECT CONCAT(statefp, countyfp)::int as full_fp, geom
FROM spatial_analytics.luick.tl_2019_us_county
)
SELECT c.id, c.election_year, c.fips, c.candidate, c.party, c.candidate_votes, c.total_votes, c.vote_percent, f.geom
FROM spatial_analytics.luick.county_winners as c, concat_fp as f
WHERE c.fips = f.full_fp