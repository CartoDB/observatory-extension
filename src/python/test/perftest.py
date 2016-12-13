from nose.tools import assert_equal, assert_is_not_none
from nose_parameterized import parameterized

from util import query, commit

from time import time

import json
import os

USE_SCHEMA = True

for q in (
        'DROP TABLE IF EXISTS obs_perftest_simple',
        '''CREATE TABLE obs_perftest_simple (cartodb_id SERIAL PRIMARY KEY,
           point GEOMETRY,
           geom GEOMETRY,
           offset_geom GEOMETRY,
           name TEXT, measure NUMERIC, category TEXT)''',
        '''INSERT INTO obs_perftest_simple (point, geom, offset_geom, name)
           SELECT ST_PointOnSurface(the_geom) point,
                  the_geom geom,
                  ST_Translate(the_geom, -0.1, 0.1) offset_geom,
                  geom_refs AS name
           FROM (SELECT * FROM {schema}OBS_GetBoundariesByGeometry(
                 st_makeenvelope(-74.05437469482422,40.66319159533881,
                                 -73.81885528564453,40.745696344339564, 4326),
                 'us.census.tiger.census_tract_clipped')) foo
           ORDER BY ST_NPoints(the_geom) ASC
           LIMIT 500''',
        'DROP TABLE IF EXISTS obs_perftest_complex',
        '''CREATE TABLE obs_perftest_complex (cartodb_id SERIAL PRIMARY KEY,
           point GEOMETRY,
           geom GEOMETRY,
           offset_geom GEOMETRY,
           name TEXT, measure NUMERIC, category TEXT)''',
        '''INSERT INTO obs_perftest_complex (point, geom, offset_geom, name)
           SELECT ST_PointOnSurface(the_geom) point,
                  the_geom geom,
                  ST_Translate(the_geom, -0.1, 0.1) offset_geom,
                  geom_refs AS name
           FROM (SELECT * FROM {schema}OBS_GetBoundariesByGeometry(
                 st_makeenvelope(-75.05437469482422,40.66319159533881,
                                 -73.81885528564453,41.745696344339564, 4326),
                 'us.census.tiger.county_clipped')) foo
           ORDER BY ST_NPoints(the_geom) DESC
           LIMIT 50;''',
        'DROP TABLE IF EXISTS obs_perftest_country_simple',
        '''CREATE TABLE obs_perftest_country_simple (cartodb_id SERIAL PRIMARY KEY,
           geom GEOMETRY,
           name TEXT) ''',
        '''INSERT INTO obs_perftest_country_simple (geom, name)
           SELECT the_geom geom,
                  geom_refs AS name
           FROM (SELECT * FROM {schema}OBS_GetBoundariesByGeometry(
                 st_makeenvelope(-179,-89, 179,89, 4326),
                 'whosonfirst.wof_country_geom')) foo
           ORDER BY ST_NPoints(the_geom) ASC
           LIMIT 50;''',
        'DROP TABLE IF EXISTS obs_perftest_country_complex',
        '''CREATE TABLE obs_perftest_country_complex (cartodb_id SERIAL PRIMARY KEY,
           geom GEOMETRY,
           name TEXT) ''',
        '''INSERT INTO obs_perftest_country_complex (geom, name)
           SELECT the_geom geom,
                  geom_refs AS name
           FROM (SELECT * FROM {schema}OBS_GetBoundariesByGeometry(
                 st_makeenvelope(-179,-89, 179,89, 4326),
                 'whosonfirst.wof_country_geom')) foo
           ORDER BY ST_NPoints(the_geom) DESC
           LIMIT 50;''',
        #'''SET statement_timeout = 5000;'''
):
    query(q.format(
        schema='cdb_observatory.' if USE_SCHEMA else '',
    ))
    commit()


ARGS = {
    ('OBS_GetMeasureByID', None): "name, 'us.census.acs.B01001002', '{}'",
    ('OBS_GetMeasure', 'predenominated'): "{}, 'us.census.acs.B01003001', NULL, {}",
    ('OBS_GetMeasure', 'area'): "{}, 'us.census.acs.B01001002', 'area', {}",
    ('OBS_GetMeasure', 'denominator'): "{}, 'us.census.acs.B01001002', 'denominator', {}",
    ('OBS_GetCategory', None): "{}, 'us.census.spielman_singleton_segments.X10', {}",
    ('_OBS_GetGeometryScores', None): "{}, NULL"
}


def record(params, results):
    sha = os.environ['OBS_EXTENSION_SHA']
    fpath = os.path.join(os.environ['OBS_PERFTEST_DIR'], sha + '.json')
    if os.path.isfile(fpath):
        tests = json.load(open(fpath, 'r'))
    else:
        tests = {}
    with open(fpath, 'w') as fhandle:
        tests[json.dumps(params)] = {
            'params': params,
            'results': results
        }
        json.dump(tests, fhandle)

