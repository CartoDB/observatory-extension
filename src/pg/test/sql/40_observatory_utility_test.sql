\pset format unaligned
\set ECHO all
\i test/fixtures/load_fixtures.sql
SET client_min_messages TO WARNING;
\set ECHO none

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

-- should give back a standardized measure name
SELECT cdb_observatory._OBS_StandardizeMeasureName('test 343 %% 2 qqq }}{{}}') = 'test_343_2_qqq' As _OBS_StandardizeMeasureName_test;

SELECT cdb_observatory.OBS_DumpVersion()
  IS NOT NULL AS OBS_DumpVersion_notnull;
