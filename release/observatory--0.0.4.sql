--DO NOT MODIFY THIS FILE, IT IS GENERATED AUTOMATICALLY FROM SOURCES
-- Complain if script is sourced in psql, rather than via CREATE EXTENSION
\echo Use "CREATE EXTENSION observatory" to load this file. \quit
-- Version number of the extension release
CREATE OR REPLACE FUNCTION cdb_observatory_version()
RETURNS text AS $$
  SELECT '0.0.4'::text;
$$ language 'sql' STABLE STRICT;

-- Internal identifier of the installed extension instence
-- e.g. 'dev' for current development version
CREATE OR REPLACE FUNCTION _cdb_observatory_internal_version()
RETURNS text AS $$
  SELECT installed_version FROM pg_available_extensions where name='observatory' and pg_available_extensions IS NOT NULL;
$$ language 'sql' STABLE STRICT;

-- Returns the table name with geoms for the given geometry_id
-- TODO probably needs to take in the column_id array to get the relevant
-- table where there is multiple sources for a column from multiple
-- geometries.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GeomTable(
  geom geometry(Geometry, 4326),
  geometry_id text,
  time_span text DEFAULT NULL
)
  RETURNS TEXT
AS $$
DECLARE
  result text;
BEGIN
  EXECUTE '
    SELECT tablename FROM observatory.OBS_table
    WHERE id IN (
      SELECT table_id
      FROM observatory.OBS_table tab,
           observatory.OBS_column_table coltable,
           observatory.OBS_column col
      WHERE type ILIKE ''geometry''
        AND coltable.column_id = col.id
        AND coltable.table_id = tab.id
        AND col.id = $1
        AND CASE WHEN $3::TEXT IS NOT NULL THEN timespan ILIKE $3::TEXT ELSE TRUE END
      ORDER BY timespan DESC LIMIT 1
    )
    '
  USING geometry_id, geom, time_span
  INTO result;

  return result;

END;
$$ LANGUAGE plpgsql;



-- A function that gets the column data for multiple columns
-- Old: OBS_GetColumnData
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetColumnData(
  geometry_id text,
  column_ids text[],
  timespan text
)
RETURNS SETOF JSON
AS $$
BEGIN

  -- figure out highest-weight geometry_id/timespan pair for the first data column
  -- TODO this should be done for each data column separately
  IF geometry_id IS NULL OR timespan IS NULL THEN
    EXECUTE '
      SELECT data_t.timespan timespan, geom_c.id boundary_id
      FROM observatory.obs_table data_t,
           observatory.obs_column_table data_ct,
           observatory.obs_column data_c,
           observatory.obs_column_table geoid_ct,
           observatory.obs_column_to_column c2c,
           observatory.obs_column geom_c
      WHERE data_c.id = $2
           AND data_ct.column_id = data_c.id
           AND data_ct.table_id = data_t.id
           AND geoid_ct.table_id = data_t.id
           AND geoid_ct.column_id = c2c.source_id
           AND c2c.reltype = ''geom_ref''
           AND geom_c.id = c2c.target_id
           AND CASE WHEN $3 IS NULL THEN True ELSE $3 = timespan END
           AND CASE WHEN $1 IS NULL THEN True ELSE $1 = geom_c.id END
      ORDER BY geom_c.weight DESC,
               data_t.timespan DESC
      LIMIT 1
    ' INTO timespan, geometry_id
    USING geometry_id, (column_ids)[1], timespan;
  END IF;

  RETURN QUERY
  EXECUTE '
  WITH geomref AS (
    SELECT ct.table_id id
    FROM observatory.OBS_column_to_column c2c,
         observatory.OBS_column_table ct
    WHERE c2c.reltype = ''geom_ref''
      AND c2c.target_id = $1
      AND c2c.source_id = ct.column_id
    ),
  column_ids as (
    select row_number() over () as no, a.column_id as column_id from (select unnest($2) as column_id) a
  )
 SELECT row_to_json(a) from (
   select  colname,
            tablename,
            aggregate,
            name,
            type,
            c.description,
            $1 AS boundary_id
           FROM column_ids, observatory.OBS_column c, observatory.OBS_column_table ct, observatory.OBS_table t
           WHERE column_ids.column_id  = c.id
             AND c.id = ct.column_id
             AND t.id = ct.table_id
             AND t.timespan = $3
             AND t.id in (SELECT id FROM geomref)
          order by column_ids.no
    ) a
 '
 USING geometry_id, column_ids, timespan
 RETURN;

