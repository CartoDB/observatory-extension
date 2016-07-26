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
    --RAISE NOTICE 'No boundaries found for ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN NULL::geometry;
  END IF;

  --RAISE NOTICE 'target_table: %', target_table;

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
    --RAISE NOTICE 'Warning: No boundaries found for ''%''', boundary_id;
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

  --RAISE NOTICE 'target_table: %, geoid_colname: %', target_table, geoid_colname;

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

  --RAISE NOTICE '%', target_table;

  IF target_table IS NULL
  THEN
    --RAISE NOTICE 'No geometries found';
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
  overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  geom_colname text;
  geoid_colname text;
  target_table text;
BEGIN
  overlap_type := COALESCE(overlap_type, 'intersects');
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
    --RAISE NOTICE 'No boundaries found for bounding box ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN QUERY SELECT NULL::geometry, NULL::text;
    RETURN;
  END IF;

  --RAISE NOTICE 'target_table: %', target_table;

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
  overlap_type text DEFAULT NULL)
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
  overlap_type text DEFAULT NULL)
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
                        time_span,
                        overlap_type);
  RETURN;
END;
$$ LANGUAGE plpgsql;

-- _OBS_GetPointsByGeometry


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetPointsByGeometry(
  geom geometry(Geometry, 4326),
  boundary_id text,
  time_span text DEFAULT NULL,
  overlap_type text DEFAULT NULL)
RETURNS TABLE(the_geom geometry, geom_refs text)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  geom_colname text;
  geoid_colname text;
  target_table text;
BEGIN
  overlap_type := COALESCE(overlap_type, 'intersects');

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
    --RAISE NOTICE 'No boundaries found for bounding box ''%'' in ''%''', ST_AsText(geom), boundary_id;
    RETURN QUERY SELECT NULL::geometry, NULL::text;
    RETURN;
  END IF;

  --RAISE NOTICE 'target_table: %', target_table;

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
  overlap_type text DEFAULT NULL)
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
  overlap_type text DEFAULT NULL)
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
