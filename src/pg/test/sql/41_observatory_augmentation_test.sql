\pset format unaligned
\set ECHO none
SET client_min_messages TO WARNING;

--
WITH result as(
  Select count(coalesce(OBS_GetDemographicSnapshot->>'value', 'foo')) expected_columns
  FROM cdb_observatory.OBS_GetDemographicSnapshot(cdb_observatory._TestPoint(), '2010 - 2014')
) select expected_columns = 52 as OBS_GetDemographicSnapshot_test_no_returns
FROM result;

SELECT cdb_observatory.OBS_GetSegmentSnapshot(
    cdb_observatory._TestPoint(),
    'us.census.tiger.census_tract'
)::JSONB =
 '{"x10_segment": "Wealthy, urban without Kids", "x55_segment": "Wealthy transplants displacing long-term local residents", "us.census.acs.B01001002_quantile": "0.494716216216216", "us.census.acs.B01001026_quantile": "0.183756756756757", "us.census.acs.B01002001_quantile": "0.0752837837837838", "us.census.acs.B01003001_quantile": "0.3235", "us.census.acs.B03002003_quantile": "0.293162162162162", "us.census.acs.B03002004_quantile": "0.455527027027027", "us.census.acs.B03002006_quantile": "0.656405405405405", "us.census.acs.B03002012_quantile": "0.840081081081081", "us.census.acs.B05001006_quantile": "0.727135135135135", "us.census.acs.B08006001_quantile": "0.688635135135135", "us.census.acs.B08006002_quantile": "0.0204459459459459", "us.census.acs.B08006009_quantile": "0.679324324324324", "us.census.acs.B08006011_quantile": "0.996716216216216", "us.census.acs.B08006015_quantile": "0.967418918918919", "us.census.acs.B08006017_quantile": "0.512945945945946", "us.census.acs.B08301010_quantile": "0.994743243243243", "us.census.acs.B09001001_quantile": "0.0504864864864865", "us.census.acs.B11001001_quantile": "0.192405405405405", "us.census.acs.B14001001_quantile": "0.331702702702703", "us.census.acs.B14001002_quantile": "0.296283783783784", "us.census.acs.B14001005_quantile": "0.045472972972973", "us.census.acs.B14001006_quantile": "0.0442702702702703", "us.census.acs.B14001007_quantile": "0.0829054054054054", "us.census.acs.B14001008_quantile": "0.701135135135135", "us.census.acs.B15003001_quantile": "0.404527027027027", "us.census.acs.B15003017_quantile": "0.191824324324324", "us.census.acs.B15003022_quantile": "0.864162162162162", "us.census.acs.B15003023_quantile": "0.754297297297297", "us.census.acs.B16001001_quantile": "0.350054054054054", "us.census.acs.B16001002_quantile": "0.217635135135135", "us.census.acs.B16001003_quantile": "0.85972972972973", "us.census.acs.B17001001_quantile": "0.342851351351351", "us.census.acs.B17001002_quantile": "0.51204054054054", "us.census.acs.B19013001_quantile": "0.813540540540541", "us.census.acs.B19083001_quantile": "0.0948648648648649", "us.census.acs.B19301001_quantile": "0.678351351351351", "us.census.acs.B25001001_quantile": "0.146108108108108", "us.census.acs.B25002003_quantile": "0.149067567567568", "us.census.acs.B25004002_quantile": "0", "us.census.acs.B25004004_quantile": "0", "us.census.acs.B25058001_quantile": "0.944554054054054", "us.census.acs.B25071001_quantile": "0.398040540540541", "us.census.acs.B25075001_quantile": "0.0596081081081081", "us.census.acs.B25075025_quantile": "0"}'::JSONB as test_point_segmentation;

-- segmentation around null island
SELECT cdb_observatory.OBS_GetSegmentSnapshot(
    ST_SetSRID(ST_Point(0, 0), 4326),
    'us.census.tiger.census_tract'
)::text is null as null_island_segmentation;

-- Point-based OBS_GetMeasure with zillow
SELECT abs(OBS_GetMeasure_zhvi_point - 597900) / 597900 < 5.0 AS OBS_GetMeasure_zhvi_point_test FROM cdb_observatory.OBS_GetMeasure(
  ST_SetSRID(ST_Point(-73.94602417945862, 40.6768220087458), 4326),
  'us.zillow.AllHomes_Zhvi', null, 'us.census.tiger.zcta5', '2014-01'
) As t(OBS_GetMeasure_zhvi_point);

-- Point-based OBS_GetMeasure with later measure
SELECT abs(OBS_GetMeasure_zhvi_point_default_latest - 995400) / 995400 < 5.0 AS OBS_GetMeasure_zhvi_point_default_latest_test FROM cdb_observatory.OBS_GetMeasure(
  ST_SetSRID(ST_Point(-73.94602417945862, 40.6768220087458), 4326),
  'us.zillow.AllHomes_Zhvi', null, 'us.census.tiger.zcta5', '2016-06'
) As t(OBS_GetMeasure_zhvi_point_default_latest);

-- Point-based OBS_GetMeasure, default normalization (area)
-- is result within 0.1% of expected
SELECT abs(OBS_GetMeasure_total_pop_point - 10923.093200390833950) / 10923.093200390833950 < 0.001 As OBS_GetMeasure_total_pop_point_test FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestPoint(),
    'us.census.acs.B01003001'
) As t(OBS_GetMeasure_total_pop_point);

