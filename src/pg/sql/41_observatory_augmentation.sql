--Functions for augmenting specific tables
--------------------------------------------------------------------------------

-- Creates a table of demographic snapshot

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetDemographicSnapshot(geom geometry(Geometry, 4326),
  timespan text DEFAULT NULL,
  boundary_id text DEFAULT NULL
) RETURNS SETOF JSON
AS $$
DECLARE
  meta JSON;
BEGIN
  boundary_id = COALESCE(boundary_id, 'us.census.tiger.census_tract');

  EXECUTE $query$ SELECT cdb_observatory.OBS_GetMeta($1,
         ('[ ' ||
'{"numer_id": "us.census.acs.B01003001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B01001002", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B01001026", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B01002001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002003", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002004", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002006", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002012", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002005", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002008", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002009", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B03002002", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B11001001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003017", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003019", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003020", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003021", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003022", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B15003023", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19013001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19083001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19301001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25001001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25002003", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25004002", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25004004", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25058001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25071001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25075001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25075025", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B25081002", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134002", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134003", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134004", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134005", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134006", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134007", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134008", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134009", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08134010", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B08135001", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001002", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001003", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001004", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001005", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001006", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001007", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001008", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001009", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001010", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001011", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001012", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001013", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001014", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001015", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001016", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '},' ||
'{"numer_id": "us.census.acs.B19001017", "numer_timespan": ' || $2 || ', "geom_id": ' || $3 || '}' ||
      ']')::JSON)
  $query$
  INTO meta
  USING geom,
        COALESCE('"' || timespan || '"', 'null'),
        COALESCE('"' || boundary_id || '"', 'null');

  RETURN QUERY EXECUTE $query$
    WITH vals AS (SELECT JSON_Array_Elements(data)->'value' val,
                         JSON_Array_Elements($2) meta
                  FROM cdb_observatory.OBS_GetData( ARRAY[($1, 1)::geomval], $2))
    SELECT JSON_Build_Object(
        'value', val,
        'id', meta->'numer_id',
        'name', meta->'numer_name',
        'type', meta->'numer_type',
        'description', meta->'numer_description'
    ) FROM vals
  $query$
  USING geom, meta
  RETURN;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeta(
  geom geometry(Geometry, 4326),
  params JSON,
  num_timespan_options INTEGER DEFAULT NULL, -- how many timespan options to show
  num_score_options INTEGER DEFAULT NULL, -- how many score options to show
  target_geoms INTEGER DEFAULT NULL
)
RETURNS JSON
AS $$
DECLARE
  numer_filters TEXT[];
  geom_filters TEXT[];
  meta_filter_clause TEXT;
  scores_clause TEXT;
  result JSON;
