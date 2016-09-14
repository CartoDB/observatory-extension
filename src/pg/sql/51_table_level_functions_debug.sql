
CREATE OR REPLACE FUNCTION cdb_observatory._DEBUGResultMetadata(params json)
RETURNS cdb_observatory.ds_return_metadata
AS $$
DECLARE
  colnames text[]; -- Array to store the name of the measures to be returned
  coltypes text[]; -- Array to store the type of the measures to be returned
  requested_measures text[];
  measure_id text;
  type_f text;
BEGIN
  SELECT params->'function' INTO type_f;
  RAISE NOTICE 'param %', type_f;
  IF type_f ilike '%measure%' THEN

    -- By definition, all the measure results for the OBS_GetMeasure API are numeric values
    SELECT ARRAY(SELECT json_array_elements_text(params->'measure_id'))::text[] INTO requested_measures;

    FOREACH measure_id IN ARRAY requested_measures
    LOOP
      SELECT array_append(colnames, measure_id) INTO colnames;
      SELECT array_append(coltypes, 'numeric'::text) INTO coltypes;
    END LOOP;
  ELSIF type_f ILIKE '%Segmentize%' THEN
    colnames := Array['segments'];
    coltypes := Array['geometry'];
  ELSIF type_f ILIKE '%ConvexHull%' THEN
    colnames := Array['convexresult'];
    coltypes := Array['geometry'];
  ELSIF type_f ILIKE '%CentroidSegmentize%' THEN
    colnames := Array['segments'];
    coltypes := Array['geometry'];
  ELSIF type_f ILIKE '%Voronoi%' THEN
    colnames := Array['voronoi_cells'];
    coltypes := Array['geometry collection'];
  ELSIF type_f ILIKE '%Moran%' THEN
    colnames := Array['moran', 'quads', 'significance', 'vals'];
    coltypes := Array['numeric', 'text', 'numeric' , 'numeric'];
  ELSE
    RAISE 'This function is not supported yet: %', type_f;
  END IF;

  RETURN (colnames::text[], coltypes::text[]);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory._DEBUGQuery(table_schema text, table_name text, params json)
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
  max_segment_length numeric;
  type_f text;
BEGIN
  SELECT params->'function' INTO type_f;

  data_query := '';

   IF type_f ilike '%measure%' THEN
      data_query := 'SELECT total_pop, cartodb_id FROM ' || table_schema || '.' || table_name || ';';
   IF type_f ILIKE 'GetMeasure' THEN
        SELECT translate(params::json->>'measure_id','[]', '{}')::text[] INTO tag_name;
        SELECT array_to_string(tag_name, ',') INTO tags_list;
        tags_query := '';

        FOREACH tag IN ARRAY tag_name
        LOOP
          SELECT tags_query || ' sum(' || tag || '/fraction)::double precision as ' || tag || ', ' INTO tags_query;

        END LOOP;

        -- Simple mock, there should be real logic in here.
        data_query := '(WITH _areas AS(SELECT ST_Area(a.the_geom::geography)'
            || '/ (1000 * 1000) as fraction, a.geoid, b.cartodb_id FROM '
            || 'observatory.obs_c6fb99c47d61289fbb8e561ff7773799d3fcc308 as a, '
            || table_schema || '.' || table_name || ' AS b '
            || 'WHERE b.the_geom && a.the_geom ), values AS (SELECT geoid, '
            || tags_list
            || ' FROM observatory.obs_1a098da56badf5f32e336002b0a81708c40d29cd ) '
            || 'SELECT '
            || tags_query
            || ' cartodb_id::int FROM _areas, values '
            || 'WHERE values.geoid = _areas.geoid GROUP BY cartodb_id);';

    -- Construct query for ST_Segmentize
    ELSIF type_f ILIKE 'Segmentize' THEN
        SELECT (params::json->>'max_segment_length')::double precision INTO max_segment_length;
        data_query := 'SELECT ST_Segmentize(the_geom, ' || max_segment_length || ')::geometry as segments, cartodb_id::int FROM '
            || table_schema || '.' || table_name || ';';
    ELSIF type_f ILIKE '%CentroidSegmentize%' THEN
        SELECT (params::json->>'max_segment_length')::double precision INTO max_segment_length;
        data_query := 'SELECT ST_Centroid(ST_Segmentize(the_geom, ' || max_segment_length || '))::geometry as segments, cartodb_id::int FROM '
            || table_schema || '.' || table_name || ';';

    ELSIF type_f ILIKE '%ConvexHull%' THEN
        data_query := 'SELECT ST_ConvexHull(ST_Collect(the_geom)) as convexresult, 1::int as cartodb_id FROM '
            || table_schema || '.' || table_name || ';';

    ELSIF type_f ILIKE '%Moran%' THEN
        SELECT (params::json->>'column_name')::text INTO moran_colname;
        data_query := 'SELECT moran, quads, significance, vals, cartodb_id from cdb_observatory._CDB_AreasOfInterestLocalTABLE(''SELECT * FROM ' || table_schema || '.' || table_name || '''::text, ''' || moran_colname ||'''::text, ''knn''::text, 5, 99, ''the_geom''::text, ''cartodb_id''::text) as (moran numeric, quads text, significance numeric, cartodb_id int, vals numeric);';

    END IF;

  RETURN data_query;
END;
$$ LANGUAGE plpgsql;