END;
$$ LANGUAGE plpgsql;

--Test point cause Stuart always seems to make random points in the water
CREATE OR REPLACE FUNCTION cdb_observatory._TestPoint()
  RETURNS geometry(Point, 4326)
AS $$
BEGIN
  -- new york city
  RETURN ST_SetSRID(ST_Point( -73.936669, 40.704512), 4326);
END;
$$ LANGUAGE plpgsql;

--Test polygon cause Stuart always seems to make random points in the water
-- TODO: remove as it's not used anywhere?
CREATE OR REPLACE FUNCTION cdb_observatory._TestArea()
  RETURNS geometry(Geometry, 4326)
AS $$
BEGIN
  -- Buffer NYC point by 500 meters
  RETURN ST_Buffer(cdb_observatory._TestPoint()::geography, 500)::geometry;

END;
$$ LANGUAGE plpgsql;

--Used to expand a column based response to a table based one. Give it the desired
--columns and it will return a partial query for rolling them out to a table.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_BuildSnapshotQuery(names text[])
RETURNS TEXT
AS $$
DECLARE
  q text;
  i numeric;
BEGIN

  q := 'SELECT ';

  FOR i IN 1..array_upper(names,1)
  LOOP
    q = q || format(' vals[%s] As %I', i, names[i]);
    IF i < array_upper(names, 1) THEN
      q= q || ',';
    END IF;
  END LOOP;
  RETURN q;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetRelatedColumn(columns_ids text[], reltype text )
RETURNS TEXT[]
AS $$
DECLARE
  result TEXT[];
BEGIN
  EXECUTE '
    With ids as (
      select row_number() over() as no, id from (select unnest($1) as id) t
    )
    select array_agg(target_id order by no)
    FROM  ids
    LEFT JOIN observatory.obs_column_to_column
    on  source_id  = id
    where reltype = $2 or reltype is null
  '
  INTO result
  using columns_ids, reltype;
  return result;
END;
$$ LANGUAGE plpgsql;

-- Function that replaces all non digits or letters with _ trims and lowercases the
-- passed measure name

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_StandardizeMeasureName(measure_name text)
RETURNS text
AS $$
DECLARE
  result text;
BEGIN
  -- Turn non letter or digits to _
  result = regexp_replace(measure_name, '[^\dA-Za-z]+','_', 'g');
  -- Remove duplicate _'s
  result = regexp_replace(result,'_{2,}','_', 'g');
  -- Trim _'s from beginning and end
  result = trim(both  '_' from result);
  result = lower(result);
  RETURN result;
END;
$$ LANGUAGE plpgsql;

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
     RAISE NOTICE 'Point % is outside of the data region', ST_AsText(geom);
      -- TODO this should return JSON
     RETURN QUERY SELECT '{}'::json;
     RETURN;
  END IF;

  IF data_table_info IS NULL THEN
    RAISE NOTICE 'Cannot find data table for boundary ID %, column_ids %, and time_span %', geometry_level, column_ids, time_span;
  END IF;

  IF ST_GeometryType(geom) = 'ST_Point'
  THEN
    RAISE NOTICE 'geom_table_name %, data_table_info %', geom_table_name, data_table_info::json[];
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

  RAISE NOTICE 'geoid is %, geometry table is % ', geoid, geom_table_name;

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
    RAISE NOTICE 'No geometry at %', ST_AsText(geom);
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
  result NUMERIC;
  measure_ids TEXT[];
  denominator_id TEXT;
  vals NUMERIC[];
