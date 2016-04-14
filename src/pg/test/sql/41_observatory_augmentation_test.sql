SELECT set_config(
    'search_path',
    current_setting('search_path') || ',cdb_observatory,observatory',
    false
) WHERE current_setting('search_path') !~ '(^|,)(cdb_observatory|observatory)(,|$)';

\i test/sql/load_fixtures.sql

--
SELECT * FROM
  cdb_observatory.OBS_GetDemographicSnapshot(
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
  cdb_observatory.OBS_GetCensus(
    cdb_observatory._TestPoint(),
    Array['total_pop','male_pop']::text[]
  );

-- what happens on null island?
-- expect nulls back: {female_pop, male_pop} | {NULL, NULL}
SELECT *
FROM
  cdb_observatory.OBS_GetCensus(
    ST_Buffer(CDB_LatLng(0, 0)::geography, 5000)::geometry,
    Array['female_pop','male_pop']::text[]
  );
-- expect nulls back {female_pop, male_pop} | {NULL, NULL}
SELECT *
FROM
  cdb_observatory.OBS_GetCensus(
    CDB_LatLng(0, 0),
    Array['female_pop', 'male_pop']::text[]
  );

--
-- names      | vals
-- -----------|-------
-- gini_index | 0.3494

SELECT * FROM
  cdb_observatory.OBS_Get(
    cdb_observatory._TestPoint(),
    Array['"us.census.acs".B19083001']::text[],
    '2009 - 2013',
    '"us.census.tiger".block_group'
  );

-- OBS_GetPoints
-- obs_getpoints
-- --------------------
-- {4809.33511352425}

SELECT
  cdb_observatory.OBS_GetPoints(
    cdb_observatory._TestPoint(),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array[('total_pop','obs_ab038198aaab3f3cb055758638ee4de28ad70146','sum')::cdb_observatory.OBS_ColumnData]
  );

-- OBS_GetPolygons
--   obs_getpolygons
-- --------------------
--  {12996.8172420752}

SELECT
  OBS_GetPolygons(
    _TestArea(),
    'obs_a92e1111ad3177676471d66bb8036e6d057f271b'::text, -- see example in obs_geomtable
    Array[('total_pop','obs_ab038198aaab3f3cb055758638ee4de28ad70146','sum')::OBS_ColumnData]
);

SELECT * FROM
  cdb_observatory.OBS_GetSegmentSnapshot(
    _TestPoint(),
    '"us.census.tiger".census_tract'
);

SELECT * FROM
  cdb_observatory.OBS_GetCategories(
    _TestPoint(),
    Array['"us.census.spielman_singleton_segments".X10'],
    '"us.census.tiger".census_tract'
);

\i test/sql/drop_fixtures.sql