BEGIN
  IF num_timespan_options IS NULL THEN
    num_timespan_options := 1;
  END IF;
  IF num_score_options IS NULL THEN
    num_score_options := 1;
  END IF;

  numer_filters := (SELECT Array_Agg(val) FILTER (WHERE val IS NOT NULL) FROM (SELECT (JSON_Array_Elements(params))->>'numer_id' val) foo);
  geom_filters := (SELECT Array_Agg(val) FILTER (WHERE val IS NOT NULL) FROM (SELECT (JSON_Array_Elements(params))->>'geom_id' val) bar);
  meta_filter_clause := '(m.numer_id = ANY ($6) OR m.geom_id = ANY ($7))';

  scores_clause := ' agg_geoms AS (
    SELECT target_geoms, target_area, ARRAY_AGG(geom_id) geom_ids
    FROM meta
    GROUP BY target_geoms, target_area
  ), scores AS (
    SELECT target_geoms, target_area,
      CASE target_area
      -- point-specific, just order by numgeoms instead of score
      WHEN 0 THEN scores.numgeoms
      -- has some area, use proper scoring
      ELSE scores.score
      END AS score,
           scores.numgeoms, scores.table_id, scores.column_id
    FROM agg_geoms,
         LATERAL cdb_observatory._OBS_GetGeometryScores($1,
            geom_ids, COALESCE(target_geoms, $2), target_area) scores
  ) ';

  IF JSON_Array_Length(params) = 1 THEN
    IF numer_filters IS NULL AND geom_filters IS NOT NULL THEN
      meta_filter_clause := 'm.geom_id = ($7)[1]';
    ELSIF geom_filters IS NULL AND numer_filters IS NOT NULL THEN
      meta_filter_clause := 'm.numer_id = ($6)[1]';
    ELSIF numer_filters IS NOT NULL AND geom_filters IS NOT NULL THEN
      meta_filter_clause := 'm.numer_id = ($6)[1] AND m.geom_id = ($7)[1]';
    ELSE
      RAISE EXCEPTION 'Must pass either numer_id or geom_id to every key in GetMeta';
    END IF;

    IF geom_filters IS NOT NULL AND numer_filters IS NOT NULL THEN
      scores_clause := 'scores AS (
        SELECT NULL::INTEGER target_geoms, NULL::Numeric target_area,
        1 score, null, geom_tid table_id, geom_id column_id,
        NULL::Integer numgeoms
        FROM meta) ';
    END IF;
  END IF;

  EXECUTE format($string$
    WITH _filters AS (SELECT
        row_number() over () id, *
        FROM json_to_recordset($3)
        AS x(numer_id TEXT, denom_id TEXT, geom_id TEXT, numer_timespan TEXT,
          geom_timespan TEXT, normalization TEXT, max_timespan_rank TEXT,
          max_score_rank TEXT, target_geoms INTEGER, target_area Numeric
        )
    ), meta AS (SELECT
        id,
        f.numer_id,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_aggregate END numer_aggregate,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_colname END numer_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_geomref_colname END numer_geomref_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_tablename END numer_tablename,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_type END numer_type,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_name END numer_name,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_description END numer_description,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_t_description END numer_t_description,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE m.numer_timespan END numer_timespan,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE m.denom_id END denom_id,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_aggregate END denom_aggregate,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_colname END denom_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_geomref_colname END denom_geomref_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_tablename END denom_tablename,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_name END denom_name,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_description END denom_description,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_t_description END denom_t_description,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_type END denom_type,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_reltype END denom_reltype,
        m.geom_id,
        m.geom_timespan,
        geom_colname,
        geom_tid,
        geom_geomref_colname,
        geom_tablename,
        geom_name,
        geom_description,
        geom_t_description,
        geom_type,
        Coalesce(normalization,
          -- automatically assign normalization to numeric numerators
          CASE WHEN cdb_observatory.isnumeric(numer_type) THEN
            CASE WHEN denom_reltype ILIKE 'denominator' THEN 'denominated'
                 WHEN numer_aggregate ILIKE 'sum' THEN 'area'
                 WHEN numer_aggregate IN ('median', 'average') AND denom_reltype ILIKE 'universe'
                  THEN 'prenormalized'
                ELSE 'prenormalized'
            END ELSE NULL
          END
        ) normalization,
        max_timespan_rank,
        max_score_rank,
        target_geoms,
        target_area
      FROM observatory.obs_meta m JOIN _filters f
      ON CASE WHEN f.numer_id IS NULL THEN m.geom_id ELSE m.numer_id END =
         CASE WHEN f.numer_id IS NULL THEN f.geom_id ELSE f.numer_id END
      WHERE
        %s
        AND (m.numer_id = f.numer_id OR COALESCE(f.numer_id, '') = '')
        AND (m.denom_id = f.denom_id OR COALESCE(f.denom_id, '') = '')
        AND (m.geom_id = f.geom_id OR COALESCE(f.geom_id, '') = '')
        AND (m.geom_timespan = f.geom_timespan OR COALESCE(f.geom_timespan, '') = '')
        AND (m.numer_timespan = f.numer_timespan OR COALESCE(f.numer_timespan, '') = '')
    ), %s
    , groups AS (SELECT
        id,
        scores.score,
        numer_timespan,
        dense_rank() OVER (PARTITION BY id ORDER BY numer_timespan DESC) timespan_rank,
        dense_rank() OVER (PARTITION BY id ORDER BY score DESC) score_rank,
        json_build_object(
          'id', id,
          'numer_id', numer_id,
          'timespan_rank', dense_rank() OVER (PARTITION BY id ORDER BY numer_timespan DESC),
          'score_rank', dense_rank() OVER (PARTITION BY id ORDER BY score DESC),
          'timespan_rownum', row_number() over
            (PARTITION BY id, score ORDER BY numer_timespan DESC, Coalesce(denom_id, '')),
          'score_rownum', row_number() over
            (PARTITION BY id, numer_timespan ORDER BY score DESC, Coalesce(denom_id, '')),
          'score', scores.score,
          'suggested_name', cdb_observatory.FIRST(
            LOWER(TRIM(BOTH '_' FROM regexp_replace(CASE WHEN numer_id IS NOT NULL
              THEN CASE
                WHEN normalization ILIKE 'area%%' THEN numer_colname || ' per sq km' || ' ' || numer_timespan
                WHEN normalization ILIKE 'denom%%' THEN numer_colname || ' ' || numer_timespan || ' by ' || denom_colname
                ELSE numer_colname || ' ' || numer_timespan
              END
              ELSE geom_name || ' ' || geom_timespan
            END, '[^a-zA-Z0-9]+', '_', 'g')))
          ),
          'numer_aggregate', cdb_observatory.FIRST(meta.numer_aggregate),
          'numer_colname', cdb_observatory.FIRST(meta.numer_colname),
          'numer_geomref_colname', cdb_observatory.FIRST(meta.numer_geomref_colname),
          'numer_tablename', cdb_observatory.FIRST(meta.numer_tablename),
          'numer_type', cdb_observatory.FIRST(meta.numer_type),
          'numer_description', cdb_observatory.FIRST(meta.numer_description),
          'numer_t_description', cdb_observatory.FIRST(meta.numer_t_description),
          'denom_aggregate', cdb_observatory.FIRST(meta.denom_aggregate),
          'denom_colname', cdb_observatory.FIRST(denom_colname),
          'denom_geomref_colname', cdb_observatory.FIRST(denom_geomref_colname),
          'denom_tablename', cdb_observatory.FIRST(denom_tablename),
          'denom_type', cdb_observatory.FIRST(meta.denom_type),
          'denom_reltype', cdb_observatory.FIRST(meta.denom_reltype),
          'denom_description', cdb_observatory.FIRST(meta.denom_description),
          'denom_t_description', cdb_observatory.FIRST(meta.denom_t_description),
          'geom_colname', cdb_observatory.FIRST(geom_colname),
          'geom_geomref_colname', cdb_observatory.FIRST(geom_geomref_colname),
          'geom_tablename', cdb_observatory.FIRST(geom_tablename),
          'geom_type', cdb_observatory.FIRST(meta.geom_type),
          'geom_timespan', cdb_observatory.FIRST(meta.geom_timespan),
          'geom_description', cdb_observatory.FIRST(meta.geom_description),
          'geom_t_description', cdb_observatory.FIRST(meta.geom_t_description),
          'numer_timespan', cdb_observatory.FIRST(numer_timespan),
          'numer_name', cdb_observatory.FIRST(numer_name),
          'denom_name', cdb_observatory.FIRST(denom_name),
          'geom_name', cdb_observatory.FIRST(geom_name),
          'normalization', cdb_observatory.FIRST(normalization),
          'max_timespan_rank', cdb_observatory.FIRST(max_timespan_rank),
          'max_score_rank', cdb_observatory.FIRST(max_score_rank),
          'target_geoms', cdb_observatory.FIRST(scores.target_geoms),
          'target_area', cdb_observatory.FIRST(scores.target_area),
          'num_geoms', cdb_observatory.FIRST(scores.numgeoms),
          'denom_id', denom_id,
          'geom_id', meta.geom_id
        ) metadata
      FROM meta, scores
      WHERE meta.geom_id = scores.column_id
        AND meta.geom_tid = scores.table_id
        AND COALESCE(meta.target_geoms, 0) = COALESCE(scores.target_geoms, 0)
        AND COALESCE(meta.target_area, 0) = COALESCE(scores.target_area, 0)
      GROUP BY id, score, numer_id, denom_id, geom_id, numer_timespan
    ) SELECT JSON_AGG(metadata ORDER BY id)
      FROM groups
      WHERE timespan_rank <= Coalesce((metadata->>'max_timespan_rank')::INTEGER, 'infinity'::FLOAT)
        AND score_rank <= Coalesce((metadata->>'max_score_rank')::INTEGER, 1)
        AND (metadata->>'timespan_rownum')::INTEGER <= $4
        AND (metadata->>'score_rownum')::INTEGER <= $5
  $string$, meta_filter_clause, scores_clause)
  INTO result
  USING
    CASE WHEN ST_GeometryType(geom) = 'ST_Point' THEN
              ST_Buffer(geom::geography, 200)::geometry(geometry, 4326)
         ELSE geom
    END,
    target_geoms,
    params,
    num_timespan_options,
    num_score_options, numer_filters, geom_filters
    ;
  RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeasure(
  geom geometry(Geometry, 4326),
  measure_id TEXT,
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL,
  simplification NUMERIC DEFAULT 0.00001
)
RETURNS NUMERIC
AS $$
DECLARE
  geom_type TEXT;
  params JSON;
  map_type TEXT;
  result Numeric;
  numer_aggregate TEXT;
