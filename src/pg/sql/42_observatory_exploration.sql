
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
  bounds GEOMETRY DEFAULT NULL,
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
  numer_aggregate TEXT,
  numer_extra JSONB,
  numer_tags JSONB,
  valid_denom BOOLEAN,
  valid_geom BOOLEAN,
  valid_timespan BOOLEAN
) AS $$
DECLARE
  geom_clause TEXT;
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  denom_id := COALESCE(denom_id, '');
  geom_id := COALESCE(geom_id, '');
  timespan := COALESCE(timespan, '');
  IF bounds IS NULL THEN
    geom_clause := '';
  ELSE
    geom_clause := 'ST_Intersects(the_geom, $5) AND';
  END IF;
  RETURN QUERY
  EXECUTE
  format($string$
    SELECT numer_id::TEXT,
           numer_name::TEXT,
           numer_description::TEXT,
           numer_weight::NUMERIC,
           NULL::TEXT license,
           NULL::TEXT source,
           numer_type numer_type,
           numer_aggregate numer_aggregate,
           numer_extra::JSONB numer_extra,
           numer_tags numer_tags,
    $1 = ANY(denoms) valid_denom,
    $2 = ANY(geoms) valid_geom,
    $3 = ANY(timespans) valid_timespan
    FROM observatory.obs_meta_numer
    WHERE %s (numer_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$, geom_clause)
  USING denom_id, geom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableDenominators(
  bounds GEOMETRY DEFAULT NULL,
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
  denom_aggregate TEXT,
  denom_extra JSONB,
  denom_tags JSONB,
  valid_numer BOOLEAN,
  valid_geom BOOLEAN,
  valid_timespan BOOLEAN
) AS $$
DECLARE
  geom_clause TEXT;
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  numer_id := COALESCE(numer_id, '');
  geom_id := COALESCE(geom_id, '');
  timespan := COALESCE(timespan, '');
  IF bounds IS NULL THEN
    geom_clause := '';
  ELSE
    geom_clause := 'ST_Intersects(the_geom, $5) AND';
  END IF;
  RETURN QUERY
  EXECUTE
  format($string$
    SELECT denom_id::TEXT,
           denom_name::TEXT,
           denom_description::TEXT,
           denom_weight::NUMERIC,
           NULL::TEXT license,
           NULL::TEXT source,
           denom_type::TEXT,
           denom_aggregate::TEXT,
           denom_extra::JSONB,
           denom_tags::JSONB,
    $1 = ANY(numers) valid_numer,
    $2 = ANY(geoms) valid_geom,
    $3 = ANY(timespans) valid_timespan
    FROM observatory.obs_meta_denom
    WHERE %s (denom_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$, geom_clause)
  USING numer_id, geom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableGeometries(
  bounds GEOMETRY DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  timespan TEXT DEFAULT NULL
) RETURNS TABLE (
  geom_id TEXT,
  geom_name TEXT,
  geom_description TEXT,
  geom_weight NUMERIC,
  geom_aggregate TEXT,
  geom_license TEXT,
  geom_source TEXT,
  valid_numer BOOLEAN,
  valid_denom BOOLEAN,
  valid_timespan BOOLEAN,
  score NUMERIC,
  numtiles BIGINT,
  notnull_percent NUMERIC,
  numgeoms NUMERIC,
  percentfill NUMERIC,
  estnumgeoms NUMERIC,
  meanmediansize NUMERIC
) AS $$
DECLARE
  geom_clause TEXT;
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  numer_id := COALESCE(numer_id, '');
  denom_id := COALESCE(denom_id, '');
  timespan := COALESCE(timespan, '');
  IF bounds IS NULL THEN
    geom_clause := '';
  ELSE
    geom_clause := 'ST_Intersects(the_geom, $5) AND';
  END IF;
  RETURN QUERY
  EXECUTE
  format($string$
    WITH available_geoms AS (
      SELECT geom_id::TEXT,
             geom_name::TEXT,
             geom_description::TEXT,
             geom_weight::NUMERIC,
             NULL::TEXT geom_aggregate,
             NULL::TEXT license,
             NULL::TEXT source,
      $1 = ANY(numers) valid_numer,
      $2 = ANY(denoms) valid_denom,
      $3 = ANY(timespans) valid_timespan
      FROM observatory.obs_meta_geom
      WHERE %s (geom_tags ?& $4 OR CARDINALITY($4) = 0)
    ), scores AS (
      SELECT * FROM cdb_observatory._OBS_GetGeometryScores($5,
        (SELECT ARRAY_AGG(geom_id) FROM available_geoms)
      )
    ) SELECT available_geoms.*, score, numtiles, notnull_percent, numgeoms,
             percentfill, estnumgeoms, meanmediansize
      FROM available_geoms, scores
      WHERE available_geoms.geom_id = scores.geom_id
  $string$, geom_clause)
  USING numer_id, denom_id, timespan, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetAvailableTimespans(
  bounds GEOMETRY DEFAULT NULL,
  filter_tags TEXT[] DEFAULT NULL,
  numer_id TEXT DEFAULT NULL,
  denom_id TEXT DEFAULT NULL,
  geom_id TEXT DEFAULT NULL
) RETURNS TABLE (
  timespan_id TEXT,
  timespan_name TEXT,
  timespan_description TEXT,
  timespan_weight NUMERIC,
  timespan_aggregate TEXT,
  timespan_license TEXT,
  timespan_source TEXT,
  valid_numer BOOLEAN,
  valid_denom BOOLEAN,
  valid_geom BOOLEAN
) AS $$
DECLARE
  geom_clause TEXT;
BEGIN
  filter_tags := COALESCE(filter_tags, (ARRAY[])::TEXT[]);
  numer_id := COALESCE(numer_id, '');
  denom_id := COALESCE(denom_id, '');
  geom_id := COALESCE(geom_id, '');
  IF bounds IS NULL THEN
    geom_clause := '';
  ELSE
    geom_clause := 'ST_Intersects(the_geom, $5) AND';
  END IF;
  RETURN QUERY
  EXECUTE
  format($string$
    SELECT timespan_id::TEXT,
           timespan_name::TEXT,
           timespan_description::TEXT,
           timespan_weight::NUMERIC,
           NULL::TEXT timespan_aggregate,
           NULL::TEXT license,
           NULL::TEXT source,
    $1 = ANY(numers) valid_numer,
    $2 = ANY(denoms) valid_denom,
    $3 = ANY(geoms) valid_geom_id
    FROM observatory.obs_meta_timespan
    WHERE %s (timespan_tags ?& $4 OR CARDINALITY($4) = 0)
  $string$, geom_clause)
  USING numer_id, denom_id, geom_id, filter_tags, bounds;
  RETURN;
END
$$ LANGUAGE plpgsql;


-- Function below should replace SQL in
-- https://github.com/CartoDB/cartodb/blob/ab465cb2918c917940e955963b0cd8a050c06600/lib/assets/javascripts/cartodb3/editor/layers/layer-content-views/analyses/data-observatory-metadata.js
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_LegacyBuilderMetadata(
  aggregate_type TEXT DEFAULT NULL
)
RETURNS TABLE (
  name TEXT,
  subsection JSONB
) AS $$
DECLARE
  aggregate_condition TEXT DEFAULT '';
BEGIN
  IF aggregate_type IS NOT NULL THEN
    aggregate_condition := format(' AND numer_aggregate = %L ', aggregate_type);
  END IF;
  RETURN QUERY
  EXECUTE format($string$
    WITH expanded AS (
        SELECT JSONB_Build_Object('id', numer_id, 'name', numer_name) "column",
               SUBSTR((sections).key, 9) section_id, (sections).value section_name,
               SUBSTR((subsections).key, 12) subsection_id, (subsections).value subsection_name
        FROM (
          SELECT numer_id, numer_name,
                 jsonb_each_text(numer_tags) as sections,
                 jsonb_each_text as subsections
          FROM (SELECT numer_id, numer_name, numer_tags,
                       jsonb_each_text(numer_tags)
                FROM cdb_observatory.obs_getavailablenumerators()
                WHERE numer_weight > 0 %s
               ) foo
        ) bar
        WHERE (sections).key LIKE 'section/%%'
          AND (subsections).key LIKE 'subsection/%%'
      ), grouped_by_subsections AS (
        SELECT JSONB_Agg(JSONB_Build_Object('f1', "column")) AS columns,
               section_id, section_name, subsection_id, subsection_name
        FROM expanded
        GROUP BY section_id, section_name, subsection_id, subsection_name
      )
    SELECT section_name as name, JSONB_Agg(
      JSONB_Build_Object(
        'f1', JSONB_Build_Object(
          'name', subsection_name,
          'id', subsection_id,
          'columns', columns
        )
      )
    ) as subsection
    FROM grouped_by_subsections
    GROUP BY section_name
  $string$, aggregate_condition);
  RETURN;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetGeometryScores(
  bounds Geometry(Geometry, 4326) DEFAULT NULL,
  filter_geom_ids TEXT[] DEFAULT NULL,
  desired_num_geoms INTEGER DEFAULT 3000
) RETURNS TABLE (
  score NUMERIC,
  numtiles BIGINT,
  geom_id TEXT,
  notnull_percent NUMERIC,
  numgeoms NUMERIC,
  percentfill NUMERIC,
  estnumgeoms NUMERIC,
  meanmediansize NUMERIC
) AS $$
BEGIN
  filter_geom_ids := COALESCE(filter_geom_ids, (ARRAY[])::TEXT[]);
  -- Very complex geometries simply fail.  For a boundary check, we can
  -- comfortably get away with the simplicity of an envelope
  IF ST_Npoints(bounds) > 10000 THEN
    bounds := ST_Envelope(bounds);
  END IF;
  RETURN QUERY
  EXECUTE $string$
    WITH clipped_geom AS (
      SELECT column_id, table_id
        , CASE WHEN $1 IS NOT NULL THEN ST_Clip(tile, $1, True) -- -20
               ELSE tile END clipped_tile
        , tile
      FROM observatory.obs_column_table_tile_simple
      WHERE ($1 IS NULL OR ST_Intersects($1, tile))
        AND (column_id = ANY($2) OR cardinality($2) = 0)
    ), clipped_geom_countagg AS (
      SELECT column_id, table_id
        , ST_CountAgg(clipped_tile, 1, True)::Numeric notnull_pixels -- -10
        , ST_CountAgg(clipped_tile, 1, False)::Numeric pixels -- -10
      FROM clipped_geom
      GROUP BY column_id, table_id
    ), clipped_geom_reagg AS (
      SELECT COUNT(*)::BIGINT cnt, a.column_id,
             cdb_observatory.FIRST(pixels) first_pixel,
             cdb_observatory.FIRST(notnull_pixels) first_notnull_pixel,
             cdb_observatory.FIRST(tile) first_tile,
             (ST_SummaryStatsAgg(clipped_tile, 1, True)).sum::Numeric sum_geoms, -- ND
             (ST_SummaryStatsAgg(clipped_tile, 2, True)).mean::Numeric / 255 mean_fill --ND
      FROM clipped_geom_countagg a, clipped_geom b
      WHERE a.table_id = b.table_id
        AND a.column_id = b.column_id
      GROUP BY a.column_id, a.table_id
    ), final AS (
      SELECT
        cnt, column_id

        , (CASE WHEN first_notnull_pixel > 0
                THEN first_notnull_pixel / first_pixel
                ELSE 1
          END)::Numeric
        AS notnull_percent
        , (CASE WHEN first_notnull_pixel > 0
                THEN sum_geoms
                ELSE COALESCE(ST_Value(first_tile, 1, ST_PointOnSurface($1)), 0)
                  * (ST_Area($1) / ST_Area(ST_PixelAsPolygon(first_tile, 0, 0))
                    * first_pixel) -- -20
          END)::Numeric
        AS numgeoms

        , (CASE WHEN first_notnull_pixel > 0
                THEN mean_fill
                ELSE COALESCE(ST_Value(first_tile, 2, ST_PointOnSurface($1))::Numeric / 255, 0) -- -2
          END)::Numeric
        AS percentfill
        , null::numeric estnumgeoms
        , null::numeric meanmediansize
      FROM clipped_geom_reagg
    ) SELECT
      ((100.0 / (1+abs(log(1 + $3) - log(1 + numgeoms::Numeric)))) * percentfill)::Numeric
      AS score, *
      FROM final
  $string$ USING bounds, filter_geom_ids, desired_num_geoms;
  RETURN;
END
$$ LANGUAGE plpgsql IMMUTABLE;
