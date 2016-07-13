
--For Longer term Dev


--Break out table definitions to types
--Automate type creation from a script, something like
----CREATE OR REPLACE FUNCTION OBS_Get<%=tag_name%>(geom GEOMETRY)
----RETURNS TABLE(
----<%=get_dimensions_for_tag(tag_name)%>
----AS $$
----DECLARE
----target_cols text[];
----names text[];
----vals NUMERIC[];-
----q text;
----BEGIN
----target_cols := Array[<%=get_dimensions_for_tag(tag_name)%>],


--Functions for augmenting specific tables
--------------------------------------------------------------------------------

-- Creates a table of demographic snapshot

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetDemographicSnapshot(geom geometry(Geometry, 4326),
  time_span text DEFAULT NULL,
  boundary_id text DEFAULT NULL)
RETURNS SETOF JSON
AS $$
  DECLARE
  target_cols text[];
  BEGIN

  IF time_span IS NULL THEN
    time_span = '2010 - 2014';
  END IF;

  IF boundary_id IS NULL THEN
    boundary_id = 'us.census.tiger.block_group';
  END IF;

  target_cols := Array['us.census.acs.B01003001',
                  'us.census.acs.B01001002',
                  'us.census.acs.B01001026',
                  'us.census.acs.B01002001',
                  'us.census.acs.B03002003',
                  'us.census.acs.B03002004',
                  'us.census.acs.B03002006',
                  'us.census.acs.B03002012',
                  'us.census.acs.B03002005',
                  'us.census.acs.B03002008',
                  'us.census.acs.B03002009',
                  'us.census.acs.B03002002',
                  --'not_us_citizen_pop',
                  --'workers_16_and_over',
                  --'commuters_by_car_truck_van',
                  --'commuters_drove_alone',
                  --'commuters_by_carpool',
                  --'commuters_by_public_transportation',
                  --'commuters_by_bus',
                  --'commuters_by_subway_or_elevated',
                  --'walked_to_work',
                  --'worked_at_home',
                  --'children',
                  'us.census.acs.B11001001',
                  --'population_3_years_over',
                  --'in_school',
                  --'in_grades_1_to_4',
                  --'in_grades_5_to_8',
                  --'in_grades_9_to_12',
                  --'in_undergrad_college',
                  'us.census.acs.B15003001',
                  'us.census.acs.B15003017',
                  'us.census.acs.B15003019',
                  'us.census.acs.B15003020',
                  'us.census.acs.B15003021',
                  'us.census.acs.B15003022',
                  'us.census.acs.B15003023',
                  --'pop_5_years_over',
                  --'speak_only_english_at_home',
                  --'speak_spanish_at_home',
                  --'pop_determined_poverty_status',
                  --'poverty',
                  'us.census.acs.B19013001',
                  'us.census.acs.B19083001',
                  'us.census.acs.B19301001',
                  'us.census.acs.B25001001',
                  'us.census.acs.B25002003',
                  'us.census.acs.B25004002',
                  'us.census.acs.B25004004',
                  'us.census.acs.B25058001',
                  'us.census.acs.B25071001',
                  'us.census.acs.B25075001',
                  'us.census.acs.B25075025',
                  'us.census.acs.B25081002',
                  --'pop_15_and_over',
                  --'pop_never_married',
                  --'pop_now_married',
                  --'pop_separated',
                  --'pop_widowed',
                  --'pop_divorced',
                  'us.census.acs.B08134001',
                  'us.census.acs.B08134002',
                  'us.census.acs.B08134003',
                  'us.census.acs.B08134004',
                  'us.census.acs.B08134005',
                  'us.census.acs.B08134006',
                  'us.census.acs.B08134007',
                  'us.census.acs.B08134008',
                  'us.census.acs.B08134009',
                  'us.census.acs.B08134010',
                  'us.census.acs.B08135001',
                  'us.census.acs.B19001002',
                  'us.census.acs.B19001003',
                  'us.census.acs.B19001004',
                  'us.census.acs.B19001005',
                  'us.census.acs.B19001006',
                  'us.census.acs.B19001007',
                  'us.census.acs.B19001008',
                  'us.census.acs.B19001009',
                  'us.census.acs.B19001010',
                  'us.census.acs.B19001011',
                  'us.census.acs.B19001012',
                  'us.census.acs.B19001013',
                  'us.census.acs.B19001014',
                  'us.census.acs.B19001015',
                  'us.census.acs.B19001016',
                  'us.census.acs.B19001017'];
    RETURN QUERY
    EXECUTE
    'select * from cdb_observatory._OBS_Get($1, $2, $3, $4 )'
    USING geom, target_cols, time_span, boundary_id
    RETURN;
END;
$$ LANGUAGE plpgsql;


--Base functions for performing augmentation
----------------------------------------------------------------------------------------

-- Base augmentation fucntion.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_Get(
  geom geometry(Geometry, 4326),
  column_ids text[],
  time_span text,
  geometry_level text
)
RETURNS SETOF JSON
AS $$
DECLARE
  results json[];
  geom_table_name text;
  names text[];
  query text;
  data_table_info json[];
BEGIN

  EXECUTE
  'SELECT array_agg(_obs_getcolumndata)
   FROM cdb_observatory._OBS_GetColumnData($1, $2, $3);'
  INTO data_table_info
  USING geometry_level, column_ids, time_span;

  IF geometry_level IS NULL THEN
    geometry_level = data_table_info[1]->>'boundary_id';
  END IF;

  geom_table_name := cdb_observatory._OBS_GeomTable(geom, geometry_level);

  IF geom_table_name IS NULL
  THEN
     --raise notice 'Point % is outside of the data region', ST_AsText(geom);
      -- TODO this should return JSON
     RETURN QUERY SELECT '{}'::json;
     RETURN;
  END IF;

  IF data_table_info IS NULL THEN
    --raise notice 'Cannot find data table for boundary ID %, column_ids %, and time_span %', geometry_level, column_ids, time_span;
  END IF;

  IF ST_GeometryType(geom) = 'ST_Point'
  THEN
    --raise notice 'geom_table_name %, data_table_info %', geom_table_name, data_table_info::json[];
    results := cdb_observatory._OBS_GetPoints(geom,
                                              geom_table_name,
                                              data_table_info);

  ELSIF ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon')
  THEN
    results := cdb_observatory._OBS_GetPolygons(geom,
                                                geom_table_name,
                                                data_table_info);
  END IF;

  RETURN QUERY
  EXECUTE
  $query$
    SELECT unnest($1)
  $query$
  USING results;
  RETURN;

END;
$$ LANGUAGE plpgsql;


-- If the variable of interest is just a rate return it as such,
--  otherwise normalize it to the census block area and return that
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetPoints(
  geom geometry(Geometry, 4326),
  geom_table_name text, -- TODO: change to boundary_id
  data_table_info json[]
)
RETURNS json[]
AS $$
DECLARE
  result NUMERIC[];
  json_result json[];
  query text;
  i int;
  geoid text;
  data_geoid_colname text;
  geom_geoid_colname text;
  area NUMERIC;
BEGIN

  -- TODO we're assuming our geom_table has only one geom_ref column
  --      we *really* should pass in both geom_table_name and boundary_id
  -- TODO tablename should not be passed here (use boundary_id)
  EXECUTE
    format('SELECT ct.colname
              FROM observatory.obs_column_to_column c2c,
                   observatory.obs_column_table ct,
                   observatory.obs_table t
             WHERE c2c.reltype = ''geom_ref''
               AND ct.column_id = c2c.source_id
               AND ct.table_id = t.id
               AND t.tablename = %L'
     , (data_table_info)[1]->>'tablename')
  INTO data_geoid_colname;
  EXECUTE
    format('SELECT ct.colname
              FROM observatory.obs_column_to_column c2c,
                   observatory.obs_column_table ct,
                   observatory.obs_table t
             WHERE c2c.reltype = ''geom_ref''
               AND ct.column_id = c2c.source_id
               AND ct.table_id = t.id
               AND t.tablename = %L'
   , geom_table_name)
  INTO geom_geoid_colname;

  EXECUTE
    format('SELECT %I
              FROM observatory.%I
             WHERE ST_Within($1, the_geom)',
            geom_geoid_colname,
            geom_table_name)
  USING geom
  INTO geoid;

  --raise notice 'geoid is %, geometry table is % ', geoid, geom_table_name;

  EXECUTE
    format('SELECT ST_Area(the_geom::geography) / (1000 * 1000)
            FROM observatory.%I
            WHERE %I = %L',
            geom_table_name,
            geom_geoid_colname,
            geoid)
  INTO area;

  IF area IS NULL
  THEN
    --raise notice 'No geometry at %', ST_AsText(geom);
  END IF;

  query := 'SELECT Array[';
  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    IF area is NULL OR area = 0
    THEN
      -- give back null values
      query := query || format('NULL::numeric ');
    ELSIF ((data_table_info)[i])->>'aggregate' != 'sum'
    THEN
      -- give back full variable
      query := query || format('%I ', ((data_table_info)[i])->>'colname');
    ELSE
      -- give back variable normalized by area of geography
      query := query || format('%I/%s ',
        ((data_table_info)[i])->>'colname',
        area);
    END IF;

    IF i < array_upper(data_table_info, 1)
    THEN
      query := query || ',';
    END IF;
  END LOOP;

  query := query || format(' ]::numeric[]
    FROM observatory.%I
    WHERE %I.%I  = %L
  ',
  ((data_table_info)[1])->>'tablename',
  ((data_table_info)[1])->>'tablename',
  data_geoid_colname,
  geoid
  );

  EXECUTE
    query
  INTO result
  USING geom;

  EXECUTE
    $query$
     SELECT array_agg(row_to_json(t)) FROM (
      SELECT values As value,
              meta->>'name' As name,
              meta->>'tablename' As tablename,
              meta->>'aggregate' As aggregate,
              meta->>'type' As type,
              meta->>'description' As description
             FROM (SELECT unnest($1) As values, unnest($2) As meta) b
      ) t
    $query$
    INTO json_result
    USING result, data_table_info;

  RETURN json_result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeasure(
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT 'area', -- TODO none/null
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL
)
RETURNS NUMERIC
AS $$
DECLARE
  map_type TEXT;
  numer_aggregate TEXT;
  numer_colname TEXT;
  numer_geomref_colname TEXT;
  numer_tablename TEXT;
  denom_colname TEXT;
  denom_geomref_colname TEXT;
  denom_tablename TEXT;
  geom_colname TEXT;
  geom_geomref_colname TEXT;
  geom_tablename TEXT;
  result NUMERIC;
  sql TEXT;
  numer_name TEXT;
BEGIN

  EXECUTE
     $query$
     SELECT numer_aggregate, numer_colname, numer_geomref_colname, numer_tablename,
            denom_colname, denom_geomref_colname, denom_tablename,
            geom_colname, geom_geomref_colname, geom_tablename, numer_name
             FROM observatory.obs_meta
             WHERE (geom_id = $1 OR ($1 = ''))
               AND numer_id = $2
               AND (numer_timespan = $3 OR ($3 = ''))
             ORDER BY geom_weight DESC, numer_timespan DESC
             LIMIT 1
     $query$
    INTO numer_aggregate, numer_colname, numer_geomref_colname, numer_tablename,
         denom_colname, denom_geomref_colname, denom_tablename,
         geom_colname, geom_geomref_colname, geom_tablename, numer_name
    USING COALESCE(boundary_id, ''), measure_id, COALESCE(time_span, '');

  IF normalize ILIKE 'area' AND numer_aggregate ILIKE 'sum' THEN
    map_type := 'areaNormalized';
  ELSIF normalize ILIKE 'denominator' AND numer_aggregate ILIKE 'sum' THEN
    map_type := 'denominated';
  ELSE
    map_type := 'predenominated';
  END IF;

  IF ST_GeometryType(geom) = 'ST_Point' THEN
    IF map_type = 'areaNormalized' THEN
      sql = format('WITH _geom AS (SELECT ST_Area(geom.%I::Geography) / 1000000 area, geom.%I geom_ref
                                   FROM observatory.%I geom
                                   WHERE ST_Within(%L, geom.%I)
                                   LIMIT 1)
                    SELECT numer.%I / (SELECT area FROM _geom)
                    FROM observatory.%I numer
                    WHERE numer.%I = (SELECT geom_ref FROM _geom)',
                geom_colname, geom_geomref_colname, geom_tablename,
                geom, geom_colname, numer_colname, numer_tablename,
                numer_geomref_colname);
    ELSIF map_type = 'denominated' THEN
      sql = format('SELECT numer.%I / NULLIF((SELECT denom.%I FROM observatory.%I denom WHERE denom.%I = numer.%I LIMIT 1), 0)
                    FROM observatory.%I numer
                    WHERE numer.%I = (SELECT geom.%I FROM observatory.%I geom WHERE ST_Within(%L, geom.%I) LIMIT 1)',
                        numer_colname, denom_colname, denom_tablename,
                        denom_geomref_colname, numer_geomref_colname,
                        numer_tablename,
                        numer_geomref_colname, geom_geomref_colname,
                        geom_tablename, geom, geom_colname);
    ELSIF map_type = 'predenominated' THEN
      sql = format('SELECT numer.%I
                    FROM observatory.%I numer
                    WHERE numer.%I = (SELECT geom.%I FROM observatory.%I geom WHERE ST_Within(%L, geom.%I) LIMIT 1)',
                        numer_colname, numer_tablename,
                        numer_geomref_colname, geom_geomref_colname, geom_tablename,
                        geom, geom_colname);
    END IF;
  ELSIF ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon') THEN
    IF map_type = 'areaNormalized' THEN
      sql = format('WITH _geom AS (SELECT ST_Area(ST_Intersection(%L, geom.%I))
                                        / ST_Area(geom.%I) overlap, geom.%I geom_ref
                                   FROM observatory.%I geom
                                   WHERE ST_Intersects(%L, geom.%I)
                                     AND ST_Area(ST_Intersection(%L, geom.%I)) / ST_Area(geom.%I) > 0)
                    SELECT SUM(numer.%I * (SELECT _geom.overlap FROM _geom WHERE _geom.geom_ref = numer.%I)) /
                           ST_Area(%L::Geography)
                    FROM observatory.%I numer
                    WHERE numer.%I = ANY ((SELECT ARRAY_AGG(geom_ref) FROM _geom)::TEXT[])',
                geom, geom_colname, geom_colname,
                geom_geomref_colname, geom_tablename,
                geom, geom_colname,
                geom, geom_colname, geom_colname,
                numer_colname, numer_geomref_colname,
                geom, numer_tablename,
                numer_geomref_colname);
    ELSIF map_type = 'denominated' THEN
      sql = format('WITH _geom AS (SELECT ST_Area(ST_Intersection(%L, geom.%I))
                                        / ST_Area(geom.%I) overlap, geom.%I geom_ref
                                   FROM observatory.%I geom
                                   WHERE ST_Intersects(%L, geom.%I)
                                     AND ST_Area(ST_Intersection(%L, geom.%I)) / ST_Area(geom.%I) > 0),
                        _denom AS (SELECT denom.%I, denom.%I geom_ref
                                   FROM observatory.%I denom
                                   WHERE denom.%I IN (SELECT geom_ref FROM _geom))
                    SELECT SUM(numer.%I * (SELECT _geom.overlap FROM _geom WHERE _geom.geom_ref = numer.%I)) /
                           SUM((SELECT _denom.%I * (SELECT _geom.overlap
                                                    FROM _geom
                                                    WHERE _geom.geom_ref = _denom.geom_ref)
                                FROM _denom WHERE _denom.geom_ref = numer.%I))
                    FROM observatory.%I numer
                    WHERE numer.%I = ANY ((SELECT ARRAY_AGG(geom_ref) FROM _geom)::TEXT[])',
                geom, geom_colname,
                geom_colname, geom_geomref_colname,
                geom_tablename,
                geom, geom_colname,
                geom, geom_colname, geom_colname,
                denom_colname, denom_geomref_colname,
                denom_tablename,
                denom_geomref_colname,
                numer_colname, numer_geomref_colname,
                denom_colname,
                numer_geomref_colname,
                numer_tablename,
                numer_geomref_colname);
    ELSIF map_type = 'predenominated' THEN
      IF numer_aggregate NOT ILIKE 'sum' THEN
        RAISE EXCEPTION 'Cannot calculate "%" (%) for custom area as it cannot be summed, use ST_PointOnSurface instead',
                        numer_name, numer_id;
      ELSE
        sql = format('WITH _geom AS (SELECT ST_Area(ST_Intersection(%L, geom.%I))
                                          / ST_Area(geom.%I) overlap, geom.%I geom_ref
                                     FROM observatory.%I geom
                                     WHERE ST_Intersects(%L, geom.%I)
                                       AND ST_Area(ST_Intersection(%L, geom.%I)) / ST_Area(geom.%I) > 0)
                      SELECT SUM(numer.%I * (SELECT _geom.overlap FROM _geom WHERE _geom.geom_ref = numer.%I))
                      FROM observatory.%I numer
                      WHERE numer.%I = ANY ((SELECT ARRAY_AGG(geom_ref) FROM _geom)::TEXT[])',
                  geom, geom_colname, geom_colname,
                  geom_geomref_colname, geom_tablename,
                  geom, geom_colname,
                  geom, geom_colname, geom_colname,
                  numer_colname, numer_geomref_colname,
                  numer_tablename,
                  numer_geomref_colname);
      END IF;
    END IF;
  ELSE
    RAISE EXCEPTION 'Invalid geometry type (%), can only handle ''ST_Point'', ''ST_Polygon'', and ''ST_MultiPolygon''',
                    ST_GeometryType(geom);
  END IF;

  EXECUTE sql INTO result;
  RETURN result;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeasureById(
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL
)
RETURNS NUMERIC
AS $$
DECLARE
  target_table TEXT;
  colname TEXT;
  measure_val NUMERIC;
  data_geoid_colname TEXT;