BEGIN
  IF geom IS NULL THEN
    RETURN NULL;
  END IF;

  IF simplification IS NOT NULL THEN
    geom := ST_Simplify(geom, simplification);
  END IF;

  IF ST_GeometryType(geom) = 'ST_Point' THEN
    geom_type := 'point';
  ELSIF ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon') THEN
    geom_type := 'polygon';
    geom := ST_CollectionExtract(ST_MakeValid(geom), 3);
  ELSE
    RAISE EXCEPTION 'Invalid geometry type (%), can only handle ''ST_Point'', ''ST_Polygon'', and ''ST_MultiPolygon''',
                    ST_GeometryType(geom);
  END IF;

  params := (SELECT cdb_observatory.OBS_GetMeta(
    geom, JSON_Build_Array(JSON_Build_Object('numer_id', measure_id,
                                             'geom_id', boundary_id,
                                             'numer_timespan', time_span
                                            )), 1, 1, 500));
  numer_aggregate := params->0->>'numer_aggregate';

  IF normalize ILIKE 'area%' AND numer_aggregate ILIKE 'sum' THEN
    map_type := 'areaNormalized';
  ELSIF normalize ILIKE 'denom%' THEN
    map_type := 'denominated';
  ELSIF normalize ILIKE 'pre%' THEN
    map_type := 'predenominated';
  ELSE
    -- defaults: area normalization for point if it's possible and none for
    -- polygon or non-summable point
    IF geom_type = 'point' AND numer_aggregate ILIKE 'sum' THEN
      map_type := 'areaNormalized';
    ELSE
      map_type := 'predenominated';
    END IF;
  END IF;

  params := JSON_Build_Array(JSONB_Set((params::JSONB)->0, '{normalization}', to_jsonb(map_type))::JSON);

  IF params->0->>'geom_id' IS NULL THEN
    RAISE NOTICE 'No boundary found for geom';
    RETURN NULL;
  ELSE
    RAISE NOTICE 'Using boundary %', params->0->>'geom_id';
  END IF;

  EXECUTE $query$
  SELECT (data->0->>'value')::Numeric FROM
    cdb_observatory.OBS_GetData(ARRAY[($1, 1)::geomval], $2)
  $query$
  INTO result
  USING geom, params;

  RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeasureById(
  geom_ref TEXT,
  measure_id TEXT,
  boundary_id TEXT,
  time_span TEXT DEFAULT NULL
)
RETURNS NUMERIC
AS $$
DECLARE
  result NUMERIC;
