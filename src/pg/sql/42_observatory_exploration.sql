
-- return a table that contains a string match based on input
-- TODO: implement search for timespan

CREATE OR REPLACE FUNCTION OBS_SearchTables(
  search_term text,
  time_span text DEFAULT '2009 - 2013'
)
RETURNS text[]
As $$
DECLARE
  out_var text[];
BEGIN

  EXECUTE
  'SELECT array_agg(tablename)
FROM observatory.obs_table t JOIN observatory.obs_column_table ct
  ON ct.table_id = t.id
JOIN observatory.obs_column c
  ON ct.column_id = c.id
WHERE c.type ILIKE ''geometry''
AND c.id = $1'
  INTO out_var
  USING search_term;

  RETURN out_var;

END;
$$ LANGUAGE plpgsql;