@parameterized([
    ('simple', '_OBS_GetGeometryScores', 'NULL', 1),
    ('simple', '_OBS_GetGeometryScores', 'NULL', 500),
    ('simple', '_OBS_GetGeometryScores', 'NULL', 3000),

    ('complex', '_OBS_GetGeometryScores', 'NULL', 1),
    ('complex', '_OBS_GetGeometryScores', 'NULL', 500),
    ('complex', '_OBS_GetGeometryScores', 'NULL', 3000),

    ('country_simple', '_OBS_GetGeometryScores', 'NULL', 1),
    ('country_simple', '_OBS_GetGeometryScores', 'NULL', 500),
    ('country_simple', '_OBS_GetGeometryScores', 'NULL', 5000),

    ('country_complex', '_OBS_GetGeometryScores', 'NULL', 1),
    ('country_complex', '_OBS_GetGeometryScores', 'NULL', 500),
    ('country_complex', '_OBS_GetGeometryScores', 'NULL', 5000),
])
def test_getgeometryscores_performance(geom_complexity, api_method, filters, target_geoms):
    print api_method, geom_complexity, filters, target_geoms

    rownums = (1, 5, 10, ) if 'complex' in geom_complexity else (5, 25, 50,)
    results = []
    for rows in rownums:
        stmt = '''SELECT {schema}{api_method}(geom, {filters}, {target_geoms})
                   FROM obs_perftest_{complexity}
                   WHERE cartodb_id < {n}'''.format(
                       complexity=geom_complexity,
                       schema='cdb_observatory.' if USE_SCHEMA else '',
                       api_method=api_method,
                       filters=filters,
                       target_geoms=target_geoms,
                       n=rows+1)
        start = time()
        query(stmt)
        end = time()
        qps = (rows / (end - start))
        results.append({
            'rows': rows,
            'qps': qps,
            'stmt': stmt
        })
        print rows, ': ', qps, ' QPS'

    if 'OBS_RECORD_TEST' in os.environ:
        record({
            'geom_complexity': geom_complexity,
            'api_method': api_method,
            'filters': filters,
            'target_geoms': target_geoms
        }, results)

