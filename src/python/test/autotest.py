from nose.tools import assert_equal, assert_is_not_none
from nose.plugins.skip import SkipTest
from nose_parameterized import parameterized

from util import query

USE_SCHEMA = True

MEASURE_COLUMNS = query('''
SELECT distinct numer_id, numer_aggregate NOT ILIKE 'sum' as point_only
FROM observatory.obs_meta
WHERE numer_type ILIKE 'numeric'
AND numer_weight > 0
''').fetchall()

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
AND 'us.census.acs.acs' = ANY (subsection_tags)
AND numer_weight > 0
''').fetchall()

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
])

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


def default_point(column_id):
    '''
    Returns default test point for the column_id.
    '''
    if column_id == 'whosonfirst.wof_disputed_geom':
        return 'ST_SetSRID(ST_MakePoint(76.57, 33.78), 4326)'
    elif column_id == 'whosonfirst.wof_marinearea_geom':
        return 'ST_SetSRID(ST_MakePoint(-68.47, 43.33), 4326)'
    elif column_id in ('us.census.tiger.school_district_elementary',
                       'us.census.tiger.school_district_secondary',
                       'us.census.tiger.school_district_elementary_clipped',
                       'us.census.tiger.school_district_secondary_clipped'):
        return 'ST_SetSRID(ST_MakePoint(-73.7067, 40.7025), 4326)'
    elif column_id.startswith('uk'):
        if 'WA' in column_id:
            return 'ST_SetSRID(ST_MakePoint(-3.184833526611328, 51.46844551219723), 4326)'
        else:
            return 'ST_SetSRID(ST_MakePoint(-0.08883476257324219, 51.51461834694225), 4326)'
    elif column_id.startswith('es'):
        return 'ST_SetSRID(ST_MakePoint(-2.51141249535454, 42.8226119029222), 4326)'
    elif column_id.startswith('us.zillow'):
        return 'ST_SetSRID(ST_MakePoint(-81.3544048197256, 28.3305906291771), 4326)'
    elif column_id.startswith('mx.'):
        return 'ST_SetSRID(ST_MakePoint(-99.17019367218018, 19.41347699386547), 4326)'
    elif column_id.startswith('ca.'):
        raise SkipTest('Skipping Canada until validation of data complete')
        return 'ST_SetSRID(ST_MakePoint(-79.39716339111328, 43.65694347778308), 4326)'
    elif column_id.startswith('th.'):
        return 'ST_SetSRID(ST_MakePoint(100.49263000488281, 13.725377712079784), 4326)'
    # cols for French Guyana only
    elif column_id in ('fr.insee.P12_RP_CHOS', 'fr.insee.P12_RP_HABFOR'
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
                       , 'fr.insee.P12_ACTOCC15P_ILT45D'):
        return 'ST_SetSRID(ST_MakePoint(-52.32908248901367, 4.938408371206558), 4326)'
    elif column_id.startswith('fr'):
        return 'ST_SetSRID(ST_MakePoint(2.3613739013671875, 48.860875144709475), 4326)'
    elif column_id.startswith('ca'):
        return 'ST_SetSRID(ST_MakePoint(-79.37965393066406, 43.65594991256823), 4326)'
    else:
        return 'ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326)'


def default_area(column_id):
    '''
    Returns default test area for the column_id
    '''
    point = default_point(column_id)
    area = 'ST_Transform(ST_Buffer(ST_Transform({point}, 3857), 250), 4326)'.format(
        point=point)
    return area

@parameterized(US_CENSUS_MEASURE_COLUMNS)
def test_get_us_census_measure_points(name):
    resp = query('''
SELECT * FROM {schema}OBS_GetUSCensusMeasure({point}, '{name}')
                 '''.format(name=name.replace("'", "''"),
                            schema='cdb_observatory.' if USE_SCHEMA else '',
                            point=default_point('')))
    rows = resp.fetchall()
    assert_equal(1, len(rows))
    assert_is_not_none(rows[0][0])


@parameterized(MEASURE_COLUMNS)
def test_get_measure_areas(column_id, point_only):
    if column_id in SKIP_COLUMNS:
        raise SkipTest('Column {} should be skipped'.format(column_id))
    if point_only:
        return
    resp = query('''
SELECT * FROM {schema}OBS_GetMeasure({area}, '{column_id}')
                 '''.format(column_id=column_id,
                            schema='cdb_observatory.' if USE_SCHEMA else '',
                            area=default_area(column_id)))
    rows = resp.fetchall()
    assert_equal(1, len(rows))
    assert_is_not_none(rows[0][0])


@parameterized(MEASURE_COLUMNS)
def test_get_measure_points(column_id, point_only):
    if column_id in SKIP_COLUMNS:
        raise SkipTest('Column {} should be skipped'.format(column_id))
    resp = query('''
SELECT * FROM {schema}OBS_GetMeasure({point}, '{column_id}')
                 '''.format(column_id=column_id,
                            schema='cdb_observatory.' if USE_SCHEMA else '',
                            point=default_point(column_id)))
    rows = resp.fetchall()
    assert_equal(1, len(rows))
    assert_is_not_none(rows[0][0])

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

@parameterized(CATEGORY_COLUMNS)
def test_get_category_points(column_id):
    if column_id in SKIP_COLUMNS:
        raise SkipTest('Column {} should be skipped'.format(column_id))
    resp = query('''
SELECT * FROM {schema}OBS_GetCategory({point}, '{column_id}')
                 '''.format(column_id=column_id,
                            schema='cdb_observatory.' if USE_SCHEMA else '',
                            point=default_point(column_id)))
    rows = resp.fetchall()
    assert_equal(1, len(rows))
    assert_is_not_none(rows[0][0])

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

