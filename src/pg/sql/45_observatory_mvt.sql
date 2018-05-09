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
lon1, lat1 = tile2lnglat(z, x+1, y+1)

return [lon0, lat0, lon1, lat1]
$$ LANGUAGE plpythonu;

DROP FUNCTION IF EXISTS cdb_observatory.OBS_GetMVT(z INTEGER, x INTEGER, y INTEGER, params JSONB);
CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMVT(z INTEGER, x INTEGER, y INTEGER,
params JSON DEFAULT NULL,
extent INTEGER DEFAULT 4096, buf INTEGER DEFAULT 256, clip_geom BOOLEAN DEFAULT True)
RETURNS TABLE (mvt BYTEA)
AS $$
DECLARE
  tolerance NUMERIC DEFAULT 100;
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
          --|| ' AND ST_Area(st_intersection(' || geom_tablename || '.' |QUERY| geom_colname || ', _geoms.geom)) > ST_Area($1) / $6 '
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
                -- denominated polygon interpolation
                -- SUM (numer * (% OBS geom in user geom)) / SUM (denom * (% OBS geom in user geom))
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
                -- SUM (numer * (% OBS geom in user geom)) / area of big geom
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                ' * _procgeoms.pct_obs' ||
                ' ) / (Nullif(ST_Area(cdb_observatory.FIRST(_procgeoms.geom)::Geography), 0) / 1000000) AS NUMERIC), 4) '
              -- median/average measures with universe
              WHEN LOWER(numer_aggregate) IN ('median', 'average') AND
                  denom_reltype ILIKE 'universe' AND LOWER(normalization) LIKE 'pre%'
                THEN
                -- predenominated polygon interpolation weighted by universe
                -- SUM (numer * denom * (% user geom in OBS geom)) / SUM (denom * (% user geom in OBS geom))
                --     (10 * 1000 * 1) / (1000 * 1) = 10
                --     (10 * 1000 * 1 + 50 * 10 * 1) / (1000 + 10) = 10500 / 10000 = 10.5
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname ||
                ' * ' || denom_tablename || '.' || denom_colname ||
                ' * _procgeoms.pct_obs ' ||
                ' ) / Nullif(SUM(' || denom_tablename || '.' || denom_colname ||
                ' * _procgeoms.pct_obs ' || '), 0)AS NUMERIC), 4) '
              -- prenormalized for summable measures. point or summable only!
              WHEN numer_aggregate ILIKE 'sum' AND LOWER(normalization) LIKE 'pre%'
                THEN
                -- predenominated polygon interpolation
                -- SUM (numer * (% user geom in OBS geom))
                ' ROUND(CAST(SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
                ' * _procgeoms.pct_obs) AS NUMERIC), 4) '
              -- Everything else. Point only!
              ELSE
                ' cdb_observatory._OBS_RaiseNotice(''Cannot perform calculation over polygon for ' ||
                    numer_id || '/' || coalesce(denom_id, '') || '/' || geom_id || '/' || numer_timespan || ''')::Numeric '
              END || '::' || numer_type

            -- categorical/text
            WHEN LOWER(numer_type) LIKE 'text' THEN
              '''value'', ' || 'MODE() WITHIN GROUP (ORDER BY ' || numer_tablename || '.' || numer_colname || ') '
              -- geometry
            WHEN numer_id IS NULL THEN
              '''geomref'', _procgeoms.geomref, ' ||
              '''value'', ' || 'cdb_observatory.FIRST(_procgeoms.mvtgeom)::TEXT'
              -- code below will return the intersection of the user's geom and the
              -- OBS geom
              --'''value'', ' || 'ST_Union(cdb_observatory.safe_intersection(_geoms.geom, ' || geom_tablename ||
              --    '.' || geom_colname || '))::TEXT'
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
        to_JSONB(' || (SELECT String_Agg('val_' || colid, ', ') FROM _meta) || ')
      FROM ' || String_Agg(cte_name, ', ') ||
    ' WHERE ST_Area(' || cdb_observatory.FIRST(cte_name) || '.mvtgeom) / ST_Perimeter(' || cdb_observatory.FIRST(cte_name) || '.mvtgeom)' || ' > 0.001' ||
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
  USING geom, ext, extent, buf, clip_geom, tolerance;
  RETURN;

END
$$ LANGUAGE plpgsql;
