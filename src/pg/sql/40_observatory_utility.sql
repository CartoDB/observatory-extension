
-- Returns the table name with geoms for the given geometry_id
-- TODO probably needs to take in the column_id array to get the relevant
-- table where there is multiple sources for a column from multiple
-- geometries.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GeomTable(
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
    WHERE id IN (ps
      SELECT table_id
      FROM observatory.OBS_table tab,
           observatory.OBS_column_table coltable,
           observatory.OBS_column col
      WHERE type ILIKE ''geometry''
        AND coltable.column_id = col.id
        AND coltable.table_id = tab.id
        AND col.id = $1
    )
    '
  USING geometry_id, geom
  INTO result;

  return result;

END;
$$ LANGUAGE plpgsql;

-- A type for use with the OBS_GetColumnData function
CREATE TYPE cdb_observatory.OBS_ColumnData AS (colname text, tablename text, aggregate text);


-- A function that gets the column data for multiple columns
-- Old: OBS_GetColumnData
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetColumnData(
  geometry_id text,
  column_ids text[],
  timespan text
)
RETURNS cdb_observatory.OBS_ColumnData[]
AS $$
DECLARE
  result cdb_observatory.OBS_ColumnData[];
BEGIN
  EXECUTE '
  WITH geomref AS (
    SELECT t.table_id id
    FROM observatory.OBS_column_to_column c2c, observatory.OBS_column_table t
    WHERE c2c.reltype = ''geom_ref''
      AND c2c.target_id = $1
      AND c2c.source_id = t.column_id
    ),
  column_ids as (
    select row_number() over () as no, a.column_id as column_id from (select unnest($2) as column_id) a
  )
 SELECT array_agg(ROW(colname, tablename, aggregate)::cdb_observatory.OBS_ColumnData order by column_ids.no)
 FROM column_ids, observatory.OBS_column c, observatory.OBS_column_table ct, observatory.OBS_table t
 WHERE column_ids.column_id  = c.id
   AND c.id = ct.column_id
   AND t.id = ct.table_id
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

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_LookupCensusHuman(
  column_names text[],
  -- TODO: change variable name table_name to table_id
  table_name text DEFAULT '"us.census.acs".extract_block_group_5yr_2013_69b156927c'
)
RETURNS text[] as $$
DECLARE
  column_id text;
  result text;
BEGIN
    EXECUTE format('
      WITH col_names AS (
        select row_number() over() as no, a.column_name as column_name from(
          select unnest($1) as column_name
        ) a
      )
      select array_agg(column_id order by col_names.no)
      FROM observatory.OBS_column_table,col_names
      where colname = col_names.column_name
      and table_id = %L limit 1
    ', table_name)
    INTO result
    using column_names;
    RETURN result;
END
$$ LANGUAGE plpgsql;


--Test point cause Stuart always seems to make random points in the water
CREATE OR REPLACE FUNCTION cdb_observatory._TestPoint()
  RETURNS geometry
AS $$
BEGIN
  -- new york city
  RETURN CDB_LatLng(40.704512, -73.936669);
END;
$$ LANGUAGE plpgsql;

--Test polygon cause Stuart always seems to make random points in the water
-- TODO: remove as it's not used anywhere?
CREATE OR REPLACE FUNCTION cdb_observatory._TestArea()
  RETURNS geometry
AS $$
BEGIN
  -- Buffer NYC point by 500 meters
  RETURN ST_Buffer(cdb_observatory._TestPoint()::geography, 500)::geometry;

END;
$$ LANGUAGE plpgsql;

-- Generates json from an array of keys and values
--
CREATE OR REPLACE FUNCTION cdb_observatory._keys_vals_to_json(keys text[], vals anyarray )
RETURNS json
as $$
DECLARE
  query text;
  result text;
BEGIN
query = '';
for i in 1..array_upper(keys,1) LOOP
  query = query || format('vals[%s]  %I' , i , keys[i]);
  if i < array_upper(keys,1) then
    query = query || ', ';
  end IF;
end LOOP;
  RAISE NOTICE ' query %', query;
  EXECUTE
    ' with key_vals as (select $1 keys, $2 vals),
      expanded as (select '||query||' from key_vals)
      select row_to_json(expanded) from expanded'
  INTO result
  USING keys, vals;
  return result;
END;
$$ language plpgsql ;

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

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_NormalizeMeasureName(measure_name text )
RETURNS text
AS $$
DECLARE
  result text;
BEGIN
  -- Turn non letter or digits to _
  result = regexp_replace(measure_name, '[^\dA-Za-z]+','_', 'g');
  -- Remove duplicate _'s
  result = regexp_replace(result,'_{2,}','_', 'g');
  -- Trim _'s from begning and end
  result = trim(both  '_' from result);
  result = lower(result);
  RETURN result;
END;
$$ LANGUAGE plpgsql;
