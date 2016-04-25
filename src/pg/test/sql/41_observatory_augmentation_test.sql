\i test/sql/load_fixtures.sql
--
WITH result as(
  Select count(OBS_GetDemographicSnapshot->>'value') expected_columns
  FROM cdb_observatory.OBS_GetDemographicSnapshot(cdb_observatory._TestPoint())
) select expected_columns ='58' as OBS_GetDemographicSnapshot_test_no_returns
FROM result;
--
-- dimension | dimension_value
-- ----------|----------------
-- total_pop | 9516.27915900609
-- male_pop  | 6152.51885204623

WITH result as (
  SELECT array_agg(_obs_getcensus->>'value') as b
  FROM( select * from 
    cdb_observatory._OBS_GetCensus(
      cdb_observatory._TestPoint(),
      Array['total_pop','male_pop']::text[]
    )) a
) 
select b='{9516.27915900609,6152.51885204623}'
  as test_obsGetCensusWithTestPointAnd2Variables
  from result;
-- what happens on null island?
-- expect nulls back: {female_pop, male_pop} | {NULL, NULL}

WITH result as (
  SELECT count(vals) non_null
  FROM( select _OBS_GetCensus->>'value' vals from 
    cdb_observatory._OBS_GetCensus(
      ST_Buffer(CDB_LatLng(0, 0)::geography, 5000)::geometry,
      Array['total_pop','male_pop']::text[]
    )) a
) 
SELECT non_null = 0 as test_obsGetCensusWithNullIslandArea
FROM result;

-- expect nulls back {female_pop, male_pop} | {NULL, NULL}
WITH result as (
  SELECT count(vals) non_null
  FROM( select _OBS_GetCensus->>'value' vals from 
    cdb_observatory._OBS_GetCensus(
      CDB_LatLng(0, 0),
      Array['total_pop','male_pop']::text[]
    )) a
) 
SELECT non_null = 0 as test_obsGetCensusWithNullIsland
FROM result;

--
-- names      | vals
-- -----------|-------
-- gini_index | 0.3494

WITH result as (
  SELECT _OBS_Get::text as expected FROM
  cdb_observatory._OBS_Get(
    cdb_observatory._TestPoint(),
    Array['"us.census.acs".B19083001']::text[],
    '2009 - 2013',
    '"us.census.tiger".block_group'
  ) 
) select expected = '{"value":0.3494,"name":"Gini Index","tablename":"obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb","aggregate":"","type":"Numeric","description":""}'
  as OBS_Get_gini_index_at_test_point
  from result;

-- gini index at null island
WITH result as (
  SELECT count(_OBS_Get) as expected FROM
  cdb_observatory._OBS_Get(
    CDB_LatLng(0, 0),
    Array['"us.census.acs".B19083001']::text[],
    '2009 - 2013',
    '"us.census.tiger".block_group'
  ) 
) select expected = 0 as OBS_Get_gini_index_at_null_island
  from result;
  
-- OBS_GetPoints
-- obs_getpoints
-- --------------------
-- {4809.33511352425}

SELECT
  (cdb_observatory._OBS_GetPoints(
    cdb_observatory._TestPoint(),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    (Array['{"colname":"total_pop","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":"sum","name":"Total Population","type":"Numeric","description":"The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates."}'::json])
  ))[1]::text  = '{"value":4809.33511352425,"name":"Total Population","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":"sum","type":"Numeric","description":"The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates."}'
  as OBS_GetPoints_for_test_point;
-- what happens at null island

SELECT
  (cdb_observatory._OBS_GetPoints(
    CDB_LatLng(0, 0),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    (Array['{"colname":"total_pop","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":"sum","name":"Total Population","type":"Numeric","description":"The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates."}'::json])
  ))[1]::text  is null
  as OBS_GetPoints_for_null_island;

-- OBS_GetPolygons
--   obs_getpolygons
-- --------------------
--  {12996.8172420752}

SELECT
  (cdb_observatory._OBS_GetPolygons(
    cdb_observatory._TestArea(),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array['{"colname":"total_pop","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":"sum","name":"Total Population","type":"Numeric","description":"The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates."}'::json]
))[1]::text = '{"value":12996.8172420752,"name":"Total Population","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":"sum","type":"Numeric","description":"The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates."}'
  as OBS_GetPolygons_for_test_point;

