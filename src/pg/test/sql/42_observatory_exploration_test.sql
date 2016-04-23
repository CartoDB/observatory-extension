\i test/sql/load_fixtures.sql
\pset format unaligned

-- set up variables for use in testing

\set cartodb_census_tract_geometry ''

\set cartodb_county_geometry ''

-- _OBS_SearchTables tests
SELECT 
  t.table_name IN ('obs_b0ef6dd68d5faddbf231fd7f02916b3d00ec43c4', 
                   'obs_23da37d4e66e9de2f525572967f8618bde99a8c0') As _OBS_SearchTables_tables_match,
  t.timespan = '2013' As _OBS_SearchTables_timespan_matches
FROM cdb_observatory._OBS_SearchTables(
  '"us.census.tiger".county',
  '2013'
) As t(table_name, timespan);

-- _OBS_SearchTables tests
-- should not return tables for year that does not match
SELECT count(*) = 0 As _OBS_SearchTables_timespan_does_not_match
FROM cdb_observatory._OBS_SearchTables(
  '"us.census.tiger".county',
  '1988' -- year before first tiger data was collected
) As t(table_name, timespan);

\i test/sql/drop_fixtures.sql