-- Point-based OBS_GetMeasure, default normalization by NULL (area)
-- is result within 0.1% of expected
SELECT abs(OBS_GetMeasure_total_pop_point_null_normalization - 10923.093200390833950) / 10923.093200390833950 < 0.001 As OBS_GetMeasure_total_pop_point_null_normalization_test FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestPoint(),
    'us.census.acs.B01003001', NULL
) As t(OBS_GetMeasure_total_pop_point_null_normalization);

-- Point-based OBS_GetMeasure, explicit area normalization area
-- is result within 0.1% of expected
SELECT abs(OBS_GetMeasure_total_pop_point_area - 10923.093200390833950) / 10923.093200390833950 < 0.001 As OBS_GetMeasure_total_pop_point_area_test FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestPoint(),
    'us.census.acs.B01003001', 'area'
) As t(OBS_GetMeasure_total_pop_point_area);

-- Poly-based OBS_GetMeasure, default normalization (none)
-- is result within 0.1% of expected
SELECT abs(OBS_GetMeasure_total_pop_polygon - 12327.3133495107) / 12327.3133495107 < 0.001 As OBS_GetMeasure_total_pop_polygon_test FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestArea(),
    'us.census.acs.B01003001'
) As t(OBS_GetMeasure_total_pop_polygon);

-- Poly-based OBS_GetMeasure, default normalization by NULL (none)
-- is result within 0.1% of expected
SELECT abs(OBS_GetMeasure_total_pop_polygon_null_normalization - 12327.3133495107) / 12327.3133495107 < 0.001 As OBS_GetMeasure_total_pop_polygon_null_normalization_test FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestArea(),
    'us.census.acs.B01003001', NULL
) As t(OBS_GetMeasure_total_pop_polygon_null_normalization);

-- Poly-based OBS_GetMeasure, explicit area normalization
-- is result within 0.1% of expected
SELECT abs(OBS_GetMeasure_total_pop_polygon_area - 15787.4325563538) / 15787.4325563538 < 0.001 As OBS_GetMeasure_total_pop_polygon_area_test FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestArea(),
    'us.census.acs.B01003001', 'area'
) As t(OBS_GetMeasure_total_pop_polygon_area);

-- Point-based OBS_GetMeasure with denominator normalization
SELECT (abs(cdb_observatory.OBS_GetMeasure(
  cdb_observatory._TestPoint(),
  'us.census.acs.B01001002', 'denominator') - 0.62157894736842105263) / 0.62157894736842105263) < 0.001 As OBS_GetMeasure_total_male_point_denominator;

-- Poly-based OBS_GetMeasure with denominator normalization
SELECT abs(cdb_observatory.OBS_GetMeasure(
  cdb_observatory._TestArea(),
  'us.census.acs.B01001002', 'denominator', null, '2010 - 2014') - 0.49026340444793965457) / 0.49026340444793965457 < 0.001 As OBS_GetMeasure_total_male_poly_denominator;

-- Poly-based OBS_GetMeasure with one very bad geom
SELECT abs(cdb_observatory.OBS_GetMeasure(
  cdb_observatory._ProblemTestArea(),
  'us.census.acs.B01003001') - 96230.2929825897) / 96230.2929825897 < 0.001 As OBS_GetMeasure_bad_geometry;

-- OBS_GetMeasure with NULL Input geometry
SELECT cdb_observatory.OBS_GetMeasure(
  NULL,
  'us.census.acs.B01003001') IS NULL As OBS_GetMeasure_null_geometry;

-- OBS_GetMeasure where there is no data
SELECT cdb_observatory.OBS_GetMeasure(
  ST_SetSRID(st_point(0, 0), 4326),
  'us.census.acs.B01003001') IS NULL As OBS_GetMeasure_out_of_bounds_geometry;

-- OBS_GetMeasure over arbitrary area for a measure we cannot estimate
SELECT cdb_observatory.OBS_GetMeasure(
  ST_Buffer(cdb_observatory._testpoint(), 0.1),
  'us.census.acs.B19083001') IS NULL As OBS_GetMeasure_estimate_for_blank_aggregate;

-- OBS_GetMeasure over arbitrary area for an average measure we can estimate
SELECT abs(cdb_observatory.OBS_GetMeasure(
  ST_Buffer(cdb_observatory._testpoint(), 0.01),
  'us.census.acs.B19301001') - 20025) / 20025 < 0.001 As OBS_GetMeasure_per_capita_income_average;

-- OBS_GetMeasure over arbitrary area for a median measure we can estimate
SELECT abs(cdb_observatory.OBS_GetMeasure(
  ST_Buffer(cdb_observatory._testpoint(), 0.01),
  'us.census.acs.B19013001') - 39266) / 39266 < 0.001 As OBS_GetMeasure_median_capita_income_average;

-- Point-based OBS_GetCategory
SELECT cdb_observatory.OBS_GetCategory(
  cdb_observatory._TestPoint(), 'us.census.spielman_singleton_segments.X10') = 'Wealthy, urban without Kids' As OBS_GetCategory_point;

-- Poly-based OBS_GetCategory
SELECT cdb_observatory.OBS_GetCategory(
  cdb_observatory._TestArea(), 'us.census.spielman_singleton_segments.X10') = 'Hispanic and Young' As obs_getcategory_polygon;

-- NULL Input OBS_GetCategory
SELECT cdb_observatory.OBS_GetCategory(
  NULL, 'us.census.spielman_singleton_segments.X10') IS NULL As obs_getcategory_null;

-- Point-based OBS_GetPopulation, default normalization (area)
SELECT (abs(OBS_GetPopulation - 10923.093200390833950) / 10923.093200390833950) < 0.001 As OBS_GetPopulation FROM
  cdb_observatory.OBS_GetPopulation(
    cdb_observatory._TestPoint()
  ) As m(OBS_GetPopulation);