BEGIN
  IF geom_ref IS NULL THEN
    RETURN NULL;
  ELSIF boundary_id IS NULL THEN
    RETURN NULL;
  END IF;

  EXECUTE $query$
    SELECT data->0->>'value'
    FROM cdb_observatory.OBS_GetData(Array[$1],
      cdb_observatory.OBS_GetMeta(ST_MakeEnvelope(-180, -90, 180, 90, 4326),
        JSON_Build_Array(JSON_Build_Object(
            'numer_id', $2,
            'geom_id', $3,
            'numer_timespan', $4,
            'normalization', 'predenominated'
          ))))
  $query$
  INTO result
  USING geom_ref, measure_id, boundary_id, time_span;

  RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;


-- GetData that obtains data from array of geomrefs
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetData(
  geomrefs text[],
  params JSON
)
RETURNS TABLE (
  id TEXT,
  data JSON
)
AS $$
DECLARE
  colspecs TEXT;
  tables TEXT;
  obs_wheres TEXT;
  user_wheres TEXT;

  q text;
BEGIN
    IF params IS NULL OR JSON_ARRAY_LENGTH(params) = 0 THEN
      RETURN QUERY EXECUTE $query$ SELECT NULL::TEXT, NULL::JSON LIMIT 0 $query$;
      RETURN;
    END IF;

    EXECUTE
      $query$
        WITH _meta AS (SELECT
          generate_series(1, array_length($1, 1)) colid,
          (unnest($1))->>'id' id,
          (unnest($1))->>'numer_id' numer_id,
          (unnest($1))->>'numer_aggregate' numer_aggregate,
          (unnest($1))->>'numer_colname' numer_colname,
          (unnest($1))->>'numer_geomref_colname' numer_geomref_colname,
          (unnest($1))->>'numer_tablename' numer_tablename,
          (unnest($1))->>'numer_type' numer_type,
          (unnest($1))->>'denom_id' denom_id,
          (unnest($1))->>'denom_aggregate' denom_aggregate,
          (unnest($1))->>'denom_colname' denom_colname,
          (unnest($1))->>'denom_geomref_colname' denom_geomref_colname,
          (unnest($1))->>'denom_tablename' denom_tablename,
          (unnest($1))->>'denom_type' denom_type,
          (unnest($1))->>'denom_reltype' denom_reltype,
          (unnest($1))->>'geom_id' geom_id,
          (unnest($1))->>'geom_colname' geom_colname,
          (unnest($1))->>'geom_geomref_colname' geom_geomref_colname,
          (unnest($1))->>'geom_tablename' geom_tablename,
          (unnest($1))->>'geom_type' geom_type,
          (unnest($1))->>'geom_timespan' geom_timespan,
          (unnest($1))->>'numer_timespan' numer_timespan,
          (unnest($1))->>'normalization' normalization,
          (unnest($1))->>'api_method' api_method,
          (unnest($1))->'api_args' api_args
        )
        SELECT String_Agg(
        -- numeric
        'JSON_Build_Object(' || CASE
        WHEN api_method IS NOT NULL THEN
          '''value'', ' ||
            'ARRAY_AGG( ' ||
              api_method || '.' || numer_colname || ')::' || numer_type || '[]'
        -- numeric internal values
        WHEN cdb_observatory.isnumeric(numer_type) THEN
          '''value'', ' || CASE
          -- denominated
          WHEN LOWER(normalization) LIKE 'denom%' OR (normalization IS NULL AND denom_id IS NOT NULL)
            THEN 'cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname ||
                 ' / NullIf(' || denom_tablename || '.' || denom_colname || ', 0))'
          -- areaNormalized
          WHEN LOWER(normalization) LIKE 'area%' OR (normalization IS NULL AND numer_aggregate ILIKE 'sum')
            THEN 'cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname ||
                 ' / (ST_Area(' || geom_tablename || '.' || geom_colname || '::Geography)/1000000))'
          -- prenormalized
          ELSE 'cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname || ')'
          END || ':: ' || numer_type

        -- categorical/text
        WHEN LOWER(numer_type) LIKE 'text' THEN
          '''value'', ' || 'cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname || ') '

        -- geometry
        WHEN numer_id IS NULL THEN
          '''geomref'', ' || 'cdb_observatory.FIRST(' || geom_tablename ||
            '.' || geom_geomref_colname || '), ' ||
          '''value'', ' || '(cdb_observatory.FIRST(' || geom_tablename ||
              '.' || geom_colname || '))::TEXT' -- Needed to force text output in Postgis 3+, later parsed automagically by ::Geometry. Otherwise we'd get geojson output
        ELSE ''
        END || ')', ', ')
        AS colspecs,

          (SELECT String_Agg(DISTINCT CASE
              -- External API
              WHEN tablename LIKE 'cdb_observatory.%' THEN
                'LATERAL (SELECT * FROM ' || tablename || ') ' ||
                  REPLACE(split_part(tablename, '(', 1), 'cdb_observatory.', '')
              -- Internal obs_ table
              ELSE 'observatory.' || tablename
            END, ', ') FROM (
            SELECT DISTINCT UNNEST(tablenames_ary) tablename FROM (
            SELECT ARRAY_AGG(numer_tablename) ||
                ARRAY_AGG(denom_tablename) ||
                ARRAY_AGG(geom_tablename) ||
                ARRAY_AGG('cdb_observatory.' || api_method || '(_geomrefs.id' || COALESCE(', ' ||
                      (SELECT STRING_AGG(REPLACE(val::text, '"', ''''), ', ')
                       FROM (SELECT json_array_elements(api_args) as val) as vals),
                    '') || ')')
              tablenames_ary
            ) tablenames_inner
          ) tablenames_outer) tablenames,

          String_Agg(DISTINCT array_to_string(ARRAY[
            CASE WHEN numer_tablename != geom_tablename
                 THEN numer_tablename || '.' || numer_geomref_colname || ' = ' ||
                      geom_tablename || '.' || geom_geomref_colname
                 ELSE NULL END,
            CASE WHEN numer_tablename != denom_tablename
                 THEN numer_tablename || '.' || numer_geomref_colname || ' = ' ||
                      denom_tablename || '.' || denom_geomref_colname
                 ELSE NULL END
            ], ' AND '),
           ' AND ') AS obs_wheres,

          String_Agg(geom_tablename || '.' || geom_geomref_colname || ' = ' ||
             '_geomrefs.id', ' AND ')
             AS user_wheres
        FROM _meta
        ;
      $query$
    INTO colspecs, tables, obs_wheres, user_wheres
    USING (SELECT ARRAY(SELECT json_array_elements_text(params))::json[]);

    RETURN QUERY EXECUTE format($query$
      WITH _geomrefs AS (SELECT UNNEST($1) as id)
      SELECT _geomrefs.id, Array_to_JSON(ARRAY[%s]::JSON[])
      FROM _geomrefs, %s
           %s
      GROUP BY _geomrefs.id
      ORDER BY _geomrefs.id
    $query$, colspecs, tables,
             'WHERE ' || NULLIF(ARRAY_TO_STRING(ARRAY[
                    Nullif(obs_wheres, ''), Nullif(user_wheres, '')
                ], ' AND '), '')
        )
    USING geomrefs;
    RETURN;
