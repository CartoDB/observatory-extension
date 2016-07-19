CREATE TYPE cdb_observatory.ds_fdw_metadata as (schemaname text, tabname text, servername text);
CREATE TYPE cdb_observatory.ds_return_metadata as (colnames text[], coltypes text[]);

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_ConnectUserTable(username text, orgname text, user_db_role text, input_schema text, dbname text, host_addr text, table_name text)
RETURNS cdb_observatory.ds_fdw_metadata
AS $$
DECLARE
  fdw_server text;
  fdw_import_schema text;
  connection_str json;
  import_foreign_schema_q text;
  epoch_timestamp text;
BEGIN

  SELECT extract(epoch from now() at time zone 'utc')::int INTO epoch_timestamp;
  fdw_server := 'fdw_server_' || username || '_' || epoch_timestamp;
  fdw_import_schema:= fdw_server;

  -- Import foreign table
  EXECUTE FORMAT ('SELECT cdb_observatory._OBS_ConnectRemoteTable(%L, %L, %L, %L, %L, %L, %L)', fdw_server, fdw_import_schema, dbname, host_addr, user_db_role, table_name, input_schema);

  RETURN (fdw_import_schema::text, table_name::text, fdw_server::text);

EXCEPTION
  WHEN others THEN
    -- Disconnect user imported table. Delete schema and FDW server.
    EXECUTE 'DROP FOREIGN TABLE IF EXISTS ' || fdw_import_schema || '.' || table_name;
    EXECUTE 'DROP SCHEMA IF EXISTS ' || fdw_import_schema || ' CASCADE';
    EXECUTE 'DROP SERVER IF EXISTS ' || fdw_server || ' CASCADE;';
    RETURN (null, null, null);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetReturnMetadata(username text, orgname text, function_name text, params json)
RETURNS cdb_observatory.ds_return_metadata
AS $$
DECLARE
  colnames text[];
  coltypes text[];
  requested_measures text[];
  measure text;
BEGIN

  -- Simple mock, there should be real logic in here.

  IF $3 NOT ILIKE 'GetMeasure' OR $3 IS NULL THEN
    RAISE 'This function is not supported yet: %', $3;
  END IF;

  SELECT translate($4::json->>'tag_name','[]', '{}')::text[] INTO requested_measures;

  FOREACH measure IN ARRAY requested_measures
  LOOP
    IF NOT measure ILIKE ANY (Array['total_pop', 'pop_16_over']::text[]) THEN
      RAISE 'This measure is not supported yet: %', measure;
    END IF;
  SELECT array_append(colnames, measure) INTO colnames;
  SELECT array_append(coltypes, 'double precision'::text) INTO coltypes;

  END LOOP;

  RETURN (colnames::text[], coltypes::text[]);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS SETOF record
AS $$
DECLARE
  data_query text;
  tag_name text[];
  tag text;
  tags_list text;
  tags_query text;
  rec RECORD;
BEGIN
    SELECT translate($6::json->>'tag_name','[]', '{}')::text[] INTO tag_name;
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


    FOR rec IN EXECUTE data_query
    LOOP
        RETURN NEXT rec;
    END LOOP;
    RETURN;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_DisconnectUserTable(username text, orgname text, table_schema text, table_name text, servername text)
RETURNS boolean
AS $$
BEGIN
    EXECUTE 'DROP FOREIGN TABLE IF EXISTS "' || table_schema || '".' || table_name;
    EXECUTE 'DROP SCHEMA IF EXISTS ' || table_schema || ' CASCADE';
    EXECUTE 'DROP SERVER IF EXISTS ' || servername || ' CASCADE;';
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;