
from sqldumpr import Dumpr

def get_tablename_query(column_id, boundary_id, timespan):
    """
        given a column_id, boundary-id (us.census.tiger.block_group), and
        timespan, give back the current table hash from the data observatory
    """
    q = """
        SELECT t.tablename, geoid_ct.colname colname
        FROM obs_table t,
             obs_column_table geoid_ct,
             obs_column_table data_ct
        WHERE
             t.id = geoid_ct.table_id AND
             t.id = data_ct.table_id AND
             geoid_ct.column_id =
        (SELECT source_id
         FROM obs_column_to_column
         WHERE target_id = '{boundary_id}'
         AND reltype = 'geom_ref'
        ) AND
        data_ct.column_id = '{column_id}' AND
        timespan = '{timespan}'
    """.replace('\n','')

    return q.format(column_id=column_id,
                    boundary_id=boundary_id,
                    timespan=timespan)

def select_star(tablename):
    return "SELECT * FROM {}".format(tablename)

cdb = Dumpr('observatory.cartodb.com','')

metadata = ['obs_table', 'obs_column_table', 'obs_column', 'obs_column_tag', 'obs_tag', 'obs_column_to_column']

fixtures = [
    ('us.census.tiger.census_tract', 'us.census.tiger.census_tract', '2014'),
    ('us.census.tiger.block_group', 'us.census.tiger.block_group', '2014'),
    ('us.census.tiger.zcta5', 'us.census.tiger.zcta5', '2014'),
    ('us.census.tiger.county', 'us.census.tiger.county', '2014'),
    ('us.census.acs.B01003001', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01003001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01003001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.spielman_singleton_segments.X10', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.zillow.AllHomes_Zhvi', 'us.census.tiger.zcta5', '2014-01'),
    ('us.zillow.AllHomes_Zhvi', 'us.census.tiger.zcta5', '2016-03'),
    ('whosonfirst.wof_country_geom', 'whosonfirst.wof_country_geom', '2016'),
    ('us.census.tiger.zcta5_clipped', 'us.census.tiger.zcta5_clipped', '2014'),
    ('us.census.tiger.block_group_clipped', 'us.census.tiger.block_group_clipped', '2014'),
]

unique_tables = set()

for f in fixtures:
    column_id, boundary_id, timespan = f
    tablename_query = get_tablename_query(*f)
    resp = cdb.query(tablename_query).json()['rows'][0]
    tablename = resp['tablename']
    colname = resp['colname']
    table_colname = (tablename, colname, boundary_id, )
    if table_colname not in unique_tables:
        print table_colname
        unique_tables.add(table_colname)

print unique_tables

with open('src/pg/test/fixtures/load_fixtures.sql', 'w') as outfile:
    with open('src/pg/test/fixtures/drop_fixtures.sql', 'w') as dropfiles:
        outfile.write('SET client_min_messages TO WARNING;\n\set ECHO none\n')
        dropfiles.write('SET client_min_messages TO WARNING;\n\set ECHO none\n')
        for tablename in metadata:
            cdb.dump(select_star(tablename), tablename, outfile, schema='observatory')
            dropfiles.write('DROP TABLE IF EXISTS observatory.{};\n'.format(tablename))
            print tablename

        for tablename, colname, boundary_id in unique_tables:
            if 'zcta5' in boundary_id:
                where = '\'11%\''
                compare = 'LIKE'
            elif 'whosonfirst' in boundary_id:
                where = '(\'85632785\',\'85633051\',\'85633111\',\'85633147\',\'85633253\',\'85633267\')'
                compare = 'IN'
            else:
                where = '\'36047%\''
                compare = 'LIKE'
            print ' '.join([select_star(tablename), "WHERE {}::text {} {}".format(colname, compare, where)])
            cdb.dump(' '.join([select_star(tablename), "WHERE {}::text {} {}".format(colname, compare, where)]),
                     tablename, outfile, schema='observatory')
            dropfiles.write('DROP TABLE IF EXISTS observatory.{};\n'.format(tablename))