-- Poly-based OBS_GetPopulation, default normalization (none)
SELECT (abs(obs_getpopulation_polygon - 12327.3133495107) / 12327.3133495107) < 0.001 As obs_getpopulation_polygon_test
FROM
  cdb_observatory.OBS_GetPopulation(
    cdb_observatory._TestArea()
  ) As m(obs_getpopulation_polygon);

-- Poly-based OBS_GetPopulation, default normalization (none) specified as NULL
SELECT (abs(obs_getpopulation_polygon_null - 12327.3133495107) / 12327.3133495107) < 0.001 As obs_getpopulation_polygon_null_test
FROM
  cdb_observatory.OBS_GetPopulation(
    cdb_observatory._TestArea(), NULL
  ) As m(obs_getpopulation_polygon_null);

-- Null input OBS_GetPopulation
SELECT obs_getpopulation_polygon_null_geom IS NULL As obs_getpopulation_polygon_null_geom_test
FROM
  cdb_observatory.OBS_GetPopulation(
    NULL, NULL
  ) As m(obs_getpopulation_polygon_null_geom);

-- Point-based OBS_GetUSCensusMeasure, default normalization (area)
SELECT (abs(cdb_observatory.obs_getuscensusmeasure(
  cdb_observatory._testpoint(), 'male population') - 6789.5647735060920500) / 6789.5647735060920500) < 0.001 As obs_getuscensusmeasure_point_male_pop;

-- Poly-based OBS_GetUSCensusMeasure, default normalization (none)
SELECT (abs(cdb_observatory.obs_getuscensusmeasure(
  cdb_observatory._testarea(), 'male population') - 6043.63061042765) / 6043.63061042765) < 0.001 As obs_getuscensusmeasure;

-- Poly-based OBS_GetUSCensusMeasure, default normalization (none) specified
-- with NULL
SELECT (abs(cdb_observatory.obs_getuscensusmeasure(
  cdb_observatory._testarea(), 'male population', NULL) - 6043.63061042765) / 6043.63061042765) < 0.001 As obs_getuscensusmeasure_null;

-- Poly-based OBS_GetUSCensusMeasure, Null input geom
SELECT cdb_observatory.obs_getuscensusmeasure(
  NULL, 'male population', NULL) IS NULL As obs_getuscensusmeasure_null_geom;


-- Point-based OBS_GetUSCensusCategory
SELECT cdb_observatory.OBS_GetUSCensusCategory(
  cdb_observatory._testpoint(), 'Spielman-Singleton Segments: 10 Clusters') = 'Wealthy, urban without Kids' As OBS_GetUSCensusCategory_point;

-- Area-based OBS_GetUSCensusCategory
SELECT cdb_observatory.OBS_GetUSCensusCategory(
  cdb_observatory._testarea(), 'Spielman-Singleton Segments: 10 Clusters') = 'Hispanic and Young' As OBS_GetUSCensusCategory_polygon;

-- Null-input OBS_GetUSCensusCategory
SELECT cdb_observatory.OBS_GetUSCensusCategory(
  NULL, 'Spielman-Singleton Segments: 10 Clusters') IS NULL As OBS_GetUSCensusCategory_null;


-- OBS_GetMeasureById tests
-- typical query
SELECT (cdb_observatory.OBS_GetMeasureById(
  '36047048500',
  'us.census.acs.B01003001',
  'us.census.tiger.census_tract',
  '2010 - 2014'
) - 3241) / 3241 < 0.0001 As OBS_GetMeasureById_cartodb_census_tract;

-- no boundary_id should give null
SELECT cdb_observatory.OBS_GetMeasureById(
  '36047048500',
  'us.census.acs.B01003001',
  NULL,
  NULL
) IS NULL As OBS_GetMeasureById_null_boundary_null_timespan;

-- query at block_group level
SELECT (cdb_observatory.OBS_GetMeasureById(
  '360470485002',
  'us.census.acs.B01003001',
  'us.census.tiger.block_group',
  '2010 - 2014'
) - 1900) / 1900 < 0.0001 As OBS_GetMeasureById_cartodb_block_group;

-- geom ref / boundary mismatch
SELECT cdb_observatory.OBS_GetMeasureById(
  '36047048500',
  'us.census.acs.B01003001',
  'us.census.tiger.block_group',
  '2010 - 2014'
) IS NULL As OBS_GetMeasureById_nulls;

-- NULL input id
SELECT cdb_observatory.OBS_GetMeasureById(
  NULL,
  'us.census.acs.B01003001',
  'us.census.tiger.block_group',
  '2010 - 2014'
) IS NULL As OBS_GetMeasureById_null_id;

-- OBS_GetMeta null/null
SELECT cdb_observatory.OBS_GetMeta(NULL, NULL) IS NULL
AS OBS_GetMeta_null_null_is_null;

-- OBS_GetMeta null/empty array
SELECT cdb_observatory.OBS_GetMeta(NULL, '[]') IS NULL
AS OBS_GetMeta_null_empty_is_null;

-- OBS_GetMeta nullisland/null
SELECT cdb_observatory.OBS_GetMeta(ST_Point(0, 0), NULL) IS NULL
AS OBS_GetMeta_nullisland_null_is_null;

-- OBS_GetMeta nullisland/empty array
SELECT cdb_observatory.OBS_GetMeta(ST_Point(0, 0), '[]') IS NULL
AS OBS_GetMeta_nullisland_empty_is_null;

-- OBS_GetMeta nullisland/us_measure data
SELECT cdb_observatory.OBS_GetMeta(ST_Point(0, 0),
  '[{"numer_id": "us.census.acs.B01003001"}]') IS NULL