END;
$$ LANGUAGE plpgsql STABLE;


-- GetData that obtains data from array of (geom, id) geomvals.
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetData(
  geomvals geomval[],
  params JSON,
  merge BOOLEAN DEFAULT True
)
RETURNS TABLE (
  id INT,
  data JSON
)
AS $$
DECLARE
  procgeom_clauses TEXT;
  val_clauses TEXT;
  json_clause TEXT;
  geomtype TEXT;
BEGIN
    IF params IS NULL OR JSON_ARRAY_LENGTH(params) = 0 OR ARRAY_LENGTH(geomvals, 1) IS NULL THEN
      RETURN QUERY EXECUTE $query$ SELECT NULL::INT, NULL::JSON LIMIT 0 $query$;
      RETURN;
    END IF;

    geomtype := ST_GeometryType(geomvals[1].geom);

    /* Read metadata to generate clauses for query */
    EXECUTE $query$
      WITH _meta AS (SELECT
        row_number() over () colid, *
        FROM json_to_recordset($1)
        AS x(id TEXT, numer_id TEXT, numer_aggregate TEXT, numer_colname TEXT,
             numer_geomref_colname TEXT, numer_tablename TEXT, numer_type TEXT,
             denom_id TEXT, denom_aggregate TEXT, denom_colname TEXT,
             denom_geomref_colname TEXT, denom_tablename TEXT, denom_type TEXT,
             denom_reltype TEXT, geom_id TEXT, geom_colname TEXT,
             geom_geomref_colname TEXT, geom_tablename TEXT, geom_type TEXT,
             numer_timespan TEXT, geom_timespan TEXT, normalization TEXT,
             api_method TEXT, api_args JSON)
      ),

      -- Generate procgeom clauses.
      -- These join the users' geoms to the relevant geometries for the
      -- asked-for measures in the Observatory.
      _procgeom_clauses AS (
        SELECT
          '_procgeoms_' || Coalesce(geom_tablename || '_' || geom_geomref_colname, api_method) || ' AS (' ||
            CASE WHEN api_method IS NULL THEN
              'SELECT _geoms.id, ' ||
                CASE $3 WHEN True THEN '_geoms.geom'
                        ELSE geom_tablename || '.' || geom_colname
                END || ' AS geom, ' ||
                geom_tablename || '.' || geom_geomref_colname || ' AS geomref, ' ||
                CASE
                  WHEN $2 = 'ST_Point' THEN
                    ' Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '::Geography), 0)/1000000 ' ||
                    ' AS area'
                  -- for numeric areas, include more complex calcs
                  ELSE
                  'CASE WHEN ST_Within(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ')
                       THEN ST_Area(_geoms.geom) / Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '), 0)
                       WHEN ST_Within(' || geom_tablename || '.' || geom_colname || ', _geoms.geom)
                       THEN 1
                       ELSE ST_Area(cdb_observatory.safe_intersection(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ')) /
                         Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '), 0)
                  END pct_obs'
                END || '
              FROM _geoms, observatory.' || geom_tablename || '
              WHERE ST_Intersects(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ')'
              -- pass through input geometries for api_method
              ELSE 'SELECT _geoms.id, _geoms.geom FROM _geoms'
            END ||
          ') '
          AS procgeom_clause
        FROM _meta
        GROUP BY api_method, geom_tablename, geom_geomref_colname, geom_colname
      ),

      -- Generate val clauses.
      -- These perform interpolations or other necessary calculations to
      -- provide values according to users geometries.
      _val_clauses AS (
        SELECT
          '_vals_' || Coalesce(geom_tablename || '_' || geom_geomref_colname, api_method) || ' AS (
            SELECT _procgeoms.id, ' ||
              String_Agg('json_build_object(' || CASE
                -- api-delivered values
                WHEN api_method IS NOT NULL THEN
                '''value'', ' ||
                  'ARRAY_AGG( ' ||
                    api_method || '.' || numer_colname || ')::' || numer_type || '[]'
                -- numeric internal values
                WHEN cdb_observatory.isnumeric(numer_type) THEN
                '''value'', ' || CASE
                  -- denominated
                  WHEN LOWER(normalization) LIKE 'denom%'
                    THEN CASE
                    WHEN denom_tablename IS NULL THEN ' NULL '
                    -- denominated point-in-poly
                    WHEN $2 = 'ST_Point' THEN
                    ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname ||
                    '      / NullIf(' || denom_tablename || '.' || denom_colname || ', 0))'
                    -- denominated polygon interpolation
                    -- SUM (numer * (% OBS geom in user geom)) / SUM (denom * (% OBS geom in user geom))
                    ELSE
                    ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                    ' * _procgeoms.pct_obs ' ||
                    ' ) / NULLIF(SUM(' || denom_tablename || '.' || denom_colname || ' ' ||
                    '            * _procgeoms.pct_obs), 0) '
                    END
                  -- areaNormalized
                  WHEN LOWER(normalization) LIKE 'area%'
                    THEN CASE
                    -- areaNormalized point-in-poly
                    WHEN $2 = 'ST_Point' THEN
                    ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname ||
                    '      / _procgeoms.area)'
                    -- areaNormalized polygon interpolation
                    -- SUM (numer * (% OBS geom in user geom)) / area of big geom
                    ELSE
                    --' NULL END '
                    ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                    ' * _procgeoms.pct_obs' ||
                    ' ) / (Nullif(ST_Area(cdb_observatory.FIRST(_procgeoms.geom)::Geography), 0) / 1000000) '
                    END
                  -- median/average measures with universe
                  WHEN LOWER(numer_aggregate) IN ('median', 'average') AND
                      denom_reltype ILIKE 'universe' AND LOWER(normalization) LIKE 'pre%'
                    THEN CASE
                    -- predenominated point-in-poly
                    WHEN $2 = 'ST_Point' THEN
                    ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname || ') '
                    ELSE
                    -- predenominated polygon interpolation weighted by universe
                    -- SUM (numer * denom * (% user geom in OBS geom)) / SUM (denom * (% user geom in OBS geom))
                    --     (10 * 1000 * 1) / (1000 * 1) = 10
                    --     (10 * 1000 * 1 + 50 * 10 * 1) / (1000 + 10) = 10500 / 10000 = 10.5
                    ' SUM(' || numer_tablename || '.' || numer_colname ||
                    ' * ' || denom_tablename || '.' || denom_colname ||
                    ' * _procgeoms.pct_obs ' ||
                    ' ) / Nullif(SUM(' || denom_tablename || '.' || denom_colname ||
                    ' * _procgeoms.pct_obs ' || '), 0) '
                    END
                  -- prenormalized for summable measures. point or summable only!
                  WHEN numer_aggregate ILIKE 'sum' AND LOWER(normalization) LIKE 'pre%'
                    THEN CASE
                    -- predenominated point-in-poly
                    WHEN $2 = 'ST_Point' THEN
                    ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname || ') '
                    ELSE
                    -- predenominated polygon interpolation
                    -- SUM (numer * (% user geom in OBS geom))
                    ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                    ' * _procgeoms.pct_obs) '
                    END
                  -- Everything else. Point only!
                  ELSE CASE
                    WHEN $2 = 'ST_Point' THEN
                    ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname || ') '
                    ELSE
                    ' cdb_observatory._OBS_RaiseNotice(''Cannot perform calculation over polygon for ' ||
                        numer_id || '/' || coalesce(denom_id, '') || '/' || geom_id || '/' || numer_timespan || ''')::Numeric '
                    END
                  END || '::' || numer_type

                -- categorical/text
                WHEN LOWER(numer_type) LIKE 'text' THEN
                  '''value'', ' || 'MODE() WITHIN GROUP (ORDER BY ' || numer_tablename || '.' || numer_colname || ') '
                  -- geometry
                WHEN numer_id IS NULL THEN
                  '''geomref'', _procgeoms.geomref, ' ||
                  '''value'', ' || 'cdb_observatory.FIRST(_procgeoms.geom)::TEXT'
                  -- code below will return the intersection of the user's geom and the
                  -- OBS geom
                  --'''value'', ' || 'ST_Union(cdb_observatory.safe_intersection(_geoms.geom, ' || geom_tablename ||
                  --    '.' || geom_colname || '))::TEXT'
                ELSE ''
                END
              || ') val_' || colid, ', ')
            || '
            FROM _procgeoms_' || Coalesce(geom_tablename || '_' || geom_geomref_colname, api_method) || ' _procgeoms ' ||
              Coalesce(String_Agg(DISTINCT
                  Coalesce('LEFT JOIN observatory.' || numer_tablename || ' ON _procgeoms.geomref = observatory.' || numer_tablename || '.' || numer_geomref_colname,
                    ', LATERAL (SELECT * FROM cdb_observatory.' || api_method || '(_procgeoms.geom' || Coalesce(', ' ||
                        (SELECT STRING_AGG(REPLACE(val::text, '"', ''''), ', ')
                          FROM (SELECT JSON_Array_Elements(api_args) as val) as vals),
                        '') || ')) AS ' || api_method)
              , ' '), '') ||
            CASE $3 WHEN True THEN E'\n GROUP BY _procgeoms.id ORDER BY _procgeoms.id '
                    ELSE           E'\n GROUP BY _procgeoms.id, _procgeoms.geomref
                                        ORDER BY _procgeoms.id, _procgeoms.geomref' END
          || ')'
          AS val_clause,
          '_vals_' || Coalesce(geom_tablename || '_' || geom_geomref_colname, api_method) AS cte_name
        FROM _meta
        GROUP BY geom_tablename, geom_geomref_colname, geom_colname, api_method
      ),

      -- Generate clauses necessary to join together val_clauses
      _val_joins AS (
        SELECT String_Agg(a.cte_name || '.id = ' || b.cte_name || '.id ', ' AND ') val_joins
        FROM _val_clauses a, _val_clauses b
        WHERE a.cte_name != b.cte_name
          AND a.cte_name < b.cte_name
      ),

      -- Generate JSON clause.  This puts together vals from val_clauses
      _json_clause AS (SELECT
        'SELECT ' || cdb_observatory.FIRST(cte_name) || '.id::INT,
           Array_to_JSON(ARRAY[' || (SELECT String_Agg('val_' || colid, ', ') FROM _meta) || '])
         FROM ' || String_Agg(cte_name, ', ') ||
        Coalesce(' WHERE ' || val_joins, '')
        AS json_clause
        FROM _val_clauses, _val_joins
        GROUP BY val_joins
      )

      SELECT (SELECT String_Agg(procgeom_clause, E',\n     ') FROM _procgeom_clauses),
             (SELECT String_Agg(val_clause, E',\n     ') FROM _val_clauses),
             json_clause
      FROM _json_clause
    $query$ INTO
      procgeom_clauses,
      val_clauses,
      json_clause
    USING params, geomtype, merge;

    /* Execute query */
    RETURN QUERY EXECUTE format($query$
      WITH _raw_geoms AS (%s),
      _geoms AS (SELECT id,
        CASE WHEN (ST_NPoints(geom) > 1000)
               THEN ST_CollectionExtract(ST_MakeValid(ST_SimplifyVW(geom, 0.00001)), 3)
             ELSE geom END geom
        FROM _raw_geoms),
      -- procgeom_clauses
      %s,

      -- val_clauses
      %s

      -- json_clause
      %s
    $query$, CASE WHEN ARRAY_LENGTH(geomvals, 1) = 1
               THEN ' SELECT $1[1].val as id, $1[1].geom as geom '
               ELSE ' SELECT val as id, geom FROM UNNEST($1) '
             END,
             String_Agg(procgeom_clauses, E',\n       '),
             String_Agg(val_clauses, E',\n       '),
             json_clause)
    USING geomvals;
    RETURN;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetCategory(
  geom geometry(Geometry, 4326),
  category_id TEXT,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL,
  simplification NUMERIC DEFAULT 0.00001
)
RETURNS TEXT
AS $$
DECLARE
  geom_type TEXT;
  params JSON;
  map_type TEXT;
  result TEXT;
