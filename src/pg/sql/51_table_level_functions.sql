--
--
-- OBS_GetMeasure
--
--

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetMeasureResultMetadata(params json)
RETURNS cdb_observatory.ds_return_metadata
AS $$
DECLARE
  colnames text[];
  coltypes text[];
  requested_measures text[];
  measure_id text;
BEGIN
  EXECUTE
    $query$
      WITH _filters AS (SELECT
        row_number() over () as filter_id,
        unnest($1) filter_numer_id,
        unnest($2) filter_denom_id,
        unnest($3) filter_geom_id,
        unnest($4) filter_timespan
      )
      SELECT ARRAY_AGG(numer_colname ORDER BY filter_id), ARRAY_AGG(numer_type ORDER BY filter_id)
      FROM observatory.obs_meta, _filters
      WHERE (numer_id, coalesce(denom_id, ''), geom_id, numer_timespan)
         = (filter_numer_id, filter_denom_id, filter_geom_id, filter_timespan);
      ;
    $query$
  INTO colnames, coltypes
  USING (SELECT ARRAY(SELECT json_array_elements_text(params->'numer_ids'))::text[]),
        (SELECT ARRAY(SELECT json_array_elements_text(params->'denom_ids'))::text[]),
        (SELECT ARRAY(SELECT json_array_elements_text(params->'geom_ids'))::text[]),
        (SELECT ARRAY(SELECT json_array_elements_text(params->'timespans'))::text[]);

  RETURN (colnames, coltypes);
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetMeasureQuery(
  table_schema text, table_name text, params json)
