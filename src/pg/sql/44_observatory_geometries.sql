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
  geom geometry(Geometry, 4326),
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
    'SELECT t.the_geom
     FROM observatory.%s As t
     WHERE ST_Intersects($1, t.the_geom)
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
