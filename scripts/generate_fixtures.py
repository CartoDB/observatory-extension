import os
import psycopg2
import subprocess

DB_CONN = psycopg2.connect('postgres://{user}:{password}@{host}:{port}/{database}'.format(
    user=os.environ.get('PGUSER', 'postgres'),
    password=os.environ.get('PGPASSWORD', ''),
    host=os.environ.get('PGHOST', 'localhost'),
    port=os.environ.get('PGPORT', '5432'),
    database=os.environ.get('PGDATABASE', 'postgres'),
))
CURSOR = DB_CONN.cursor()


def query(q):
    '''
    Query the database.
    '''
    try:
        CURSOR.execute(q)
        return CURSOR
    except:
        DB_CONN.rollback()
        raise


def commit():
    try:
        DB_CONN.commit()
    except:
        DB_CONN.rollback()
        raise


def get_tablename_query(column_id, boundary_id, timespan):
    """
        given a column_id, boundary-id (us.census.tiger.block_group), and
        timespan, give back the current table hash from the data observatory
    """
    return """
        SELECT t.tablename, geoid_ct.colname colname, t.id table_id
        FROM observatory.obs_table t,
             observatory.obs_column_table geoid_ct,
             observatory.obs_column_table data_ct
        WHERE
             t.id = geoid_ct.table_id AND
             t.id = data_ct.table_id AND
             geoid_ct.column_id =
        (SELECT source_id
         FROM observatory.obs_column_to_column
         WHERE target_id = '{boundary_id}'
         AND reltype = 'geom_ref'
        ) AND
        data_ct.column_id = '{column_id}' AND
        timespan = '{timespan}'
    """.format(column_id=column_id,
               boundary_id=boundary_id,
               timespan=timespan)


METADATA_TABLES = ['obs_table', 'obs_column_table', 'obs_column', 'obs_column_tag',
                   'obs_tag', 'obs_column_to_column', 'obs_dump_version', 'obs_meta',
                   'obs_meta_numer', 'obs_meta_denom', 'obs_meta_geom',
                   'obs_meta_timespan', 'obs_column_table_tile',
                   'obs_column_table_tile_simple']