RETURNS text
AS $$
DECLARE
  data_query text;

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
    EXECUTE
      $query$
        WITH _filters AS (SELECT
          unnest($1) numer_id,
          unnest($2) denom_id,
          unnest($3) geom_id,
          unnest($4) timespan
        )
        SELECT String_Agg(CASE
          -- denominated
          WHEN denom_id IS NOT NULL THEN ' CASE ' ||
            -- denominated point-in-poly or user polygon is same as OBS polygon
            ' WHEN ST_GeometryType(FIRST(_user_table.the_geom)) = ''ST_Point'' ' ||
            '      OR FIRST(_user_table.the_geom = ' || geom_tablename || '.' || geom_colname || ')' ||
            ' THEN FIRST(' || numer_tablename || '.' || numer_colname ||
            '      / NullIf(' || denom_tablename || '.' || denom_colname || ', 0))' ||
            -- denominated polygon interpolation
            -- SUM ((numer / denom) * (% user geom in OBS geom))
            ' ELSE ' ||
            --' NULL END '
            ' SUM((' || numer_tablename || '.' || numer_colname || '/NullIf(' || denom_tablename || '.' || denom_colname || ', 0)) ' ||
            ' * CASE WHEN ST_Within(_user_table.the_geom, ' || geom_tablename || '.' || geom_colname || ') THEN 1 ' ||
            '        WHEN ST_Within(' || geom_tablename || '.' || geom_colname || ', _user_table.the_geom) THEN ' ||
            '          ST_Area(' || geom_tablename || '.' || geom_colname || ') ' ||
            '          / ST_Area(_user_table.the_geom)' ||
            '        ELSE (ST_Area(ST_Intersection(_user_table.the_geom, ' || geom_tablename || '.' || geom_colname || ')) ' ||
            '         / ST_Area(_user_table.the_geom))' ||
            '   END) END '
          -- areaNormalized
          WHEN numer_aggregate ILIKE 'sum' THEN ' CASE ' ||
            -- areaNormalized point-in-poly or user polygon is the same as OBS polygon
            ' WHEN ST_GeometryType(FIRST(_user_table.the_geom)) = ''ST_Point'' ' ||
            '      OR FIRST(_user_table.the_geom = ' || geom_tablename || '.' || geom_colname || ')' ||
            ' THEN FIRST(' || numer_tablename || '.' || numer_colname ||
            '      / (ST_Area(' || geom_tablename || '.' || geom_colname || '::Geography)/1000000)) ' ||
            -- areaNormalized polygon interpolation
            -- SUM (numer * (% OBS geom in user geom)) / area of big geom
            ' ELSE ' ||
            --' NULL END '
            ' SUM(' || numer_tablename || '.' || numer_colname || ' ' ||
            ' * CASE WHEN ST_Within(_user_table.the_geom, ' || geom_tablename || '.' || geom_colname || ') ' ||
            '         THEN ST_Area(_user_table.the_geom) / ST_Area(' || geom_tablename || '.' || geom_colname || ') ' ||
            '        WHEN ST_Within(' || geom_tablename || '.' || geom_colname || ', _user_table.the_geom) ' ||
            '         THEN 1 ' ||
            '        ELSE (ST_Area(ST_Intersection(_user_table.the_geom, ' || geom_tablename || '.' || geom_colname || ')) ' ||
            '         / ST_Area(' || geom_tablename || '.' || geom_colname || '))' ||
            '   END) END '
          -- prenormalized
          ELSE ' CASE ' ||
            -- predenominated point-in-poly or user polygon is the same as OBS- polygon
            ' WHEN ST_GeometryType(FIRST(_user_table.the_geom)) = ''ST_Point'' ' ||
            '      OR FIRST(_user_table.the_geom = ' || geom_tablename || '.' || geom_colname || ')' ||
            ' THEN FIRST(' || numer_tablename || '.' || numer_colname || ') ' ||
            ' ELSE ' ||
            -- predenominated polygon interpolation
            -- TODO should weight by universe instead of area
            -- SUM (numer * (% user geom in OBS geom))
            ' SUM((' || numer_tablename || '.' || numer_colname || ') ' ||
            ' * CASE WHEN ST_Within(_user_table.the_geom, ' || geom_tablename || '.' || geom_colname || ') THEN 1 ' ||
            '        WHEN ST_Within(' || geom_tablename || '.' || geom_colname || ', _user_table.the_geom) THEN ' ||
            '          ST_Area(' || geom_tablename || '.' || geom_colname || ') ' ||
            '          / ST_Area(_user_table.the_geom)' ||
            '        ELSE (ST_Area(ST_Intersection(_user_table.the_geom, ' || geom_tablename || '.' || geom_colname || ')) ' ||
            '         / ST_Area(_user_table.the_geom))' ||
            '   END) END '
          END || ' ' || numer_colname, ', ') AS colspecs,

          (SELECT String_Agg(tablename, ', ') FROM (SELECT JSONB_Object_Keys(JSONB_Object(
             Array_Cat(Array_Agg('observatory.' || numer_tablename),
               Array_Cat(Array_Agg('observatory.' || geom_tablename),
                         Array_Agg('observatory.' || denom_tablename) FILTER (WHERE denom_tablename IS NOT NULL))),
             Array_Cat(Array_Agg(numer_tablename),
               Array_Cat(Array_Agg(geom_tablename),
                         Array_Agg(denom_tablename) FILTER (WHERE denom_tablename IS NOT NULL)))
           )) tablename) bar) tablenames,
          String_Agg(numer_tablename || '.' || numer_geomref_colname || ' = ' ||
                     geom_tablename || '.' || geom_geomref_colname ||
           Coalesce(' AND ' || numer_tablename || '.' || numer_geomref_colname || ' = ' ||
                               denom_tablename || '.' || denom_geomref_colname, ''),
           ' AND ') AS obs_wheres,
          String_Agg('ST_Intersects(' || geom_tablename || '.' ||  geom_colname
             || ', _user_table.the_geom)', ' AND ')
             AS user_wheres
        FROM observatory.obs_meta
        WHERE (numer_id, coalesce(denom_id, ''), geom_id, numer_timespan)
           IN (SELECT numer_id, denom_id, geom_id, timespan FROM _filters)
        ;
      $query$
    INTO colspecs, tables, obs_wheres, user_wheres
    USING (SELECT ARRAY(SELECT json_array_elements_text(params->'numer_ids'))::text[]),
          (SELECT ARRAY(SELECT json_array_elements_text(params->'denom_ids'))::text[]),
          (SELECT ARRAY(SELECT json_array_elements_text(params->'geom_ids'))::text[]),
          (SELECT ARRAY(SELECT json_array_elements_text(params->'timespans'))::text[]);

    data_query := format($query$
      SELECT %s, _user_table.cartodb_id::int
      FROM %s, %s.%s _user_table
      WHERE %s
        AND %s
      GROUP BY _user_table.cartodb_id
    $query$, colspecs, tables, table_schema, table_name, obs_wheres, user_wheres);
    RETURN data_query;
END;
$$ LANGUAGE plpgsql;