BEGIN
  IF geom IS NULL THEN
    RETURN NULL;
  END IF;

  IF simplification IS NOT NULL THEN
    geom := ST_Simplify(geom, simplification);
  END IF;

  IF ST_GeometryType(geom) = 'ST_Point' THEN
    geom_type := 'point';
  ELSIF ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon') THEN
    geom_type := 'polygon';
    geom := ST_CollectionExtract(ST_MakeValid(geom), 3);
  ELSE
    RAISE EXCEPTION 'Invalid geometry type (%), can only handle ''ST_Point'', ''ST_Polygon'', and ''ST_MultiPolygon''',
                    ST_GeometryType(geom);
  END IF;

  params := (SELECT cdb_observatory.OBS_GetMeta(
    geom, JSON_Build_Array(JSON_Build_Object('numer_id', category_id,
                                             'geom_id', boundary_id,
                                             'numer_timespan', time_span
                                            )), 1, 1, 500));

  IF params->0->>'geom_id' IS NULL THEN
    RAISE NOTICE 'No boundary found for geom';
    RETURN NULL;
  ELSE
    RAISE NOTICE 'Using boundary %', params->0->>'geom_id';
  END IF;

  EXECUTE $query$
  SELECT data->0->>'value' FROM
    cdb_observatory.OBS_GetData(ARRAY[($1, 1)::geomval], $2)
  $query$
  INTO result
  USING geom, params;

  RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetUSCensusMeasure(
   geom geometry(Geometry, 4326),
   name TEXT,
   normalize TEXT DEFAULT NULL,
   boundary_id TEXT DEFAULT NULL,
   time_span TEXT DEFAULT NULL
 )
