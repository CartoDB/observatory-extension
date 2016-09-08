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
    EXECUTE 'DROP FOREIGN TABLE IF EXISTS "' || fdw_import_schema || '".' || table_name;
    EXECUTE 'DROP FOREIGN TABLE IF EXISTS "' || fdw_import_schema || '".cdb_tablemetadata';
    EXECUTE 'DROP SCHEMA IF EXISTS "' || fdw_import_schema || '"';
    EXECUTE 'DROP USER MAPPING IF EXISTS FOR public SERVER "' || fdw_server || '"';
    EXECUTE 'DROP SERVER IF EXISTS "' || fdw_server || '"';

    RETURN (null, null, null);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetReturnMetadata(username text, orgname text, function_name text, params json)
RETURNS cdb_observatory.ds_return_metadata
AS $$
DECLARE
  colnames text[];
  coltypes text[];
BEGIN
  EXECUTE FORMAT('SELECT r.colnames::text[], r.coltypes::text[] FROM cdb_observatory._%sResultMetadata(%L::json) r', function_name, params::text)
  INTO colnames, coltypes;

  RETURN (colnames::text[], coltypes::text[]);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_FetchJoinFdwTableData(username text, orgname text, table_schema text, table_name text, function_name text, params json)
RETURNS SETOF record
AS $$
DECLARE
  data_query text;
  rec RECORD;
BEGIN

    EXECUTE FORMAT('SELECT cdb_observatory._%sQuery(%L, %L, %L::json)', function_name, table_schema, table_name, params::text)
    INTO data_query;

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
    EXECUTE 'DROP FOREIGN TABLE IF EXISTS "' || table_schema || '".cdb_tablemetadata';
    EXECUTE 'DROP SCHEMA IF EXISTS "' || table_schema || '"';
    EXECUTE 'DROP USER MAPPING IF EXISTS FOR public SERVER "' || servername || '"';
    EXECUTE 'DROP SERVER IF EXISTS "' || servername || '"';
    RETURN true;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
