\pset format unaligned
\set ECHO none
SET client_min_messages TO WARNING;

-- set up variables for use in testing

\set cartodb_census_tract_geometry ''

\set cartodb_county_geometry ''

-- _OBS_SearchTables tests
SELECT
  t.table_name = 'obs_0310c639744a2014bb1af82709228f05b59e7d3d' As _OBS_SearchTables_tables_match,
  t.timespan = '2015' As _OBS_SearchTables_timespan_matches
FROM cdb_observatory._OBS_SearchTables(
  'us.census.tiger.county',
  '2015'
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
AS _obs_getavailablenumerators_usa_pop_in_all;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailablenumerators_usa_pop_in_nyc_point;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakeEnvelope(
      -169.8046875, 21.289374355860424,
      -47.4609375, 72.0739114882038
  ), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailablenumerators_usa_pop_in_usa_extents;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(0, 0), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailablenumerators_no_usa_pop_not_in_zero_point;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.age_gender']
))
AS _obs_getavailablenumerators_usa_pop_in_age_gender_subsection;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.income']
))
AS _obs_getavailablenumerators_no_pop_in_income_subsection;

SELECT 'us.census.acs.B01001002' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001'
) WHERE valid_denom = True)
AS _obs_getavailablenumerators_male_pop_denom_by_total_pop;

SELECT 'us.census.acs.B19013001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001'
) WHERE valid_denom = True)
AS _obs_getavailablenumerators_no_income_denom_by_total_pop;

SELECT 'us.zillow.AllHomes_Zhvi' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.tiger.zcta5'
) WHERE valid_geom = True)
AS _obs_getavailablenumerators_zillow_at_zcta5;

SELECT 'us.zillow.AllHomes_Zhvi' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.tiger.block_group'
) WHERE valid_geom = True)
AS _obs_getavailablenumerators_no_zillow_at_block_group;

SELECT 'us.census.acs.B01003001' IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '2010 - 2014'
) WHERE valid_timespan = True)
AS _obs_getavailablenumerators_total_pop_2010_2014;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT numer_id
FROM cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '1996'
) WHERE valid_timespan = True)
AS _obs_getavailablenumerators_no_total_pop_1996;

--
-- OBS_GetAvailableDenominators tests
--

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators())
AS _obs_getavailabledenominators_usa_pop_in_all;

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailabledenominators_usa_pop_in_nyc_point;

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakeEnvelope(
      -169.8046875, 21.289374355860424,
      -47.4609375, 72.0739114882038
  ), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailabledenominators_usa_pop_in_usa_extents;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(0, 0), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailabledenominators_no_usa_pop_not_in_zero_point;

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.age_gender']
))
AS _obs_getavailabledenominators_usa_pop_in_age_gender_subsection;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.income']
))
AS _obs_getavailabledenominators_no_pop_in_income_subsection;

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01001002'
) WHERE valid_numer = True)
AS _obs_getavailabledenominators_male_pop_denom_by_total_pop;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B19013001'
) WHERE valid_numer = True)
AS _obs_getavailabledenominators_no_income_denom_by_total_pop;

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.tiger.zcta5'
) WHERE valid_geom = True)
AS _obs_getavailabledenominators_at_zcta5;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'es.ine.the_geom'
) WHERE valid_geom = True)
AS _obs_getavailabledenominators_none_spanish_geom;

SELECT 'us.census.acs.B01003001' IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '2010 - 2014'
) WHERE valid_timespan = True)
AS _obs_getavailabledenominators_total_pop_2010_2014;

SELECT 'us.census.acs.B01003001' NOT IN (SELECT denom_id
FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '1996'
) WHERE valid_timespan = True)
AS _obs_getavailabledenominators_no_total_pop_1996;

--
-- OBS_GetAvailableGeometries tests
--

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries())
AS _obs_getavailablegeometries_usa_bg_in_all;

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailablegeometries_usa_bg_in_nyc_point;

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakeEnvelope(
      -169.8046875, 21.289374355860424,
      -47.4609375, 72.0739114882038
  ), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailablegeometries_usa_bg_in_usa_extents;

SELECT 'us.census.tiger.block_group' NOT IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(0, 0), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailablegeometries_no_usa_bg_not_in_zero_point;

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['subsection/tags.boundary']
))
AS _obs_getavailablegeometries_usa_bg_in_boundary_subsection;

SELECT 'us.census.tiger.block_group' NOT IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['section/tags.uk']
))
AS _obs_getavailablegeometries_no_bg_in_uk_section;

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001'
) WHERE valid_numer = True)
AS _obs_getavailablegeometries_total_pop_in_usa_bg;