BEGIN

  IF normalize ILIKE 'area' THEN
    measure_ids := ARRAY[measure_id];
  ELSIF normalize ILIKE 'denominator' THEN
    EXECUTE 'SELECT (cdb_observatory._OBS_GetRelatedColumn(ARRAY[$1], ''denominator''))[1]
    ' INTO denominator_id
    USING measure_id;
    measure_ids := ARRAY[measure_id, denominator_id];
  ELSIF normalize ILIKE 'none' THEN
    -- TODO we need a switch on obs_get to disable area normalization
    RAISE EXCEPTION 'No normalization not yet supported.';
  ELSE
    RAISE EXCEPTION 'Only valid inputs for "normalize" are "area" (default) and "denominator".';
  END IF;

  EXECUTE '
    SELECT ARRAY_AGG(val) FROM (SELECT (cdb_observatory._OBS_Get($1, $2, $3, $4)->>''value'')::NUMERIC val) b
  '
  INTO vals
  USING geom, measure_ids, time_span, boundary_id;

  IF normalize ILIKE 'denominator' THEN
    RETURN (vals)[1]/(vals)[2];
  ELSE
    RETURN (vals)[1];
  END IF;
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
  denominator_id TEXT;
  categories TEXT[];
BEGIN

  IF boundary_id IS NULL THEN
    -- TODO we should determine best boundary for this geom
    boundary_id := 'us.census.tiger.census_tract';
  END IF;

  IF time_span IS NULL THEN
    -- TODO we should determine latest timespan for this measure
    time_span := '2010 - 2014';
  END IF;

  EXECUTE '
    SELECT ARRAY_AGG(val) FROM (SELECT (cdb_observatory._OBS_GetCategories($1, $2, $3, $4))->>''category'' val LIMIT 1) b
  '
  INTO categories
  USING geom, ARRAY[category_id], boundary_id, time_span;

  RETURN (categories)[1];

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
  WHERE values.%I = _overlaps.%I', geom_geoid_colname, geom_geoid_colname);

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
     RAISE NOTICE 'Point % is outside of the data region', ST_AsText(geom);
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
    RAISE NOTICE 'No data table found for this location';
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
    RAISE NOTICE 'No geometry id for this location';
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
-- return a table that contains a string match based on input
-- TODO: implement search for timespan

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_SearchTables(
  search_term text,
  time_span text DEFAULT NULL
)
RETURNS table(tablename text, timespan text)
As $$
DECLARE
  out_var text[];
BEGIN

  IF time_span IS NULL
  THEN
    RETURN QUERY
    EXECUTE
    'SELECT tablename::text, timespan::text
       FROM observatory.obs_table t
       JOIN observatory.obs_column_table ct
         ON ct.table_id = t.id
       JOIN observatory.obs_column c
         ON ct.column_id = c.id
       WHERE c.type ILIKE ''geometry''
        AND c.id = $1'
    USING search_term;
    RETURN;
  ELSE
    RETURN QUERY
    EXECUTE
    'SELECT tablename::text, timespan::text
       FROM observatory.obs_table t
       JOIN observatory.obs_column_table ct
         ON ct.table_id = t.id
       JOIN observatory.obs_column c
         ON ct.column_id = c.id
       WHERE c.type ILIKE ''geometry''
        AND c.id = $1
        AND t.timespan = $2'
    USING search_term, time_span;
    RETURN;
  END IF;

END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Functions used to search the observatory for measures
--------------------------------------------------------------------------------
-- TODO allow the user to specify the boundary to search for measures
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_Search(
  search_term text,
  relevant_boundary text DEFAULT null
)
RETURNS TABLE(id text, description text, name text, aggregate text, source text)  as $$
DECLARE
  boundary_term text;
BEGIN
  IF relevant_boundary then
    boundary_term = '';
  else
    boundary_term = '';
  END IF;

  RETURN QUERY
  EXECUTE format($string$
              SELECT id::text, description::text,
                name::text,
                  aggregate::text,
                  NULL::TEXT source -- TODO use tags
                  FROM observatory.OBS_column
                  where name ilike     '%%' || %L || '%%'
                  or description ilike '%%' || %L || '%%'
                  %s
                $string$, search_term, search_term,boundary_term);
  RETURN;
END
$$ LANGUAGE plpgsql;


-- Functions to return the geometry levels that a point is part of
--------------------------------------------------------------------------------
-- TODO add test response

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableBoundaries(
  geom geometry(Geometry, 4326),
  timespan text DEFAULT null)
RETURNS TABLE(boundary_id text, description text, time_span text, tablename text)  as $$
DECLARE
  timespan_query TEXT DEFAULT '';
