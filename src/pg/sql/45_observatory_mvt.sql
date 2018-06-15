CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetTileBounds(z INTEGER, x INTEGER, y INTEGER)
RETURNS NUMERIC[] AS $$
import math
def tile2lnglat(z, x, y):
    n = 2.0 ** z
    y = (1 << z) - y - 1

    lon = x / n * 360.0 - 180.0
    lat_rad = math.atan(math.sinh(math.pi * (1 - 2 * y / n)))
    lat = - math.degrees(lat_rad)

    return lon, lat

lon0, lat0 = tile2lnglat(z, x, y)
lon1, lat1 = tile2lnglat(z, x+1, y-1)

return [lon0, lat0, lon1, lat1]
$$ LANGUAGE plpythonu;

DROP FUNCTION IF EXISTS cdb_observatory.OBS_GetMVT(z INTEGER, x INTEGER, y INTEGER, params JSONB);
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMVT(z INTEGER, x INTEGER, y INTEGER,
params JSON DEFAULT NULL,
extent INTEGER DEFAULT 4096, buf INTEGER DEFAULT 256, clip_geom BOOLEAN DEFAULT True)
RETURNS TABLE (mvt BYTEA)
AS $$
DECLARE
  bounds NUMERIC[];
  geom GEOMETRY;
  ext BOX2D;
  meta JSON;

  procgeom_clauses TEXT;
  val_clauses TEXT;
  json_clause TEXT;