BEGIN

  EXECUTE
     $query$
     SELECT numer_colname, numer_geomref_colname, numer_tablename
             FROM observatory.obs_meta
             WHERE (geom_id = $1 OR ($1 = ''))
               AND numer_id = $2
               AND (numer_timespan = $3 OR ($3 = ''))
             ORDER BY geom_weight DESC, numer_timespan DESC
             LIMIT 1
     $query$
    INTO colname, data_geoid_colname, target_table
    USING COALESCE(boundary_id, ''), measure_id, COALESCE(time_span, '');

  --RAISE DEBUG 'target_table %, colname %', target_table, colname;

  EXECUTE format(
      'SELECT %I
       FROM observatory.%I data
       WHERE data.%I = %L',
       colname,
       target_table,
       data_geoid_colname, geom_ref)
  INTO measure_val;

  RETURN measure_val;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetCategory(
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL
)
RETURNS TEXT
AS $$
DECLARE
  data_table TEXT;
  geom_table TEXT;
  colname TEXT;
  data_geomref_colname TEXT;
  geom_geomref_colname TEXT;
  geom_colname TEXT;
  category_val TEXT;
  category_share NUMERIC;
BEGIN

  EXECUTE
     $query$
     SELECT numer_colname, numer_geomref_colname, numer_tablename,
            geom_geomref_colname, geom_colname, geom_tablename
             FROM observatory.obs_meta
             WHERE (geom_id = $1 OR ($1 = ''))
               AND numer_id = $2
               AND (numer_timespan = $3 OR ($3 = ''))
             ORDER BY geom_weight DESC, numer_timespan DESC
             LIMIT 1
     $query$
    INTO colname, data_geomref_colname, data_table,
         geom_geomref_colname, geom_colname, geom_table
    USING COALESCE(boundary_id, ''), category_id, COALESCE(time_span, '');

  IF ST_GeometryType(geom) = 'ST_Point' THEN
    EXECUTE format(
        'SELECT data.%I
         FROM observatory.%I data, observatory.%I geom
         WHERE data.%I = geom.%I
           AND ST_WITHIN(%L, geom.%I) ',
         colname, data_table, geom_table, data_geomref_colname,
         geom_geomref_colname, geom, geom_colname)
    INTO category_val;
  ELSE
    -- favor the category with the most area
    EXECUTE format(
       'SELECT data.%I category, SUM(overlap_fraction) category_share
        FROM observatory.%I data, (
          SELECT ST_Area(
           ST_Intersection(%L, a.%I)
          ) / ST_Area(%L) AS overlap_fraction, a.%I geomref
          FROM observatory.%I as a
          WHERE %L && a.%I) _overlaps
        WHERE data.%I = _overlaps.geomref
        GROUP BY category
        ORDER BY SUM(overlap_fraction) DESC
        LIMIT 1',
          colname, data_table,
          geom, geom_colname, geom, geom_geomref_colname,
          geom_table, geom, geom_colname, data_geomref_colname)
    INTO category_val, category_share;
  END IF;

  RETURN category_val;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetUSCensusMeasure(
   geom geometry(Geometry, 4326),
   name TEXT,
   normalize TEXT DEFAULT 'area',
   boundary_id TEXT DEFAULT NULL,
   time_span TEXT DEFAULT NULL
 )