RETURNS NUMERIC AS $$
DECLARE
  standardized_name text;
  measure_id text;
  result Numeric;
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
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetUSCensusCategory(
   geom geometry(Geometry, 4326),
   name TEXT,
   boundary_id TEXT DEFAULT NULL,
   time_span TEXT DEFAULT NULL
 )
RETURNS TEXT AS $$
DECLARE
  standardized_name TEXT;
  category_id TEXT;
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
$$ LANGUAGE plpgsql STABLE;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetPopulation(
  geom geometry(Geometry, 4326),
  normalize TEXT DEFAULT NULL,
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL
)
RETURNS NUMERIC
AS $$
DECLARE
  population_measure_id TEXT;
  result Numeric;
BEGIN
  -- TODO use a super-column for global pop
  population_measure_id := 'us.census.acs.B01003001';

  EXECUTE $query$ SELECT cdb_observatory.OBS_GetMeasure(
      $1, $2, $3, $4, $5
  ) LIMIT 1
  $query$
  INTO result
  USING geom, population_measure_id, normalize, boundary_id, time_span;

  RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetSegmentSnapshot(
  geom geometry(Geometry, 4326),
  boundary_id text DEFAULT NULL
)
RETURNS JSON
AS $$
DECLARE
  meta JSON;
  data JSON;
  result JSON;
