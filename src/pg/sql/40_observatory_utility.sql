
-- Returns the table name with geoms for the given geometry_id
-- TODO probably needs to take in the column_id array to get the relevant
-- table where there is multiple sources for a column from multiple
-- geometries.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GeomTable(
  geom geometry(Geometry, 4326),
  geometry_id text,
  time_span text DEFAULT NULL
)
  RETURNS TEXT
AS $$
DECLARE
  result text;
BEGIN
  EXECUTE '
    SELECT tablename FROM observatory.OBS_table
    WHERE id IN (
      SELECT table_id
      FROM observatory.OBS_table tab,
           observatory.OBS_column_table coltable,
           observatory.OBS_column col
      WHERE type ILIKE ''geometry''
        AND coltable.column_id = col.id
        AND coltable.table_id = tab.id
        AND col.id = $1
        AND CASE WHEN $3::TEXT IS NOT NULL THEN timespan ILIKE $3::TEXT ELSE TRUE END
      ORDER BY timespan DESC LIMIT 1
    )
    '
  USING geometry_id, geom, time_span
  INTO result;

  return result;

END;
$$ LANGUAGE plpgsql;


--Test point cause Stuart always seems to make random points in the water
CREATE OR REPLACE FUNCTION cdb_observatory._TestPoint()
  RETURNS geometry(Point, 4326)
AS $$
BEGIN
  -- new york city
  RETURN ST_SetSRID(ST_Point( -73.936669, 40.704512), 4326);
END;
$$ LANGUAGE plpgsql;

--Test polygon cause Stuart always seems to make random points in the water
-- TODO: remove as it's not used anywhere?
CREATE OR REPLACE FUNCTION cdb_observatory._TestArea()
  RETURNS geometry(Geometry, 4326)
AS $$
BEGIN
  -- Buffer NYC point by 500 meters
  RETURN ST_Buffer(cdb_observatory._TestPoint()::geography, 500)::geometry;

END;
$$ LANGUAGE plpgsql;

--Used to expand a column based response to a table based one. Give it the desired
--columns and it will return a partial query for rolling them out to a table.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_BuildSnapshotQuery(names text[])
RETURNS TEXT
AS $$
DECLARE
  q text;
  i numeric;
BEGIN

  q := 'SELECT ';

  FOR i IN 1..array_upper(names,1)
  LOOP
    q = q || format(' vals[%s] As %I', i, names[i]);
    IF i < array_upper(names, 1) THEN
      q= q || ',';
    END IF;
  END LOOP;
  RETURN q;

END;
$$ LANGUAGE plpgsql;

-- Function that replaces all non digits or letters with _ trims and lowercases the
-- passed measure name

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_StandardizeMeasureName(measure_name text)
RETURNS text
AS $$
DECLARE
  result text;
BEGIN
  -- Turn non letter or digits to _
  result = regexp_replace(measure_name, '[^\dA-Za-z]+','_', 'g');
  -- Remove duplicate _'s
  result = regexp_replace(result,'_{2,}','_', 'g');
  -- Trim _'s from beginning and end
  result = trim(both  '_' from result);
  result = lower(result);
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function that returns the currently deployed obs_dump_version from the
-- remote table of the same name.

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_DumpVersion(
)
  RETURNS TEXT
AS $$
DECLARE
  result text;
BEGIN
  EXECUTE '
    SELECT MAX(dump_id) FROM observatory.obs_dump_version
  ' INTO result;
  RETURN result;
END;
$$ LANGUAGE plpgsql;
