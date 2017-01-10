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

  -- return the first boundary in intersections
  EXECUTE $query$
    SELECT * FROM cdb_observatory._OBS_GetBoundariesByGeometry($1, $2, $3) LIMIT 1
  $query$ INTO boundary
  USING geom, boundary_id, time_span;

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
  result TEXT;
BEGIN

  EXECUTE $query$
    SELECT geom_refs FROM cdb_observatory._OBS_GetBoundariesByGeometry(
      $1, $2, $3) LIMIT 1
  $query$
  INTO result
  USING geom, boundary_id, time_span;

  RETURN result;
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
  result GEOMETRY;
BEGIN

  EXECUTE $query$
    SELECT (data->0->>'value')::Geometry
    FROM cdb_observatory.OBS_GetData(
      ARRAY[$1],
      cdb_observatory.OBS_GetMeta(
        ST_MakeEnvelope(-180, -90, 180, 90, 4326),
        ('[{"geom_id": "' || $2 || '"}]')::JSON))
  $query$
  INTO result
  USING geometry_id, boundary_id;

  RETURN result;
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
RETURNS TABLE (
  the_geom geometry,
  geom_refs text
) AS $$
DECLARE
  meta JSON;
BEGIN
  overlap_type := COALESCE(overlap_type, 'intersects');
  -- check inputs
  IF lower(overlap_type) NOT IN ('contains', 'intersects', 'within')
  THEN
    -- recognized overlap type (map to ST_Contains, ST_Intersects, and ST_Within)
    RAISE EXCEPTION 'Overlap type ''%'' is not an accepted type (choose intersects, within, or contains)', overlap_type;
  END IF;

  EXECUTE $query$
    SELECT cdb_observatory.OBS_GetMeta($1, JSON_Build_Array(JSON_Build_Object(
                'geom_id', $2, 'geom_timespan', $3)))
  $query$
  INTO meta
  USING geom, boundary_id, time_span;

  IF meta->0->>'geom_id' IS NULL THEN
    RETURN QUERY EXECUTE 'SELECT NULL::Geometry, NULL::Text LIMIT 0';
    RETURN;
  END IF;

  -- return first boundary in intersections
  RETURN QUERY EXECUTE $query$
    SELECT (data->0->>'value')::Geometry the_geom, data->0->>'geomref' geom_refs
    FROM cdb_observatory.OBS_GetData(
      ARRAY[($1, 1)::geomval], $2, False
    )
  $query$ USING geom, meta;
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

  -- return first boundary in intersections
  RETURN QUERY EXECUTE $query$
    SELECT ST_PointOnSurface(the_geom), geom_refs
    FROM cdb_observatory._OBS_GetBoundariesByGeometry($1, $2)
  $query$ USING geom, boundary_id;
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
