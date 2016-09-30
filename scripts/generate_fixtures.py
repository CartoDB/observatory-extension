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
        SELECT t.tablename, geoid_ct.colname colname
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
            'obs_meta_timespan', ]

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

OUTFILE_PATH = 'src/pg/test/fixtures/load_fixtures.sql'
DROPFILE_PATH = 'src/pg/test/fixtures/drop_fixtures.sql'

def dump(cols, tablename, where=''):

    with open(DROPFILE_PATH, 'a') as dropfile:
        dropfile.write('DROP TABLE IF EXISTS observatory.{tablename};\n'.format(
            tablename=tablename,
        ))

    subprocess.check_call('pg_dump -x --section=pre-data -t observatory.{tablename} '
                          ' | sed "s:, pg_catalog::" '
                          ' | sed "s:CREATE TABLE :CREATE TABLE observatory.:" '
                          ' | sed "s:ALTER TABLE.*OWNER.*::" '
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

    for f in fixtures:
        column_id, boundary_id, timespan = f
        tablename_query = get_tablename_query(column_id, boundary_id, timespan)
        tablename, colname = query(tablename_query).fetchone()
        table_colname = (tablename, colname, boundary_id, )
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
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_meta_numer':
            where = "WHERE " + " OR ".join([
                "numer_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_meta_denom':
            where = "WHERE " + " OR ".join([
                "denom_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_meta_geom':
            where = "WHERE " + " OR ".join([
                "geom_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_meta_timespan':
            where = "WHERE " + " OR ".join([
                "timespan_id = ('{}')".format(timespan)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_column':
            where = "WHERE " + " OR ".join([
                "id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename in ('obs_column_table', 'obs_column_tag'):
            where = "WHERE " + " OR ".join([
                "column_id IN ('{}', '{}')".format(numer_id, geom_id)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_column_to_column':
            where = "WHERE " + " OR ".join([
                "source_id IN ('{}', '{}') OR target_id IN ('{}', '{}')".format(
                    numer_id, geom_id, numer_id, geom_id)
                for numer_id, geom_id, timespan in fixtures
            ])
        elif tablename == 'obs_table':
            where = "WHERE " + " OR ".join([
                "timespan = '{}'".format(timespan)
                for numer_id, geom_id, timespan in fixtures
            ])
        else:
            where = ''
        dump('*', tablename, where)

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
        print ' '.join(['*', tablename, "WHERE {}::text {} {}".format(colname, compare, where)])
        dump('*', tablename, "WHERE {}::text {} {}".format(colname, compare, where))
        #cdb.dump(' '.join([select_star(tablename), "WHERE {}::text {} {}".format(colname, compare, where)]),
        #         tablename, outfile, schema='observatory')
        #dropfiles.write('DROP TABLE IF EXISTS observatory.{};\n'.format(tablename))

if __name__ == '__main__':
    main()