BEGIN
  boundary_id = COALESCE(boundary_id, 'us.census.tiger.census_tract');

  EXECUTE $query$
    SELECT cdb_observatory.OBS_GetMeta($1, ('[ ' ||
            '{"numer_id": "us.census.acs.B01003001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B01001002_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B01001026_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B01002001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B03002003_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B03002004_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B03002006_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B03002012_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B05001006_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08006001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08006002_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08301010_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08006009_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08006011_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08006015_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B08006017_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B09001001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B11001001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B14001001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B14001002_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B14001005_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B14001006_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B14001007_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B14001008_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B15003001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B15003017_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B15003022_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B15003023_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B16001001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B16001002_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B16001003_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B17001001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B17001002_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B19013001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B19083001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B19301001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25001001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25002003_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25004002_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25004004_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25058001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25071001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25075001_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.acs.B25075025_quantile", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.spielman_singleton_segments.X10", "geom_id": ' || $2 || '},' ||
            '{"numer_id": "us.census.spielman_singleton_segments.X55", "geom_id": ' || $2 || '}' ||
          ']')::JSON)
  $query$
  INTO meta
  USING geom, COALESCE('"' || boundary_id || '"', 'null');

  EXECUTE $query$
    SELECT data FROM cdb_observatory.OBS_GetData(
      ARRAY[($1, 1)::geomval], $2)
  $query$
  INTO data
  USING geom, meta;

  EXECUTE $query$
    WITH els AS (SELECT
      REPLACE(REPLACE(JSON_Array_Elements($1)->>'numer_id',
        'us.census.spielman_singleton_segments.X55', 'x55_segment'),
        'us.census.spielman_singleton_segments.X10', 'x10_segment') k,
      JSON_Array_Elements($2)->>'value' v)
    SELECT JSON_Object_Agg(k, v) FROM els
  $query$
  INTO result
  USING meta, data;

  RETURN result;
END;
$$ LANGUAGE plpgsql STABLE;

-- MetadataValidation checks the metadata parameters and the geometry type
-- of the data in order to find possible wrong cases
CREATE OR REPLACE FUNCTION cdb_observatory.obs_metadatavalidation(
  geometry_extent geometry(Geometry, 4326),
  geometry_type text,
  params JSON,
  target_geoms INTEGER DEFAULT NULL
)
RETURNS TABLE(valid boolean, errors text[]) AS $$
DECLARE
  meta json;
  errors text[];
BEGIN
  errors := (ARRAY[])::TEXT[];
  IF geometry_type IN ('ST_Polygon', 'ST_MultiPolygon') THEN
      FOR meta IN EXECUTE 'SELECT json_array_elements(cdb_observatory.OBS_GetMeta($1, $2, 1, 1, $3))' USING geometry_extent, params, target_geoms
      LOOP
          IF (meta->>'normalization' = 'denominated' AND meta->>'denom_id' is NULL) THEN
              errors := array_append(errors, 'Normalizated measure should have a numerator and a denominator. Please review the provided options.');
          END IF;
          IF (meta->>'numer_aggregate' IS NULL) THEN
              errors := array_append(errors, 'For polygon geometries, aggregation is mandatory. Please review the provided options');
          END IF;
          IF (meta->>'numer_aggregate' IN ('median', 'average') AND meta->>'denom_id' IS NULL) THEN
              errors := array_append(errors, 'Median or average aggregation for polygons requires a denominator to provide weights. Please review the provided options');
          END IF;
          IF (meta->>'numer_aggregate' IN ('median', 'average') AND meta->>'normalization' NOT LIKE 'pre%') THEN
              errors := array_append(errors, format('Median or average aggregation only supports prenormalized normalization, %s passed. Please review the provided options', meta->>'normalization'));
          END IF;
      END LOOP;

      IF CARDINALITY(errors) > 0 THEN
          RETURN QUERY EXECUTE 'SELECT FALSE, $1' USING errors;
      ELSE
          RETURN QUERY SELECT TRUE, ARRAY[]::TEXT[];
      END IF;
  ELSE
    RETURN QUERY SELECT TRUE, ARRAY[]::TEXT[];
  END IF;
  RETURN;
END;
$$ LANGUAGE plpgsql STABLE;
