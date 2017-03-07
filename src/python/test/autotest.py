from nose.tools import assert_equal, assert_is_not_none
from nose.plugins.skip import SkipTest
from nose_parameterized import parameterized

from itertools import izip_longest
from util import query
from collections import OrderedDict
import json


def grouper(iterable, n, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx
    args = [iter(iterable)] * n
    return izip_longest(fillvalue=fillvalue, *args)


USE_SCHEMA = True

SKIP_COLUMNS = set([
    u'mx.inegi_columns.INDI18',
    u'mx.inegi_columns.ECO40',
    u'mx.inegi_columns.POB34',
    u'mx.inegi_columns.POB63',
    u'mx.inegi_columns.INDI7',
    u'mx.inegi_columns.EDU28',
    u'mx.inegi_columns.SCONY10',
    u'mx.inegi_columns.EDU31',
    u'mx.inegi_columns.POB7',
    u'mx.inegi_columns.VIV30',
    u'mx.inegi_columns.INDI12',
    u'mx.inegi_columns.EDU13',
    u'mx.inegi_columns.ECO43',
    u'mx.inegi_columns.VIV9',
    u'mx.inegi_columns.HOGAR25',
    u'mx.inegi_columns.POB32',
    u'mx.inegi_columns.ECO7',
    u'mx.inegi_columns.INDI19',
    u'mx.inegi_columns.INDI16',
    u'mx.inegi_columns.POB65',
    u'mx.inegi_columns.INDI3',
    u'mx.inegi_columns.INDI9',
    u'mx.inegi_columns.POB36',
    u'mx.inegi_columns.POB33',
    u'mx.inegi_columns.POB58',
    u'mx.inegi_columns.DISC4',
    u'mx.inegi_columns.VIV41',
    u'mx.inegi_columns.VIV40',
    u'mx.inegi_columns.VIV17',
    u'mx.inegi_columns.VIV25',
    u'mx.inegi_columns.EDU10',
    u'whosonfirst.wof_disputed_name',
    u'us.census.tiger.fullname',
    u'whosonfirst.wof_marinearea_name',
    u'us.census.tiger.mtfcc',
    u'whosonfirst.wof_county_name',
    u'whosonfirst.wof_region_name',
    'fr.insee.P12_RP_CHOS', 'fr.insee.P12_RP_HABFOR'
    , 'fr.insee.P12_RP_EAUCH', 'fr.insee.P12_RP_BDWC'
    , 'fr.insee.P12_RP_MIDUR', 'fr.insee.P12_RP_CLIM'
    , 'fr.insee.P12_RP_MIBOIS', 'fr.insee.P12_RP_CASE'
    , 'fr.insee.P12_RP_TTEGOU', 'fr.insee.P12_RP_ELEC'
    , 'fr.insee.P12_ACTOCC15P_ILT45D'
    , 'fr.insee.P12_RP_CHOS', 'fr.insee.P12_RP_HABFOR'
    , 'fr.insee.P12_RP_EAUCH', 'fr.insee.P12_RP_BDWC'
    , 'fr.insee.P12_RP_MIDUR', 'fr.insee.P12_RP_CLIM'
    , 'fr.insee.P12_RP_MIBOIS', 'fr.insee.P12_RP_CASE'
    , 'fr.insee.P12_RP_TTEGOU', 'fr.insee.P12_RP_ELEC'
    , 'fr.insee.P12_ACTOCC15P_ILT45D'
])

MEASURE_COLUMNS = query('''
SELECT ARRAY_AGG(DISTINCT numer_id) numer_ids,
       numer_aggregate,
       section_tags
FROM observatory.obs_meta
WHERE numer_weight > 0
  AND numer_id NOT IN ('{skip}')
GROUP BY numer_aggregate, section_tags
'''.format(skip="', '".join(SKIP_COLUMNS))).fetchall()

CATEGORY_COLUMNS = query('''
SELECT distinct numer_id
FROM observatory.obs_meta
WHERE numer_type ILIKE 'text'
AND numer_weight > 0
''').fetchall()

BOUNDARY_COLUMNS = query('''
SELECT id FROM observatory.obs_column
WHERE type ILIKE 'geometry'
AND weight > 0
''').fetchall()

US_CENSUS_MEASURE_COLUMNS = query('''
SELECT distinct numer_name
FROM observatory.obs_meta
WHERE numer_type ILIKE 'numeric'
AND 'us.census.acs' = ANY (subsection_tags)
AND numer_weight > 0
''').fetchall()


#def default_geometry_id(column_id):
#    '''
#    Returns default test point for the column_id.
#    '''
#    if column_id == 'whosonfirst.wof_disputed_geom':
#        return 'ST_SetSRID(ST_MakePoint(76.57, 33.78), 4326)'
#    elif column_id == 'whosonfirst.wof_marinearea_geom':
#        return 'ST_SetSRID(ST_MakePoint(-68.47, 43.33), 4326)'
#    elif column_id in ('us.census.tiger.school_district_elementary',
#                       'us.census.tiger.school_district_secondary',
#                       'us.census.tiger.school_district_elementary_clipped',
#                       'us.census.tiger.school_district_secondary_clipped'):
#        return 'ST_SetSRID(ST_MakePoint(-73.7067, 40.7025), 4326)'
#    elif column_id.startswith('es.ine'):
#        return 'ST_SetSRID(ST_MakePoint(-2.51141249535454, 42.8226119029222), 4326)'
#    elif column_id.startswith('us.zillow'):
#        return 'ST_SetSRID(ST_MakePoint(-81.3544048197256, 28.3305906291771), 4326)'
#    elif column_id.startswith('ca.'):
#        return ''
#    else:
#        return 'ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)'


def default_lonlat(column_id):
    '''
    Returns default test point for the column_id.
    '''
    if column_id == 'whosonfirst.wof_disputed_geom':
        return (76.57, 33.78)
    elif column_id == 'whosonfirst.wof_marinearea_geom':
        return (-68.47, 43.33)
    elif column_id in ('us.census.tiger.school_district_elementary',
                       'us.census.tiger.school_district_secondary',
                       'us.census.tiger.school_district_elementary_clipped',
                       'us.census.tiger.school_district_secondary_clipped'):
        return (40.7025, -73.7067)
    elif column_id.startswith('uk'):
        if 'WA' in column_id:
            return (51.46844551219723, -3.184833526611328)
        else:
            return (51.51461834694225, -0.08883476257324219)
    elif column_id.startswith('es'):
        return (42.8226119029222, -2.51141249535454)
    elif column_id.startswith('us.zillow'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('mx.'):
        return (19.41347699386547, -99.17019367218018)
    elif column_id.startswith('th.'):
        return (13.725377712079784, 100.49263000488281)
    # cols for French Guyana only
    #elif column_id in ('fr.insee.P12_RP_CHOS', 'fr.insee.P12_RP_HABFOR'
    #                   , 'fr.insee.P12_RP_EAUCH', 'fr.insee.P12_RP_BDWC'
    #                   , 'fr.insee.P12_RP_MIDUR', 'fr.insee.P12_RP_CLIM'
    #                   , 'fr.insee.P12_RP_MIBOIS', 'fr.insee.P12_RP_CASE'
    #                   , 'fr.insee.P12_RP_TTEGOU', 'fr.insee.P12_RP_ELEC'
    #                   , 'fr.insee.P12_ACTOCC15P_ILT45D'
    #                   , 'fr.insee.P12_RP_CHOS', 'fr.insee.P12_RP_HABFOR'
    #                   , 'fr.insee.P12_RP_EAUCH', 'fr.insee.P12_RP_BDWC'
    #                   , 'fr.insee.P12_RP_MIDUR', 'fr.insee.P12_RP_CLIM'
    #                   , 'fr.insee.P12_RP_MIBOIS', 'fr.insee.P12_RP_CASE'
    #                   , 'fr.insee.P12_RP_TTEGOU', 'fr.insee.P12_RP_ELEC'
    #                   , 'fr.insee.P12_ACTOCC15P_ILT45D'):
    #    return (4.938408371206558, -52.32908248901367)
    elif column_id.startswith('fr.'):
        return (48.860875144709475, 2.3613739013671875)
    elif column_id.startswith('ca.'):
        return (43.65594991256823, -79.37965393066406)
    elif column_id.startswith('us.census.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('us.dma.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('us.ihme.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('us.bls.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('us.qcew.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('whosonfirst.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('us.epa.'):
        return (28.3305906291771, -81.3544048197256)
    elif column_id.startswith('eu.'):
        raise SkipTest('No tests for Eurostat!')
    elif column_id.startswith('br.'):
        return (-23.53, -46.63)
    elif column_id.startswith('au.'):
        return (-33.8806, 151.2131)
    else:
        raise Exception('No catalog point set for {}'.format(column_id))


def default_point(column_id):
    lat, lng = default_lonlat(column_id)
    return 'ST_SetSRID(ST_MakePoint({lng}, {lat}), 4326)'.format(
        lat=lat, lng=lng)


def default_area(column_id):
    '''
    Returns default test area for the column_id
    '''
    point = default_point(column_id)
    area = 'ST_Transform(ST_Buffer(ST_Transform({point}, 3857), 250), 4326)'.format(
        point=point)
    return area

#@parameterized(US_CENSUS_MEASURE_COLUMNS)
#def test_get_us_census_measure_points(name):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetUSCensusMeasure({point}, '{name}')
#                 '''.format(name=name.replace("'", "''"),
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            point=default_point('')))
#    rows = resp.fetchall()
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])


#@parameterized(MEASURE_COLUMNS)
#def test_get_measure_areas(numer_ids, numer_aggregate, section_tags):
#    if numer_aggregate.lower() not in ('sum', 'median', 'average'):
#        return
#    resp = query('''
#                 SELECT * FROM {schema}OBS_GetMeasure({area}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            area=default_area(column_id)))
#    rows = resp.fetchall()
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])