AS OBS_GetMeta_nullisland_us_measure_is_null;

-- OBS_GetMeta for point completes one partial measure with "best" metadata
-- with no denominator
WITH meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001"}]') meta)
SELECT
(meta->0->>'id')::integer = 1 id,
(meta->0->>'numer_id') = 'us.census.acs.B01003001' numer_id,
(meta->0->>'timespan_rank')::integer = 1 timespan_rank,
(meta->0->>'score_rank')::integer = 1 score_rank,
(meta->0->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->0->>'numer_colname') = 'total_pop' numer_colname,
(meta->0->>'numer_type') = 'Numeric' numer_type,
(meta->0->>'numer_name') = 'Total Population' numer_name,
(meta->0->>'denom_id') IS NULL denom_id,
(meta->0->>'geom_id') = 'us.census.tiger.block_group' geom_id,
(meta->0->>'normalization') IS NULL normalization
FROM meta;

-- OBS_GetMeta for point completes one partial measure with "best" metadata
-- with a denominator
WITH meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01001002"}]') meta)
SELECT
(meta->0->>'id')::integer = 1 id,
(meta->0->>'numer_id') = 'us.census.acs.B01001002' numer_id,
(meta->0->>'timespan_rank')::integer = 1 timespan_rank,
(meta->0->>'score_rank')::integer = 1 score_rank,
(meta->0->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->0->>'numer_colname') = 'male_pop' numer_colname,
(meta->0->>'numer_type') = 'Numeric' numer_type,
(meta->0->>'numer_name') = 'Male Population' numer_name,
(meta->0->>'denom_id') = 'us.census.acs.B01003001' denom_id,
(meta->0->>'denom_aggregate') = 'sum' denom_aggregate,
(meta->0->>'denom_colname') = 'total_pop' denom_colname,
(meta->0->>'denom_type') = 'Numeric' denom_type,
(meta->0->>'denom_name') = 'Total Population' denom_name,
(meta->0->>'geom_id') = 'us.census.tiger.block_group' geom_id,
(meta->0->>'normalization') IS NULL normalization
FROM meta;

-- OBS_GetMeta for polygon completes one partial measure with "best" metadata
-- with no denominator
WITH meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001"}]') meta)
SELECT
(meta->0->>'id')::integer = 1 id,
(meta->0->>'numer_id') = 'us.census.acs.B01003001' numer_id,
(meta->0->>'timespan_rank')::integer = 1 timespan_rank,
(meta->0->>'score_rank')::integer = 1 score_rank,
(meta->0->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->0->>'numer_colname') = 'total_pop' numer_colname,
(meta->0->>'numer_type') = 'Numeric' numer_type,
(meta->0->>'numer_name') = 'Total Population' numer_name,
(meta->0->>'denom_id') IS NULL denom_id,
(meta->0->>'geom_id') = 'us.census.tiger.block_group' geom_id,
(meta->0->>'normalization') IS NULL normalization
FROM meta;

-- OBS_GetMeta for polygon completes one partial measure with "best" metadata
-- with a denominator
WITH meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01001002"}]') meta)
SELECT
(meta->0->>'id')::integer = 1 id,
(meta->0->>'numer_id') = 'us.census.acs.B01001002' numer_id,
(meta->0->>'timespan_rank')::integer = 1 timespan_rank,
(meta->0->>'score_rank')::integer = 1 score_rank,
(meta->0->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->0->>'numer_colname') = 'male_pop' numer_colname,
(meta->0->>'numer_type') = 'Numeric' numer_type,
(meta->0->>'numer_name') = 'Male Population' numer_name,
(meta->0->>'denom_id') = 'us.census.acs.B01003001' denom_id,
(meta->0->>'denom_aggregate') = 'sum' denom_aggregate,
(meta->0->>'denom_colname') = 'total_pop' denom_colname,
(meta->0->>'denom_type') = 'Numeric' denom_type,
(meta->0->>'denom_name') = 'Total Population' denom_name,
(meta->0->>'geom_id') = 'us.census.tiger.block_group' geom_id,
(meta->0->>'normalization') IS NULL normalization
FROM meta;

-- OBS_GetMeta for point completes several partial measures with "best"
-- metadata, includes geom alternatives if asked
WITH meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01001002", "max_score_rank": 2}]', null, 2) meta)
SELECT
(meta->0->>'id')::integer = 1 id,
(meta->0->>'numer_id') = 'us.census.acs.B01001002' numer_id,
(meta->0->>'timespan_rank')::integer = 1 timespan_rank,
(meta->0->>'score_rank')::integer = 1 score_rank,
(meta->0->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->0->>'numer_colname') = 'male_pop' numer_colname,
(meta->0->>'numer_type') = 'Numeric' numer_type,
(meta->0->>'numer_name') = 'Male Population' numer_name,
(meta->0->>'denom_id') = 'us.census.acs.B01003001' denom_id,
(meta->0->>'denom_aggregate') = 'sum' denom_aggregate,
(meta->0->>'denom_colname') = 'total_pop' denom_colname,
(meta->0->>'denom_type') = 'Numeric' denom_type,
(meta->0->>'denom_name') = 'Total Population' denom_name,
(meta->0->>'geom_id') = 'us.census.tiger.block_group' geom_id,
(meta->0->>'normalization') IS NULL normalization,
(meta->1->>'id')::integer = 1 id,
(meta->1->>'numer_id') = 'us.census.acs.B01001002' numer_id,
(meta->1->>'timespan_rank')::integer = 1 timespan_rank,
(meta->1->>'score_rank')::integer = 2 score_rank,
(meta->1->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->1->>'numer_colname') = 'male_pop' numer_colname,
(meta->1->>'numer_type') = 'Numeric' numer_type,
(meta->1->>'numer_name') = 'Male Population' numer_name,
(meta->1->>'denom_id') = 'us.census.acs.B01003001' denom_id,
(meta->1->>'denom_aggregate') = 'sum' denom_aggregate,
(meta->1->>'denom_colname') = 'total_pop' denom_colname,
(meta->1->>'denom_type') = 'Numeric' denom_type,
(meta->1->>'denom_name') = 'Total Population' denom_name,
(meta->1->>'geom_id') = 'us.census.tiger.census_tract' geom_id,
(meta->1->>'normalization') IS NULL normalization
FROM meta;

