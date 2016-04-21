-- Returns the polygon(s) that overlap with the input geometry.
-- Input:
-- :param geom geometry: input geometry
-- :param boundary_id text: table to get polygon from (can be approximate name)
-- :param use_literal boolean: use the literal table name (defaults to true)

-- From an input point geometry, find the boundary which intersects with the centroid of the input geometry

CREATE OR REPLACE FUNCTION Andy_OBS_GetGeometry(
  geom geometry(Geometry, 4326),
  boundary_id text DEFAULT '"us.census.tiger".census_tract', -- TODO: from a specified column id list (e.g., list of available catalog, see OBS_List)
  time_span text DEFAULT '2009 - 2013')
  RETURNS geometry(Geometry, 4326)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  target_table text;
  target_table_list text[];
BEGIN

  -- TODO: Check if SRID = 4326, if not transform?

  -- if not a point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  target_table_list := OBS_SearchTables(boundary_id, time_span);

  -- if no tables are found, raise notice and return null
  IF array_length(target_table_list, 1) IS NULL
  THEN
    RAISE NOTICE 'No boundaries found for ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN NULL::geometry;
  ELSE
  -- else, choose first result
    target_table = target_table_list[1];
  END IF;

  RAISE NOTICE 'target_table: %', target_table;

  -- return the first boundary in intersections
  EXECUTE format(
    'SELECT t.the_geom
     FROM observatory.%s As t
     WHERE ST_Intersects($1, t.the_geom)
     LIMIT 1', target_table)
  INTO boundary
  USING geom;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION ANDY_OBS_GetGeometryId(
  geom geometry(Geometry, 4326),
  boundary_id text DEFAULT '"us.census.tiger".census_tract',
  time_span text DEFAULT '2009 - 2013'
)
RETURNS text
AS $$
DECLARE
  output_id text;
  target_table text;
  target_table_list text[];
BEGIN

  -- If not point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Error: Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  target_table_list := OBS_SearchTables(boundary_id, time_span);

  -- if no tables are found, raise error
  IF array_length(target_table_list, 1) IS NULL
  THEN
    RAISE NOTICE 'Error: No boundaries found for ''%''', boundary_id;
    RETURN NULL::text;
  ELSE
    target_table = target_table_list[1];
  END IF;

  RAISE NOTICE 'target_table: %', target_table;

  -- return name of geometry id column
  EXECUTE format(
    'SELECT t.geoid
     FROM observatory.%s As t
     WHERE ST_Intersects($1, t.the_geom)
     LIMIT 1', target_table)
  INTO output_id
  USING geom;

  RETURN output_id;

END;
$$ LANGUAGE plpgsql;

-- Given a geometry reference (e.g., geoid for US Census), and it's geometry level (see OBS_ListGeomColumns() for all available boundary ids), give back the boundary that corresponds to that reference and level.

-- @param geom_ref text: identifier for boundary geometry corresponding to a boundary id `boundary_id`. E.g., '36047' is a geoid for US Census Tiger boundaries corresponding to a county (047) in New York State (36)
-- @param boundary_id:

CREATE OR REPLACE FUNCTION OBS_GetGeometryById(
  geom_ref text,      -- ex: '36047'
  boundary_id text -- ex: '"us.census.tiger".county'
)
RETURNS geometry(geometry, 4326)
AS $$
DECLARE
  boundary geometry;
  target_table text;
  geoid_colname text;
  geom_colname text;
BEGIN

  EXECUTE
  format(
    $string$
    SELECT geoid_ct.colname As geoid_colname,
           tablename,
           geom_ct.colname As geom_colname
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
      AND geoid_ct.table_id = geom_t.id and
          geom_t.id = geom_ct.table_id and
          geom_ct.column_id = geom_c.id and
          geom_c.type ilike 'geometry'
    $string$, boundary_id
  ) INTO geoid_colname, target_table, geom_colname;

  IF target_table IS NULL
  THEN
    RAISE NOTICE 'No geometries found';
    RETURN NULL::geometry;
  END IF;

  -- retrieve boundary
  EXECUTE
    'SELECT t.$1
     FROM observatory.$2 As t
     WHERE t.$1 = ''$3''
     LIMIT 1'
  INTO boundary
  USING geom_colname, target_table, geom_ref;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;