@parameterized(MEASURE_COLUMNS)
def test_get_measure_points(numer_ids, numer_aggregate, section_tags):
    all_in_params = []
    for numer_id in numer_ids:
        all_in_params.append({
            'numer_id': numer_id,
            'normalization': 'predenominated'
        })
    for in_params in grouper(all_in_params, 50):
        print('{} {}'.format(numer_aggregate, section_tags))
        in_params = [ip for ip in in_params if ip]

        params = query(u'''
            SELECT {schema}OBS_GetMeta({point}, '{in_params}')
        '''.format(schema='cdb_observatory.' if USE_SCHEMA else '',
                   point=default_point(numer_ids[0]),
                   in_params=json.dumps(in_params))).fetchone()[0]
        try:
            # We can get duplicate IDs from multi-denominators
            params = OrderedDict([(p['id'], p) for p in params]).values()
            assert_equal(len(params), len(in_params))
        except:
            import pdb
            pdb.set_trace()
        resp = query(u'''
             SELECT * FROM {schema}OBS_GetData(ARRAY[({point}, 1)::geomval], '{params}')
        '''.format(schema='cdb_observatory.' if USE_SCHEMA else '',
                   point=default_point(numer_ids[0]),
                   params=json.dumps(params).replace(u"'", "''"))).fetchone()[1]
        vals = [v['value'] for v in resp]
        assert_equal(len(vals), len(in_params))
        for i, val in enumerate(vals):
            try:
                assert_is_not_none(val)
            except:
                import pdb
                pdb.set_trace()
                print(val)
                raise
    #resp = query('''
    #SELECT * FROM {schema}OBS_GetMeasure({point}, '{column_id}')
    #             '''.format(column_id=column_id,
    #                        schema='cdb_observatory.' if USE_SCHEMA else '',
    #                        point=default_point(column_id)))
    #rows = resp.fetchall()
    #assert_equal(1, len(rows))
    #assert_is_not_none(rows[0][0])