@parameterized([
    ('simple', 'OBS_GetMeasureByID', None, 'us.census.tiger.census_tract', None),
    ('complex', 'OBS_GetMeasureByID', None, 'us.census.tiger.county', None),

    ('simple', 'OBS_GetMeasure', 'predenominated', 'point', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'predenominated', 'geom', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'predenominated', 'offset_geom', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'area', 'point', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'area', 'geom', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'area', 'offset_geom', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'denominator', 'point', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'denominator', 'geom', 'NULL'),
    ('simple', 'OBS_GetMeasure', 'denominator', 'offset_geom', 'NULL'),
    ('simple', 'OBS_GetCategory', None, 'point', 'NULL'),
    ('simple', 'OBS_GetCategory', None, 'geom', 'NULL'),
    ('simple', 'OBS_GetCategory', None, 'offset_geom', 'NULL'),

    ('simple', 'OBS_GetMeasure', 'predenominated', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'predenominated', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'predenominated', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'area', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'area', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'area', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'denominator', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'denominator', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetMeasure', 'denominator', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetCategory', None, 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetCategory', None, 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'OBS_GetCategory', None, 'offset_geom', "'us.census.tiger.census_tract'"),

    ('complex', 'OBS_GetMeasure', 'predenominated', 'point', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'offset_geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'area', 'point', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'area', 'geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'area', 'offset_geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'point', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'offset_geom', 'NULL'),
    ('complex', 'OBS_GetCategory', None, 'point', 'NULL'),
    ('complex', 'OBS_GetCategory', None, 'geom', 'NULL'),
    ('complex', 'OBS_GetCategory', None, 'offset_geom', 'NULL'),

    ('complex', 'OBS_GetMeasure', 'predenominated', 'point', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'area', 'point', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'area', 'geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'area', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'denominator', 'point', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'denominator', 'geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'denominator', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetCategory', None, 'point', "'us.census.tiger.census_tract'"),
    ('complex', 'OBS_GetCategory', None, 'geom', "'us.census.tiger.census_tract'"),
    ('complex', 'OBS_GetCategory', None, 'offset_geom', "'us.census.tiger.census_tract'"),
])
def test_getmeasure_performance(geom_complexity, api_method, normalization, geom, boundary):
    print api_method, geom_complexity, normalization, geom, boundary
    col = 'measure' if 'measure' in api_method.lower() else 'category'
    results = []

    rownums = (1, 5, 10, ) if geom_complexity == 'complex' else (5, 25, 50, )
    for rows in rownums:
        stmt = '''UPDATE obs_perftest_{complexity}
                   SET {col} = {schema}{api_method}({args})
                   WHERE cartodb_id <= {n}'''.format(
                       col=col,
                       complexity=geom_complexity,
                       schema='cdb_observatory.' if USE_SCHEMA else '',
                       api_method=api_method,
                       args=ARGS[api_method, normalization].format(geom, boundary),
                       n=rows)
        start = time()
        query(stmt)
        end = time()
        qps = (rows / (end - start))
        results.append({
            'rows': rows,
            'qps': qps,
            'stmt': stmt
        })
        print rows, ': ', qps, ' QPS'

    if 'OBS_RECORD_TEST' in os.environ:
        record({
            'geom_complexity': geom_complexity,
            'api_method': api_method,
            'normalization': normalization,
            'geom': geom
        }, results)


@parameterized([
    ('simple', 'predenominated', 'point', 'NULL'),
    ('simple', 'predenominated', 'geom', 'NULL'),
    ('simple', 'predenominated', 'offset_geom', 'NULL'),
    ('simple', 'area', 'point', 'NULL'),
    ('simple', 'area', 'geom', 'NULL'),
    ('simple', 'area', 'offset_geom', 'NULL'),
    ('simple', 'denominator', 'point', 'NULL'),
    ('simple', 'denominator', 'geom', 'NULL'),
    ('simple', 'denominator', 'offset_geom', 'NULL'),

    ('simple', 'predenominated', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'predenominated', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'predenominated', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'area', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'area', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'area', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'denominator', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'denominator', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'denominator', 'offset_geom', "'us.census.tiger.census_tract'"),

    ('complex', 'predenominated', 'point', 'NULL'),
    ('complex', 'predenominated', 'geom', 'NULL'),
    ('complex', 'predenominated', 'offset_geom', 'NULL'),
    ('complex', 'area', 'point', 'NULL'),
    ('complex', 'area', 'geom', 'NULL'),
    ('complex', 'area', 'offset_geom', 'NULL'),
    ('complex', 'denominator', 'point', 'NULL'),
    ('complex', 'denominator', 'geom', 'NULL'),
    ('complex', 'denominator', 'offset_geom', 'NULL'),

    ('complex', 'predenominated', 'point', "'us.census.tiger.county'"),
    ('complex', 'predenominated', 'geom', "'us.census.tiger.county'"),
    ('complex', 'predenominated', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'area', 'point', "'us.census.tiger.county'"),
    ('complex', 'area', 'geom', "'us.census.tiger.county'"),
    ('complex', 'area', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'denominator', 'point', "'us.census.tiger.county'"),
    ('complex', 'denominator', 'geom', "'us.census.tiger.county'"),
    ('complex', 'denominator', 'offset_geom', "'us.census.tiger.county'"),
])
def test_getmeasure_split_performance(geom_complexity, normalization, geom, boundary):
    print geom_complexity, normalization, geom, boundary
    results = []

    rownums = (1, 5, 10, ) if geom_complexity == 'complex' else (5, 25, 50, )
    for rows in rownums:
        stmt = '''
WITH meta AS (SELECT * FROM {schema}{api_method}meta(
                              (SELECT ST_SetSRID(ST_Extent(geom), 4326)
                              FROM obs_perftest_{complexity}),
                              'us.census.acs.B01001002', {boundary}))
, data AS (SELECT cartodb_id, {schema}{api_method}data(
  {geom}, '{point_or_poly}', '{normalization}', numer_aggregate,
  numer_colname, numer_geomref_colname, numer_tablename,
  denom_colname, denom_geomref_colname, denom_tablename,
  geom_colname, geom_geomref_colname, geom_tablename
) AS measure
FROM meta, obs_perftest_{complexity}
WHERE cartodb_id <= {n}
)
UPDATE obs_perftest_{complexity}
SET measure = data.measure
FROM data
WHERE obs_perftest_{complexity}.cartodb_id = data.cartodb_id
;
        '''.format(
            point_or_poly='point' if geom == 'point' else 'polygon',
            complexity=geom_complexity,
            schema='cdb_observatory.' if USE_SCHEMA else '',
            api_method='obs_getmeasure',
            normalization=normalization,
            geom=geom,
            boundary=boundary,
            n=rows)
        start = time()
        query(stmt)
        end = time()
        qps = (rows / (end - start))
        results.append({
            'rows': rows,
            'qps': qps,
            'stmt': stmt
        })
        print rows, ': ', qps, ' QPS'

    if 'OBS_RECORD_TEST' in os.environ:
        record({
            'geom_complexity': geom_complexity,
            'api_method': 'OBS_GetMeasureMeta/OBS_GetMeasureData',
            'normalization': normalization,
            'geom': geom
        }, results)