-- see what happens around null island
SELECT
  (cdb_observatory._OBS_GetPolygons(
    ST_Buffer(CDB_LatLng(0, 0)::geography, 500)::geometry,
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array['{"colname":"total_pop","tablename":"obs_ab038198aaab3f3cb055758638ee4de28ad70146","aggregate":"sum","name":"Total Population","type":"Numeric","description":"The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates."}'::json])
  )[1]->>'value'  is null
  as OBS_GetPolygons_for_null_island;

SELECT cdb_observatory.OBS_GetSegmentSnapshot(
    cdb_observatory._TestPoint(),
    '"us.census.tiger".census_tract'
)::text = '{"segment_name":"SS_segment_10_clusters","\"us.census.acs\".B01001001_quantile":"0.234783783783784","\"us.census.acs\".B01001002_quantile":"0.422405405405405","\"us.census.acs\".B01001026_quantile":"0.0987567567567568","\"us.census.acs\".B01002001_quantile":"0.0715","\"us.census.acs\".B03002003_quantile":"0.295310810810811","\"us.census.acs\".B03002004_quantile":"0.407189189189189","\"us.census.acs\".B03002006_quantile":"0.625608108108108","\"us.census.acs\".B03002012_quantile":"0.795202702702703","\"us.census.acs\".B05001006_quantile":"0.703797297297297","\"us.census.acs\".B08006001_quantile":"0.59227027027027","\"us.census.acs\".B08006002_quantile":"0.0180540540540541","\"us.census.acs\".B08006008_quantile":"0.993756756756757","\"us.census.acs\".B08006009_quantile":"0.728162162162162","\"us.census.acs\".B08006011_quantile":"0.995972972972973","\"us.census.acs\".B08006015_quantile":"0.929135135135135","\"us.census.acs\".B08006017_quantile":"0.625432432432432","\"us.census.acs\".B09001001_quantile":"0.0386081081081081","\"us.census.acs\".B11001001_quantile":"0.157121621621622","\"us.census.acs\".B14001001_quantile":"0.241878378378378","\"us.census.acs\".B14001002_quantile":"0.173783783783784","\"us.census.acs\".B14001005_quantile":"0.0380675675675676","\"us.census.acs\".B14001006_quantile":"0.0308108108108108","\"us.census.acs\".B14001007_quantile":"0.0486216216216216","\"us.census.acs\".B14001008_quantile":"0.479743243243243","\"us.census.acs\".B15003001_quantile":"0.297675675675676","\"us.census.acs\".B15003017_quantile":"0.190351351351351","\"us.census.acs\".B15003022_quantile":"0.802513513513514","\"us.census.acs\".B15003023_quantile":"0.757148648648649","\"us.census.acs\".B16001001_quantile":"0.255405405405405","\"us.census.acs\".B16001002_quantile":"0.196094594594595","\"us.census.acs\".B16001003_quantile":"0.816851351351351","\"us.census.acs\".B17001001_quantile":"0.252513513513514","\"us.census.acs\".B17001002_quantile":"0.560054054054054","\"us.census.acs\".B19013001_quantile":"0.777472972972973","\"us.census.acs\".B19083001_quantile":"0.336932432432432","\"us.census.acs\".B19301001_quantile":"0.655378378378378","\"us.census.acs\".B25001001_quantile":"0.141810810810811","\"us.census.acs\".B25002003_quantile":"0.362824324324324","\"us.census.acs\".B25004002_quantile":"0.463837837837838","\"us.census.acs\".B25004004_quantile":"0","\"us.census.acs\".B25058001_quantile":"0.939040540540541","\"us.census.acs\".B25071001_quantile":"0.419445945945946","\"us.census.acs\".B25075001_quantile":"0.0387972972972973","\"us.census.acs\".B25075025_quantile":"0"}' as test_point_segmentation;

