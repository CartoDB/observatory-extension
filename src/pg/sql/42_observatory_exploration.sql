
-- return a table that contains a string match based on input
-- TODO: implement search for timespan

CREATE OR REPLACE FUNCTION _OBS_SearchTables(
  search_term text,
  time_span text DEFAULT NULL
)
RETURNS table(tablename text, timespan text)
As $$
DECLARE
  out_var text[];
BEGIN

  IF time_span IS NULL
  THEN
    RETURN QUERY
    EXECUTE
    'SELECT tablename, timespan
       FROM observatory.obs_table t
       JOIN observatory.obs_column_table ct
         ON ct.table_id = t.id
       JOIN observatory.obs_column c
         ON ct.column_id = c.id
       WHERE c.type ILIKE ''geometry''
        AND c.id = $1'
    USING search_term;
  ELSE
    RETURN QUERY
    EXECUTE
    'SELECT tablename, timespan
       FROM observatory.obs_table t
       JOIN observatory.obs_column_table ct
         ON ct.table_id = t.id
       JOIN observatory.obs_column c
         ON ct.column_id = c.id
       WHERE c.type ILIKE ''geometry''
        AND c.id = $1
        AND t.timespan = $2'
    USING search_term, time_span;
  END IF;

END;
$$ LANGUAGE plpgsql IMMUTABLE;
