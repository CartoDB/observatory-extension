
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
        ST_Intersects($1, st_setsrid(observatory.obs_table.the_geom, 4326))
  $string$ || timespan_query
  USING geom;
  RETURN;
END
$$ LANGUAGE plpgsql;

-- Functions the interface works from to identify available numerators,
-- denominators, geometries, and timespans

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableNumerators(
  bounds GEOMETRY,
  filter_tags TEXT[] DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL
) RETURNS TABLE (
  numer_id TEXT,
  numer_name TEXT,
  numer_description TEXT,
  numer_weight NUMERIC,
  numer_license TEXT,
  numer_source TEXT,
  numer_type TEXT,
  numer_extra JSONB,
  numer_tags JSONB,
  valid_denom BOOLEAN,
  valid_geom BOOLEAN,
  valid_timespan BOOLEAN
) AS $$
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  denom_id := COALESCE(denom_id, '');
  geom_id := COALESCE(geom_id, '');
  timespan := COALESCE(timespan, '');
  RETURN QUERY
  EXECUTE
  $string$
    SELECT numer_id::TEXT,
           numer_name::TEXT,
           numer_description::TEXT,
           numer_weight::NUMERIC,
           NULL::TEXT license,
           NULL::TEXT source,
           numer_type numer_type,
           numer_extra::JSONB numer_extra,
           numer_tags numer_tags,
    $1 = ANY(denoms) valid_denom,
    $2 = ANY(geoms) valid_geom,
    $3 = ANY(timespans) valid_timespan
    FROM observatory.obs_meta_numer
    WHERE st_intersects(the_geom, $5)
      AND (numer_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING denom_id, geom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableDenominators(
  bounds GEOMETRY,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL
) RETURNS TABLE (
  denom_id TEXT,
  denom_name TEXT,
  denom_description TEXT,
  denom_weight NUMERIC,
  denom_license TEXT,
  denom_source TEXT,
  denom_type TEXT,
  denom_extra JSONB,
  denom_tags JSONB,
  valid_numer BOOLEAN,
  valid_geom BOOLEAN,
  valid_timespan BOOLEAN
) AS $$
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  numer_id := COALESCE(numer_id, '');
  geom_id := COALESCE(geom_id, '');
  timespan := COALESCE(timespan, '');
  RETURN QUERY
  EXECUTE
  $string$
    SELECT denom_id::TEXT,
           denom_name::TEXT,
           denom_description::TEXT,
           denom_weight::NUMERIC,
           NULL::TEXT license,
           NULL::TEXT source,
           denom_type::TEXT,
           denom_extra::JSONB,
           denom_tags::JSONB,
    $1 = ANY(numers) valid_numer,
    $2 = ANY(geoms) valid_geom,
    $3 = ANY(timespans) valid_timespan
    FROM observatory.obs_meta_denom
    WHERE st_intersects(the_geom, $5)
      AND (denom_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING numer_id, geom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableGeometries(
  bounds GEOMETRY,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL
) RETURNS TABLE (
  geom_id TEXT,
  geom_name TEXT,
  geom_description TEXT,
  geom_weight NUMERIC,
  geom_license TEXT,
  geom_source TEXT,
  valid_numer BOOLEAN,
  valid_denom BOOLEAN,
  valid_timespan BOOLEAN
) AS $$
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  numer_id := COALESCE(numer_id, '');
  denom_id := COALESCE(denom_id, '');
  timespan := COALESCE(timespan, '');
  RETURN QUERY
  EXECUTE
  $string$
    SELECT geom_id::TEXT,
           geom_name::TEXT,
           geom_description::TEXT,
           geom_weight::NUMERIC,
           NULL::TEXT license,
           NULL::TEXT source,
    $1 = ANY(numers) valid_numer,
    $2 = ANY(denoms) valid_denom,
    $3 = ANY(timespans) valid_timespan
    FROM observatory.obs_meta_geom
    WHERE st_intersects(the_geom, $5)
      AND (geom_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING numer_id, denom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableTimespans(
  bounds GEOMETRY,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL
) RETURNS TABLE (
  timespan_id TEXT,
  timespan_name TEXT,
  timespan_description TEXT,
  timespan_weight NUMERIC,
  timespan_license TEXT,
  timespan_source TEXT,
  valid_numer BOOLEAN,
  valid_denom BOOLEAN,
  valid_geom BOOLEAN,
  stats JSONB -- information about # of geoms, avg geom size, etc.
) AS $$
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  numer_id := COALESCE(numer_id, '');
  denom_id := COALESCE(denom_id, '');
  geom_id := COALESCE(geom_id, '');
  RETURN QUERY
  EXECUTE
  $string$
    SELECT timespan_id::TEXT,
           timespan_name::TEXT,
           timespan_description::TEXT,
           timespan_weight::NUMERIC,
           NULL::TEXT license,
           NULL::TEXT source,
    $1 = ANY(numers) valid_numer,
    $2 = ANY(denoms) valid_denom,
    $3 = ANY(geoms) valid_geom_id,
    NULL::JSONB stats
    FROM observatory.obs_meta_timespan
    WHERE st_intersects(the_geom, $5)
      AND (timespan_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING numer_id, denom_id, geom_id, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;
