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
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeta(
  geom geometry(Geometry, 4326),
  params JSON,
  max_timespan_rank INTEGER DEFAULT NULL, -- cutoff for timespan ranks when there's ambiguity
  max_score_rank INTEGER DEFAULT NULL, -- cutoff for geom ranks when there's ambiguity
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
  IF max_timespan_rank IS NULL THEN
    max_timespan_rank := 1;
  END IF;
  IF max_score_rank IS NULL THEN
    max_score_rank := 1;
  END IF;

  numer_filters := (SELECT Array_Agg(val) FILTER (WHERE val IS NOT NULL) FROM (SELECT (JSON_Array_Elements(params))->>'numer_id' val) foo);
  geom_filters := (SELECT Array_Agg(val) FILTER (WHERE val IS NOT NULL) FROM (SELECT (JSON_Array_Elements(params))->>'geom_id' val) bar);
  meta_filter_clause := '(m.numer_id = ANY ($6) OR m.geom_id = ANY ($7))';

  scores_clause := 'SELECT *
                    FROM cdb_observatory._OBS_GetGeometryScores($1,
                    (SELECT Array_Agg(geom_id) FROM meta), $2) scores ';

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
      scores_clause := 'SELECT 1 score, null, geom_tid table_id, geom_id column_id,
                               null, null, null, null, null, null
                        FROM meta ';
    END IF;
  END IF;

  EXECUTE format($string$
    WITH _filters AS (SELECT
        generate_series(1, array_length($3, 1)) id,
        (unnest($3))->>'numer_id' numer_id,
        (unnest($3))->>'denom_id' denom_id,
        (unnest($3))->>'geom_id' geom_id,
        (unnest($3))->>'numer_timespan' numer_timespan,
        (unnest($3))->>'geom_timespan' geom_timespan,
        (unnest($3))->>'normalization' normalization
    ), meta AS (SELECT
        id,
        f.numer_id,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_aggregate END numer_aggregate,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_colname END numer_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_geomref_colname END numer_geomref_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_tablename END numer_tablename,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_type END numer_type,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE numer_name END numer_name,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE m.numer_timespan END numer_timespan,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE m.denom_id END denom_id,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_aggregate END denom_aggregate,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_colname END denom_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_geomref_colname END denom_geomref_colname,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_tablename END denom_tablename,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_name END denom_name,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_type END denom_type,
        CASE WHEN f.numer_id IS NULL THEN NULL ELSE denom_reltype END denom_reltype,
        m.geom_id,
        m.geom_timespan,
        geom_colname,
        geom_tid,
        geom_geomref_colname,
        geom_tablename,
        geom_name,
        geom_type,
        normalization
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
    ), scores AS (
        %s
    ), groups AS (SELECT
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
          'score', scores.score,
          'numer_aggregate', cdb_observatory.FIRST(meta.numer_aggregate),
          'numer_colname', cdb_observatory.FIRST(meta.numer_colname),
          'numer_geomref_colname', cdb_observatory.FIRST(meta.numer_geomref_colname),
          'numer_tablename', cdb_observatory.FIRST(meta.numer_tablename),
          'numer_type', cdb_observatory.FIRST(meta.numer_type),
          --'numer_description', cdb_observatory.FIRST(meta.numer_description),
          --'numer_t_description', cdb_observatory.FIRST(meta.numer_t_description),
          'denom_aggregate', cdb_observatory.FIRST(meta.denom_aggregate),
          'denom_colname', cdb_observatory.FIRST(denom_colname),
          'denom_geomref_colname', cdb_observatory.FIRST(denom_geomref_colname),
          'denom_tablename', cdb_observatory.FIRST(denom_tablename),
          'denom_type', cdb_observatory.FIRST(meta.denom_type),
          'denom_reltype', cdb_observatory.FIRST(meta.denom_reltype),
          --'denom_description', cdb_observatory.FIRST(meta.denom_description),
          --'denom_t_description', cdb_observatory.FIRST(meta.denom_t_description),
          'geom_colname', cdb_observatory.FIRST(geom_colname),
          'geom_geomref_colname', cdb_observatory.FIRST(geom_geomref_colname),
          'geom_tablename', cdb_observatory.FIRST(geom_tablename),
          'geom_type', cdb_observatory.FIRST(meta.geom_type),
          'geom_timespan', cdb_observatory.FIRST(meta.geom_timespan),
          --'geom_description', cdb_observatory.FIRST(meta.geom_description),
          --'geom_t_description', cdb_observatory.FIRST(meta.geom_t_description),
          'numer_timespan', cdb_observatory.FIRST(numer_timespan),
          'numer_name', cdb_observatory.FIRST(numer_name),
          'denom_name', cdb_observatory.FIRST(denom_name),
          'geom_name', cdb_observatory.FIRST(geom_name),
          'normalization', cdb_observatory.FIRST(normalization),
          'denom_id', denom_id,
          'geom_id', meta.geom_id
        ) metadata
      FROM meta, scores
      WHERE meta.geom_id = scores.column_id
        AND meta.geom_tid = scores.table_id
      GROUP BY id, score, numer_id, denom_id, geom_id, numer_timespan
    ) SELECT JSON_AGG(metadata ORDER BY id)
      FROM groups
      WHERE timespan_rank <= $4
        AND score_rank <= $5
  $string$, meta_filter_clause, scores_clause)
  INTO result
  USING
    CASE WHEN ST_GeometryType(geom) = 'ST_Point' THEN
              ST_Buffer(geom::geography, 200)::geometry(geometry, 4326)
         ELSE geom
    END,
    target_geoms,
    (SELECT ARRAY(SELECT json_array_elements_text(params))::json[]),
    max_timespan_rank,
    max_score_rank, numer_filters, geom_filters
    ;
  RETURN result;