-- OBS_GetMeta for point completes several partial measures with "best" metadata
-- with pre-computed geom
WITH meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01001002", "geom_id": "us.census.tiger.census_tract"}]') meta)
SELECT
(meta->0->>'id')::integer = 1 id,
(meta->0->>'numer_id') = 'us.census.acs.B01001002' numer_id,
(meta->0->>'timespan_rank')::integer = 1 timespan_rank,
(meta->0->>'score_rank')::integer = 1 score_rank,
(meta->0->>'numer_aggregate') = 'sum' numer_aggregate,
(meta->0->>'numer_colname') = 'male_pop' numer_colname,
(meta->0->>'numer_type') = 'Numeric' numer_type,
(meta->0->>'numer_name') = 'Male Population' numer_name,
(meta->0->>'denom_id') = 'us.census.acs.B01003001' denom_id,
(meta->0->>'denom_aggregate') = 'sum' denom_aggregate,
(meta->0->>'denom_colname') = 'total_pop' denom_colname,
(meta->0->>'denom_type') = 'Numeric' denom_type,
(meta->0->>'denom_name') = 'Total Population' denom_name,
(meta->0->>'geom_id') = 'us.census.tiger.census_tract' geom_id,
(meta->0->>'normalization') IS NULL normalization
FROM meta;

-- OBS_GetMeta for point completes several partial measures with conflicting
-- metadata
SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01001002", "denom_id": "us.census.acs.B01001002", "geom_id": "us.census.tiger.census_tract"}]') IS NULL
AS obs_getmeta_conflicting_metadata;

-- OBS_GetMeta provides suggested name for simple meta request
SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001"}]'
)->0->>'suggested_name' = 'total_pop_2010_2014' obs_getmeta_suggested_name;

-- OBS_GetMeta provides suggested name for simple meta request with area norm
SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "area"}]'
)->0->>'suggested_name' = 'total_pop_per_sq_km_2010_2014' obs_getmeta_suggested_name_area;

-- OBS_GetMeta provides suggested name for simple meta request with denom
SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01001002", "normalization": "denom"}]'
)->0->>'suggested_name' = 'male_pop_rate_2010_2014' obs_getmeta_suggested_name_denom;

-- OBS_GetData/OBS_GetMeta by id with empty list/null
WITH data AS (SELECT * FROM cdb_observatory.OBS_GetData(ARRAY[]::TEXT[], null))
SELECT ARRAY_AGG(data) IS NULL AS obs_getdata_geomval_empty_null FROM data;

-- OBS_GetData/OBS_GetMeta by geom with empty list/null
WITH data AS (SELECT * FROM cdb_observatory.OBS_GetData(ARRAY[]::GEOMVAL[], null))
SELECT ARRAY_AGG(data) IS NULL AS obs_getdata_text_empty_null FROM data;

-- OBS_GetData/OBS_GetMeta by geom with empty list
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(ARRAY[]::GEOMVAL[],
  (SELECT meta FROM meta)))
SELECT ARRAY_AGG(data) IS NULL AS obs_getdata_geomval_empty_one_measure FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with one standard measure NULL
-- normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 10923) / 10923 < 0.001 data_point_measure_null,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one standard measure NULL
-- normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 15787) / 15787 < 0.001 data_polygon_measure_null,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with one standard measure area
-- normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "area"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 10923) / 10923 < 0.001 data_point_measure_area,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one standard measure area
-- normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "area"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 15787) / 15787 < 0.001 data_polygon_measure_area,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with one standard measure predenom
-- called "prednormalized"
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "prenormalized"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 1900) / 1900 < 0.001 data_point_measure_prenormalized,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with one standard measure predenom
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "predenominated"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 1900) / 1900 < 0.001 data_point_measure_predenominated,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one standard measure predenom
-- called "prenormalized"
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "prenormalized"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 12327) / 12327 < 0.001 data_polygon_measure_prenormalized,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one standard measure predenom
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "predenominated"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 12327) / 12327 < 0.001 data_polygon_measure_predenominated,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with impossible denom
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "denominated"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       data->0->>'value' IS NULL data_point_measure_impossible_denominated,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one impossible denom
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "denominated"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       data->0->>'value' IS NULL data_polygon_measure_impossible_denominated,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with denom
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.acs.B01001002", "normalization": "denominated"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 0.6215) / 0.6215 < 0.001 data_point_measure_denominated,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one denom measure
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01001002", "normalization": "denominated"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 0.4902) / 0.4902 < 0.001 data_polygon_measure_denominated,
       data->1 IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with two standard measures NULL normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001"}, {"numer_id": "us.census.acs.B01001002"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 15787) / 15787 < 0.001 data_polygon_measure_one_null,
       abs((data->1->>'value')::Numeric - 0.4902) / 0.4902 < 0.001 data_polygon_measure_two_null
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with two standard measures predenom normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "predenom"}, {"numer_id": "us.census.acs.B01001002", "normalization": "predenom"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 12327) / 12327 < 0.001 data_polygon_measure_one_predenom,
       abs((data->1->>'value')::Numeric - 6043) / 6043 < 0.001 data_polygon_measure_two_predenom
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with two standard measures area normalization
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "normalization": "area"}, {"numer_id": "us.census.acs.B01001002", "normalization": "area"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 15787) / 15787 < 0.001 data_polygon_measure_one_area,
       abs((data->1->>'value')::Numeric - 7739) / 7739 < 0.001 data_polygon_measure_two_area
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with two standard measures different geoms
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.census_tract"}, {"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.block_group"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       abs((data->0->>'value')::Numeric - 16960) / 16960 < 0.001 data_polygon_measure_tract,
       abs((data->1->>'value')::Numeric - 15787) / 15787 < 0.001 data_polygon_measure_bg
