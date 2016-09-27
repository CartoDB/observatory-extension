\pset format unaligned
\set ECHO none
SET client_min_messages TO WARNING;

-- Point table augmentation with one measure, areanormalized (total_pop)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testpoints',
  '{"numer_ids":["us.census.acs.B01003001"], "denom_ids":[], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Buffer table augmentation with one measure, areanormalized (total_pop)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testbuffers',
  '{"numer_ids":["us.census.acs.B01003001"], "denom_ids":[], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Rich geometry table augmentation with one measure, areanormalized
-- (total_pop)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testgeoms',
  '{"numer_ids":["us.census.acs.B01003001"], "denom_ids":[], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Point table augmentation with one measure, predenominated
-- (median_income)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testpoints',
  '{"numer_ids":["us.census.acs.B19013001"], "denom_ids":[], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Buffer table augmentation with one measure, predenominated
-- (median_income)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testbuffers',
  '{"numer_ids":["us.census.acs.B19013001"], "denom_ids":[], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Rich geometry table augmentation with one measure, predenominated
-- (median_income)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testgeoms',
  '{"numer_ids":["us.census.acs.B19013001"], "denom_ids":[], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Point table augmentation with one measure, denominated (hispanic_pop)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testpoints',
  '{"numer_ids":["us.census.acs.B03002012"], "denom_ids":["us.census.acs.B01003001"], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Buffer table augmentation with one measure, denominated (hispanic_pop)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testbuffers',
  '{"numer_ids":["us.census.acs.B03002012"], "denom_ids":["us.census.acs.B01003001"], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Rich geometry table augmentation with one measure, denominated (hispanic_pop)
SELECT cdb_observatory._OBS_GetMeasureQuery(
  'public', 'testgeoms',
  '{"numer_ids":["us.census.acs.B03002012"], "denom_ids":["us.census.acs.B01003001"], "geom_ids": ["us.census.tiger.census_tract"], "timespans": ["2010 - 2014"]}'::json
);

-- Point table augmentation with three measures from one source

-- Buffer table augmentation with three measures from one source

-- Rich geometry table augmentation with three measures from one source

-- Point table augmentation with three measures from two sources

-- Buffer table augmentation with three measures from two sources

-- Rich geometry table augmentation with three measures from two sources

-- Point table augmentation with three measures from three sources

-- Buffer table augmentation with three measures from three sources

-- Rich geometry table augmentation with three measures from three sources

-- Table with nulls augmentation with one measure

-- Table with LINESTRINGs augmentation with one measure

-- Point table augmentation with a bad numer_id

-- Point table augmentation with a bad denom_id

-- Point table augmentation with a bad geom_id

-- Point table augmentation with a bad timespan

-- Point-based OBS_GetMeasure with zillow
--SELECT abs(OBS_GetMeasure_zhvi_point - 583600) / 583600 < 0.001 AS OBS_GetMeasure_zhvi_point_test FROM cdb_observatory.OBS_GetMeasure(
--  ST_SetSRID(ST_Point(-73.94602417945862, 40.6768220087458), 4326),
--  'us.zillow.AllHomes_Zhvi', null, 'us.census.tiger.zcta5', '2014-01'
--) As t(OBS_GetMeasure_zhvi_point);
