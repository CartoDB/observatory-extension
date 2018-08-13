from nose.tools import assert_equal, assert_is_not_none
from nose_parameterized import parameterized

from itertools import zip_longest
from util import query
from collections import OrderedDict
import json


def grouper(iterable, n, fillvalue=None):
    "Collect data into fixed-length chunks or blocks"
    # grouper('ABCDEFG', 3, 'x') --> ABC DEF Gxx
    args = [iter(iterable)] * n
    return zip_longest(fillvalue=fillvalue, *args)


USE_SCHEMA = True

SKIP_COLUMNS = set([
    'mx.inegi_columns.INDI18',
    'mx.inegi_columns.ECO40',
    'mx.inegi_columns.POB34',
    'mx.inegi_columns.POB63',
    'mx.inegi_columns.INDI7',
    'mx.inegi_columns.EDU28',
    'mx.inegi_columns.SCONY10',
    'mx.inegi_columns.EDU31',
    'mx.inegi_columns.POB7',
    'mx.inegi_columns.VIV30',
    'mx.inegi_columns.INDI12',
    'mx.inegi_columns.EDU13',
    'mx.inegi_columns.ECO43',
    'mx.inegi_columns.VIV9',
    'mx.inegi_columns.HOGAR25',
    'mx.inegi_columns.POB32',
    'mx.inegi_columns.ECO7',
    'mx.inegi_columns.INDI19',
    'mx.inegi_columns.INDI16',
    'mx.inegi_columns.POB65',
    'mx.inegi_columns.INDI3',
    'mx.inegi_columns.INDI9',
    'mx.inegi_columns.POB36',
    'mx.inegi_columns.POB33',
    'mx.inegi_columns.POB58',
    'mx.inegi_columns.DISC4',
    'mx.inegi_columns.VIV41',
    'mx.inegi_columns.VIV40',
    'mx.inegi_columns.VIV17',
    'mx.inegi_columns.VIV25',
    'mx.inegi_columns.EDU10',
    'whosonfirst.wof_disputed_name',
    'us.census.tiger.fullname',
    'whosonfirst.wof_marinearea_name',
    'us.census.tiger.mtfcc',
    'whosonfirst.wof_county_name',
    'whosonfirst.wof_region_name',
    'fr.insee.P12_RP_CHOS',
    'fr.insee.P12_RP_HABFOR',
    'fr.insee.P12_RP_EAUCH',
    'fr.insee.P12_RP_BDWC',
    'fr.insee.P12_RP_MIDUR',
    'fr.insee.P12_RP_CLIM',
    'fr.insee.P12_RP_MIBOIS',
    'fr.insee.P12_RP_CASE',
    'fr.insee.P12_RP_TTEGOU',
    'fr.insee.P12_RP_ELEC',
    'fr.insee.P12_ACTOCC15P_ILT45D',
    'fr.insee.P12_RP_CHOS',
    'fr.insee.P12_RP_HABFOR',
    'fr.insee.P12_RP_EAUCH',
    'fr.insee.P12_RP_BDWC',
    'fr.insee.P12_RP_MIDUR',
    'fr.insee.P12_RP_CLIM',
    'fr.insee.P12_RP_MIBOIS',
    'fr.insee.P12_RP_CASE',
    'fr.insee.P12_RP_TTEGOU',
    'fr.insee.P12_RP_ELEC',
    'fr.insee.P12_ACTOCC15P_ILT45D',
    'uk.ons.LC3202WA0007',
    'uk.ons.LC3202WA0010',
    'uk.ons.LC3202WA0004',
    'uk.ons.LC3204WA0004',
    'uk.ons.LC3204WA0007',
    'uk.ons.LC3204WA0010',
    'br.geo.subdistritos_name'
])

MEASURE_COLUMNS = query('''
SELECT cdb_observatory.FIRST(distinct numer_id) numer_ids,
       numer_aggregate,
       denom_reltype
FROM observatory.obs_meta
WHERE numer_weight > 0
  AND numer_id NOT IN ('{skip}')
  AND numer_id NOT LIKE 'eu.%' --Skipping Eurostat
  AND section_tags IS NOT NULL
  AND subsection_tags IS NOT NULL
GROUP BY numer_id, numer_aggregate, denom_reltype
'''.format(skip="', '".join(SKIP_COLUMNS))).fetchall()