BEGIN

  IF timespan != NULL
  THEN
    timespan_query = format('AND timespan = %L', timespan);
  END IF;

  RETURN QUERY
  EXECUTE
  $string$
      SELECT
        column_id::text As column_id,
        obs_column.description::text As description,
        timespan::text As timespan,
        tablename::text As tablename
      FROM
        observatory.OBS_table,
        observatory.OBS_column_table,
        observatory.OBS_column
      WHERE
        observatory.OBS_column_table.column_id = observatory.obs_column.id AND
        observatory.OBS_column_table.table_id = observatory.obs_table.id
      AND
        observatory.OBS_column.type = 'Geometry'
      AND
        $1 && bounds::box2d
  $string$ || timespan_query
  USING geom;
  RETURN;
END
$$ LANGUAGE plpgsql;
-- Data Observatory -- Welcome to the Future
-- These Data Observatory functions provide access to boundary polyons (and
--   their ids) such as those available through the US Census Tiger, Who's on
--   First, the Spanish Census, and so on


-- OBS_GetBoundary
--
-- Returns the boundary polygon(s) that overlap with the input point geometry.
-- From an input point geometry, find the boundary which intersects with the
--   centroid of the input geometry
-- Inputs:
--   geom geometry: input point geometry
--   boundary_id text: source id of boundaries
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   boundary geometry: geometry boundary that intersects with geom, is at the
--                      resolution requested with boundary_id, and time_span
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetBoundary(
  geom geometry(Point, 4326),
  boundary_id text,
  time_span text DEFAULT NULL)
