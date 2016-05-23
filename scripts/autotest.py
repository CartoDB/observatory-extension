from nose.tools import assert_equal, assert_is_not_none
from nose_parameterized import parameterized

import os
import re
import requests

HOSTNAME = os.environ['OBS_HOSTNAME']
API_KEY = os.environ['OBS_API_KEY']
META_HOSTNAME = os.environ.get('OBS_META_HOSTNAME', HOSTNAME)
META_API_KEY = os.environ.get('OBS_META_API_KEY', API_KEY)
USE_SCHEMA = 'OBS_USE_SCHEMA' in os.environ


def query(q, is_meta=False, **options):
    '''
    Query the account.  Returned is the response, wrapped by the requests
    library.
    '''
    url = 'https://{hostname}/api/v2/sql'.format(
        hostname=META_HOSTNAME if is_meta else HOSTNAME)
    params = options.copy()
    params['q'] = re.sub(r'\s+', ' ', q)
    params['api_key'] = META_API_KEY if is_meta else API_KEY
    return requests.get(url, params=params)

MEASURE_COLUMNS = [(r['id'], ) for r in query('''
SELECT id FROM obs_column
WHERE type ILIKE 'numeric'
AND weight > 0
''', is_meta=True).json()['rows']]

CATEGORY_COLUMNS = [(r['id'], ) for r in query('''
SELECT id FROM obs_column
WHERE type ILIKE 'text'
AND weight > 0
''', is_meta=True).json()['rows']]

BOUNDARY_COLUMNS = [(r['id'], ) for r in query('''
SELECT id FROM obs_column
WHERE type ILIKE 'geometry'
AND weight > 0
''', is_meta=True).json()['rows']]

def default_point(column_id):
    '''
    Returns default test point for the column_id.
    '''
    if column_id == 'whosonfirst.wof_disputed_geom':
        return 'CDB_LatLng(33.78, 76.57)'
    elif column_id == 'whosonfirst.wof_marinearea_geom':
        return 'CDB_LatLng(43.33, -68.47)'
    elif column_id in ('us.census.tiger.school_district_elementary',
                       'us.census.tiger.school_district_secondary',
                       'us.census.tiger.school_district_elementary_clipped',
                       'us.census.tiger.school_district_secondary_clipped'):
        return 'CDB_LatLng(40.7025, -73.7067)'
    elif column_id.startswith('es.ine'):
        return 'CDB_LatLng(42.8226119029222, -2.51141249535454)'
    elif column_id.startswith('us.zillow'):
        return 'CDB_LatLng(28.3305906291771, -81.3544048197256)'
    else:
        return 'CDB_LatLng(40.7, -73.9)'


@parameterized(MEASURE_COLUMNS)
def test_measure_points(column_id):
    if not column_id.startswith('es.ine'):
        return
    resp = query('''
SELECT * FROM {schema}OBS_GetMeasure({point}, '{column_id}')
                 '''.format(column_id=column_id,
                            schema='cdb_observatory.' if USE_SCHEMA else '',
                            point=default_point(column_id)))
    assert_equal(resp.status_code, 200)
    rows = resp.json()['rows']
    assert_equal(1, len(rows))
    assert_is_not_none(rows[0].values()[0])

#@parameterized(CATEGORY_COLUMNS)
#def test_category_points(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetCategory({point}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            point=default_point(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0].values()[0])
#
#@parameterized(BOUNDARY_COLUMNS)
#def test_boundary_points(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetBoundary({point}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            point=default_point(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0].values()[0])
