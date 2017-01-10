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
