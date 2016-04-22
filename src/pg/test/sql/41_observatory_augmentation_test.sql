\i test/sql/load_fixtures.sql
--
SELECT * FROM
  cdb_observatory._OBS_GetDemographicSnapshot(
      cdb_observatory._TestPoint(),
      '2009 - 2013',
      '"us.census.tiger".block_group'
  ) As snapshot;

--
-- dimension | dimension_value
-- ----------|----------------
-- total_pop | 9516.27915900609
-- male_pop  | 6152.51885204623

SELECT *
FROM
  cdb_observatory._OBS_GetCensus(
    cdb_observatory._TestPoint(),
    Array['total_pop','male_pop']::text[]
  );

-- what happens on null island?
-- expect nulls back: {female_pop, male_pop} | {NULL, NULL}
SELECT *
FROM
  cdb_observatory._OBS_GetCensus(
    ST_Buffer(CDB_LatLng(0, 0)::geography, 5000)::geometry,
    Array['female_pop','male_pop']::text[]
  );
-- expect nulls back {female_pop, male_pop} | {NULL, NULL}
SELECT *
FROM
  cdb_observatory._OBS_GetCensus(
    CDB_LatLng(0, 0),
    Array['female_pop', 'male_pop']::text[]
  );

--
-- names      | vals
-- -----------|-------
-- gini_index | 0.3494

WITH result as (
  SELECT _OBS_GetJSON::text as expected FROM
  cdb_observatory._OBS_GetJSON(
    cdb_observatory._TestPoint(),
    Array['"us.census.acs".B19083001']::text[],
    '2009 - 2013',
    '"us.census.tiger".block_group'
  ) 
) select expected = '{"value":0.3494,"name":"Gini Index","tablename":"obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb","aggregate":"","type":"Numeric","description":""}'
  from result;

-- gini index at null island
WITH result as (
  SELECT count(_OBS_GetJSON) as expected FROM
  cdb_observatory._OBS_GetJSON(
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

SELECT * FROM
  cdb_observatory._OBS_GetSegmentSnapshot(
    cdb_observatory._TestPoint(),
    '"us.census.tiger".census_tract'
);

-- segmentation around null island
SELECT * FROM
  cdb_observatory._OBS_GetSegmentSnapshot(
    CDB_LatLng(0, 0),
    '"us.census.tiger".census_tract'
);

SELECT * FROM
  cdb_observatory._OBS_GetCategories(
    cdb_observatory._TestPoint(),
    Array['"us.census.spielman_singleton_segments".X10'],
    '"us.census.tiger".census_tract'
);

SELECT * FROM
  cdb_observatory._OBS_GetCategories(
    CDB_LatLng(0, 0),
    Array['"us.census.spielman_singleton_segments".X10'],
    '"us.census.tiger".census_tract'
);

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