FROM data;

-- OBS_GetData/OBS_GetMeta by point geom with one categorical
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestPoint(),
  '[{"numer_id": "us.census.spielman_singleton_segments.X55"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestPoint(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       data->0->>'value' = 'Wealthy transplants displacing long-term local residents' data_point_categorical,
       data->1->>'value' IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by polygon geom with one categorical
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.spielman_singleton_segments.X55"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       data->0->>'value' = 'Hispanic Black mix multilingual, high poverty, renters, uses public transport' data_poly_categorical,
       data->1->>'value' IS NULL nullcol
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with one categorical and one measure
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"numer_id": "us.census.spielman_singleton_segments.X55"}, {"numer_id": "us.census.acs.B01003001"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta)))
SELECT id = 1 id,
       data->0->>'value' = 'Hispanic Black mix multilingual, high poverty, renters, uses public transport' data_poly_categorical,
       abs((data->1->>'value')::Numeric - 15787) / 15787 < 0.0001 valcol
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with polygons inside a polygon
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.block_group"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta), false))
SELECT every(id = 1) is TRUE id,
       count(distinct (data->0->>'value')::geometry) = 16 correct_num_geoms
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with polygons inside a polygon + one measure
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.block_group"}, {"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.block_group"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta), false))
SELECT every(id = 1) is TRUE id,
       count(distinct (data->0->>'value')::geometry) = 16 correct_num_geoms,
       abs(sum((data->1->>'value')::numeric) - 15787) / 15787 < 0.001 correct_pop
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with polygons inside a polygon + one measure + one text
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.block_group"}, {"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.block_group"}, {"numer_id": "us.census.tiger.name", "geom_id": "us.census.tiger.block_group"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta), false))
SELECT every(id = 1) is TRUE id,
       count(distinct (data->0->>'value')::geometry) = 16 correct_num_geoms,
       abs(sum((data->1->>'value')::numeric) - 15787) / 15787 < 0.001 correct_pop,
       array_agg(distinct data->2->>'value') = '{"Block Group 1","Block Group 2","Block Group 3","Block Group 4","Block Group 5"}' correct_bg_names
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with points inside a polygon
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.pointlm_geom"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta), false))
SELECT every(id = 1) AS id,
       count(distinct (data->0->>'value')::geometry(point, 4326)) = 3 correct_num_points
FROM data;

-- OBS_GetData/OBS_GetMeta by geom with points inside a polygon + one text
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.pointlm_geom"}, {"geom_id": "us.census.tiger.pointlm_geom", "numer_id": "us.census.tiger.fullname"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY[(cdb_observatory._TestArea(), 1)::geomval],
  (SELECT meta FROM meta), false))
SELECT every(id = 1) AS id,
       count(distinct (data->0->>'value')::geometry(point, 4326)) = 3 correct_num_points,
       array_agg(data->1->>'value') = '{"Bushwick Yards","Edward Block Square","Bushwick Houses"}' pointgeom_names
FROM data;


-- OBS_GetData by id with one standard measure
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.census_tract", "numer_id": "us.census.acs.B01003001"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY['36047048500'],
    (SELECT meta FROM meta)))
SELECT id = '36047048500' AS id,
       (abs((data->0->>'value')::numeric) - 5578) / 5578 < 0.001 obs_getdata_by_id_one_measure_null
FROM data;

-- OBS_GetData by id with one standard measure, predenominated
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"normalization": "predenominated", "geom_id": "us.census.tiger.census_tract", "numer_id": "us.census.acs.B01003001"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY['36047048500'],
    (SELECT meta FROM meta)))
SELECT id = '36047048500' AS id,
       (abs((data->0->>'value')::numeric) - 3241) / 3241 < 0.001 obs_getdata_by_id_one_measure_predenom
FROM data;

-- OBS_GetData/OBS_GetMeta by id with two standard measures
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.census_tract", "numer_id": "us.census.acs.B01003001"}, {"geom_id": "us.census.tiger.census_tract", "numer_id": "us.census.acs.B01001002"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY['36047048500'],
    (SELECT meta FROM meta)))
SELECT id = '36047048500' AS id,
       (abs((data->0->>'value')::numeric) - 5578) / 5578 < 0.001 obs_getdata_by_id_one_measure_null,
       (abs((data->1->>'value')::numeric) - 0.6053) / 0.6053 < 0.001 obs_getdata_by_id_two_measure_null
FROM data;

-- OBS_GetData/OBS_GetMeta by id with one categorical
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.census_tract", "numer_id": "us.census.spielman_singleton_segments.X55"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY['36047048500'],
    (SELECT meta FROM meta)))
SELECT id = '36047048500' AS id,
       data->0->>'value' = 'Wealthy transplants displacing long-term local residents' obs_getdata_by_id_categorical
