--
--
-- OBS_GetMeasure
--
--

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetMeasureResultMetadata(params json)
RETURNS cdb_observatory.ds_return_metadata
AS $$
DECLARE
  colnames text[]; -- Array to store the name of the measures to be returned
  coltypes text[]; -- Array to store the type of the measures to be returned
  requested_measures text[];
  measure_id text;
BEGIN
  -- By definition, all the measure results for the OBS_GetMeasure API are numeric values
  SELECT ARRAY(SELECT json_array_elements_text(params->'measure_id'))::text[] INTO requested_measures;

  FOREACH measure_id IN ARRAY requested_measures
  LOOP
    SELECT array_append(colnames, measure_id) INTO colnames;
    SELECT array_append(coltypes, 'numeric'::text) INTO coltypes;
  END LOOP;

  RETURN (colnames::text[], coltypes::text[]);
END;
$$ LANGUAGE plpgsql;

--select cdb_observatory._obs_getmeasurequery('public', 'testinput', '{"numer_ids":["us.census.acs.B03002006", "us.census.acs.B03002012"], "denom_ids":["us.census.acs.B01003001", "us.census.acs.B01003001"], "geom_ids": ["us.census.tiger.census_tract", "us.census.tiger.state"], "timespans": ["2006 - 2010", "2010 - 2014"], "geom": "0101000020E610000000000000807A54C0C3CF8DC4FADB4240" }'::json);


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetMeasureQuery(
  table_schema text, table_name text, params json)
RETURNS text
AS $$
DECLARE
  data_query text;

  numer_ids_arr text[];
  denom_ids_arr text[];
  geom_ids_arr text[];
  timespans_arr text[];

  geom Geometry(Geometry, 4326);
  colspecs TEXT;
  tables TEXT;
  obs_wheres TEXT;
  user_wheres TEXT;

  measure_id text;
  measures_list text;
  measures_query text;
  geom_table_name text;
  data_table_name text;
BEGIN
  /*
params: {
  geom: geometry(Geometry, 4326),
  numer_ids: TEXT[],
  denom_ids: TEXT[],
  geom_ids: TEXT[],
  timespans: TEXT[]
}
   */

    -- Deconstruct JSON args
    SELECT params->>'geom' INTO geom;
    SELECT ARRAY(SELECT json_array_elements_text(params->'numer_ids'))::text[] INTO numer_ids_arr;
    SELECT ARRAY(SELECT json_array_elements_text(params->'denom_ids'))::text[] INTO denom_ids_arr;
    SELECT ARRAY(SELECT json_array_elements_text(params->'geom_ids'))::text[] INTO geom_ids_arr;
    SELECT ARRAY(SELECT json_array_elements_text(params->'timespans'))::text[] INTO timespans_arr;

    EXECUTE
      $query$
        WITH _filters AS (SELECT
          unnest($1) numer_id,
          unnest($2) denom_id,
          unnest($3) geom_id,
          unnest($4) timespan
        )
        SELECT
           String_Agg(numer_tablename || '.' || numer_colname ||
                      '/NullIf(' || denom_tablename || '.' || denom_colname || ', 0)' || numer_colname, ', ') AS colspecs,
           (SELECT String_Agg(tablename, ', ') FROM (SELECT JSONB_Object_Keys(JSONB_Object(
              Array_Cat(Array_Agg('observatory.' || numer_tablename),
                Array_Cat(Array_Agg('observatory.' || geom_tablename),
                          Array_Agg('observatory.' || denom_tablename))),
              Array_Cat(Array_Agg(numer_tablename),
                Array_Cat(Array_Agg(geom_tablename),
                          Array_Agg(denom_tablename)))
            )) tablename) bar) tablenames,
           String_Agg(numer_tablename || '.' || numer_geomref_colname || ' = ' || denom_tablename || '.' || denom_geomref_colname ||
            ' AND ' || denom_tablename || '.' || denom_geomref_colname || ' = ' || geom_tablename || '.' || geom_geomref_colname,
            ' AND ') AS obs_wheres,
           String_Agg('ST_Intersects(' || geom_tablename || '.' ||  geom_colname
              || ', ' || $5 || '.' || $6 || '.the_geom)', ' AND ')
              AS user_wheres
        FROM observatory.obs_meta
        WHERE (numer_id, coalesce(denom_id, ''), geom_id, numer_timespan)
           IN (SELECT numer_id, denom_id, geom_id, timespan FROM _filters)
          --AND ST_Overlaps($7, the_geom)
        ;
      $query$
    INTO colspecs, tables, obs_wheres, user_wheres
    USING numer_ids_arr, denom_ids_arr, geom_ids_arr, timespans_arr, table_schema, table_name, geom;

    data_query := format($query$
      SELECT cartodb_id, %s FROM %s, %s.%s WHERE %s AND %s
    $query$, colspecs, tables, table_schema, table_name, obs_wheres, user_wheres);
    RETURN data_query;

    --FOREACH measure_id IN ARRAY measure_ids_arr
    --LOOP
    --  -- Build query to compute each value and normalize
    --  -- Assumes the default normalization method, the normalize parameter given in the JSON
    --  -- should be checked in order to build the final query
    --  SELECT measures_query || ' sum(' || measure_id || '/fraction)::numeric as ' || measure_id || ', ' INTO measures_query;
    --END LOOP;

    -- Data query should select the measures and the cartodb_id of the user table, in that order.
    --data_query := '(WITH _areas AS(SELECT ST_Area(a.the_geom::geography)'
    --    || '/ (1000 * 1000) as fraction, a.geoid, b.cartodb_id FROM '
    --    || geom_table_name || ' as a, '
    --    || table_schema || '.' || table_name || ' AS b '
    --    || 'WHERE b.the_geom && a.the_geom ), values AS (SELECT geoid, '
    --    || measures_list
    --    || ' FROM ' || data_table_name || ' ) '
    --    || 'SELECT '
    --    || measures_query
    --    || ' cartodb_id::int FROM _areas, values '
    --    || 'WHERE values.geoid = _areas.geoid GROUP BY cartodb_id);';
    --RETURN data_query;
END;
$$ LANGUAGE plpgsql;