-- segmentation around null island
SELECT cdb_observatory.OBS_GetSegmentSnapshot(
    CDB_LatLng(0, 0),
    '"us.census.tiger".census_tract'
)::text = '{"segment_name":null,"\"us.census.acs\".B01001001_quantile":null,"\"us.census.acs\".B01001002_quantile":null,"\"us.census.acs\".B01001026_quantile":null,"\"us.census.acs\".B01002001_quantile":null,"\"us.census.acs\".B03002003_quantile":null,"\"us.census.acs\".B03002004_quantile":null,"\"us.census.acs\".B03002006_quantile":null,"\"us.census.acs\".B03002012_quantile":null,"\"us.census.acs\".B05001006_quantile":null,"\"us.census.acs\".B08006001_quantile":null,"\"us.census.acs\".B08006002_quantile":null,"\"us.census.acs\".B08006008_quantile":null,"\"us.census.acs\".B08006009_quantile":null,"\"us.census.acs\".B08006011_quantile":null,"\"us.census.acs\".B08006015_quantile":null,"\"us.census.acs\".B08006017_quantile":null,"\"us.census.acs\".B09001001_quantile":null,"\"us.census.acs\".B11001001_quantile":null,"\"us.census.acs\".B14001001_quantile":null,"\"us.census.acs\".B14001002_quantile":null,"\"us.census.acs\".B14001005_quantile":null,"\"us.census.acs\".B14001006_quantile":null,"\"us.census.acs\".B14001007_quantile":null,"\"us.census.acs\".B14001008_quantile":null,"\"us.census.acs\".B15003001_quantile":null,"\"us.census.acs\".B15003017_quantile":null,"\"us.census.acs\".B15003022_quantile":null,"\"us.census.acs\".B15003023_quantile":null,"\"us.census.acs\".B16001001_quantile":null,"\"us.census.acs\".B16001002_quantile":null,"\"us.census.acs\".B16001003_quantile":null,"\"us.census.acs\".B17001001_quantile":null,"\"us.census.acs\".B17001002_quantile":null,"\"us.census.acs\".B19013001_quantile":null,"\"us.census.acs\".B19083001_quantile":null,"\"us.census.acs\".B19301001_quantile":null,"\"us.census.acs\".B25001001_quantile":null,"\"us.census.acs\".B25002003_quantile":null,"\"us.census.acs\".B25004002_quantile":null,"\"us.census.acs\".B25004004_quantile":null,"\"us.census.acs\".B25058001_quantile":null,"\"us.census.acs\".B25071001_quantile":null,"\"us.census.acs\".B25075001_quantile":null,"\"us.census.acs\".B25075025_quantile":null}' as null_island_segmentation;

WITH result as (
  SELECT array_agg(_OBS_GetCategories) as expected FROM
    cdb_observatory._OBS_GetCategories(
      cdb_observatory._TestPoint(),
      Array['"us.census.spielman_singleton_segments".X10'],
      '"us.census.tiger".census_tract'
  )
)
  select (expected)[1]::text = '{"category":"Wealthy, urban without Kids","name":"SS_segment_10_clusters","tablename":"obs_65f29658e096ca1485bf683f65fdbc9f05ec3c5d","aggregate":null,"type":"Text","description":"Sociodemographic classes from Spielman and Singleton 2015, 10 clusters"}' as GetCategories_at_test_point_1,
  (expected)[2]::text ='{"category":"Wealthy, urban without Kids","name":"SS_segment_10_clusters","tablename":"obs_11ee8b82c877c073438bc935a91d3dfccef875d1","aggregate":null,"type":"Text","description":"Sociodemographic classes from Spielman and Singleton 2015, 10 clusters"}' as GetCategories_at_test_point_2
  from result;
  
WITH result as (
  SELECT array_agg(_OBS_GetCategories) as expected FROM
    cdb_observatory._OBS_GetCategories(
      CDB_LatLng(0,0),
      Array['"us.census.spielman_singleton_segments".X10'],
      '"us.census.tiger".census_tract'
  )
)
  select expected is null as GetCategories_at_null_island
  from result;

-- Point-based OBS_GetMeasure, default normalization (area)
SELECT * FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestPoint(),
    '"us.census.acs".B01001001'
);

-- Poly-based OBS_GetMeasure, default normalization (none)
SELECT * FROM
  cdb_observatory.OBS_GetMeasure(
    cdb_observatory._TestArea(),
    '"us.census.acs".B01001001'
);


\i test/sql/drop_fixtures.sql