FROM data;

-- OBS_GetData/OBS_GetMeta by id with one geometry
WITH
meta AS (SELECT cdb_observatory.OBS_GetMeta(cdb_observatory._TestArea(),
  '[{"geom_id": "us.census.tiger.census_tract"}]') meta),
data AS (SELECT * FROM cdb_observatory.OBS_GetData(
    ARRAY['36047048500'],
    (SELECT meta FROM meta)))
SELECT id = '36047048500' AS id,
       ST_GeometryType((data->0->>'value')::geometry) = 'ST_MultiPolygon' obs_getdata_by_id_geometry
FROM data;

-- OBS_GetData with an API + geomvals, no args
SELECT (SELECT array_agg(json_array_elements::text) @> array['"us.census.tiger.census_tract"']
        FROM json_array_elements(data->0->'value'))
AS OBS_GetData_API_geomvals_no_args
FROM cdb_observatory.obs_getdata(array[(cdb_observatory._testarea(), 1)::geomval],
  '[{"numer_type": "text", "numer_colname": "boundary_id", "api_method": "obs_getavailableboundaries"}]');

-- OBS_GetData with an API + geomvals, args, numeric
SELECT json_typeof(data->0->'value') = 'array' ary_type,
       json_typeof(data->0->'value'->0) = 'number'
AS OBS_GetData_API_geomvals_args_numer_return
FROM cdb_observatory.obs_getdata(array[(cdb_observatory._testarea(), 1)::geomval],
    '[{"numer_type": "numeric", "numer_colname": "obs_getmeasure", "api_method": "obs_getmeasure", "api_args": ["us.census.acs.B01003001"]}]');

-- OBS_GetData with an API + geomvals, args, text
SELECT json_typeof(data->0->'value') = 'array' ary_type,
       json_typeof(data->0->'value'->0) = 'string'
AS OBS_GetData_API_geomvals_args_string_return
FROM cdb_observatory.obs_getdata(array[(cdb_observatory._testarea(), 1)::geomval],
    '[{"numer_type": "text", "numer_colname": "obs_getcategory", "api_method": "obs_getcategory", "api_args": ["us.census.spielman_singleton_segments.X55"]}]');

-- OBS_GetData with an API + geomrefs, args, numeric
SELECT json_typeof(data->0->'value') = 'array' ary_type,
       json_typeof(data->0->'value'->0) = 'number'
AS OBS_GetData_API_geomrefs_args_numer_return
FROM cdb_observatory.obs_getdata(array['36047076200'],
      '[{"numer_type": "numeric", "numer_colname": "obs_getmeasurebyid", "api_method": "obs_getmeasurebyid", "api_args": ["us.census.acs.B01003001", "us.census.tiger.census_tract"]}]');

-- OBS_GetData with an API + geomrefs, args, text
SELECT json_typeof(data->0->'value') = 'array' ary_type,
       json_typeof(data->0->'value'->0) = 'string'
AS OBS_GetData_API_geomrefs_args_string_return
FROM cdb_observatory.obs_getdata(array['36047'],
      '[{"numer_type": "text", "numer_colname": "obs_getboundarybyid", "api_method": "obs_getboundarybyid", "api_args": ["us.census.tiger.county"]}]');

-- Ensure consistent results below.
select setseed(0);

