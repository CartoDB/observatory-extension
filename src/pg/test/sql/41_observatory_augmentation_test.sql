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

SELECT * FROM
  cdb_observatory._OBS_Get(
    cdb_observatory._TestPoint(),
    Array['"us.census.acs".B19083001']::text[],
    '2009 - 2013',
    '"us.census.tiger".block_group'
  );

-- gini index at null island
SELECT * FROM
  cdb_observatory._OBS_Get(
    CDB_LatLng(0, 0),
    Array['"us.census.acs".B19083001']::text[],
    '2009 - 2013',
    '"us.census.tiger".block_group'
  );

-- OBS_GetPoints
-- obs_getpoints
-- --------------------
-- {4809.33511352425}

SELECT
  cdb_observatory._OBS_GetPoints(
    cdb_observatory._TestPoint(),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array[('total_pop','obs_ab038198aaab3f3cb055758638ee4de28ad70146','sum')::cdb_observatory.OBS_ColumnData]
  );

-- what happens at null island
SELECT
  cdb_observatory._OBS_GetPoints(
    CDB_LatLng(0, 0),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array[('total_pop','obs_ab038198aaab3f3cb055758638ee4de28ad70146','sum')::cdb_observatory.OBS_ColumnData]
  );

-- OBS_GetPolygons
--   obs_getpolygons
-- --------------------
--  {12996.8172420752}

SELECT
  cdb_observatory._OBS_GetPolygons(
    cdb_observatory._TestArea(),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array[('total_pop','obs_ab038198aaab3f3cb055758638ee4de28ad70146','sum')::cdb_observatory.OBS_ColumnData]
);

-- see what happens around null island
SELECT
  cdb_observatory._OBS_GetPolygons(
    ST_Buffer(CDB_LatLng(0, 0)::geography, 500)::geometry,
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array[('total_pop','obs_ab038198aaab3f3cb055758638ee4de28ad70146','sum')::cdb_observatory.OBS_ColumnData]
);

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

-- Point-based OBS_GetMeasure with denominator normalization
SELECT cdb_observatory.OBS_GetMeasure(
  cdb_observatory._TestPoint(),
  '"us.census.acs".B01001002', 'denominator');

-- Poly-based OBS_GetMeasure with denominator normalization
SELECT cdb_observatory.OBS_GetMeasure(
  cdb_observatory._TestArea(),
  '"us.census.acs".B01001002', 'denominator');

-- Point-based OBS_GetCategory
SELECT cdb_observatory.OBS_GetCategory(
  cdb_observatory._TestPoint(), '"us.census.spielman_singleton_segments".X10');

-- Poly-based OBS_GetCategory
SELECT cdb_observatory.OBS_GetCategory(
  cdb_observatory._TestArea(), '"us.census.spielman_singleton_segments".X10');

-- Point-based OBS_GetPopulation, default normalization (area)
SELECT * FROM
  cdb_observatory.OBS_GetPopulation(
    cdb_observatory._TestPoint()
  );

-- Poly-based OBS_GetPopulation, default normalization (none)
SELECT * FROM
  cdb_observatory.OBS_GetPopulation(
    cdb_observatory._TestArea()
  );

-- Point-based OBS_GetUSCensusMeasure, default normalization (area)
SELECT cdb_observatory.obs_getuscensusmeasure(
  cdb_observatory._testpoint(), 'male population');

-- Poly-based OBS_GetUSCensusMeasure, default normalization (none)
SELECT cdb_observatory.obs_getuscensusmeasure(
  cdb_observatory._testarea(), 'male population');

-- Point-based OBS_GetUSCensusCategory
SELECT cdb_observatory.OBS_GetUSCensusCategory(
  cdb_observatory._testpoint(), 'SS Segment, 10 clusters');

-- Area-based OBS_GetUSCensusCategory
SELECT cdb_observatory.OBS_GetUSCensusCategory(
  cdb_observatory._testarea(), 'SS Segment, 10 clusters');


\i test/sql/drop_fixtures.sql