FIXTURES = [
    ('us.census.acs.B01003001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01001002_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01001026_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01002001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B03002003_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B03002004_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B03002006_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B03002012_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B05001006_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006002_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006008_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006009_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006011_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006015_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B08006017_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B09001001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B11001001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B14001001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B14001002_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B14001005_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B14001006_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B14001007_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B14001008_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B15003001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B15003017_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B15003022_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B15003023_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B16001001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B16001002_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B16001003_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B17001001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B17001002_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B19013001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B19083001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B19301001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25001001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25002003_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25004002_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25004004_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25058001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25071001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25075001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B25075025_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01003001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B01001002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B01001026', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B01002001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002003', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002004', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002006', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002012', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002005', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002008', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002009', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B03002002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B11001001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003017', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003019', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003020', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003021', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003022', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B15003023', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19013001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19083001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19301001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25001001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25002003', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25004002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25004004', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25058001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25071001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25075001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25075025', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B25081002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134003', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134004', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134005', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134006', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134007', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134008', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134009', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08134010', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B08135001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001003', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001004', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001005', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001006', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001007', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001008', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001009', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001010', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001011', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001012', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001013', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001014', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001015', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001016', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B19001017', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.tiger.census_tract', 'us.census.tiger.census_tract', '2015'),
    ('us.census.tiger.census_tract', 'us.census.tiger.census_tract', '2014'),
    ('us.census.tiger.block_group', 'us.census.tiger.block_group', '2015'),
    ('us.census.tiger.zcta5', 'us.census.tiger.zcta5', '2015'),
    ('us.census.tiger.county', 'us.census.tiger.county', '2015'),
    ('us.census.acs.B01001002', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.acs.B01003001', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01003001_quantile', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.acs.B01003001', 'us.census.tiger.block_group', '2010 - 2014'),
    ('us.census.spielman_singleton_segments.X2', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.spielman_singleton_segments.X10', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.spielman_singleton_segments.X31', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.census.spielman_singleton_segments.X55', 'us.census.tiger.census_tract', '2010 - 2014'),
    ('us.zillow.AllHomes_Zhvi', 'us.census.tiger.zcta5', '2014-01'),
    ('us.zillow.AllHomes_Zhvi', 'us.census.tiger.zcta5', '2016-06'),
    ('whosonfirst.wof_country_geom', 'whosonfirst.wof_country_geom', '2016'),
    ('us.census.tiger.zcta5_clipped', 'us.census.tiger.zcta5_clipped', '2014'),
    ('us.census.tiger.block_group_clipped', 'us.census.tiger.block_group_clipped', '2014'),
    ('us.census.tiger.census_tract_clipped', 'us.census.tiger.census_tract_clipped', '2014'),
]

OUTFILE_PATH = os.path.join(os.path.dirname(__file__), '..',
                            'src/pg/test/fixtures/load_fixtures.sql')
DROPFILE_PATH = os.path.join(os.path.dirname(__file__), '..',
                             'src/pg/test/fixtures/drop_fixtures.sql')

def dump(cols, tablename, where=''):

    with open(DROPFILE_PATH, 'a') as dropfile:
        dropfile.write('DROP TABLE IF EXISTS observatory.{tablename};\n'.format(
            tablename=tablename,
        ))

    subprocess.check_call('pg_dump -x --section=pre-data -t observatory.{tablename} '
                          ' | sed "s:SET search_path.*::" '
                          ' | sed "s:CREATE TABLE :CREATE TABLE observatory.:" '
                          ' | sed "s:ALTER TABLE.*OWNER.*::" '
                          ' | sed "s:SET idle_in_transaction_session_timeout.*::" '
                          ' >> {outfile}'.format(
                              tablename=tablename,
                              outfile=OUTFILE_PATH,
                          ), shell=True)

    with open(OUTFILE_PATH, 'a') as outfile:
        outfile.write('COPY observatory."{}" FROM stdin WITH CSV HEADER;\n'.format(tablename))

    subprocess.check_call('''
      psql -c "COPY (SELECT {cols} \
      FROM observatory.{tablename} {where}) \
      TO STDOUT WITH CSV HEADER" >> {outfile}'''.format(
          cols=cols,
          tablename=tablename,
          where=where,
          outfile=OUTFILE_PATH,
      ), shell=True)

    with open(OUTFILE_PATH, 'a') as outfile:
        outfile.write('\\.\n\n')


def main():
    unique_tables = set()

    for f in FIXTURES:
        column_id, boundary_id, timespan = f
        tablename_query = get_tablename_query(column_id, boundary_id, timespan)
        resp = query(tablename_query).fetchone()
        if resp:
            tablename, colname, table_id = resp
        else:
            print("Could not find table for {}, {}, {}".format(
                column_id, boundary_id, timespan))
            continue
        table_colname = (tablename, colname, boundary_id, table_id, )
        if table_colname not in unique_tables:
            print(table_colname)
            unique_tables.add(table_colname)

    print unique_tables

    with open(OUTFILE_PATH, 'w') as outfile:
        outfile.write('SET client_min_messages TO WARNING;\n\\set ECHO none\n')
        outfile.write('CREATE SCHEMA IF NOT EXISTS observatory;\n\n')

    with open(DROPFILE_PATH, 'w') as dropfile:
        dropfile.write('SET client_min_messages TO WARNING;\n\\set ECHO none\n')

    for tablename in METADATA_TABLES:
        print(tablename)
        if tablename == 'obs_meta':
            where = "WHERE " + " OR ".join([
                "(numer_id, geom_id, numer_timespan) = ('{}', '{}', '{}')".format(
                    numer_id, geom_id, timespan)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_meta_numer':
            where = "WHERE " + " OR ".join([
                "numer_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_meta_denom':
            where = "WHERE " + " OR ".join([
                "denom_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_meta_geom':
            where = "WHERE " + " OR ".join([
                "geom_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_meta_timespan':
            where = "WHERE " + " OR ".join([
                "timespan_id = ('{}')".format(timespan)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_column':
            where = "WHERE " + " OR ".join([
                "id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_column_tag':
            where = "WHERE " + " OR ".join([
                "column_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename in ('obs_column_table', 'obs_column_table_tile',
                           'obs_column_table_tile_simple'):
            where = 'WHERE column_id IN ({numer_ids}) ' \
                    'OR column_id IN ({geom_ids}) ' \
                    'OR table_id IN ({table_ids}) '.format(
                        numer_ids=','.join(["'{}'".format(x) for x, _, _ in FIXTURES]),
                        geom_ids=','.join(["'{}'".format(x) for _, x, _ in FIXTURES]),
                        table_ids=','.join(["'{}'".format(x) for _, _, _, x in unique_tables])
                    )
        elif tablename == 'obs_column_to_column':
            where = "WHERE " + " OR ".join([
                "source_id IN ('{}', '{}') OR target_id IN ('{}', '{}')".format(
                    numer_id, geom_id, numer_id, geom_id)
                for numer_id, geom_id, timespan in FIXTURES
            ])
        elif tablename == 'obs_table':
            where = 'WHERE timespan IN ({timespans}) ' \
                    'OR id IN ({table_ids}) '.format(
                        timespans=','.join(["'{}'".format(x) for _, _, x in FIXTURES]),
                        table_ids=','.join(["'{}'".format(x) for _, _, _, x in unique_tables])
                    )
        else:
            where = ''
        dump('*', tablename, where)

    for tablename, colname, boundary_id, table_id in unique_tables:
        if 'zcta5' in boundary_id:
            where = '\'11%\''
            compare = 'LIKE'
        elif 'whosonfirst' in boundary_id:
            where = '(\'85632785\',\'85633051\',\'85633111\',\'85633147\',\'85633253\',\'85633267\')'
            compare = 'IN'
        else:
            where = '\'36047%\''
            compare = 'LIKE'
        print ' '.join(['*', tablename, "WHERE {}::text {} {}".format(colname, compare, where)])
        dump('*', tablename, "WHERE {}::text {} {}".format(colname, compare, where))

if __name__ == '__main__':
    main()