-- Check that random assortment of block groups in Brooklyn return accurate data
WITH _geoms AS (
  SELECT
    (data->0->>'value')::geometry the_geom,
    data->0->>'geomref' geom_ref,
    (data->1->>'value')::numeric total_pop
  FROM cdb_observatory.OBS_GetData(
    array[(st_buffer(cdb_observatory._testpoint(), 0.2), 1)::geomval],
    (SELECT cdb_observatory.OBS_GetMeta(ST_MakeEnvelope(-179, 89, 179, -89, 4326),
      '[{"geom_id": "us.census.tiger.block_group"},
        {"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.block_group", "normalization": "predenom"}]')),
    FALSE
  )
  WHERE data->0->>'geomref' LIKE '36047%'
  ORDER BY RANDOM()
), geoms AS (
  SELECT *, row_number() OVER () cartodb_id FROM _geoms
), samples AS (
  SELECT COUNT(*) cnt, unnest(ARRAY[1, 2, 3, 5, 10, 25, 50, 100, COUNT(*)]) sample FROM geoms
), filtered AS (
  SELECT * FROM geoms, samples WHERE cartodb_id % (cnt / sample) = 0
), summary AS (
  SELECT sample, ST_SetSRID(ST_Extent(the_geom), 4326) extent,
    COUNT(*)::INT cnt,
    ARRAY_AGG((the_geom, cartodb_id)::geomval) geomvals,
    SUM(ST_Area(the_geom))::Numeric sumarea
  FROM filtered
  GROUP BY sample
), meta AS (
  SELECT sample, cdb_observatory.OBS_GetMeta(extent,
    ('[{"numer_id": "us.census.acs.B01003001", "normalization": "predenom", "target_area": ' || sumarea || '}]')::JSON,
    1, 1, cnt) meta
  FROM summary
  GROUP BY sample, extent, cnt, sumarea
), results AS (
  SELECT summary.sample, id, meta->0->>'geom_id' geom_id, (data->0->>'value')::Numeric as val
  FROM summary, meta, LATERAL cdb_observatory.OBS_GetData(geomvals, meta) data
  WHERE summary.sample = meta.sample
) SELECT sample bg_sample
 , MAX(100 * abs((geoms.total_pop - val) / Coalesce(NullIf(total_pop, 0), NULL)))::Numeric(10, 2) < 10 bg_max_error
 , AVG(100 * abs((geoms.total_pop - val) / Coalesce(NullIf(total_pop, 0), NULL)))::Numeric(10, 2) < 10 bg_avg_error
 , MIN(100 * abs((geoms.total_pop - val) / Coalesce(NullIf(total_pop, 0), NULL)))::Numeric(10, 2) < 10 bg_min_error
FROM geoms, results
WHERE cartodb_id = id
GROUP BY sample
ORDER BY sample
;

-- Check that random assortment of tracts in Brooklyn return accurate data
WITH _geoms AS (
  SELECT
    (data->0->>'value')::geometry the_geom,
    data->0->>'geomref' geom_ref,
    (data->1->>'value')::numeric total_pop
  FROM cdb_observatory.OBS_GetData(
    array[(st_buffer(cdb_observatory._testpoint(), 0.2), 1)::geomval],
    (SELECT cdb_observatory.OBS_GetMeta(ST_MakeEnvelope(-179, 89, 179, -89, 4326),
      '[{"geom_id": "us.census.tiger.census_tract"},
        {"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.census_tract", "normalization": "predenom"}]')),
    FALSE
  )
  WHERE data->0->>'geomref' LIKE '36047%'
  ORDER BY RANDOM()
), geoms AS (
  SELECT *, row_number() OVER () cartodb_id FROM _geoms
), samples AS (
  SELECT COUNT(*) cnt, unnest(ARRAY[1, 2, 3, 5, 10, 25, 50, 100, COUNT(*)]) sample FROM geoms
), filtered AS (
  SELECT * FROM geoms, samples WHERE cartodb_id % (cnt / sample) = 0
), summary AS (
  SELECT sample, ST_SetSRID(ST_Extent(the_geom), 4326) extent,
    COUNT(*)::INT cnt,
    ARRAY_AGG((the_geom, cartodb_id)::geomval) geomvals,
    SUM(ST_Area(the_geom))::Numeric sumarea
  FROM filtered
  GROUP BY sample
), meta AS (
  SELECT sample, cdb_observatory.OBS_GetMeta(extent,
    ('[{"numer_id": "us.census.acs.B01003001", "normalization": "predenom", "target_area": ' || sumarea || '}]')::JSON,
    1, 1, cnt) meta
  FROM summary
  GROUP BY sample, extent, cnt, sumarea
), results AS (
  SELECT summary.sample, id, meta->0->>'geom_id' geom_id, (data->0->>'value')::Numeric as val
  FROM summary, meta, LATERAL cdb_observatory.OBS_GetData(geomvals, meta) data
  WHERE summary.sample = meta.sample
) SELECT sample tract_sample
 , MAX(100 * abs((geoms.total_pop - val) / Coalesce(NullIf(total_pop, 0), NULL)))::Numeric(10, 2) < 10 tract_max_error
 , AVG(100 * abs((geoms.total_pop - val) / Coalesce(NullIf(total_pop, 0), NULL)))::Numeric(10, 2) < 10 tract_avg_error
 , MIN(100 * abs((geoms.total_pop - val) / Coalesce(NullIf(total_pop, 0), NULL)))::Numeric(10, 2) < 10 tract_min_error
FROM geoms, results
WHERE cartodb_id = id
GROUP BY sample
ORDER BY sample
;

-- Check that random assortment of block group points in Brooklyn return accurate data
WITH _geoms AS (
  SELECT
    ST_PointOnSurface((data->0->>'value')::geometry) the_geom,
    data->0->>'geomref' geom_ref,
    (data->1->>'value')::numeric total_pop
  FROM cdb_observatory.OBS_GetData(
    array[(st_buffer(cdb_observatory._testpoint(), 0.2), 1)::geomval],
    (SELECT cdb_observatory.OBS_GetMeta(ST_MakeEnvelope(-179, 89, 179, -89, 4326),
      '[{"geom_id": "us.census.tiger.block_group"},
        {"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.block_group", "normalization": "predenom"}]')),
    FALSE
  )
  WHERE data->0->>'geomref' LIKE '36047%'
), geoms AS (
  SELECT *, row_number() OVER () cartodb_id FROM _geoms
), samples AS (
  SELECT COUNT(*) cnt, unnest(ARRAY[1, 2, 3, 5, 10, 25, 50, 100, COUNT(*)]) sample FROM geoms
), filtered AS (
  SELECT * FROM geoms, samples WHERE cartodb_id % (cnt / sample) = 0
), summary AS (
  SELECT sample, ST_SetSRID(ST_Extent(the_geom), 4326) extent,
    COUNT(*)::INT cnt,
    ARRAY_AGG((the_geom, cartodb_id)::geomval) geomvals,
    SUM(ST_Area(the_geom))::Numeric sumarea
  FROM filtered
  GROUP BY sample
), meta AS (
  SELECT sample, cdb_observatory.OBS_GetMeta(extent,
    ('[{"numer_id": "us.census.acs.B01003001", "normalization": "predenom", "target_area": ' || sumarea || '}]')::JSON,
    1, 1, cnt) meta
  FROM summary
  GROUP BY sample, extent, cnt, sumarea
), results AS (
  SELECT summary.sample, id, meta->0->>'geom_id' geom_id, (data->0->>'value')::Numeric as val
  FROM summary, meta, LATERAL cdb_observatory.OBS_GetData(geomvals, meta) data
  WHERE summary.sample = meta.sample
) SELECT
 BOOL_AND(abs((geoms.total_pop - val) /
      Coalesce(NullIf(total_pop, 0), 1)) = 0) is True no_bg_point_error
FROM geoms, results
WHERE cartodb_id = id
;
