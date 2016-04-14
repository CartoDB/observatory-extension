SELECT set_config(
    'search_path',
    current_setting('search_path') || ',cdb_observatory,observatory',
    false
) WHERE current_setting('search_path') !~ '(^|,)(cdb_observatory|observatory)(,|$)';

\i test/sql/02_load_fixtures.sql


-- OBS_GeomTable
-- get table with known geometry_id
-- should give back a table like obs_{hex hash}
SELECT 
  cdb_observatory.OBS_GeomTable(
    CDB_LatLng(40.7128,-74.0059),
    '"us.census.tiger".census_tract'
  );

-- get null for unknown geometry_id
-- should give back null
SELECT 
  cdb_observatory.OBS_GeomTable(
    CDB_LatLng(40.7128,-74.0059),
    '"us.census.tiger".nonexistant_id'
  );

-- OBS_GetColumnData
-- should give back:
--  colname   | tablename       | aggregate
-- -----------|-----------------|-----------
--  geoid     | obs_{hex table} | null
--  total_pop | obs_{hex table} | sum
SELECT 
  (unnest(cdb_observatory.OBS_GetColumnData(
    '"us.census.tiger".census_tract',
    Array['"us.census.tiger".census_tract_geoid', '"us.census.acs".B01001001'],
    '2009 - 2013'
  ))).*
ORDER BY 1 ASC;

-- OBS_LookupCensusHuman
-- should give back: {"\"us.census.acs\".B19083001"}
SELECT 
  cdb_observatory.OBS_LookupCensusHuman(
    Array['gini_index']
  );

-- OBS_BuildSnapshotQuery
-- Should give back: SELECT  vals[1] As total_pop, vals[2] As male_pop, vals[3] As female_pop, vals[4] As median_age
SELECT 
  cdb_observatory.OBS_BuildSnapshotQuery(
    Array['total_pop','male_pop','female_pop','median_age']
  );

\i test/sql/03_drop_fixtures.sql