
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

metadata = ['obs_table', 'obs_column_table', 'obs_column', 'obs_column_tag',
            'obs_tag', 'obs_column_to_column', 'obs_dump_version', ]

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


        outfile.write('''
ALTER TABLE observatory.obs_table
  ADD PRIMARY KEY (id);
ALTER TABLE observatory.obs_column_table
  ADD PRIMARY KEY (column_id, table_id),
  ADD FOREIGN KEY (column_id) REFERENCES observatory.obs_column(id) ON DELETE CASCADE,
  ADD FOREIGN KEY (table_id) REFERENCES observatory.obs_table(id) ON DELETE CASCADE;
CREATE UNIQUE INDEX ON observatory.obs_column_table (table_id, colname);
ALTER TABLE observatory.obs_column
  ADD PRIMARY KEY (id);
ALTER TABLE observatory.obs_column_to_column
  ADD PRIMARY KEY (source_id, target_id, reltype),
  ADD FOREIGN KEY (source_id) REFERENCES observatory.obs_column(id) ON DELETE CASCADE,
  ADD FOREIGN KEY (target_id) REFERENCES observatory.obs_column(id) ON DELETE CASCADE;
ALTER TABLE observatory.obs_column_tag
  ADD PRIMARY KEY (column_id, tag_id),
  ADD FOREIGN KEY (column_id) REFERENCES observatory.obs_column(id) ON DELETE CASCADE,
  ADD FOREIGN KEY (tag_id) REFERENCES observatory.obs_tag(id) ON DELETE CASCADE;
ALTER TABLE observatory.obs_tag
  ADD PRIMARY KEY (id);

CREATE TABLE observatory.obs_meta AS
SELECT numer_c.id numer_id,
       denom_c.id denom_id,
       geom_c.id geom_id,
       MAX(numer_c.name) numer_name,
       MAX(denom_c.name) denom_name,
       MAX(geom_c.name) geom_name,
       MAX(numer_c.description) numer_description,
       MAX(denom_c.description) denom_description,
       MAX(geom_c.description) geom_description,
       MAX(numer_c.aggregate) numer_aggregate,
       MAX(denom_c.aggregate) denom_aggregate,
       MAX(geom_c.aggregate) geom_aggregate,
       MAX(numer_c.type) numer_type,
       MAX(denom_c.type) denom_type,
       MAX(geom_c.type) geom_type,
       MAX(numer_data_ct.colname) numer_colname,
       MAX(denom_data_ct.colname) denom_colname,
       MAX(geom_geom_ct.colname) geom_colname,
       MAX(numer_geomref_ct.colname) numer_geomref_colname,
       MAX(denom_geomref_ct.colname) denom_geomref_colname,
       MAX(geom_geomref_ct.colname) geom_geomref_colname,
       MAX(numer_t.tablename) numer_tablename,
       MAX(denom_t.tablename) denom_tablename,
       MAX(geom_t.tablename) geom_tablename,
       MAX(numer_t.timespan) numer_timespan,
       MAX(denom_t.timespan) denom_timespan,
       MAX(numer_c.weight) numer_weight,
       MAX(denom_c.weight) denom_weight,
       MAX(geom_c.weight) geom_weight,
       MAX(geom_t.timespan) geom_timespan,
       MAX(geom_t.the_geom_webmercator)::geometry AS the_geom_webmercator,
       ARRAY_AGG(DISTINCT s_tag.id) section_tags,
       ARRAY_AGG(DISTINCT ss_tag.id) subsection_tags,
       ARRAY_AGG(DISTINCT unit_tag.id) unit_tags
FROM observatory.obs_column_table numer_data_ct,
     observatory.obs_table numer_t,
     observatory.obs_column_table numer_geomref_ct,
     observatory.obs_column geomref_c,
     observatory.obs_column_to_column geomref_c2c,
     observatory.obs_column geom_c,
     observatory.obs_column_table geom_geom_ct,
     observatory.obs_column_table geom_geomref_ct,
     observatory.obs_table geom_t,
     observatory.obs_column_tag ss_ctag,
     observatory.obs_tag ss_tag,
     observatory.obs_column_tag s_ctag,
     observatory.obs_tag s_tag,
     observatory.obs_column_tag unit_ctag,
     observatory.obs_tag unit_tag,
     observatory.obs_column numer_c
  LEFT JOIN (
    observatory.obs_column_to_column denom_c2c
    JOIN observatory.obs_column denom_c ON denom_c2c.target_id = denom_c.id
    JOIN observatory.obs_column_table denom_data_ct ON denom_data_ct.column_id = denom_c.id
    JOIN observatory.obs_table denom_t ON denom_data_ct.table_id = denom_t.id
    JOIN observatory.obs_column_table denom_geomref_ct ON denom_geomref_ct.table_id = denom_t.id
  ) ON denom_c2c.source_id = numer_c.id
WHERE numer_c.id = numer_data_ct.column_id
  AND numer_data_ct.table_id = numer_t.id
  AND numer_t.id = numer_geomref_ct.table_id
  AND numer_geomref_ct.column_id = geomref_c.id
  AND geomref_c2c.reltype = 'geom_ref'
  AND geomref_c.id = geomref_c2c.source_id
  AND geom_c.id = geomref_c2c.target_id
  AND geom_geomref_ct.column_id = geomref_c.id
  AND geom_geomref_ct.table_id = geom_t.id
  AND geom_geom_ct.column_id = geom_c.id
  AND geom_geom_ct.table_id = geom_t.id
  AND geom_c.type ILIKE 'geometry'
  AND numer_c.type NOT ILIKE 'geometry'
  AND numer_t.id != geom_t.id
  AND numer_c.id != geomref_c.id
  AND unit_tag.type = 'unit'
  AND ss_tag.type = 'subsection'
  AND s_tag.type = 'section'
  AND unit_ctag.column_id = numer_c.id
  AND unit_ctag.tag_id = unit_tag.id
  AND ss_ctag.column_id = numer_c.id
  AND ss_ctag.tag_id = ss_tag.id
  AND s_ctag.column_id = numer_c.id
  AND s_ctag.tag_id = s_tag.id
  AND (denom_c2c.reltype = 'denominator' OR denom_c2c.reltype IS NULL)
  AND (denom_geomref_ct.column_id = geomref_c.id OR denom_geomref_ct.column_id IS NULL)
  AND (denom_t.timespan = numer_t.timespan OR denom_t.timespan IS NULL)
GROUP BY numer_c.id, denom_c.id, geom_c.id,
         numer_t.id, denom_t.id, geom_t.id;
        ''')

        dropfiles.write('''
DROP TABLE IF EXISTS observatory.obs_meta;
                        ''')
