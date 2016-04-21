-- Returns the polygon(s) that overlap with the input geometry.
-- Input:
-- :param geom geometry: input geometry
-- :param boundary_id text: table to get polygon from (can be approximate name)
-- :param use_literal boolean: use the literal table name (defaults to true)

-- From an input point geometry, find the boundary which intersects with the centroid of the input geometry

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetGeometry(
  geom geometry(geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL)
RETURNS geometry(geometry, 4326)
AS $$
DECLARE
  boundary geometry(geometry, 4326);
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
                                                           time_spans)
    ORDER BY x.time_spans DESC
    LIMIT 1;
  ELSE
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory._OBS_SearchTables(boundary_id,
                            time_span) As x(target_tables,
                                            time_spans)
    WHERE x.time_spans = time_span
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
    'SELECT t.the_geom
     FROM observatory.%s As t
     WHERE ST_Intersects($1, t.the_geom)
     LIMIT 1', target_table)
  INTO boundary
  USING geom;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetGeometryId(
  geom geometry(Geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL
)
RETURNS text
AS $$
DECLARE
  output_id text;
  target_table text;
BEGIN

  -- If not point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Error: Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  -- choose appropriate table based on time_span
  IF time_span IS NULL
  THEN
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory.cdb_observatory._OBS_SearchTables(boundary_id,
                            time_span) As x(target_tables,
                                                time_spans)
    ORDER BY x.time_spans DESC
    LIMIT 1;
  ELSE
    SELECT x.target_tables INTO target_table
    FROM cdb_observatory.cdb_observatory._OBS_SearchTables(boundary_id,
                            time_span) As x(target_tables,
                                            time_spans)
    WHERE x.time_spans = time_span
    LIMIT 1;
  END IF;

  -- if no tables are found, raise error
  IF target_table IS NULL
  THEN
    RAISE NOTICE 'Error: No boundaries found for ''%''', boundary_id;
    RETURN NULL::text;
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

-- @param geometry_id text: identifier for boundary geometry corresponding to a boundary id `boundary_id`. E.g., '36047' is a geoid for US Census Tiger boundaries corresponding to a county (047) in New York State (36)
-- @param boundary_id:

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetGeometryById(
  geometry_id text,            -- ex: '36047'
  boundary_id text,            -- ex: '"us.census.tiger".county'
  time_span text DEFAULT NULL  --ex: '2009'
)
RETURNS geometry(geometry, 4326)
AS $$
DECLARE
  boundary geometry(geometry, 4326);
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
          geom_c.type ILIKE 'geometry'
    $string$, boundary_id
  ) INTO geoid_colname, target_table, geom_colname;

  RAISE NOTICE '%', target_table;

  IF target_table IS NULL
  THEN
    RAISE NOTICE 'No geometries found';
    RETURN NULL::geometry;
  END IF;

  -- retrieve boundary
  EXECUTE
    format(
    'SELECT t.%s
     FROM observatory.%I As t
     WHERE t.%s = $1
     LIMIT 1', geom_colname, target_table, geoid_colname)
  INTO boundary
  USING geometry_id;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;
