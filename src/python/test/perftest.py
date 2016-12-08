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
        #'''SET statement_timeout = 5000;'''
):
    query(q.format(
        schema='cdb_observatory.' if USE_SCHEMA else '',
    ))
    commit()


ARGS = {
    ('OBS_GetMeasureByID', None): "name, 'us.census.acs.B01001002', '{}'",
    ('OBS_GetMeasure', 'predenominated'): "{}, 'us.census.acs.B01003001'",
    ('OBS_GetMeasure', 'area'): "{}, 'us.census.acs.B01001002', 'area'",
    ('OBS_GetMeasure', 'denominator'): "{}, 'us.census.acs.B01001002', 'denominator'",
    ('OBS_GetCategory', None): "{}, 'us.census.spielman_singleton_segments.X10'",
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
    ('simple', 'OBS_GetMeasureByID', None, 'us.census.tiger.census_tract'),
    ('complex', 'OBS_GetMeasureByID', None, 'us.census.tiger.county'),

    ('simple', 'OBS_GetMeasure', 'predenominated', 'point'),
    ('simple', 'OBS_GetMeasure', 'predenominated', 'geom'),
    ('simple', 'OBS_GetMeasure', 'predenominated', 'offset_geom'),
    ('simple', 'OBS_GetMeasure', 'area', 'point'),
    ('simple', 'OBS_GetMeasure', 'area', 'geom'),
    ('simple', 'OBS_GetMeasure', 'area', 'offset_geom'),
    ('simple', 'OBS_GetMeasure', 'denominator', 'point'),
    ('simple', 'OBS_GetMeasure', 'denominator', 'geom'),
    ('simple', 'OBS_GetMeasure', 'denominator', 'offset_geom'),
    ('simple', 'OBS_GetCategory', None, 'point'),
    ('simple', 'OBS_GetCategory', None, 'geom'),
    ('simple', 'OBS_GetCategory', None, 'offset_geom'),

    ('complex', 'OBS_GetMeasure', 'predenominated', 'point'),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'geom'),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'offset_geom'),
    ('complex', 'OBS_GetMeasure', 'area', 'point'),
    ('complex', 'OBS_GetMeasure', 'area', 'geom'),
    ('complex', 'OBS_GetMeasure', 'area', 'offset_geom'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'point'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'geom'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'offset_geom'),
    ('complex', 'OBS_GetCategory', None, 'point'),
    ('complex', 'OBS_GetCategory', None, 'geom'),
    ('complex', 'OBS_GetCategory', None, 'offset_geom'),
])
def test_performance(geom_complexity, api_method, normalization, geom):
    print api_method, geom_complexity, normalization, geom
    col = 'measure' if 'measure' in api_method.lower() else 'category'
    results = []

    rownums = (1, 5, 10, ) if geom_complexity == 'complex' else (5, 25, 50 )
    for rows in rownums:
        stmt = '''UPDATE obs_perftest_{complexity}
                   SET {col} = {schema}{api_method}({args})
                   WHERE cartodb_id < {n}'''.format(
                       col=col,
                       complexity=geom_complexity,
                       schema='cdb_observatory.' if USE_SCHEMA else '',
                       api_method=api_method,
                       args=ARGS[api_method, normalization].format(geom),
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
            'normalization': normalization,
            'geom': geom
        }, results)
