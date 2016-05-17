\pset format unaligned
\set ECHO all
\i test/fixtures/load_fixtures.sql

-- OBS_GeomTable
-- get table with known geometry_id
-- should give back a table like obs_{hex hash}
SELECT
  cdb_observatory._OBS_GeomTable(
    ST_SetSRID(ST_Point(-74.0059, 40.7128), 4326),
    'us.census.tiger.census_tract',
    '2014'
  ) = 'obs_fc050f0b8673cfe3c6aa1040f749eb40975691b7' As _obs_geomtable_with_returned_table;

-- get null for unknown geometry_id
-- should give back null
SELECT
  cdb_observatory._OBS_GeomTable(
    ST_SetSRID(ST_Point(-74.0059, 40.7128), 4326),
    'us.census.tiger.nonexistant_id' -- not in catalog
  ) IS NULL _obs_geomtable_with_null_response;

-- future test: give back nulls when geometry doesn't intersect
-- SELECT
--   cdb_observatory._OBS_GeomTable(
--     ST_SetSRID(ST_Point(0,0)), -- should give back null since it's in the ocean?
--     'us.census.tiger.census_tract'
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
    'us.census.tiger.census_tract',
    Array['us.census.tiger.census_tract_geoid', 'us.census.acs.B01003001'],
    '2010 - 2014') a
)
select 
  (expected)[1]::text  = '{"colname":"geoid","tablename":"obs_1746e37b7cd28cb131971ea4187d42d71f09c5f3","aggregate":null,"name":"US Census Tracts Geoids","type":"Text","description":null,"boundary_id":"us.census.tiger.census_tract"}' as test_get_obs_column_with_geoid_and_census_1,
  (expected)[2]::text  = '{"colname":"geoid","tablename":"obs_b393b5b88c6adda634b2071a8005b03c551b609a","aggregate":null,"name":"US Census Tracts Geoids","type":"Text","description":null,"boundary_id":"us.census.tiger.census_tract"}' as test_get_obs_column_with_geoid_and_census_2
from result;

-- should be null-valued
WITH result as (
SELECT
  array_agg(a) expected from cdb_observatory._OBS_GetColumnData(
    'us.census.tiger.census_tract',
    Array['us.census.tiger.baloney'],
    '2010 - 2014') a
)
select expected is null as OBS_GetColumnData_missing_measure
from result;

-- OBS_BuildSnapshotQuery
-- Should give back: SELECT  vals[1] As total_pop, vals[2] As male_pop, vals[3] As female_pop, vals[4] As median_age
SELECT
  cdb_observatory._OBS_BuildSnapshotQuery(
    Array['total_pop','male_pop','female_pop','median_age']
  ) = 'SELECT  vals[1] As total_pop, vals[2] As male_pop, vals[3] As female_pop, vals[4] As median_age' As _OBS_BuildSnapshotQuery_test_1;

-- should give back: SELECT  vals[1] As mandarin_orange
SELECT
  cdb_observatory._OBS_BuildSnapshotQuery(
    Array['mandarin_orange']
  ) = 'SELECT  vals[1] As mandarin_orange' As _OBS_BuildSnapshotQuery_test_2;

SELECT cdb_observatory._OBS_GetRelatedColumn(
    Array[
     'es.ine.pop_0_4',
     'us.census.acs.B01003001',
     'us.census.acs.B01001002'
    ],
     'denominator'
 ) = '{es.ine.total_pop,NULL,us.census.acs.B01003001}' As _OBS_GetRelatedColumn_test;

-- should give back a standardized measure name
SELECT cdb_observatory._OBS_StandardizeMeasureName('test 343 %% 2 qqq }}{{}}') = 'test_343_2_qqq' As _OBS_StandardizeMeasureName_test;

\i test/fixtures/drop_fixtures.sql