SELECT 'us.census.tiger.block_group' NOT IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'foo.bar.baz'
) WHERE valid_numer = True)
AS _obs_getavailablegeometries_foobarbaz_not_in_usa_bg;

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.acs.B01003001'
) WHERE valid_denom = True)
AS _obs_getavailablegeometries_total_pop_denom_in_usa_bg;

SELECT 'us.census.tiger.block_group' NOT IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'foo.bar.baz'
) WHERE valid_denom = True)
AS _obs_getavailablegeometries_foobarbaz_denom_not_in_usa_bg;

SELECT 'us.census.tiger.block_group' IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '2015'
) WHERE valid_timespan = True)
AS _obs_getavailablegeometries_bg_2015;

SELECT 'us.census.tiger.block_group' NOT IN (SELECT geom_id
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, '1996'
) WHERE valid_timespan = True)
AS _obs_getavailablegeometries_bg_not_1996;

SELECT 'subsection/tags.boundary' IN (SELECT (Jsonb_Each(geom_tags)).key
FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)
)) AS _obs_getavailablegeometries_has_boundary_tag;

--
-- OBS_GetAvailableTimespans tests
--

SELECT '2010 - 2014' IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans())
AS _obs_getavailabletimespans_2010_2014_in_all;

SELECT '2010 - 2014' IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailabletimespans_2010_2014_in_nyc_point;

SELECT '2010 - 2014' IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakeEnvelope(
      -169.8046875, 21.289374355860424,
      -47.4609375, 72.0739114882038
  ), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailabletimespans_2010_2014_in_usa_extents;

SELECT '2010 - 2014' NOT IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(0, 0), 4326),
  NULL, NULL, NULL, NULL
)) AS _obs_getavailabletimespans_no_usa_bg_not_in_zero_point;

SELECT '2010 - 2014' IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001'
) WHERE valid_numer = True)
AS _obs_getavailabletimespans_total_pop_in_2010_2014;

SELECT '2010 - 2014' NOT IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'foo.bar.baz'
) WHERE valid_numer = True)
AS _obs_getavailabletimespans_foobarbaz_not_in_2010_2014;

SELECT '2010 - 2014' IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'us.census.acs.B01003001'
) WHERE valid_denom = True)
AS _obs_getavailablegeometries_total_pop_denom_in_2010_2014;

SELECT '2010 - 2014' NOT IN (SELECT timespan_id
FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, NULL, 'foo.bar.baz'
) WHERE valid_denom = True)
AS _obs_getavailablegeometries_foobarbaz_denom_not_in_2010_2014;

--
-- _OBS_GetGeometryScores tests
--

SELECT ARRAY_AGG(column_id ORDER BY score DESC) =
       ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
             'us.census.tiger.county', 'us.census.tiger.zcta5']
       AS _obs_geometryscores_500m_buffer
       FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 500)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.county', 'us.census.tiger.zcta5'])
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC)
       = ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
             'us.census.tiger.county', 'us.census.tiger.zcta5']
       AS _obs_geometryscores_5km_buffer
       FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 5000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.county', 'us.census.tiger.zcta5'])
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC) =
       ARRAY['us.census.tiger.census_tract', 'us.census.tiger.block_group',
             'us.census.tiger.zcta5', 'us.census.tiger.county']
       AS _obs_geometryscores_50km_buffer
       FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 50000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC) =
       ARRAY[ 'us.census.tiger.zcta5', 'us.census.tiger.census_tract',
              'us.census.tiger.county', 'us.census.tiger.block_group' ]
      AS _obs_geometryscores_500km_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 500000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC)
       = ARRAY['us.census.tiger.county', 'us.census.tiger.census_tract',
             'us.census.tiger.zcta5', 'us.census.tiger.block_group']
      AS _obs_geometryscores_2500km_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 2500000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.county', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.block_group'])
      WHERE table_id LIKE '%2015%';

SELECT column_id, numgeoms::int AS _obs_geometryscores_numgeoms_500m_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 500)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%'
      ORDER BY numgeoms DESC;

SELECT column_id, numgeoms::int AS _obs_geometryscores_numgeoms_5km_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 5000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%'
      ORDER BY numgeoms DESC;

SELECT column_id, numgeoms::int AS _obs_geometryscores_numgeoms_50km_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 50000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%'
      ORDER BY numgeoms DESC;

SELECT column_id, numgeoms::int AS _obs_geometryscores_numgeoms_500km_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 500000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%'
      ORDER BY numgeoms DESC;

SELECT column_id, numgeoms::int AS _obs_geometryscores_numgeoms_2500km_buffer
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 2500000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'])
      WHERE table_id LIKE '%2015%'
      ORDER BY numgeoms DESC;