RETURNS NUMERIC AS $$
DECLARE
  standardized_name text;
  measure_id text;
  result NUMERIC;
BEGIN
  standardized_name = cdb_observatory._OBS_StandardizeMeasureName(name);

  EXECUTE $string$
  SELECT c.id
  FROM observatory.obs_column c
       JOIN observatory.obs_column_tag ct
         ON c.id = ct.column_id
       WHERE cdb_observatory._OBS_StandardizeMeasureName(c.name) = $1
         AND ct.tag_id ILIKE 'us.census%'
  $string$
  INTO measure_id
  USING standardized_name;

  EXECUTE 'SELECT cdb_observatory.OBS_GetMeasure($1, $2, $3, $4, $5)'
  INTO result
  USING geom, measure_id, normalize, boundary_id, time_span;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetUSCensusCategory(
   geom geometry(Geometry, 4326),
   name TEXT,
   boundary_id TEXT DEFAULT NULL,
   time_span TEXT DEFAULT NULL
 )
RETURNS TEXT AS $$
DECLARE
  standardized_name text;
  category_id text;
  result TEXT;
BEGIN
  standardized_name = cdb_observatory._OBS_StandardizeMeasureName(name);

  EXECUTE $string$
  SELECT c.id
  FROM observatory.obs_column c
       --JOIN observatory.obs_column_tag ct
       --  ON c.id = ct.column_id
       WHERE cdb_observatory._OBS_StandardizeMeasureName(c.name) = $1
         AND c.type ILIKE 'TEXT'
         AND c.id ILIKE 'us.census%' -- TODO this should be done by tag
         --AND ct.tag_id = 'us.census.acs.demographics'
  $string$
  INTO category_id
  USING standardized_name;

  EXECUTE 'SELECT cdb_observatory.OBS_GetCategory($1, $2, $3, $4)'
  INTO result
  USING geom, category_id, boundary_id, time_span;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetPopulation(
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT 'area',
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL
)
RETURNS NUMERIC
AS $$
DECLARE
  population_measure_id TEXT;
  result NUMERIC;
