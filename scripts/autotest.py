from nose.tools import assert_equal
from nose_parameterized import parameterized

import os
import re
import requests

HOSTNAME = os.environ['OBS_HOSTNAME']
API_KEY = os.environ['OBS_API_KEY']

def query(q, **options):
    '''
    Query the account.  Returned is the response, wrapped by the requests
    library.
    '''
    url = 'https://{hostname}/api/v2/sql'.format(hostname=HOSTNAME)
    params = options.copy()
    params['q'] = re.sub(r'\s+', ' ', q)
    params['api_key'] = API_KEY
    return requests.get(url, params=params)

MEASURE_COLUMNS = [(r['id'], ) for r in query('''
SELECT id FROM observatory.obs_column
WHERE type ILIKE 'numeric'
AND weight > 0
''').json()['rows']]

CATEGORY_COLUMNS = [(r['id'], ) for r in query('''
SELECT id FROM observatory.obs_column
WHERE type ILIKE 'text'
AND weight > 0
''').json()['rows']]

BOUNDARY_COLUMNS = [(r['id'], ) for r in query('''
SELECT id FROM observatory.obs_column
WHERE type ILIKE 'geometry'
AND weight > 0
''').json()['rows']]


@parameterized(MEASURE_COLUMNS)
def test_measure_points(column_id):
    resp = query('''
SELECT *
FROM cdb_observatory.OBS_GetMeasure(cdb_observatory._TestPoint(),
                                    '{column_id}')
                 '''.format(column_id=column_id))
    assert_equal(resp.status_code, 200)

@parameterized(CATEGORY_COLUMNS)
def test_category_points(column_id):
    resp = query('''
SELECT *
FROM cdb_observatory.OBS_GetCategory(cdb_observatory._TestPoint(),
                                    '{column_id}')
                 '''.format(column_id=column_id))
    assert_equal(resp.status_code, 200)

@parameterized(BOUNDARY_COLUMNS)
def test_boundary_points(column_id):
    resp = query('''
SELECT *
FROM cdb_observatory.OBS_GetBoundary(cdb_observatory._TestPoint(),
                                    '{column_id}')
                 '''.format(column_id=column_id))
    assert_equal(resp.status_code, 200)