def default_lonlat(column_id):
    '''
    Returns default test point for the column_id.
    '''
    if column_id == 'whosonfirst.wof_disputed_geom':
        return (76.57, 33.78)
    elif column_id == 'whosonfirst.wof_marinearea_geom':
        return (-68.47, 43.33)
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
    elif column_id.startswith('fr.'):
        return (48.860875144709475, 2.3613739013671875)
    elif column_id.startswith('ca.'):
        return (43.65594991256823, -79.37965393066406)
    elif column_id in ('us.census.tiger.school_district_elementary',
                       'us.census.tiger.school_district_secondary',
                       'us.census.tiger.school_district_elementary_clipped',
                       'us.census.tiger.school_district_secondary_clipped',
                       'us.census.tiger.school_district_elementary_geoname',
                       'us.census.tiger.school_district_secondary_geoname'):
        return (40.7025, -73.7067)
    elif column_id.startswith('us.census.'):
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
    elif column_id.startswith('br.'):
        return (-23.53, -46.63)
    elif column_id.startswith('au.'):
        return (-33.8806, 151.2131)
    else:
        raise Exception('No catalog point set for {}'.format(column_id))


def default_point(test_point):
    lat, lng = test_point
    return 'ST_SetSRID(ST_MakePoint({lng}, {lat}), 4326)'.format(
        lat=lat, lng=lng)


def default_area(test_point):
    '''
    Returns default test area for the column_id
    '''
    point = default_point(test_point)
    area = 'ST_Transform(ST_Buffer(ST_Transform({point}, 3857), 250), 4326)'.format(
        point=point)
    return area


def filter_points():
    return MEASURE_COLUMNS


def filter_areas():
    filtered = []
    for numer_ids, numer_aggregate, denom_reltype in MEASURE_COLUMNS:
        if numer_aggregate is None or numer_aggregate.lower() not in ('sum', 'median', 'average'):
            continue
        if numer_aggregate.lower() in ('median', 'average') \
                and (denom_reltype is None or denom_reltype.lower() != 'universe'):
            continue
        filtered.append((numer_ids, numer_aggregate, denom_reltype))

    return filtered


def grouped_measure_columns(filtered_columns):
    groupbypoint = dict()
    for row in filtered_columns:
        numer_ids = row[0]
        point = default_lonlat(numer_ids)
        if point in groupbypoint:
            groupbypoint[point].append(numer_ids)
        else:
            groupbypoint[point] = [numer_ids]

    for point, numer_ids in groupbypoint.items():
        for colgroup in grouper(numer_ids, 50):
            yield point, [c for c in colgroup if c]


@parameterized(grouped_measure_columns(filter_points()))
def test_get_measure_points(point, numer_ids):
    _test_measures(numer_ids, default_point(point))


@parameterized(grouped_measure_columns(filter_areas()))
def test_get_measure_areas(point, numer_ids):
    _test_measures(numer_ids, default_area(point))


def _test_measures(numer_ids, geom):
    in_params = []
    for numer_id in numer_ids:
        in_params.append({
            'numer_id': numer_id,
            'normalization': 'predenominated'
        })

    params = query('''
        SELECT {schema}OBS_GetMeta({geom}, '{in_params}')
    '''.format(schema='cdb_observatory.' if USE_SCHEMA else '',
               geom=geom,
               in_params=json.dumps(in_params))).fetchone()[0]

    # We can get duplicate IDs from multi-denominators, so for now we
    # compress those measures into a single
    params = list(OrderedDict([(p['id'], p) for p in params]).values())
    assert_equal(len(params), len(in_params),
                 'Inconsistent out and in params for {}'.format(in_params))

    q = '''
    SELECT * FROM {schema}OBS_GetData(ARRAY[({geom}, 1)::geomval], '{params}')
    '''.format(schema='cdb_observatory.' if USE_SCHEMA else '',
               geom=geom,
               params=json.dumps(params).replace("'", "''"))
    resp = query(q).fetchone()
    assert_is_not_none(resp, 'NULL returned for {}'.format(in_params))
    rawvals = resp[1]
    vals = [v['value'] for v in rawvals]

    assert_equal(len(vals), len(in_params))
    for i, val in enumerate(vals):
        assert_is_not_none(val, 'NULL for {}'.format(in_params[i]['numer_id']))
