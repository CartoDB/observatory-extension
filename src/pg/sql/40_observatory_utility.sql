
-- Returns a list of avaliable geometry columns
CREATE OR REPLACE FUNCTION OBS_ListGeomColumns()
  RETURNS TABLE(column_id text)
AS $$
  SELECT id FROM observatory.OBS_column WHERE type ILIKE 'geometry';
$$ LANGUAGE SQL IMMUTABLE;

-- Returns the table name with geoms for the given geometry_id
-- TODO probably needs to take in the column_id array to get the relevant
-- table where there is multiple sources for a column from multiple
-- geometries.
CREATE OR REPLACE FUNCTION OBS_GeomTable(
  geom geometry,
  geometry_id text
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
        AND ST_Intersects($2, ST_SetSRID(bounds::box2d::geometry, 4326))
    )
    '
  USING geometry_id, geom
  INTO result;

  return result;

END;
$$ LANGUAGE plpgsql;

-- A type for use with the OBS_GetColumnData function
CREATE TYPE OBS_ColumnData AS (colname text, tablename text, aggregate text);

-- A function that gets teh column data for a column_id, geometry_id and timespan.
-- Old: OBS_GetColumnData
CREATE OR REPLACE FUNCTION OBS_GetColumnData(
  geometry_id text,
  column_id text,
  timespan text
)
RETURNS OBS_ColumnData
AS $$
DECLARE
  result OBS_ColumnData;
BEGIN
  EXECUTE '
  WITH geomref AS (
    SELECT t.table_id id
    FROM observatory.OBS_column_to_column c2c, observatory.OBS_column_table t
    WHERE c2c.reltype = ''geom_ref''
      AND c2c.target_id = $1
      AND c2c.source_id = t.column_id
    )
 SELECT colname, tablename, aggregate
 FROM observatory.OBS_column c, observatory.OBS_column_table ct, observatory.OBS_table t
 WHERE c.id = ct.column_id
   AND t.id = ct.table_id
   AND c.id = $2
   AND t.timespan = $3
   AND t.id in (SELECT id FROM geomref)
 '
 USING geometry_id, column_id, timespan
 INTO result;

 RETURN result;

END;
$$ LANGUAGE plpgsql;


-- A function that gets the column data for multiple columns
-- Old: OBS_GetColumnData
CREATE OR REPLACE FUNCTION OBS_GetColumnData(
  geometry_id text,
  column_ids text[],
  timespan text
)
RETURNS OBS_ColumnData[]
AS $$
DECLARE
  result OBS_ColumnData[];
BEGIN
  EXECUTE '
  WITH geomref AS (
    SELECT t.table_id id
    FROM observatory.OBS_column_to_column c2c, observatory.OBS_column_table t
    WHERE c2c.reltype = ''geom_ref''
      AND c2c.target_id = $1
      AND c2c.source_id = t.column_id
    )
 SELECT array_agg(ROW(colname, tablename, aggregate)::OBS_ColumnData  order by column_id)
 FROM observatory.OBS_column c, observatory.OBS_column_table ct, observatory.OBS_table t
 WHERE c.id = ct.column_id
   AND t.id = ct.table_id
   AND Array[c.id] <@ $2
   AND t.timespan = $3
   AND t.id in (SELECT id FROM geomref)

 '
 USING geometry_id, column_ids, timespan
 INTO result;
 RETURN result;

END;
$$ LANGUAGE plpgsql;

--Gets the column id for a census variable given a human readable version of it
-- Old: OBS_LOOKUP_CENSUS_HUMAN
CREATE OR REPLACE FUNCTION OBS_LookupCensusHuman(
  column_name text,
  table_name text DEFAULT '"us.census.acs".extract_year_2013_sample_5yr_geography_block_group'
)
RETURNS text
AS $$
DECLARE
  column_id text;
  result text;
BEGIN
    EXECUTE format('SELECT column_id
                    FROM observatory.OBS_column_table
                    WHERE colname = %L AND table_id = %L
                    LIMIT 1', column_name,table_name)
    INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION OBS_LookupCensusHuman(
  column_names text[],
  -- TODO: change variable name table_name to table_id
  table_name text DEFAULT '"us.census.acs".extract_year_2013_sample_5yr_geography_block_group'
)
RETURNS text[] as $$
DECLARE
  column_id text;
  result text;
BEGIN
    EXECUTE format('select array_agg(column_id) from observatory.OBS_column_table where Array[colname] <@ $1  and table_id = %L limit 1', table_name)
    INTO result
    using column_names;
    RETURN result;
END
$$ LANGUAGE plpgsql;

-- get human-readable census column name

CREATE OR REPLACE FUNCTION OBS_LookupCensusColumnId(
  column_name text,
  table_name text DEFAULT '"us.census.acs".extract_year_2013_sample_5yr_geography_block_group'
)
RETURNS text
AS $$
DECLARE
  column_id text;
  result text;
BEGIN
    EXECUTE format('SELECT colname
                    FROM observatory.OBS_column_table
                    WHERE column_id = %L AND table_id = %L
                    LIMIT 1', column_name, table_name)
    INTO result;
    RETURN result;
END;
$$ LANGUAGE plpgsql;

--Test point cause Stuart always seems to make random points in the water
-- Old: _TEST_POINT
CREATE OR REPLACE FUNCTION _TestPoint()
  RETURNS geometry
AS $$
BEGIN
  -- new york city
  RETURN CDB_LatLng(40.704512, -73.936669);
END;
$$ LANGUAGE plpgsql;

--Test polygon cause Stuart always seems to make random points in the water
-- TODO: remove as it's not used anywhere?
CREATE OR REPLACE FUNCTION _TestArea()
  RETURNS geometry
AS $$
BEGIN
  -- Buffer NYC point by 500 meters
  RETURN ST_Buffer(_TestPoint()::geography, 500)::geometry;

END;
$$ LANGUAGE plpgsql;

--Used to expand a column based response to a table based one. Give it the desired
--columns and it will return a partial query for rolling them out to a table.
-- Old: OBS_BUILD_SNAPSHOT_QUERY
CREATE OR REPLACE FUNCTION OBS_BuildSnapshotQuery(names text[])
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