RETURNS geometry(Geometry, 4326)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  target_table text;
BEGIN

  -- TODO: Check if SRID = 4326, if not transform?

  -- if not a point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  -- choose appropriate table based on time_span
  IF time_span IS NULL
  THEN
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory._OBS_SearchTables(boundary_id,
                                           time_span) As x(target_tables,
                                                           timespans)
    ORDER BY x.timespans DESC
    LIMIT 1;
  ELSE
    -- TODO: modify for only one table returned instead of arbitrarily choosing
    --       one with LIMIT 1 (could be conflict between clipped vs non-clipped
    --       boundaries in the metadata tables)
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory._OBS_SearchTables(boundary_id,
                            time_span) As x(target_tables,
                                            timespans)
    WHERE x.timespans = time_span
    LIMIT 1;
  END IF;

  -- if no tables are found, raise notice and return null
  IF target_table IS NULL
  THEN
    RAISE NOTICE 'No boundaries found for ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN NULL::geometry;
  END IF;

  RAISE NOTICE 'target_table: %', target_table;

  -- return the first boundary in intersections
  EXECUTE format(
    'SELECT the_geom
     FROM observatory.%I
     WHERE ST_Intersects($1, the_geom)
     LIMIT 1', target_table)
  INTO boundary
  USING geom;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

-- OBS_GetBoundaryId
--
-- retrieves the boundary identifier (e.g., '36047' = Kings County/Brooklyn, NY)
--   corresponding to the location geom and boundary types (e.g.,
--   us.census.tiger.county)

-- Inputs:
--   geom geometry: location where the boundary is requested to overlap with
--   boundary_id text: source id of boundaries (e.g., us.census.tiger.county)
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   geometry_id text: identifier of the geometry which overlaps with the input
--                     point geom in the table corresponding to boundary_id and
--                     time_span
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetBoundaryId(
  geom geometry(Point, 4326),
  boundary_id text,
  time_span text DEFAULT NULL
)
RETURNS text
AS $$
DECLARE
  output_id text;
  target_table text;
  geoid_colname text;
BEGIN

  -- If not point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  -- choose appropriate table based on time_span
  IF time_span IS NULL
  THEN
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory._OBS_SearchTables(boundary_id,
                            time_span) As x(target_tables,
                                                timespans)
    ORDER BY x.timespans DESC
    LIMIT 1;
  ELSE
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory._OBS_SearchTables(boundary_id,
                            time_span) As x(target_tables,
                                            timespans)
    WHERE x.timespans = time_span
    LIMIT 1;
  END IF;

  -- if no tables are found, raise notice and return null
  IF target_table IS NULL
  THEN
    RAISE NOTICE 'Warning: No boundaries found for ''%''', boundary_id;
    RETURN NULL::text;
  END IF;

  EXECUTE
    format('SELECT ct.colname
              FROM observatory.obs_column_to_column c2c,
                   observatory.obs_column_table ct,
                   observatory.obs_table t
             WHERE c2c.reltype = ''geom_ref''
               AND ct.column_id = c2c.source_id
               AND ct.table_id = t.id
               AND t.tablename = %L'
   , target_table)
  INTO geoid_colname;

  RAISE NOTICE 'target_table: %, geoid_colname: %', target_table, geoid_colname;

  -- return geometry id column value
  EXECUTE format(
    'SELECT %I::text
     FROM observatory.%I
     WHERE ST_Intersects($1, the_geom)
     LIMIT 1', geoid_colname, target_table)
  INTO output_id
  USING geom;

  RETURN output_id;

END;
$$ LANGUAGE plpgsql;


-- OBS_GetBoundaryById
--
-- Given a geometry reference (e.g., geoid for US Census), and it's geometry
--  level (see OBS_ListGeomColumns() for all available boundary ids), give back
--  the boundary that corresponds to that geometry_id, boundary_id, and
--   time_span

-- Inputs:
--   geometry_id text: geometry id of the requested boundary
--   boundary_id text: source id of boundaries (e.g., us.census.tiger.county)
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   boundary geometry: geometry boundary that matches geometry_id, is at the
--                      resolution requested with boundary_id, and time_span
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetBoundaryById(
  geometry_id text,            -- ex: '36047'
  boundary_id text,            -- ex: 'us.census.tiger.county'
  time_span text DEFAULT NULL  -- ex: '2009'
)
RETURNS geometry(geometry, 4326)
AS $$
DECLARE
  boundary geometry(geometry, 4326);
  target_table text;
  geoid_colname text;
  geom_colname text;
BEGIN

  SELECT * INTO geoid_colname, target_table, geom_colname
  FROM cdb_observatory._OBS_GetGeometryMetadata(boundary_id);

  RAISE NOTICE '%', target_table;

  IF target_table IS NULL
  THEN
    RAISE NOTICE 'No geometries found';
    RETURN NULL::geometry;
  END IF;

  -- retrieve boundary
  EXECUTE
    format(
    'SELECT %I
     FROM observatory.%I
     WHERE %I = $1
     LIMIT 1', geom_colname, target_table, geoid_colname)
  INTO boundary
  USING geometry_id;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

-- _OBS_GetBoundariesByGeometry
-- internal function for retrieving geometries based on an input geometry
--  see OBS_GetBoundariesByGeometry or OBS_GetBoundariesByPointAndRadius for
--  more information

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetBoundariesByGeometry(
  geom geometry(Geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  geom_colname text;
  geoid_colname text;
  target_table text;
BEGIN

  -- check inputs
  IF lower(overlap_type) NOT IN ('contains', 'intersects', 'within')
  THEN
    -- recognized overlap type (map to ST_Contains, ST_Intersects, and ST_Within)
    RAISE EXCEPTION 'Overlap type ''%'' is not an accepted type (choose intersects, within, or contains)', overlap_type;
  ELSIF ST_GeometryType(geom) NOT IN ('ST_Polygon', 'ST_MultiPolygon')
  THEN
      RAISE EXCEPTION 'Invalid geometry type (%), expecting ''ST_MultiPolygon'' or ''ST_Polygon''', ST_GeometryType(geom);
  END IF;

  -- TODO: add timespan in search
  -- TODO: add overlap info in search
  SELECT * INTO geoid_colname, target_table, geom_colname
  FROM cdb_observatory._OBS_GetGeometryMetadata(boundary_id);

  -- if no tables are found, raise notice and return null
  IF target_table IS NULL
  THEN
    RAISE NOTICE 'No boundaries found for bounding box ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN QUERY SELECT NULL::geometry, NULL::text;
    RETURN;
  END IF;

  RAISE NOTICE 'target_table: %', target_table;

  -- return first boundary in intersections
  RETURN QUERY
  EXECUTE format(
    'SELECT %I, %I::text
     FROM observatory.%I
     WHERE ST_%s($1, the_geom)
     ', geom_colname, geoid_colname, target_table, overlap_type)
  USING geom;
  RETURN;

END;
$$ LANGUAGE plpgsql;

-- OBS_GetBoundariesByGeometry
--
-- Given a bounding box (or a polygon), and it's geometry level (see
--  OBS_ListGeomColumns() for all available boundary ids), give back the
--  boundaries that are contained within the bounding box polygon and the
--  associated geometry ids

-- Inputs:
--   geom geometry: bounding box (or polygon) of the region of interest
--   boundary_id text: source id of boundaries (e.g., us.census.tiger.county)
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   table with the following columns
--     boundary geometry: geometry boundary that is contained within the input
--                          bounding box at the requested geometry level
--                          with boundary_id, and time_span
--     geom_refs text: geometry identifiers (e.g., geoid for the US Census)
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetBoundariesByGeometry(
  geom geometry(Geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
BEGIN

  RETURN QUERY SELECT *
               FROM cdb_observatory._OBS_GetBoundariesByGeometry(
                          geom,
                          boundary_id,
                          time_span,
                          overlap_type
                        );
  RETURN;

END;
$$ LANGUAGE plpgsql;

-- OBS_GetBoundariesByPointAndRadius
--
-- Given a point and radius, and it's geometry level (see
--  OBS_ListGeomColumns() for all available boundary ids), give back the
--  boundaries that are contained within the point buffered by radius meters and
--  the associated geometry ids

-- Inputs:
--   geom geometry: point geometry centered on area of interest
--   radius numeric: radius (in meters) of a circle centered on geom for
--                   selecting polygons
--   boundary_id text: source id of boundaries (e.g., us.census.tiger.county)
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   table with the following columns
--     boundary geometry: geometry boundary that is contained within the input
--                          bounding box at the requested geometry level
--                          with boundary_id, and time_span
--     geom_refs text: geometry identifiers (e.g., geoid for the US Census)
--
-- TODO: move to ST_DWithin instead of buffer + intersects?
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetBoundariesByPointAndRadius(
  geom geometry(Point, 4326), -- point
  radius numeric, -- radius in meters
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
DECLARE
  circle_boundary geometry(Geometry, 4326);
BEGIN

  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Input geometry ''%'' is not a point', ST_AsText(geom);
  ELSE
    circle_boundary := ST_Buffer(geom::geography, radius)::geometry;
  END IF;

  RETURN QUERY SELECT *
               FROM cdb_observatory._OBS_GetBoundariesByGeometry(
                        circle_boundary,
                        boundary_id,
                        time_span);
  RETURN;
END;
$$ LANGUAGE plpgsql;

-- _OBS_GetPointsByGeometry


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetPointsByGeometry(
  geom geometry(Geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  geom_colname text;
  geoid_colname text;
  target_table text;
BEGIN

  IF lower(overlap_type) NOT IN ('contains', 'within', 'intersects')
  THEN
    RAISE EXCEPTION 'Overlap type ''%'' is not an accepted type (choose intersects, within, or contains)', overlap_type;
  ELSIF ST_GeometryType(geom) NOT IN ('ST_Polygon', 'ST_MultiPolygon')
  THEN
    RAISE EXCEPTION 'Invalid geometry type (%), expecting ''ST_MultiPolygon'' or ''ST_Polygon''', ST_GeometryType(geom);
  END IF;

  SELECT * INTO geoid_colname, target_table, geom_colname
  FROM cdb_observatory._OBS_GetGeometryMetadata(boundary_id);

  -- if no tables are found, raise notice and return null
  IF target_table IS NULL
  THEN
    RAISE NOTICE 'No boundaries found for bounding box ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN QUERY SELECT NULL::geometry, NULL::text;
    RETURN;
  END IF;

  RAISE NOTICE 'target_table: %', target_table;

  -- return first boundary in intersections
  RETURN QUERY
  EXECUTE format(
    'SELECT ST_PointOnSurface(%I) As %s, %I::text
     FROM observatory.%I
     WHERE ST_%s($1, the_geom)
     ', geom_colname, geom_colname, geoid_colname, target_table, overlap_type)
  USING geom;
  RETURN;

END;
$$ LANGUAGE plpgsql;

-- OBS_GetPointsByGeometry
--
-- Given a polygon, and it's geometry level (see
--  OBS_ListGeomColumns() for all available boundary ids), give back a point
--  which lies in a boundary from the requested geometry level that is contained
--  within the bounding box polygon and the associated geometry ids
--
-- Inputs:
--   geom geometry: bounding box (or polygon) of the region of interest
--   boundary_id text: source id of boundaries (e.g., us.census.tiger.county)
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   table with the following columns
--     boundary geometry: point that lies on a boundary that is contained within
--                          the input bounding box at the requested geometry
--                          level with boundary_id, and time_span
--     geom_refs text: geometry identifiers (e.g., geoid for the US Census)
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetPointsByGeometry(
  geom geometry(Geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
BEGIN

  RETURN QUERY SELECT *
               FROM cdb_observatory._OBS_GetPointsByGeometry(
                      geom,
                      boundary_id,
                      time_span,
                      overlap_type);
  RETURN;

END;
$$ LANGUAGE plpgsql;

-- OBS_GetBoundariesByPointAndRadius
--
-- Given a point and radius, and it's geometry level (see
--  OBS_ListGeomColumns() for all available boundary ids), give back the
--  boundaries that are contained within the point buffered by radius meters and
--  the associated geometry ids

-- Inputs:
--   geom geometry: point geometry centered on area of interest
--   radius numeric: radius (in meters) of a circle centered on geom for
--                   selecting polygons
--   boundary_id text: source id of boundaries (e.g., us.census.tiger.county)
--                     see function OBS_ListGeomColumns for all avaiable
--                     boundary ids
--   time_span text: time span that the geometries were collected (optional)
--
-- Output:
--   table with the following columns
--     boundary geometry: geometry boundary that is contained within the input
--                          bounding box at the requested geometry level
--                          with boundary_id, and time_span
--     geom_refs text: geometry identifiers (e.g., geoid for the US Census)
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetPointsByPointAndRadius(
  geom geometry(Point, 4326), -- point
  radius numeric, -- radius in meters
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT 'intersects')
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
DECLARE
  circle_boundary geometry(Geometry, 4326);
BEGIN

  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Input geometry ''%'' is not a point', ST_AsText(geom);
  ELSE
    circle_boundary := ST_Buffer(geom::geography, radius)::geometry;
  END IF;

  RETURN QUERY SELECT *
               FROM cdb_observatory._OBS_GetPointsByGeometry(
                        ST_Buffer(geom::geography, radius)::geometry,
                        boundary_id,
                        time_span,
                        overlap_type);
  RETURN;
END;
$$ LANGUAGE plpgsql;


-- _OBS_GetGeometryMetadata()
-- TODO: add timespan in search
-- TODO: add choice of clipped versus not clipped
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetGeometryMetadata(boundary_id text)
RETURNS table(geoid_colname text, target_table text, geom_colname text)
AS $$
BEGIN

  RETURN QUERY
  EXECUTE
  format($string$
    SELECT geoid_ct.colname::text As geoid_colname,
           tablename::text,
           geom_ct.colname::text As geom_colname
    FROM observatory.obs_column_table As geoid_ct,
         observatory.obs_table As geom_t,
         observatory.obs_column_table As geom_ct,
         observatory.obs_column As geom_c
    WHERE geoid_ct.column_id
       IN (
         SELECT source_id
         FROM observatory.obs_column_to_column
         WHERE reltype = 'geom_ref'
           AND target_id = '%s'
         )
      AND geoid_ct.table_id = geom_t.id AND
          geom_t.id = geom_ct.table_id AND
          geom_ct.column_id = geom_c.id AND
          geom_c.type ILIKE 'geometry' AND
          geom_c.id = '%s'
    $string$, boundary_id, boundary_id);
  RETURN;
    --  AND geom_t.timespan = '%s' <-- put in requested year
    -- TODO: filter by clipped vs. not so appropriate tablename are unique
    --       so the limit 1 can be removed
    RETURN;

END;
$$ LANGUAGE plpgsql;
-- Placeholder for permission tweaks at creation time.
-- Make sure by default there are no permissions for publicuser
-- NOTE: this happens at extension creation time, as part of an implicit transaction.
-- REVOKE ALL PRIVILEGES ON SCHEMA cdb_observatory FROM PUBLIC, publicuser CASCADE;

-- Grant permissions on the schema to publicuser (but just the schema)
-- GRANT USAGE ON SCHEMA cdb_crankshaft TO publicuser;

-- Revoke execute permissions on all functions in the schema by default
-- REVOKE EXECUTE ON ALL FUNCTIONS IN SCHEMA cdb_observatory FROM PUBLIC, publicuser;
