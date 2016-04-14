-- Add all foreign tables in the observatory
CREATE OR REPLACE FUNCTION OBS_INIT_TABLES ()
RETURNS BOOLEAN
AS $$
DECLARE
  metatables TEXT[] := ARRAY['OBS_table', 'OBS_tag', 'OBS_column',
                           'OBS_column_table', 'OBS_column_to_column',
                           'OBS_column_tag'];
  table_name TEXT;
BEGIN
  -- Add all meta tables
  FOREACH table_name IN ARRAY metatables
  LOOP
    PERFORM OBS_INIT_TABLE(table_name);
  END LOOP;

  -- Add all data tables
  FOR table_name in SELECT tablename FROM observatory.OBS_table
  LOOP
    PERFORM OBS_INIT_TABLE(table_name);
  END LOOP;
  RETURN True;
END;
$$ LANGUAGE plpgsql;

-- Adds one foreign table to this user's account
CREATE OR REPLACE FUNCTION OBS_INIT_TABLE (
  tablename TEXT
)
RETURNS BOOLEAN
AS $$ BEGIN
  EXECUTE FORMAT('DROP FOREIGN TABLE IF EXISTS observatory.%I', tablename);
    BEGIN
      PERFORM CDB_Add_Remote_Table('observatory', tablename);
    EXCEPTION
      WHEN undefined_table THEN
        RAISE NOTICE 'Cannot add table %, it is in metadata but does not exist', tablename;
    END;
  RETURN True;
END;
$$ LANGUAGE plpgsql;