SELECT ARRAY_AGG(column_id ORDER BY score DESC) =
       ARRAY['us.census.tiger.county', 'us.census.tiger.zcta5',
             'us.census.tiger.census_tract', 'us.census.tiger.block_group']
      AS _obs_geometryscores_500km_buffer_50_geoms
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 50000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'], 50)
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC)
      = ARRAY['us.census.tiger.zcta5', 'us.census.tiger.census_tract',
              'us.census.tiger.county', 'us.census.tiger.block_group']
      AS _obs_geometryscores_500km_buffer_500_geoms
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 50000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'], 500)
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC) =
       ARRAY['us.census.tiger.census_tract', 'us.census.tiger.block_group',
             'us.census.tiger.zcta5', 'us.census.tiger.county']
      AS _obs_geometryscores_500km_buffer_2500_geoms
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 50000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'], 2500)
      WHERE table_id LIKE '%2015%';

SELECT ARRAY_AGG(column_id ORDER BY score DESC)
       = ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
               'us.census.tiger.county', 'us.census.tiger.zcta5']
      AS _obs_geometryscores_500km_buffer_25000_geoms
      FROM cdb_observatory._OBS_GetGeometryScores(
  ST_Buffer(ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)::Geography, 50000)::Geometry(Geometry, 4326),
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'], 25000)
      WHERE table_id LIKE '%2015%';

-- Check that one small geom approximates tract data
WITH geoms AS (SELECT cdb_observatory._testarea() the_geom),
summary AS (SELECT ST_SetSRID(ST_Extent(the_geom), 4326) extent,
                   COUNT(*)::INT cnt,
                   SUM(ST_Area(the_geom))::Numeric sumarea
            FROM geoms)
SELECT column_id = 'us.census.tiger.census_tract' testarea_uses_tract
FROM summary, LATERAL (
  SELECT *
  FROM cdb_observatory._OBS_GetGeometryScores(extent,
  ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
        'us.census.tiger.zcta5', 'us.census.tiger.county'],
        cnt, sumarea)) foo
ORDER BY score DESC LIMIT 1;

-- Check that randomly distributed points always use smallest geometry if we
-- order by numgeoms desc
WITH geoms as (SELECT UNNEST(ARRAY[
    cdb_observatory._testpoint(),
    st_translate(cdb_observatory._testpoint(), -0.003, 0),
    st_translate(cdb_observatory._testpoint(), -0.006, 0)
]) the_geom),
summary as (SELECT
  ST_SetSRID(ST_Extent(the_geom), 4326) extent,
  SUM(ST_Area(the_geom))::Numeric area,
  COUNT(*)::INTEGER cnt
  FROM geoms
)
SELECT column_id = 'us.census.tiger.block_group' points_use_bg
      FROM summary, LATERAL (
        SELECT * FROM cdb_observatory._OBS_GetGeometryScores(
          extent,
          ARRAY['us.census.tiger.block_group', 'us.census.tiger.census_tract',
                'us.census.tiger.zcta5', 'us.census.tiger.county'],
        cnt, area)) foo
      WHERE table_id LIKE '%2015%'
      ORDER BY numgeoms DESC LIMIT 1;

--
-- OBS_LegacyBuilderMetadata tests
--

SELECT 'us.census.acs.B01003001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata()
) AS _total_pop_in_legacy_builder_metadata;

SELECT 'us.census.acs.B19013001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata()
) AS _median_income_in_legacy_builder_metadata;

SELECT 'us.census.acs.B19083001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata()
) AS _gini_in_legacy_builder_metadata;

SELECT 'us.census.acs.B01003001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata('sum')
) AS _total_pop_in_legacy_builder_metadata_sums;

SELECT 'us.census.acs.B19013001' IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata('sum')
) AS _median_income_in_legacy_builder_metadata_sums;

SELECT 'us.census.acs.B19083001' NOT IN (SELECT
  (jsonb_array_elements(((jsonb_array_elements(subsection))->'f1')->'columns')->'f1')->>'id' AS id
  FROM cdb_observatory.OBS_LegacyBuilderMetadata('sum')
) AS _gini_not_in_legacy_builder_metadata_sums;

SELECT COUNT(*) = 0 _no_dupe_subsections_in_legacy_builder_metadata FROM (
  SELECT name, subsection, count(*) FROM
    (SELECT name, ((JSONB_Array_Elements(subsection))->'f1')->>'id' subsection
    FROM cdb_observatory.obs_legacybuildermetadata()) foo
  GROUP BY name, subsection
  HAVING count(*) > 1
) bar;

