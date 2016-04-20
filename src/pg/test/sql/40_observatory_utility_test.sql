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
SELECT
  (unnest(cdb_observatory._OBS_GetColumnData(
    '"us.census.tiger".census_tract',
    Array['"us.census.tiger".census_tract_geoid', '"us.census.acs".B01001001'],
    '2009 - 2013'
  ))).*
ORDER BY colname, tablename ASC;

-- should be null-valued
SELECT
  (unnest(cdb_observatory._OBS_GetColumnData(
    '"us.census.tiger".census_tract',
    Array['"us.census.tiger".baloney'], -- entry not in catalog
    '2009 - 2013'
  ))).*
ORDER BY 1 ASC;

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

SELECT
  select * from  cdb_observatory._GetRelatedColumn(
    Array[
    '"es.ine".pop_0_4',
     '"us.census.acs".B01001001',
    '"us.census.acs".B01001002'
    ],
     'denominator'
 );

\i test/sql/drop_fixtures.sql