END;
$$ LANGUAGE plpgsql IMMUTABLE;


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
$$ LANGUAGE plpgsql IMMUTABLE;

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
$$ LANGUAGE plpgsql;


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
          '''value'', ' || 'cdb_observatory.FIRST(' || geom_tablename ||
              '.' || geom_colname || ')'
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
$$ LANGUAGE plpgsql;


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
  geom_colspecs TEXT;
  geom_tables TEXT;
  geomrefs_alias TEXT;
  geomrefs_noalias TEXT;
  data_colspecs TEXT;
  data_tables TEXT;
  obs_wheres TEXT;
  user_wheres TEXT;
  geomtype TEXT;
BEGIN
    IF params IS NULL OR JSON_ARRAY_LENGTH(params) = 0 THEN
      RETURN QUERY EXECUTE $query$ SELECT NULL::INT, NULL::JSON LIMIT 0 $query$;
      RETURN;
    END IF;

    geomtype := ST_GeometryType(geomvals[1].geom);

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
          (unnest($1))->>'numer_timespan' numer_timespan,
          (unnest($1))->>'geom_timespan' geom_timespan,
          (unnest($1))->>'normalization' normalization,
          (unnest($1))->>'api_method' api_method,
          (unnest($1))->'api_args' api_args
        )
        SELECT
        String_Agg(DISTINCT
           CASE
           WHEN numer_id IS NULL THEN ''
           WHEN $2 = 'ST_Point' THEN
           '1 AS pct_' || geom_tablename || ', '
           ELSE
           'CASE WHEN ST_Within(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ') ' ||
           '     THEN ST_Area(_geoms.geom) / Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '), 0)' ||
           '     WHEN ST_Within(' || geom_tablename || '.' || geom_colname || ', _geoms.geom) ' ||
           '     THEN 1 ' ||
           '     ELSE ST_Area(cdb_observatory.safe_intersection(_geoms.geom, ' ||
                              geom_tablename || '.' || geom_colname || ')) / ' || 
                          'Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '), 0) ' ||
           'END pct_' || geom_tablename || ', '
           END || geom_tablename || '.' || geom_colname || ' AS geom_' || geom_tablename
        , ', ') AS geom_colspecs,
        String_Agg(DISTINCT 'observatory.' || geom_tablename, ', ') AS geom_tables,
        String_Agg(
        'JSON_Build_Object(' || CASE
          -- api-delivered values
          WHEN api_method IS NOT NULL THEN
          '''value'', ' ||
            'ARRAY_AGG( ' ||
              api_method || '.' || numer_colname || ')::' || numer_type || '[]'
          -- numeric internal values
          WHEN cdb_observatory.isnumeric(numer_type) THEN
          '''value'', ' || CASE
          -- denominated
          WHEN LOWER(normalization) LIKE 'denom%' OR
               (normalization IS NULL AND LOWER(denom_reltype) LIKE 'denominator')
            THEN CASE
            -- denominated point-in-poly
            WHEN $2 = 'ST_Point' THEN
            ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname ||
            '      / NullIf(' || denom_tablename || '.' || denom_colname || ', 0))'
            -- denominated polygon interpolation
            -- SUM (numer * (% OBS geom in user geom)) / SUM (denom * (% OBS geom in user geom))
            ELSE
            ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
            ' * pct_' || geom_tablename ||
            ' ) / NULLIF(SUM(' || denom_tablename || '.' || denom_colname || ' ' ||
            '            * pct_' || geom_tablename || '), 0) ' ||
            ' / (COUNT(*) / COUNT(distinct geomref_' || geom_tablename || ')) '
            END
          -- areaNormalized
          WHEN LOWER(normalization) LIKE 'area%' OR
              (normalization IS NULL AND numer_aggregate ILIKE 'sum')
            THEN CASE
            -- areaNormalized point-in-poly
            WHEN $2 = 'ST_Point' THEN
            ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname ||
            '      / (Nullif(ST_Area(geom_' || geom_tablename || '::Geography), 0)/1000000)) '
            -- areaNormalized polygon interpolation
            -- SUM (numer * (% OBS geom in user geom)) / area of big geom
            ELSE
            --' NULL END '
            ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
            ' * pct_' || geom_tablename ||
            ' ) / (Nullif(ST_Area(cdb_observatory.FIRST(_procgeoms.geom)::Geography), 0) / 1000000) ' ||
            ' / (COUNT(*) / COUNT(distinct geomref_' || geom_tablename || ')) '
            END
          -- median/average measures with universe
          WHEN LOWER(numer_aggregate) IN ('median', 'average') AND
              denom_reltype ILIKE 'universe' AND
              (normalization IS NULL OR LOWER(normalization) LIKE 'pre%')
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
            ' * pct_' || geom_tablename ||
            ' ) / Nullif(SUM(' || denom_tablename || '.' || denom_colname ||
            ' * pct_' || geom_tablename || '), 0) ' ||
            ' / (COUNT(*) / COUNT(distinct geomref_' || geom_tablename || ')) '
            END
          -- prenormalized for summable measures. point or summable only!
          WHEN numer_aggregate ILIKE 'sum' AND
              (normalization IS NULL OR LOWER(normalization) LIKE 'pre%')
            THEN CASE
            -- predenominated point-in-poly
            WHEN $2 = 'ST_Point' THEN
            ' cdb_observatory.FIRST(' || numer_tablename || '.' || numer_colname || ') '
            ELSE
            -- predenominated polygon interpolation
            -- SUM (numer * (% user geom in OBS geom))
            ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
            ' * pct_' || geom_tablename ||
            ' ) / (COUNT(*) / COUNT(distinct geomref_' || geom_tablename || ')) '
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
          '''geomref'', geomref_' || geom_tablename || ', ' ||
          '''value'', ' || 'cdb_observatory.FIRST(geom_' || geom_tablename ||
              ')::TEXT'
          -- code below will return the intersection of the user's geom and the
          -- OBS geom
          --'''value'', ' || 'ST_Union(cdb_observatory.safe_intersection(_geoms.geom, ' || geom_tablename ||
          --    '.' || geom_colname || '))::TEXT'
        ELSE ''
        END || ')', ', ')
        AS colspecs,

        -- geomrefs, used to separate out rows in case we don't want to merge
        -- results by user input IDs
        --
        -- api_method and geom_tablename are interchangeable since when an
        -- api_method is passed, geom_tablename is ignored
        String_Agg(DISTINCT COALESCE(geom_tablename, api_method) || '.' || geom_geomref_colname ||
          ' AS geomref_' || COALESCE(geom_tablename, api_method), ', ') AS geomrefs_alias,

        String_Agg(DISTINCT 'geomref_' || COALESCE(geom_tablename, api_method)
          , ', ') AS geomrefs_noalias,

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
                ARRAY_AGG('cdb_observatory.' || api_method || '(_procgeoms.geom' || COALESCE(', ' ||
                      (SELECT STRING_AGG(REPLACE(val::text, '"', ''''), ', ')
                       FROM (SELECT json_array_elements(api_args) as val) as vals),
                    '') || ')')
              tablenames_ary
            ) tablenames_inner
          ) tablenames_outer) data_tables,

          String_Agg(DISTINCT array_to_string(ARRAY[
            CASE WHEN numer_tablename IS NOT NULL AND geom_tablename IS NOT NULL
                 THEN numer_tablename || '.' || numer_geomref_colname || ' = ' ||
                      '_procgeoms.geomref_' || geom_tablename
                 ELSE NULL END,
            CASE WHEN numer_tablename != denom_tablename
                 THEN numer_tablename || '.' || numer_geomref_colname || ' = ' ||
                      denom_tablename || '.' || denom_geomref_colname
                 ELSE NULL END
            ], ' AND '),
           ' AND ') FILTER (WHERE numer_tablename != denom_tablename OR
                            (numer_tablename IS NOT NULL AND geom_tablename IS NOT NULL)) AS obs_wheres,

          String_Agg(DISTINCT 'ST_Intersects(' || geom_tablename || '.' ||  geom_colname
             || ', _geoms.geom)', ' AND ')
             AS user_wheres
        FROM _meta
        ;
      $query$
    INTO geom_colspecs, geom_tables, data_colspecs, geomrefs_alias,
         geomrefs_noalias, data_tables, obs_wheres, user_wheres
    USING (SELECT ARRAY(SELECT json_array_elements_text(params))::json[]), geomtype;

    RETURN QUERY EXECUTE format($query$
      WITH _raw_geoms AS (SELECT
                     (UNNEST($1)).val as id,
                     (UNNEST($1)).geom AS geom),
      _geoms AS (SELECT id,
        CASE WHEN (ST_NPoints(geom) > 500)
               THEN ST_CollectionExtract(ST_MakeValid(ST_SimplifyVW(geom, 0.0001)), 3)
             ELSE geom END geom
        FROM _raw_geoms),
      _procgeoms AS (SELECT _geoms.id, _geoms.geom %s %s
        FROM _geoms %s
        %s
      )
      SELECT _procgeoms.id::INT, Array_to_JSON(ARRAY[%s]::JSON[])
      FROM _procgeoms %s
           %s
      GROUP BY _procgeoms.id %s
      ORDER BY _procgeoms.id
    $query$, ', ' || NullIf(geomrefs_alias, ''),
             ', ' || NullIf(geom_colspecs, ''),
             ', ' || NullIf(geom_tables, ''),
             'WHERE ' || NullIf( user_wheres, ''),
              data_colspecs, ', ' || NullIf(data_tables, ''),
             'WHERE ' || NULLIF(obs_wheres, ''),
             CASE WHEN merge IS False THEN ', ' || geomrefs_noalias ELSE '' END)
    USING geomvals;
    RETURN;
END;
$$ LANGUAGE plpgsql;


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
$$ LANGUAGE plpgsql;


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
$$ LANGUAGE plpgsql;


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
$$ LANGUAGE plpgsql;

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
$$ LANGUAGE plpgsql;


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
$$ LANGUAGE plpgsql;
