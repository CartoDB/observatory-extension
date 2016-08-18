CREATE OR REPLACE FUNCTION cdb_observatory._OBS_ConnectRemoteTable(fdw_name text, schema_name text, user_dbname text, user_hostname text, username text, user_tablename text, user_schema text)
RETURNS void
AS $$
DECLARE
  row record;
  option record;
  connection_str json;
BEGIN
  -- Build connection string
  connection_str := '{"server":{"extensions":"postgis", "dbname":"'
    || user_dbname ||'", "host":"' || user_hostname ||'", "port":"6432"}, "users":{"public"'
    || ':{"user":"' || username ||'", "password":""} } }';

  -- This function tries to be as idempotent as possible, by not creating anything more than once
  -- (not even using IF NOT EXIST to avoid throwing warnings)
  IF NOT EXISTS ( SELECT * FROM pg_extension WHERE extname = 'postgres_fdw') THEN
    CREATE EXTENSION postgres_fdw;
  END IF;
  -- Create FDW first if it does not exist
  IF NOT EXISTS ( SELECT * FROM pg_foreign_server WHERE srvname = fdw_name)
    THEN
    EXECUTE FORMAT('CREATE SERVER %I FOREIGN DATA WRAPPER postgres_fdw', fdw_name);
  END IF;

  -- Set FDW settings
  FOR row IN SELECT p.key, p.value from lateral json_each_text(connection_str->'server') p
    LOOP
      IF NOT EXISTS (WITH a AS (select split_part(unnest(srvoptions), '=', 1) as options from pg_foreign_server where srvname=fdw_name) SELECT * from a where options = row.key)
        THEN
        EXECUTE FORMAT('ALTER SERVER %I OPTIONS (ADD %I %L)', fdw_name, row.key, row.value);
      ELSE
        EXECUTE FORMAT('ALTER SERVER %I OPTIONS (SET %I %L)', fdw_name, row.key, row.value);
      END IF;
    END LOOP;

    -- Create user mappings
    FOR row IN SELECT p.key, p.value from lateral json_each(connection_str->'users') p LOOP
      -- Check if entry on pg_user_mappings exists
      IF NOT EXISTS ( SELECT * FROM pg_user_mappings WHERE srvname = fdw_name AND usename = row.key ) THEN
        EXECUTE FORMAT ('CREATE USER MAPPING FOR %I SERVER %I', row.key, fdw_name);
      END IF;

      -- Update user mapping settings
      FOR option IN SELECT o.key, o.value from lateral json_each_text(row.value) o LOOP
        IF NOT EXISTS (WITH a AS (select split_part(unnest(umoptions), '=', 1) as options from pg_user_mappings WHERE srvname = fdw_name AND usename = row.key) SELECT * from a where options = option.key) THEN
          EXECUTE FORMAT('ALTER USER MAPPING FOR %I SERVER %I OPTIONS (ADD %I %L)', row.key, fdw_name, option.key, option.value);
        ELSE
          EXECUTE FORMAT('ALTER USER MAPPING FOR %I SERVER %I OPTIONS (SET %I %L)', row.key, fdw_name, option.key, option.value);
        END IF;
      END LOOP;
    END LOOP;

    -- Create schema if it does not exist.
    IF NOT EXISTS ( SELECT * from pg_namespace WHERE nspname=fdw_name) THEN
      EXECUTE FORMAT ('CREATE SCHEMA %I', fdw_name);
    END IF;

    -- Bring the remote cdb_tablemetadata
    IF NOT EXISTS ( SELECT * FROM PG_CLASS WHERE relnamespace = (SELECT oid FROM pg_namespace WHERE nspname=fdw_name) and relname='cdb_tablemetadata') THEN
      EXECUTE FORMAT ('CREATE FOREIGN TABLE %I.cdb_tablemetadata (tabname text, updated_at timestamp with time zone) SERVER %I OPTIONS (table_name ''cdb_tablemetadata_text'', schema_name ''public'', updatable ''false'')', fdw_name, fdw_name);
    END IF;

    -- Import target table
    EXECUTE FORMAT ('IMPORT FOREIGN SCHEMA %I LIMIT TO (%I) from SERVER %I INTO %I', user_schema, user_tablename, fdw_name, schema_name);

END;
$$ LANGUAGE PLPGSQL;
