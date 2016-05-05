\i test/fixtures/load_fixtures.sql
\pset format unaligned

-- set up variables for use in testing

\set cartodb_census_tract_geometry ''

\set cartodb_county_geometry ''

-- _OBS_SearchTables tests
SELECT 
  t.table_name As _OBS_SearchTables_tables_match,
  t.timespan = '2014' As _OBS_SearchTables_timespan_matches
FROM cdb_observatory._OBS_SearchTables(
  'us.census.tiger.county',
  '2014'
) As t(table_name, timespan);

-- _OBS_SearchTables tests
-- should not return tables for year that does not match
SELECT count(*) = 0 As _OBS_SearchTables_timespan_does_not_match
FROM cdb_observatory._OBS_SearchTables(
  'us.census.tiger.county',
  '1988' -- year before first tiger data was collected
) As t(table_name, timespan);

SELECT cdb_observatory.OBS_Search('total_pop');

SELECT * from cdb_observatory.OBS_GetAvailableBoundaries(cdb_observatory._TestPoint());

\i test/fixtures/drop_fixtures.sql
