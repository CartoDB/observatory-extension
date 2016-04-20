-- Functions used to search the observatory for measures
--------------------------------------------------------------------------------
-- TODO allow the user to specify the boundary to search for measures
--

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_Search_STU(
  search_term text,
  relevant_boundary text DEFAULT null
)
RETURNS TABLE(description text, name text, aggregate text, source text)  as $$
DECLARE
  boundary_term text;
BEGIN
  IF relevant_boundary then
    boundary_term = '';
  else
    boundary_term = '';
  END IF;

  RETURN QUERY
  EXECUTE format($string$
              SELECT description,
                name,
                  aggregate,
                  replace(split_part(id,'".', 1),'"', '') source
                  FROM observatory.OBS_column
                  where name ilike '%'|| %L || '%'
                  or description ilike '%'|| %L || '%'
                  %s
                $string$, search_term, search_term,boundary_term);
  RETURN;
END
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION OBS_GetAvailableBoundaries(geometry location)
RETURNS TABLE(description text, name text, id text)  as $$
BEGIN
  RETURN QUERY
  EXECUTE format($string$
    Select description, name, id FROM observatory.OBS_column
  $string$)
END
$$
