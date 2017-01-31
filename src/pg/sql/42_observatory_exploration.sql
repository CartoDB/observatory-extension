
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
      WHERE available_geoms.geom_id = scores.column_id
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


-- select st_geometrytype(
--   st_collect(array_agg(st_envelope(the_geom)))::text)
--   from observatory.obs_9812b21f90f3e6a885dc546a3c6ad32e0190d723 tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_9812b21f90f3e6a885dc546a3c6ad32e0190d723))
--   ;
-- 
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_78fb6c1d6ff6505225175922c2c389ce48d7632c
--     where geoid like '360470001%'), null, 1
-- )
-- order by score desc;
-- 
-- -- block group -> finds block group, 2s
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_78fb6c1d6ff6505225175922c2c389ce48d7632c tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_78fb6c1d6ff6505225175922c2c389ce48d7632c)))
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds block group, 2s
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_78fb6c1d6ff6505225175922c2c389ce48d7632c),
--   null, (select count(*) from observatory.obs_78fb6c1d6ff6505225175922c2c389ce48d7632c)::int
-- )
-- order by score desc;
-- 
-- -- census tract -> finds census tract, 1.6s
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_87a814e485deabe3b12545a537f693d16ca702c2 tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_87a814e485deabe3b12545a537f693d16ca702c2)))
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds census tract, 1.3s
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_87a814e485deabe3b12545a537f693d16ca702c2),
--   null, (select count(*) from observatory.obs_87a814e485deabe3b12545a537f693d16ca702c2)::int
-- )
-- order by score desc;
-- 
-- -- zcta5 -> finds zcta5
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_c4411eba732408d47d73281772dbf03d60645dec tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_c4411eba732408d47d73281772dbf03d60645dec)))
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds zcta5, 1.6s
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_c4411eba732408d47d73281772dbf03d60645dec),
--   null, (select count(*) from observatory.obs_c4411eba732408d47d73281772dbf03d60645dec)::int
-- )
-- order by score desc;
-- 
-- -- county -> finds unified school district or county
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d)))
--   , null, 3
-- )
-- order by score desc;
-- -- fails for subset (prefers puma)
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d where geoid like '36%')) where geoid like '36%')
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds county, 1s
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d),
--   null, (select count(*) from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d)::int
-- )
-- order by score desc;
-- -- fails for subset (prefers congressional district)
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d where geoid like '36%'),
--   null, (select count(*) from observatory.obs_0310c639744a2014bb1af82709228f05b59e7d3d where geoid like '36%')::int
-- )
-- order by score desc;
-- 
-- -- state -> finds congressional district (we're not adding up properly)
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_9812b21f90f3e6a885dc546a3c6ad32e0190d723 tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_9812b21f90f3e6a885dc546a3c6ad32e0190d723)))
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds congressional district (we're not adding up properly)
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_9812b21f90f3e6a885dc546a3c6ad32e0190d723),
--   null, (select count(*) from observatory.obs_9812b21f90f3e6a885dc546a3c6ad32e0190d723)::int
-- )
-- order by score desc;
-- 
-- -- au SA4 (only 106 of them) -> finds au.geo.SUA
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_b5b7ab6bbfc1acdd58e7bf770655274468c10988 tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 200.0) / count(*)))
--       from observatory.obs_b5b7ab6bbfc1acdd58e7bf770655274468c10988)))
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds SA3 (are we not adding up properly?)
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_b5b7ab6bbfc1acdd58e7bf770655274468c10988),
--   null, (select count(*) from observatory.obs_b5b7ab6bbfc1acdd58e7bf770655274468c10988)::int
-- )
-- order by score desc;
-- 
-- -- au SA4 (54K of them) -> finds au.geo.SA1, sometimes SOSR
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_collect(st_setsrid(st_envelope(the_geom), 4326))
--     from observatory.obs_c846ae4ea19a71b5026754ec730334e1828c09f2 tablesample system(
--     (select least(100, 100.0 - 100 * ((count(*) - 50.0) / count(*)))
--       from observatory.obs_c846ae4ea19a71b5026754ec730334e1828c09f2)))
--   , null, 3
-- )
-- order by score desc;
-- -- simple, alternative approach -> finds SA1, fraction of a sec
-- select *
-- from cdb_observatory._obs_getgeometryscores(
--   (select st_setsrid(st_extent(the_geom), 4326)
--     from observatory.obs_c846ae4ea19a71b5026754ec730334e1828c09f2),
--   null, (select count(*) from observatory.obs_c846ae4ea19a71b5026754ec730334e1828c09f2)::int
-- )
-- order by score desc;


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetGeometryScores(
  bounds Geometry(Geometry, 4326) DEFAULT NULL,
  filter_geom_ids TEXT[] DEFAULT NULL,
  desired_num_geoms INTEGER DEFAULT NULL
) RETURNS TABLE (
  score NUMERIC,
  numtiles BIGINT,
  table_id TEXT,
  column_id TEXT,
  notnull_percent NUMERIC,
  numgeoms NUMERIC,
  percentfill NUMERIC,
  estnumgeoms NUMERIC,
  meanmediansize NUMERIC
) AS $$
BEGIN
  IF desired_num_geoms IS NULL THEN
    desired_num_geoms := 3000;
  END IF;
  filter_geom_ids := COALESCE(filter_geom_ids, (ARRAY[])::TEXT[]);
  -- Very complex geometries simply fail.  For a boundary check, we can
  -- comfortably get away with the simplicity of an envelope
  --IF ST_Npoints(bounds) > 10000 THEN
  --  bounds := ST_Envelope(bounds);
  --END IF;
  RETURN QUERY
  EXECUTE $string$
    WITH expanded_geom AS (
      SELECT CASE WHEN $1 IS NOT NULL THEN generate_series(1, ST_NumGeometries($1))
                  ELSE 1 END AS exgeom_id,
             CASE WHEN $1 IS NOT NULL THEN (ST_Dump($1)).geom
                  ELSE NULL END AS exgeom
    ),
    clipped_geom AS (
      SELECT column_id, table_id, exgeom_id, exgeom
        , CASE WHEN exgeom IS NOT NULL THEN ST_Clip(tile, exgeom, True) -- -20
               ELSE tile END clipped_tile
        , tile
      FROM observatory.obs_column_table_tile_simple, expanded_geom
      WHERE (exgeom IS NULL OR ST_Intersects(exgeom, tile))
        AND (column_id = ANY($2) OR cardinality($2) = 0)
    ), clipped_geom_countagg AS (
      SELECT column_id, table_id, exgeom_id
        , BOOL_AND(ST_BandIsNoData(clipped_tile, 1)) nodata
        , ST_CountAgg(clipped_tile, 1, False)::Numeric pixels -- -10
      FROM clipped_geom
      GROUP BY column_id, table_id, exgeom_id
    ), clipped_geom_reagg AS (
      SELECT COUNT(*)::BIGINT cnt, a.column_id, a.table_id, a.exgeom_id,
             cdb_observatory.FIRST(exgeom) exgeom,
             cdb_observatory.FIRST(nodata) first_nodata,
             cdb_observatory.FIRST(pixels) first_pixel,
             cdb_observatory.FIRST(tile) first_tile,
             (ST_SummaryStatsAgg(clipped_tile, 1, False)).sum::Numeric sum_geoms, -- ND
             (ST_SummaryStatsAgg(clipped_tile, 2, False)).mean::Numeric / 255 mean_fill --ND
      FROM clipped_geom_countagg a, clipped_geom b
      WHERE a.table_id = b.table_id
        AND a.column_id = b.column_id
        AND a.exgeom_id = b.exgeom_id
      GROUP BY a.column_id, a.table_id, a.exgeom_id
    ), final AS (
      SELECT
        MAX(cnt) cnt, table_id, column_id
        , NULL::Numeric AS notnull_percent
        , (percentile_cont(0.5) within group (order by (CASE WHEN first_nodata IS FALSE
                THEN sum_geoms
                ELSE COALESCE(ST_Value(first_tile, 1, ST_PointOnSurface(exgeom)), 0)
                  * (ST_Area(exgeom) / ST_Area(ST_PixelAsPolygon(first_tile, 0, 0))
                    * first_pixel) -- -20
          END)::Numeric))::numeric
        AS numgeoms
        , (percentile_cont(0.5) within group (order by (CASE WHEN first_nodata IS FALSE
                THEN mean_fill
                ELSE COALESCE(ST_Value(first_tile, 2, ST_PointOnSurface(exgeom))::Numeric / 255, 0) -- -2
          END)::Numeric))::numeric
        AS percentfill
        , null::numeric estnumgeoms
        , null::numeric meanmediansize
      FROM clipped_geom_reagg
      GROUP BY table_id, column_id
    ) SELECT
      ((100.0 / (1+abs(log(0.0001 + $3) - log(0.0001 + numgeoms::Numeric)))) * percentfill)::Numeric
      AS score, *
      FROM final
  $string$ USING bounds, filter_geom_ids, desired_num_geoms;
  RETURN;
END
$$ LANGUAGE plpgsql IMMUTABLE;
