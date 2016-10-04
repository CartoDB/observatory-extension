\pset format unaligned
\set ECHO none
SET client_min_messages TO WARNING;

-- set up variables for use in testing

\set cartodb_census_tract_geometry ''

\set cartodb_county_geometry ''

-- _OBS_SearchTables tests
SELECT
  t.table_name = 'obs_1babf5a26a1ecda5fb74963e88408f71d0364b81' As _OBS_SearchTables_tables_match,
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

SELECT COUNT(*) > 0 AS _OBS_SearchTotalPop
FROM cdb_observatory.OBS_Search('total_pop')
AS t(id, description, name, aggregate, source);

SELECT COUNT(*) > 0 AS _OBS_GetAvailableBoundariesExist
FROM cdb_observatory.OBS_GetAvailableBoundaries(
  cdb_observatory._TestPoint()
) AS t(boundary_id, description, time_span, tablename);

--
-- OBS_GetAvailableNumerators tests
--

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators())
AS _obs_getavilablenumerators_usa_pop_in_all;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavilablenumerators_usa_pop_in_nyc_point;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakeEnvelope(
      -169.8046875, 21.289374355860424,
      -47.4609375, 72.0739114882038
  ), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavilablenumerators_usa_pop_in_usa_extents;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(0, 0), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavilablenumerators_no_usa_pop_not_in_zero_point;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.age_gender']
))
AS _obs_getavilablenumerators_usa_pop_in_age_gender_subsection;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.income']
))
AS _obs_getavilablenumerators_no_pop_in_income_subsection;

SELECT 'us.census.acs.B01001002' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001'
) WHERE valid_denom = True)
AS _obs_getavilablenumerators_male_pop_denominated_by_total_pop;

SELECT 'us.census.acs.B19013001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001'
) WHERE valid_denom = True)
AS _obs_getavilablenumerators_no_income_denominated_by_total_pop;

SELECT 'us.zillow.AllHomes_Zhvi' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.tiger.zcta5'
) WHERE valid_geom = True)
AS _obs_getavilablenumerators_zillow_at_zcta5;

SELECT 'us.zillow.AllHomes_Zhvi' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.tiger.block_group'
) WHERE valid_geom = True)
AS _obs_getavilablenumerators_no_zillow_at_block_group;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '2010 - 2014'
) WHERE valid_timespan = True)
AS _obs_getavilablenumerators_total_pop_2010_2014;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '1996'
) WHERE valid_timespan = True)
AS _obs_getavilablenumerators_no_total_pop_1996;

/*
SELECT * FROM  cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['unit/tags.money'], '', '', ''
);

SELECT * FROM  cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['unit/tags.money', 'subsection/tags.housing'], '', '', ''
);
*/

--
-- OBS_GetAvailableDenominators tests
--

/*
SELECT * FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B03002006', 'us.census.tiger.census_tract', ''
) where valid_numer IS true and valid_geom IS true;
*/

--
-- OBS_GetAvailableGeometries tests
--

/*
SELECT * FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B03002006', 'us.census.acs.B01003001', ''
) where valid_numer IS true and valid_denom IS true;
*/

--
-- OBS_GetAvailableTimespans tests
--

/*
SELECT * FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B03002006', 'us.census.acs.B01003001', 'us.census.tiger.census_tract'
) where valid_numer IS true and valid_denom IS true AND valid_geom IS true;
*/

-- OBS_LegacyBuilderMetadata tests

SELECT 'us.census.acs.B01003001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata()
) AS _total_pop_in_legacy_builder_metadata;

SELECT 'us.census.acs.B19013001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata()
) AS _median_income_in_legacy_builder_metadata;

SELECT 'us.census.acs.B01003001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata('sum')
) AS _total_pop_in_legacy_builder_metadata_sums;

SELECT 'us.census.acs.B19013001' NOT IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata('sum')
) AS _median_income_not_in_legacy_builder_metadata_sums;

