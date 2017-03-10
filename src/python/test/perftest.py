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
                 st_makeenvelope(-74.1, 40.5,
                                 -73.8, 40.9, 4326),
                 'us.census.tiger.census_tract_clipped')) foo
           ORDER BY ST_NPoints(the_geom) ASC
           LIMIT 1000''',
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
    q_formatted = q.format(
        schema='cdb_observatory.' if USE_SCHEMA else '',
    )
    start = time()
    resp = query(q_formatted)
    end = time()
    print('{} for {}'.format(int(end - start), q_formatted))
    if q.lower().startswith('insert'):
        if resp.rowcount == 0:
            raise Exception('''Performance fixture creation "{}" inserted 0 rows,
                            this will break tests.  Check the query to determine
                            what is going wrong.'''.format(q_formatted))
    commit()


ARGS = {
    ('OBS_GetMeasureByID', None): "name, 'us.census.acs.B01001002', '{}'",
    ('OBS_GetMeasure', 'predenominated'): "{}, 'us.census.acs.B01003001', null, {}",
    ('OBS_GetMeasure', 'area'): "{}, 'us.census.acs.B01001002', 'area', {}",
    ('OBS_GetMeasure', 'denominator'): "{}, 'us.census.acs.B01001002', 'denominator', {}",
    ('OBS_GetCategory', None): "{}, 'us.census.spielman_singleton_segments.X10', {}",
    ('_OBS_GetGeometryScores', None): "{}, NULL"
}


def record(params, results):
    sha = os.environ['OBS_EXTENSION_SHA']
    msg = os.environ.get('OBS_EXTENSION_MSG')
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
                   WHERE cartodb_id <= {n}'''.format(
                       complexity=geom_complexity,
                       schema='cdb_observatory.' if USE_SCHEMA else '',
                       api_method=api_method,
                       filters=filters,
                       target_geoms=target_geoms,
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

    ('complex', 'OBS_GetMeasure', 'predenominated', 'geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'offset_geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'area', 'geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'area', 'offset_geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'geom', 'NULL'),
    ('complex', 'OBS_GetMeasure', 'denominator', 'offset_geom', 'NULL'),
    ('complex', 'OBS_GetCategory', None, 'geom', 'NULL'),
    ('complex', 'OBS_GetCategory', None, 'offset_geom', 'NULL'),

    ('complex', 'OBS_GetMeasure', 'predenominated', 'geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'predenominated', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'area', 'geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'area', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'denominator', 'geom', "'us.census.tiger.county'"),
    ('complex', 'OBS_GetMeasure', 'denominator', 'offset_geom', "'us.census.tiger.county'"),
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
            'boundary': boundary,
            'geom': geom
        }, results)


@parameterized([
    ('simple', 'predenominated', 'point', 'null'),
    ('simple', 'predenominated', 'geom', 'null'),
    ('simple', 'predenominated', 'offset_geom', 'null'),
    ('simple', 'area', 'point', 'null'),
    ('simple', 'area', 'geom', 'null'),
    ('simple', 'area', 'offset_geom', 'null'),
    ('simple', 'denominator', 'point', 'null'),
    ('simple', 'denominator', 'geom', 'null'),
    ('simple', 'denominator', 'offset_geom', 'null'),

    ('simple', 'predenominated', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'predenominated', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'predenominated', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'area', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'area', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'area', 'offset_geom', "'us.census.tiger.census_tract'"),
    ('simple', 'denominator', 'point', "'us.census.tiger.census_tract'"),
    ('simple', 'denominator', 'geom', "'us.census.tiger.census_tract'"),
    ('simple', 'denominator', 'offset_geom', "'us.census.tiger.census_tract'"),

    ('complex', 'predenominated', 'geom', 'null'),
    ('complex', 'predenominated', 'offset_geom', 'null'),
    ('complex', 'area', 'geom', 'null'),
    ('complex', 'area', 'offset_geom', 'null'),
    ('complex', 'denominator', 'geom', 'null'),
    ('complex', 'denominator', 'offset_geom', 'null'),

    ('complex', 'predenominated', 'geom', "'us.census.tiger.county'"),
    ('complex', 'predenominated', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'area', 'geom', "'us.census.tiger.county'"),
    ('complex', 'area', 'offset_geom', "'us.census.tiger.county'"),
    ('complex', 'denominator', 'geom', "'us.census.tiger.county'"),
    ('complex', 'denominator', 'offset_geom', "'us.census.tiger.county'"),
])
def test_getdata_performance(geom_complexity, normalization, geom, boundary):
    print geom_complexity, normalization, geom, boundary

    cols = ['us.census.acs.B01001002',
            'us.census.acs.B01001003',
            'us.census.acs.B01001004',
            'us.census.acs.B01001005',
            'us.census.acs.B01001006',
            'us.census.acs.B01001007',
            'us.census.acs.B01001008',
            'us.census.acs.B01001009',
            'us.census.acs.B01001010',
            'us.census.acs.B01001011', ]
    in_meta = [{"numer_id": col,
                "normalization": normalization,
                "geom_id": None if boundary.lower() == 'null' else boundary.replace("'", '')}
               for col in cols]

    rownums = (1, 5, 10, ) if geom_complexity == 'complex' else (10, 50, 100)

    for num_meta in (1, 10, ):
        results = []
        for rows in rownums:
            stmt = '''
    with data as (
      SELECT id, data FROM {schema}OBS_GetData(
        (SELECT array_agg(({geom}, cartodb_id)::geomval)
         FROM obs_perftest_{complexity}
         WHERE cartodb_id <= {n}),
        (SELECT {schema}OBS_GetMeta(
          (SELECT st_setsrid(st_extent({geom}), 4326)
           FROM obs_perftest_{complexity}
           WHERE cartodb_id <= {n}),
          '{in_meta}'::JSON
        ))
      ))
    UPDATE obs_perftest_{complexity}
    SET measure = (data->0->>'value')::Numeric
    FROM data
    WHERE obs_perftest_{complexity}.cartodb_id = data.id
    ;
            '''.format(
                point_or_poly='point' if geom == 'point' else 'polygon',
                complexity=geom_complexity,
                schema='cdb_observatory.' if USE_SCHEMA else '',
                geom=geom,
                in_meta=json.dumps(in_meta[0:num_meta]),
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
                'api_method': 'OBS_GetData',
                'normalization': normalization,
                'boundary': boundary,
                'geom': geom,
                'num_meta': str(num_meta)
            }, results)