BEGIN
  -- TODO use a super-column for global pop
  population_measure_id := 'us.census.acs.B01003001';

  EXECUTE format('SELECT cdb_observatory.OBS_GetMeasure(
      %L, %L, %L, %L, %L
  ) LIMIT 1', geom, population_measure_id, normalize, boundary_id, time_span)
  INTO result;

  return result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetPolygons(
  geom geometry(Geometry, 4326),
  geom_table_name text,
  data_table_info json[]
)
RETURNS json[]
AS $$
DECLARE
  result numeric[];
  json_result json[];
  q_select text;
  q_sum text;
  q text;
  i NUMERIC;
  data_geoid_colname text;
  geom_geoid_colname text;
BEGIN

  -- TODO we're assuming our geom_table has only one geom_ref column
  --      we *really* should pass in both geom_table_name and boundary_id
  -- TODO tablename should not be passed here (use boundary_id)
  EXECUTE
    format('SELECT ct.colname
              FROM observatory.obs_column_to_column c2c,
                   observatory.obs_column_table ct,
                   observatory.obs_table t
             WHERE c2c.reltype = ''geom_ref''
               AND ct.column_id = c2c.source_id
               AND ct.table_id = t.id
               AND t.tablename = %L'
     , (data_table_info)[1]->>'tablename')
  INTO data_geoid_colname;
  EXECUTE
    format('SELECT ct.colname
              FROM observatory.obs_column_to_column c2c,
                   observatory.obs_column_table ct,
                   observatory.obs_table t
             WHERE c2c.reltype = ''geom_ref''
               AND ct.column_id = c2c.source_id
               AND ct.table_id = t.id
               AND t.tablename = %L'
   , geom_table_name)
  INTO geom_geoid_colname;

  q_select := format('SELECT %I, ', data_geoid_colname);
  q_sum    := 'SELECT Array[';

  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    q_select := q_select || format( '%I ', ((data_table_info)[i])->>'colname');

    IF ((data_table_info)[i])->>'aggregate' ='sum'
    THEN
      q_sum := q_sum || format('sum(overlap_fraction * COALESCE(%I, 0)) ',((data_table_info)[i])->>'colname',((data_table_info)[i])->>'colname');
    ELSE
      q_sum := q_sum || ' NULL::numeric ';
    END IF;

    IF i < array_upper(data_table_info,1)
    THEN
      q_select := q_select || format(',');
      q_sum := q_sum || format(',');
    END IF;
 END LOOP;

  q := format('
    WITH _overlaps As (
      SELECT ST_Area(
        ST_Intersection($1, a.the_geom)
      ) / ST_Area(a.the_geom) As overlap_fraction,
      %I
      FROM observatory.%I As a
      WHERE $1 && a.the_geom
    ),
    values As (
    ', geom_geoid_colname, geom_table_name);

  q := q || q_select || format('FROM observatory.%I ', ((data_table_info)[1]->>'tablename'));

  q := format(q || ' ) ' || q_sum || ' ]::numeric[] FROM _overlaps, values
  WHERE values.%I = _overlaps.%I', data_geoid_colname, geom_geoid_colname);

  EXECUTE
    q
  INTO result
  USING geom;

  EXECUTE
    $query$
     SELECT array_agg(row_to_json(t)) FROM (
      SELECT values As value,
              meta->>'name' As name,
              meta->>'tablename' As tablename,
              meta->>'aggregate' As aggregate,
              meta->>'type' As type,
              meta->>'description' As description
             FROM (SELECT unnest($1) As values, unnest($2) As meta) b
      ) t
    $query$
    INTO json_result
    USING result, data_table_info;

  RETURN json_result;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetSegmentSnapshot(
  geom geometry(Geometry, 4326),
  boundary_id text DEFAULT NULL
)
RETURNS JSON
AS $$
DECLARE
  target_cols text[];
  result       json;
  seg_name     Text;
  geom_id      Text;
  q            Text;
  segment_names Text[];
BEGIN
IF boundary_id IS NULL THEN
 boundary_id = 'us.census.tiger.census_tract';
END IF;
target_cols := Array[
          'us.census.acs.B01003001_quantile',
          'us.census.acs.B01001002_quantile',
          'us.census.acs.B01001026_quantile',
          'us.census.acs.B01002001_quantile',
          'us.census.acs.B03002003_quantile',
          'us.census.acs.B03002004_quantile',
          'us.census.acs.B03002006_quantile',
          'us.census.acs.B03002012_quantile',
          'us.census.acs.B05001006_quantile',--
          'us.census.acs.B08006001_quantile',--
          'us.census.acs.B08006002_quantile',--
          'us.census.acs.B08006008_quantile',--
          'us.census.acs.B08006009_quantile',--
          'us.census.acs.B08006011_quantile',--
          'us.census.acs.B08006015_quantile',--
          'us.census.acs.B08006017_quantile',--
          'us.census.acs.B09001001_quantile',--
          'us.census.acs.B11001001_quantile',
          'us.census.acs.B14001001_quantile',--
          'us.census.acs.B14001002_quantile',--
          'us.census.acs.B14001005_quantile',--
          'us.census.acs.B14001006_quantile',--
          'us.census.acs.B14001007_quantile',--
          'us.census.acs.B14001008_quantile',--
          'us.census.acs.B15003001_quantile',
          'us.census.acs.B15003017_quantile',
          'us.census.acs.B15003022_quantile',
          'us.census.acs.B15003023_quantile',
          'us.census.acs.B16001001_quantile',--
          'us.census.acs.B16001002_quantile',--
          'us.census.acs.B16001003_quantile',--
          'us.census.acs.B17001001_quantile',--
          'us.census.acs.B17001002_quantile',--
          'us.census.acs.B19013001_quantile',
          'us.census.acs.B19083001_quantile',
          'us.census.acs.B19301001_quantile',
          'us.census.acs.B25001001_quantile',
          'us.census.acs.B25002003_quantile',
          'us.census.acs.B25004002_quantile',
          'us.census.acs.B25004004_quantile',
          'us.census.acs.B25058001_quantile',
          'us.census.acs.B25071001_quantile',
          'us.census.acs.B25075001_quantile',
          'us.census.acs.B25075025_quantile'
               ];

    EXECUTE
      $query$
      SELECT array_agg(_OBS_GetCategories->>'category')
      FROM cdb_observatory._OBS_GetCategories(
         $1,
         Array['us.census.spielman_singleton_segments.X10', 'us.census.spielman_singleton_segments.X55'],
         $2)
      $query$
    INTO segment_names
    USING geom, boundary_id;

    q :=
      format($query$
      WITH a As (
           SELECT
             array_agg(_OBS_GET->>'name') As names,
             array_agg(_OBS_GET->>'value') As vals
           FROM cdb_observatory._OBS_Get($1,
                        $2,
                        '2010 - 2014',
                        $3)

        ), percentiles As (
           %s
         FROM  a)
         SELECT row_to_json(r) FROM
         ( SELECT $4 as x10_segment, $5 as x55_segment, percentiles.*
          FROM percentiles) r
       $query$, cdb_observatory._OBS_BuildSnapshotQuery(target_cols)) results;


    EXECUTE
      q
    into result
    USING geom, target_cols, boundary_id, segment_names[1], segment_names[2];

    return result;

END;
$$ LANGUAGE plpgsql;

--Get categorical variables from point

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetCategories(
  geom geometry(Geometry, 4326),
  dimension_names text[],
  boundary_id text DEFAULT NULL,
  time_span text DEFAULT NULL
)
RETURNS SETOF JSON as $$
DECLARE
  geom_table_name text;
  geoid text;
  names text[];
  results text[];
  query text;
  data_table_info json[];
BEGIN

  IF time_span IS NULL THEN
    time_span = '2010 - 2014';
  END IF;

  IF boundary_id IS NULL THEN
    boundary_id = 'us.census.tiger.block_group';
  END IF;

  geom_table_name := cdb_observatory._OBS_GeomTable(geom, boundary_id);

  IF geom_table_name IS NULL
  THEN
     --raise notice 'Point % is outside of the data region', ST_AsText(geom);
     RETURN QUERY SELECT '{}'::text[], '{}'::text[];
     RETURN;
  END IF;

  EXECUTE '
    SELECT array_agg(_obs_getcolumndata)
    FROM cdb_observatory._OBS_GetColumnData($1, $2, $3);
    '
  INTO data_table_info
  USING boundary_id, dimension_names, time_span;

  IF data_table_info IS NULL
  THEN
    --raise notice 'No data table found for this location';
    RETURN QUERY SELECT NULL::json;
    RETURN;
  END IF;

  EXECUTE
    format('SELECT geoid
            FROM observatory.%I
            WHERE the_geom && $1',
            geom_table_name)
  USING geom
  INTO geoid;

  IF geoid IS NULL
  THEN
    --raise notice 'No geometry id for this location';
    RETURN QUERY SELECT NULL::json;
    RETURN;
  END IF;

  query := 'SELECT ARRAY[';

  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    query = query || format('%I ', lower(((data_table_info)[i])->>'colname'));
    IF i <  array_upper(data_table_info, 1)
    THEN
      query := query || ',';
    END IF;
  END LOOP;

  query := query || format(' ]::text[]
    FROM observatory.%I
    WHERE %I.geoid  = %L
  ',
  ((data_table_info)[1])->>'tablename',
  ((data_table_info)[1])->>'tablename',
  geoid
  );

  EXECUTE
    query
  INTO results
  USING geom;

  RETURN QUERY
  EXECUTE
    $query$
     SELECT row_to_json(t) FROM (
      SELECT categories As category,
              meta->>'name' As name,
              meta->>'tablename' As tablename,
              meta->>'aggregate' As aggregate,
              meta->>'type' As type,
              meta->>'description' As description
      FROM (SELECT unnest($1) As categories,
                   unnest($2) As meta) As b
      ) t
    $query$
    USING results, data_table_info;
  RETURN;

END;
$$ LANGUAGE plpgsql;
