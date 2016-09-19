
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

DROP FUNCTION cdb_observatory.OBS_GetAvailableNumerators(
  bounds GEOMETRY, filter_tags TEXT[], denom_id TEXT, geom_id TEXT, timespan TEXT
);
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
    FROM obs_meta_numer
    WHERE st_intersects(the_geom, $5)
      AND (numer_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING denom_id, geom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT * FROM  cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B01003001', 'us.census.tiger.census_tract', ''
) where valid_denom IS true and valid_geom IS true;

SELECT * FROM  cdb_observatory.OBS_GetAvailableNumerators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  ARRAY['unit/tags.money'], '', '', ''
);


-- DENOMS
DROP FUNCTION cdb_observatory.OBS_GetAvailableDenominators(
  bounds GEOMETRY, filter_tags TEXT[], numer_id TEXT, geom_id TEXT, timespan TEXT
);
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
    FROM obs_meta_denom
    WHERE st_intersects(the_geom, $5)
      AND (denom_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING numer_id, geom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT * FROM cdb_observatory.OBS_GetAvailableDenominators(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B03002006', 'us.census.tiger.census_tract', ''
) where valid_numer IS true and valid_geom IS true;

--- GEOMS
DROP FUNCTION cdb_observatory.OBS_GetAvailableGeometries(
  bounds GEOMETRY, filter_tags TEXT[], numer_id TEXT, denom_id TEXT, timespan TEXT
);
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
    FROM obs_meta_geom
    WHERE st_intersects(the_geom, $5)
      AND (geom_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING numer_id, denom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT * FROM cdb_observatory.OBS_GetAvailableGeometries(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B03002006', 'us.census.acs.B01003001', ''
) where valid_numer IS true and valid_denom IS true;

-- TIMESPANS
DROP FUNCTION cdb_observatory.OBS_GetAvailableTimespans(
  bounds GEOMETRY, filter_tags TEXT[], numer_id TEXT, denom_id TEXT, geom_id TEXT
);
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
    FROM obs_meta_timespan
    WHERE st_intersects(the_geom, $5)
      AND (timespan_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$
  USING numer_id, denom_id, geom_id, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

SELECT * FROM cdb_observatory.OBS_GetAvailableTimespans(
  ST_SetSRID(ST_MakePoint(-73.9, 40.7), 4326),
  NULL, 'us.census.acs.B03002006', 'us.census.acs.B01003001', 'us.census.tiger.census_tract'
) where valid_numer IS true and valid_denom IS true AND valid_geom IS true;


-- notes: add the_geom index to obs_meta
-- change the_geom type to geometry(geometery, 4326)


DROP TABLE IF EXISTS obs_meta_numer;
CREATE TABLE obs_meta_numer AS
SELECT numer_id::TEXT,
       FIRST(numer_name)::TEXT numer_name,
       FIRST(numer_description)::TEXT numer_description,
       FIRST(numer_tags)::JSONB numer_tags,
       FIRST(numer_weight)::NUMERIC numer_weight,
       FIRST(numer_extra)::JSONB numer_extra, -- cannot include ct_extra because it depends on table
       FIRST(numer_type)::TEXT numer_type,
       ARRAY_AGG(DISTINCT denom_id)::TEXT[] denoms,
       ARRAY_AGG(DISTINCT geom_id)::TEXT[] geoms,
       ARRAY_AGG(DISTINCT numer_timespan)::TEXT[] timespans,
       ST_Union(DISTINCT ST_SetSRID(the_geom, 4326)) the_geom
FROM observatory.obs_meta
GROUP BY numer_id;
CREATE INDEX ON obs_meta_numer USING GIST (the_geom);

DROP TABLE IF EXISTS obs_meta_denom;
CREATE TABLE obs_meta_denom AS
SELECT denom_id::TEXT,
       FIRST(denom_name)::TEXT denom_name,
       FIRST(denom_description)::TEXT denom_description,
       NULL::JSONB denom_tags,
       FIRST(denom_weight)::NUMERIC denom_weight,
       'denominator'::TEXT reltype,
       FIRST(denom_extra)::JSONB denom_extra,
       FIRST(denom_type)::TEXT denom_type,
       ARRAY_AGG(DISTINCT numer_id)::TEXT[] numers,
       ARRAY_AGG(DISTINCT geom_id)::TEXT[] geoms,
       ARRAY_AGG(DISTINCT numer_timespan)::TEXT[] timespans,
       ST_Union(DISTINCT ST_SetSRID(the_geom, 4326)) the_geom
FROM observatory.obs_meta
GROUP BY denom_id;
CREATE INDEX ON obs_meta_denom USING GIST (the_geom);

DROP TABLE IF EXISTS obs_meta_geom;
CREATE TABLE obs_meta_geom AS
SELECT geom_id::TEXT,
       FIRST(geom_name)::TEXT geom_name,
       FIRST(geom_description)::TEXT geom_description,
       NULL::JSONB geom_tags,
       FIRST(geom_weight)::NUMERIC geom_weight,
       FIRST(geom_extra)::JSONB geom_extra,
       FIRST(geom_type)::TEXT geom_type,
       ST_SetSRID(FIRST(the_geom), 4326)::GEOMETRY(GEOMETRY, 4326) the_geom,
       NULL::raster summary_geom,
       ARRAY_AGG(DISTINCT numer_id)::TEXT[] numers,
       ARRAY_AGG(DISTINCT denom_id)::TEXT[] denoms,
       ARRAY_AGG(DISTINCT numer_timespan)::TEXT[] timespans
FROM observatory.obs_meta
GROUP BY geom_id;
CREATE INDEX ON obs_meta_geom USING GIST (the_geom);

DROP TABLE IF EXISTS obs_meta_timespan;
CREATE TABLE obs_meta_timespan AS
SELECT numer_timespan::TEXT timespan_id,
       numer_timespan::TEXT timespan_name,
       NULL::TEXT timespan_description,
       NULL::JSONB timespan_tags,
       NULL::NUMERIC timespan_weight,
       NULL::JSONB timespan_extra,
       NULL::TEXT timespan_type,
       ARRAY_AGG(DISTINCT numer_id)::TEXT[] numers,
       ARRAY_AGG(DISTINCT denom_id)::TEXT[] denoms,
       ARRAY_AGG(DISTINCT geom_id)::TEXT[] geoms,
       ST_Union(DISTINCT ST_SetSRID(the_geom, 4326)) the_geom
FROM observatory.obs_meta
GROUP BY numer_timespan;
CREATE INDEX ON obs_meta_geom USING GIST (the_geom);
