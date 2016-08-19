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

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetMeasureQuery(table_schema text, table_name text, params json)
RETURNS text
AS $$
DECLARE
  data_query text;
  measure_ids_arr text[];
  measure_id text;
  measures_list text;
  measures_query text;
  normalize text;
  boundary_id text;
  time_span text;
  geom_table_name text;
  data_table_name text;
BEGIN
    measures_query := '';
    -- SELECT table_name from obs_meta WHERE boundary_id = {bound} AND [...] INTO geom_table_name
    geom_table_name := 'observatory.obs_c6fb99c47d61289fbb8e561ff7773799d3fcc308';
    -- SELECT table_name from obs_meta WHERE time_span = {time} AND [...] INTO data_table_name
    data_table_name := 'observatory.obs_1a098da56badf5f32e336002b0a81708c40d29cd';

    -- Get measure_ids array from JSON
    SELECT ARRAY(SELECT json_array_elements_text(params->'measure_id'))::text[] INTO measure_ids_arr;

    -- Get a comma-separated list of measures ("total_pop, over_16_pop") to be used in SELECTs
    SELECT array_to_string(measure_ids_arr, ',') INTO measures_list;

    FOREACH measure_id IN ARRAY measure_ids_arr
    LOOP
      -- Build query to compute each value and normalize
      -- Assumes the default normalization method, the normalize parameter given in the JSON
      -- should be checked in order to build the final query
      SELECT measures_query || ' sum(' || measure_id || '/fraction)::numeric as ' || measure_id || ', ' INTO measures_query;
    END LOOP;

    -- Data query should select the measures and the cartodb_id of the user table, in that order.
    data_query := '(WITH _areas AS(SELECT ST_Area(a.the_geom::geography)'
        || '/ (1000 * 1000) as fraction, a.geoid, b.cartodb_id FROM '
        || geom_table_name || ' as a, '
        || table_schema || '.' || table_name || ' AS b '
        || 'WHERE b.the_geom && a.the_geom ), values AS (SELECT geoid, '
        || measures_list
        || ' FROM ' || data_table_name || ' ) '
        || 'SELECT '
        || measures_query
        || ' cartodb_id::int FROM _areas, values '
        || 'WHERE values.geoid = _areas.geoid GROUP BY cartodb_id);';
    RETURN data_query;
END;
$$ LANGUAGE plpgsql;

