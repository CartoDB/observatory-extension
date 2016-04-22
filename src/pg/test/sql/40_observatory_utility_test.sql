\i test/sql/load_fixtures.sql

\set ECHO all

-- OBS_GeomTable
-- get table with known geometry_id
-- should give back a table like obs_{hex hash}
SELECT
  cdb_observatory._OBS_GeomTable(
    CDB_LatLng(40.7128,-74.0059),
    '"us.census.tiger".census_tract'
  );

-- get null for unknown geometry_id
-- should give back null
SELECT
  cdb_observatory._OBS_GeomTable(
    CDB_LatLng(40.7128,-74.0059),
    '"us.census.tiger".nonexistant_id' -- not in catalog
  );

-- future test: give back nulls when geometry doesn't intersect
-- SELECT
--   cdb_observatory._OBS_GeomTable(
--     CDB_LatLng(0,0), -- should give back null since it's in the ocean?
--     '"us.census.tiger".census_tract'
--   );

-- OBS_GetColumnData
-- should give back:
--  colname   | tablename       | aggregate
-- -----------|-----------------|-----------
--  geoid     | obs_{hex table} | null
--  total_pop | obs_{hex table} | sum
WITH result as (
SELECT
  array_agg(a) expected from cdb_observatory._OBS_GetColumnData(
    '"us.census.tiger".census_tract',
    Array['"us.census.tiger".census_tract_geoid', '"us.census.acs".B01001001'],
    '2009 - 2013') a 
)
select (expected)[1]::text  = '{"colname":"geoid","tablename":"obs_d34555209878e8c4b37cf0b2b3d072ff129ec470","aggregate":null,"name":"US Census Tract Geoids","type":"Text","description":""}' as test_get_obs_column_with_geoid_and_census_1,
       (expected)[2]::text  = '{"colname":"geoid","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":null,"name":"US Census Tract Geoids","type":"Text","description":""}' as test_get_obs_column_with_geoid_and_census_2,
       (expected)[3]::text  = '{"colname":"geoid","tablename":"obs_65f29658e096ca1485bf683f65fdbc9f05ec3c5d","aggregate":null,"name":"US Census Tract Geoids","type":"Text","description":""}' as test_get_obs_column_with_geoid_and_census_3
from result;


-- should be null-valued
WITH result as (
SELECT
  array_agg(a) expected from cdb_observatory._OBS_GetColumnData(
    '"us.census.tiger".census_tract',
    Array['"us.census.tiger".baloney'],
    '2009 - 2013') a 
)
select expected is null as OBS_GetColumnDataJSON_missing_measure
from result;

-- OBS_LookupCensusHuman
-- should give back: {"\"us.census.acs\".B19083001"}
SELECT
  cdb_observatory._OBS_LookupCensusHuman(
    Array['gini_index']
  );

-- should be empty array
SELECT
  cdb_observatory._OBS_LookupCensusHuman(
    Array['cookies']
  );

-- OBS_BuildSnapshotQuery
-- Should give back: SELECT  vals[1] As total_pop, vals[2] As male_pop, vals[3] As female_pop, vals[4] As median_age
SELECT
  cdb_observatory._OBS_BuildSnapshotQuery(
    Array['total_pop','male_pop','female_pop','median_age']
  );

-- should give back: SELECT  vals[1] As mandarin_orange
SELECT
  cdb_observatory._OBS_BuildSnapshotQuery(
    Array['mandarin_orange']
  );

SELECT cdb_observatory._OBS_GetRelatedColumn(
    Array[
    '"es.ine".pop_0_4',
     '"us.census.acs".B01001001',
    '"us.census.acs".B01001002'
    ],
     'denominator'
 );

\i test/sql/drop_fixtures.sql