BEGIN
  bounds := cdb_observatory.OBS_GetTileBounds(z, x, y);
  geom := ST_MakeEnvelope(bounds[1], bounds[2], bounds[3], bounds[4], 4326);
  ext := ST_MakeBox2D(ST_Point(bounds[1], bounds[2]), ST_Point(bounds[3], bounds[4]));
  meta := cdb_observatory.obs_getmeta(geom, params::json, 1::integer, 1::integer, 1::integer);

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
      '_procgeoms_' || Coalesce(left(geom_tablename,40) || '_' || geom_geomref_colname, api_method) || ' AS (' ||
          'SELECT ' ||
            'st_intersection(' || geom_tablename || '.' || geom_colname || ', _geoms.geom) AS geom, ' ||
            'ST_AsMVTGeom(st_intersection(' || geom_tablename || '.' || geom_colname || ', _geoms.geom), $2, $3, $4, $5) AS mvtgeom, ' ||
            geom_tablename || '.' || geom_geomref_colname || ' AS geomref, ' ||
            'CASE WHEN ST_Within(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ')
                    THEN ST_Area(_geoms.geom) / Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '), 0)
                    WHEN ST_Within(' || geom_tablename || '.' || geom_colname || ', _geoms.geom)
                    THEN 1
                    ELSE ST_Area(cdb_observatory.safe_intersection(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ')) /
                      Nullif(ST_Area(' || geom_tablename || '.' || geom_colname || '), 0)
              END pct_obs' || '
          FROM _geoms, observatory.' || geom_tablename || '
          WHERE ST_Intersects(_geoms.geom, ' || geom_tablename || '.' || geom_colname || ')'
          || ')'
      AS procgeom_clause
    FROM _meta
    GROUP BY api_method, geom_tablename, geom_geomref_colname, geom_colname
  ),

  -- Generate val clauses.
  -- These perform interpolations or other necessary calculations to
  -- provide values according to users geometries.
  _val_clauses AS (
    SELECT
      '_vals_' || Coalesce(left(geom_tablename,40) || '_' || geom_geomref_colname, api_method) || ' AS (
        SELECT _procgeoms.geomref, _procgeoms.mvtgeom, ' ||
          String_Agg('json_build_object(' || CASE
            -- api-delivered values
            WHEN api_method IS NOT NULL THEN
            '''' || numer_colname || ''', ' ||
              'ARRAY_AGG( ' ||
                api_method || '.' || numer_colname || ')::' || numer_type || '[]'
            -- numeric internal values
            WHEN cdb_observatory.isnumeric(numer_type) THEN
            '''' || numer_colname || ''', ' || CASE
              -- denominated
              WHEN LOWER(normalization) LIKE 'denom%'
                THEN CASE
                WHEN denom_tablename IS NULL THEN ' NULL '
                -- denominated polygon interpolation
                ELSE
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                ' * _procgeoms.pct_obs ' ||
                ' ) / NULLIF(SUM(' || denom_tablename || '.' || denom_colname || ' ' ||
                '            * _procgeoms.pct_obs), 0) AS NUMERIC), 4) '
                END
              -- areaNormalized
              WHEN LOWER(normalization) LIKE 'area%'
                THEN
                -- areaNormalized polygon interpolation
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                ' * _procgeoms.pct_obs' ||
                ' ) / (Nullif(ST_Area(cdb_observatory.FIRST(_procgeoms.geom)::Geography), 0) / 1000000) AS NUMERIC), 4) '
              -- median/average measures with universe
              WHEN LOWER(numer_aggregate) IN ('median', 'average') AND
                  denom_reltype ILIKE 'universe' AND LOWER(normalization) LIKE 'pre%'
                THEN
                -- predenominated polygon interpolation weighted by universe
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname ||
                ' * ' || denom_tablename || '.' || denom_colname ||
                ' * _procgeoms.pct_obs ' ||
                ' ) / Nullif(SUM(' || denom_tablename || '.' || denom_colname ||
                ' * _procgeoms.pct_obs ' || '), 0)AS NUMERIC), 4) '
              -- prenormalized for summable measures. point or summable only!
              WHEN numer_aggregate ILIKE 'sum' AND LOWER(normalization) LIKE 'pre%'
                THEN
                -- predenominated polygon interpolation
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                ' * _procgeoms.pct_obs) AS NUMERIC), 4) '
              -- Everything else. Point only!
              ELSE
                ' cdb_observatory._OBS_RaiseNotice(''Cannot perform calculation over polygon for ' ||
                    numer_id || '/' || coalesce(denom_id, '') || '/' || geom_id || '/' || numer_timespan || ''')::Numeric '
              END || '::' || numer_type

            -- categorical/text
            WHEN LOWER(numer_type) LIKE 'text' THEN
              '''' || numer_colname || ''', ' || 'MODE() WITHIN GROUP (ORDER BY ' || numer_tablename || '.' || numer_colname || ') '
              -- geometry
            WHEN numer_id IS NULL THEN
              '''geomref'', _procgeoms.geomref, ' ||
              '''' || numer_colname || ''', ' || 'cdb_observatory.FIRST(_procgeoms.mvtgeom)::TEXT'
            ELSE ''
            END
          || ') val_' || colid, ', ')
        || '
        FROM _procgeoms_' || Coalesce(left(geom_tablename,40) || '_' || geom_geomref_colname, api_method) || ' _procgeoms ' ||
          Coalesce(String_Agg(DISTINCT
              Coalesce('LEFT JOIN observatory.' || numer_tablename || ' ON _procgeoms.geomref = observatory.' || numer_tablename || '.' || numer_geomref_colname,
                ', LATERAL (SELECT * FROM cdb_observatory.' || api_method || '(_procgeoms.mvtgeom' || Coalesce(', ' ||
                    (SELECT STRING_AGG(REPLACE(val::text, '"', ''''), ', ')
                      FROM (SELECT JSON_Array_Elements(api_args) as val) as vals),
                    '') || ')) AS ' || api_method)
          , ' '), '') ||
                                E'\n GROUP BY _procgeoms.geomref, _procgeoms.mvtgeom
                                    ORDER BY _procgeoms.geomref'
      || ')'
      AS val_clause,
      '_vals_' || Coalesce(left(geom_tablename, 40) || '_' || geom_geomref_colname, api_method) AS cte_name
    FROM _meta
    GROUP BY geom_tablename, geom_geomref_colname, geom_colname, api_method
  ),

  -- Generate clauses necessary to join together val_clauses
  _val_joins AS (
    SELECT String_Agg(a.cte_name || '.geomref = ' || b.cte_name || '.geomref ', ' AND ') val_joins
    FROM _val_clauses a, _val_clauses b
    WHERE a.cte_name != b.cte_name
      AND a.cte_name < b.cte_name
  ),

  -- Generate JSON clause.  This puts together vals from val_clauses
  _json_clause AS (SELECT
    'SELECT ST_AsMVT(q, ''data'', $3) FROM (' ||
    'SELECT ' || cdb_observatory.FIRST(cte_name) || '.mvtgeom geom,
        replace(' || (SELECT String_Agg('val_' || colid, '::TEXT || ') FROM _meta) || ', ''}{'', '', '')::jsonb
      FROM ' || String_Agg(cte_name, ', ') ||
    ' WHERE ST_Area(' || cdb_observatory.FIRST(cte_name) || '.mvtgeom) > 0' ||
    Coalesce(' AND ' || val_joins, ') q')
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
  USING meta;

  IF procgeom_clauses IS NULL OR val_clauses IS NULL OR json_clause IS NULL THEN
    RETURN;
  END IF;

  /* Execute query */
  RETURN QUERY EXECUTE format($query$
    WITH _geoms AS (%s),
    -- procgeom_clauses
    %s,

    -- val_clauses
    %s

    -- json_clause
    %s
  $query$, 'SELECT $1::geometry as geom',
            String_Agg(procgeom_clauses, E',\n       '),
            String_Agg(val_clauses, E',\n       '),
            json_clause)
  USING geom, ext, extent, buf, clip_geom;
  RETURN;

END
$$ LANGUAGE plpgsql;

DROP TABLE IF EXISTS cdb_observatory.OBS_CachedMeta;
CREATE TABLE cdb_observatory.OBS_CachedMeta(
  z INTEGER,
  parameters TEXT,
  num_timespans INTEGER,
  num_scores INTEGER,
  num_target_geoms INTEGER,
  result JSON,
  PRIMARY KEY (z, parameters, num_timespans, num_scores, num_target_geoms)
);

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_RetrieveMeta(
  zoom INTEGER,
  geom geometry(Geometry, 4326),
  getmeta_parameters JSON,
  num_timespan_options INTEGER DEFAULT NULL,
  num_score_options INTEGER DEFAULT NULL,
  target_geoms INTEGER DEFAULT NULL)
RETURNS JSON
AS $$
DECLARE
  result JSON;
BEGIN
  SELECT c.result
    INTO result
    FROM cdb_observatory.OBS_CachedMeta c
   WHERE c.z = zoom
     AND c.parameters = getmeta_parameters::TEXT
     AND c.num_timespans = num_timespan_options
     AND c.num_scores = num_score_options
     AND c.num_target_geoms = target_geoms;

  IF result IS NULL THEN
    result := cdb_observatory.obs_getmeta(geom, getmeta_parameters, num_timespan_options, num_score_options, target_geoms);

    INSERT INTO cdb_observatory.OBS_CachedMeta(z, parameters, num_timespans, num_scores, num_target_geoms, result)
    SELECT zoom, getmeta_parameters::TEXT, num_timespan_options, num_score_options, target_geoms, result
    ON CONFLICT (z, parameters, num_timespans, num_scores, num_target_geoms) 
    DO UPDATE SET result = EXCLUDED.result;
  END IF;

  return result;
END
$$ LANGUAGE plpgsql PARALLEL RESTRICTED;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_DecodeCategory(category TEXT)
RETURNS TEXT
AS $$
categories = {
    'NEP': 'non eating places',
	  'EP': 'eating places',
	  'APP': 'apparel',
	  'SB': 'small business',
	  'TR': 'total retail',
}
return categories.get(category)
$$ LANGUAGE plpythonu;

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMCDOMVT(
  z INTEGER, x INTEGER, y INTEGER,
  geography_level TEXT,
  do_measurements TEXT[],
  mc_measurements TEXT[],
  mc_categories TEXT[] DEFAULT ARRAY['TR']::TEXT[],
  mc_months TEXT[] DEFAULT ARRAY['2018-02-01']::TEXT[],
  use_meta_cache BOOLEAN DEFAULT True,
  shoreline_clipped BOOLEAN DEFAULT True,
  optimize_clipping BOOLEAN DEFAULT False,
  simplify_geometries BOOLEAN DEFAULT False,
  area_normalized BOOLEAN DEFAULT False,
  extent INTEGER DEFAULT 4096,
  buf INTEGER DEFAULT 256,
  clip_geom BOOLEAN DEFAULT True)
RETURNS TABLE (
  mvtgeom GEOMETRY,
  mvtdata JSONB
)
AS $$
DECLARE
  state_geoname CONSTANT TEXT DEFAULT 'us.census.tiger.state';
  county_geoname CONSTANT TEXT DEFAULT 'us.census.tiger.county';
  tract_geoname CONSTANT TEXT DEFAULT 'us.census.tiger.census_tract';
  blockgroup_geoname CONSTANT TEXT DEFAULT 'us.census.tiger.block_group';
  block_geoname CONSTANT TEXT DEFAULT 'us.census.tiger.block';

  mc_schema CONSTANT TEXT DEFAULT 'us.mastercard';
  mc_geoid CONSTANT TEXT DEFAULT 'region_id';
  mc_category_column CONSTANT TEXT DEFAULT 'category';
  mc_month_column CONSTANT TEXT DEFAULT 'month';
  mc_table TEXT;
  mc_category TEXT;
  mc_table_categories TEXT;
  mc_month TEXT;
  mc_month_slug TEXT;

  bounds NUMERIC[];
  geom GEOMETRY;
  ext BOX2D;

  measurement TEXT;
  getmeta_parameters TEXT;
  meta JSON;
  mc_geography_level TEXT;

  numer_tablename_do TEXT DEFAULT '';
  numer_tablenames_do TEXT[] DEFAULT ARRAY['']::TEXT[];
  numer_tablenames_do_outer TEXT DEFAULT '';
  numer_tablenames_mc TEXT;
  numer_colnames_do TEXT DEFAULT '';
  numer_colnames_do_qualified TEXT DEFAULT '';
  numer_colnames_do_normalized TEXT DEFAULT '';
  numer_colnames_mc TEXT;
  numer_colnames_mc_current TEXT;
  numer_colnames_mc_qualified TEXT;
  numer_colnames_mc_qualified_current TEXT;
  numer_colnames_mc_normalized TEXT;
  numer_colnames_mc_normalized_current TEXT;
  geom_tablenames TEXT;
  geom_colnames TEXT;
  geom_geomref_colnames TEXT;
  geom_geomref_colnames_qualified TEXT;
  geom_relations_do TEXT[] DEFAULT ARRAY['']::TEXT[];
  geom_relations_mc TEXT;
  geom_mc_outerjoins TEXT;

  simplification_tolerance NUMERIC DEFAULT 0;
  area_normalization TEXT DEFAULT '';
  i INTEGER DEFAULT 0;
  clipped TEXT default '';
BEGIN
  IF area_normalized THEN
    area_normalization := '/area_ratio';
  END IF;

  IF shoreline_clipped THEN
    clipped := '_clipped';
  END IF;

  CASE
    WHEN geography_level = state_geoname THEN
      simplification_tolerance := 0.1;
      IF optimize_clipping THEN
        clipped := '';
      END IF;
    WHEN geography_level = county_geoname THEN
      simplification_tolerance := 0.01;
    WHEN geography_level = tract_geoname THEN
      simplification_tolerance := 0.001;
    WHEN geography_level = blockgroup_geoname THEN
      simplification_tolerance := 0.0001;
    WHEN geography_level = block_geoname THEN
      simplification_tolerance := 0.0001;
    ELSE
      RETURN;
  END CASE;

  IF NOT simplify_geometries THEN
    simplification_tolerance := 0;
  END IF;

  bounds := cdb_observatory.OBS_GetTileBounds(z, x, y);
  geom := ST_MakeEnvelope(bounds[1], bounds[2], bounds[3], bounds[4], 4326);
  ext := ST_MakeBox2D(ST_Transform(ST_SetSRID(ST_Point(bounds[1], bounds[2]), 4326), 3857),
                      ST_Transform(ST_SetSRID(ST_Point(bounds[3], bounds[4]), 4326), 3857));

  ---------DO---------
  getmeta_parameters := '[ ';
  FOREACH measurement IN ARRAY do_measurements LOOP
    getmeta_parameters := getmeta_parameters || '{"numer_id":"' || measurement || '","geom_id":"' || geography_level || clipped ||'"},';
  END LOOP;
  getmeta_parameters := substring(getmeta_parameters from 1 for length(getmeta_parameters) - 1) || ' ]';

  IF use_meta_cache THEN
    meta := cdb_observatory.OBS_RetrieveMeta(z, geom, getmeta_parameters::json, 1::integer, 1::integer, 1::integer);
  ELSE
    meta := cdb_observatory.obs_getmeta(geom, getmeta_parameters::json, 1::integer, 1::integer, 1::integer);
  END IF;

  IF meta IS NOT NULL THEN
    SELECT  array_agg(distinct 'observatory.'||numer_tablename) numer_tablenames,
            string_agg(distinct numer_colname, ',')||',' numer_colnames,
            string_agg(distinct numer_tablename||'.'||numer_colname, ',')||',' numer_colnames_qualified,
            string_agg(distinct numer_colname||area_normalization||' '||numer_colname, ',')||',' numer_colnames_normalized,
            (array_agg(distinct 'observatory.'||geom_tablename))[1] geom_tablenames,
            (array_agg(distinct geom_colname))[1] geom_colnames,
            (array_agg(distinct geom_geomref_colname))[1] geom_geomref_colnames,
            (array_agg(distinct geom_tablename||'.'||geom_geomref_colname))[1] geom_geomref_colnames_qualified,
            array_agg(distinct numer_tablename||'.'||numer_geomref_colname||'='||geom_tablename||'.'||geom_geomref_colname) geom_relations
      INTO numer_tablenames_do, numer_colnames_do, numer_colnames_do_qualified, numer_colnames_do_normalized, geom_tablenames, geom_colnames,
          geom_geomref_colnames, geom_geomref_colnames_qualified, geom_relations_do
      FROM json_to_recordset(meta)
        AS x(id TEXT, numer_id TEXT, numer_aggregate TEXT, numer_colname TEXT, numer_geomref_colname TEXT, numer_tablename TEXT,
            numer_type TEXT, denom_id TEXT, denom_aggregate TEXT, denom_colname TEXT, denom_geomref_colname TEXT, denom_tablename TEXT,
            denom_type TEXT, denom_reltype TEXT, geom_id TEXT, geom_colname TEXT, geom_geomref_colname TEXT, geom_tablename TEXT,
            geom_type TEXT, numer_timespan TEXT, geom_timespan TEXT, normalization TEXT, api_method TEXT, api_args JSON);

    IF numer_tablenames_do IS NULL OR numer_colnames_do IS NULL OR numer_colnames_do_qualified IS NULL OR numer_colnames_do_normalized IS NULL
      OR geom_tablenames IS NULL OR geom_colnames IS NULL OR geom_geomref_colnames IS NULL OR geom_geomref_colnames_qualified IS NULL
      OR geom_relations_do IS NULL THEN
      RETURN;
    END IF;

    i := 0;
    FOREACH numer_tablename_do IN ARRAY numer_tablenames_do LOOP
      i := i + 1;
      numer_tablenames_do_outer := numer_tablenames_do_outer || 'LEFT OUTER JOIN ' || numer_tablename_do || ' ON ' || geom_relations_do[i] || ' ';
    END LOOP;
  ELSE
    getmeta_parameters := '[{"geom_id":"' || geography_level || clipped ||'"}]';
    meta := cdb_observatory.obs_getmeta(geom, getmeta_parameters::json, 1::integer, 1::integer, 1::integer);

    IF meta IS NULL THEN
      RETURN;
    END IF;

    SELECT  (array_agg(distinct 'observatory.'||geom_tablename))[1] geom_tablenames,
            (array_agg(distinct geom_colname))[1] geom_colnames,
            (array_agg(distinct geom_geomref_colname))[1] geom_geomref_colnames,
            (array_agg(distinct geom_tablename||'.'||geom_geomref_colname))[1] geom_geomref_colnames_qualified
      FROM json_to_recordset(meta)
      INTO geom_tablenames, geom_colnames, geom_geomref_colnames, geom_geomref_colnames_qualified
        AS x(id TEXT, numer_id TEXT, numer_aggregate TEXT, numer_colname TEXT, numer_geomref_colname TEXT, numer_tablename TEXT,
            numer_type TEXT, denom_id TEXT, denom_aggregate TEXT, denom_colname TEXT, denom_geomref_colname TEXT, denom_tablename TEXT,
            denom_type TEXT, denom_reltype TEXT, geom_id TEXT, geom_colname TEXT, geom_geomref_colname TEXT, geom_tablename TEXT,
            geom_type TEXT, numer_timespan TEXT, geom_timespan TEXT, normalization TEXT, api_method TEXT, api_args JSON);
  END IF;

  ---------MC---------
  IF geography_level = 'us.census.tiger.census_tract' THEN
    mc_geography_level := 'tract';
  ELSE
    mc_geography_level := (string_to_array(geography_level, '.'))[array_length(string_to_array(geography_level, '.'), 1)];
  END IF;

  SELECT tablename from pg_tables
    INTO mc_table
   WHERE schemaname = mc_schema
     AND tablename LIKE '%'||mc_geography_level||'%';

  FOREACH mc_category IN ARRAY mc_categories LOOP
    FOREACH mc_month IN ARRAY mc_months LOOP
      mc_month_slug := replace(mc_month, '-', '');

      SELECT string_agg(column_name||'_'||mc_category||'_'||mc_month_slug, ','),
            string_agg(mc_table||'_'||mc_category||'_'||mc_month_slug||'.'||column_name||' '||column_name||'_'||mc_category||'_'||mc_month_slug, ','),
            string_agg(distinct column_name||'_'||mc_category||'_'||mc_month_slug||area_normalization||' '||column_name||'_'||mc_category||'_'||mc_month_slug, ',')
        INTO numer_colnames_mc_current, numer_colnames_mc_qualified_current, numer_colnames_mc_normalized_current
        FROM information_schema.columns
      WHERE table_schema = mc_schema
        AND table_name = mc_table
        AND column_name = ANY(mc_measurements);

      IF numer_colnames_mc_current IS NULL OR numer_colnames_mc_qualified_current IS NULL OR numer_colnames_mc_normalized_current IS NULL THEN
        RETURN;
      END IF;

      numer_colnames_mc := coalesce(numer_colnames_mc, '')||numer_colnames_mc_current||',';
      numer_colnames_mc_qualified := coalesce(numer_colnames_mc_qualified, '')||numer_colnames_mc_qualified_current||',';
      numer_colnames_mc_normalized := coalesce(numer_colnames_mc_normalized, '')||numer_colnames_mc_normalized_current||',';

      numer_tablenames_mc := '"'||mc_schema||'".'||mc_table||' '||mc_table||'_'||mc_category||'_'||mc_month_slug;
      geom_relations_mc := mc_table||'_'||mc_category||'_'||mc_month_slug||'.'||mc_geoid||'='||geom_geomref_colnames_qualified;
      mc_table_categories := mc_table||'_'||mc_category||'_'||mc_month_slug||'.'||mc_category_column||'='''||cdb_observatory.OBS_DecodeCategory(mc_category)||''''||
                             ' AND '||mc_table||'_'||mc_category||'_'||mc_month_slug||'.'||mc_month_column||'='''||mc_month||'''';

      geom_mc_outerjoins := coalesce(geom_mc_outerjoins, '')||' LEFT OUTER JOIN '||numer_tablenames_mc||' ON '||geom_relations_mc||' AND '||mc_table_categories;
    END LOOP;
  END LOOP;

  ---------Query build and execution---------
  RETURN QUERY EXECUTE format(
    $query$
    SELECT  mvtgeom,
            (select row_to_json(_)::jsonb from (select id, %9$s %3$s area_ratio) as _) as mvtdata
          FROM (
      SELECT ST_AsMVTGeom(ST_Transform(the_geom, 3857), $1, $2, $3, $4) AS mvtgeom, %8$s as id, %6$s %7$s area_ratio FROM (
        SELECT  %1$s the_geom, %8$s, %2$s %10$s
                CASE  WHEN ST_Within($5, %1$s)
                        THEN ST_Area($5) / Nullif(ST_Area(%1$s), 0)
                      WHEN ST_Within(%1$s, $5)
                        THEN 1
                      ELSE ST_Area(cdb_observatory.safe_intersection(st_simplifyvw(%1$s, $6), $5)) / Nullif(ST_Area(%1$s), 0)
                END area_ratio
          FROM %5$s
               %4$s
               %11$s
        WHERE st_intersects(%1$s, $5)
      ) p
    ) q
    $query$,
    geom_colnames, numer_colnames_do_qualified, numer_colnames_mc, numer_tablenames_do_outer, geom_tablenames, numer_colnames_do_normalized,
    numer_colnames_mc_normalized, geom_geomref_colnames, numer_colnames_do, numer_colnames_mc_qualified, geom_mc_outerjoins)
  USING ext, extent, buf, clip_geom, geom, simplification_tolerance
  RETURN;
END
$$ LANGUAGE plpgsql PARALLEL RESTRICTED;