#@parameterized(CATEGORY_COLUMNS)
#def test_get_category_areas(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetCategory({area}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            area=default_area(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

#@parameterized(CATEGORY_COLUMNS)
#def test_get_category_points(column_id):
#    if column_id in SKIP_COLUMNS:
#        raise SkipTest('Column {} should be skipped'.format(column_id))
#    resp = query('''
#SELECT * FROM {schema}OBS_GetCategory({point}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            point=default_point(column_id)))
#    rows = resp.fetchall()
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

#@parameterized(BOUNDARY_COLUMNS)
#def test_get_boundaries_by_geometry(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetBoundariesByGeometry({area}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            area=default_area(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

#@parameterized(BOUNDARY_COLUMNS)
#def test_get_points_by_geometry(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetPointsByGeometry({area}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            area=default_area(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

#@parameterized(BOUNDARY_COLUMNS)
#def test_get_boundary_points(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetBoundary({point}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            point=default_point(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

#@parameterized(BOUNDARY_COLUMNS)
#def test_get_boundary_id(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetBoundaryId({point}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            point=default_point(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

#@parameterized(BOUNDARY_COLUMNS)
#def test_get_boundary_by_id(column_id):
#    resp = query('''
#SELECT * FROM {schema}OBS_GetBoundaryById({geometry_id}, '{column_id}')
#                 '''.format(column_id=column_id,
#                            schema='cdb_observatory.' if USE_SCHEMA else '',
#                            geometry_id=default_geometry_id(column_id)))
#    assert_equal(resp.status_code, 200)
#    rows = resp.json()['rows']
#    assert_equal(1, len(rows))
#    assert_is_not_none(rows[0][0])

