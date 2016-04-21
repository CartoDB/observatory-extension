
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
    WHERE id IN (
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
CREATE TYPE cdb_observatory.OBS_ColumnData AS (
  colname text, 
  tablename text, 
  aggregate text, 
  name text,
  type text);


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
 SELECT array_agg(ROW(colname, tablename, aggregate, name, type)::cdb_observatory.OBS_ColumnData order by column_ids.no)
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

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetRelatedColumn(columns_ids text[], reltype text )
RETURNS TEXT[]
AS $$
DECLARE
  result TEXT[];
BEGIN
  EXECUTE '
    With ids as (
      select row_number() over() as no, id from (select unnest($1) as id) t
    )
    select array_agg(target_id order by no)
    FROM  ids
    LEFT JOIN observatory.obs_column_to_column
    on  source_id  = id
    where reltype = $2 or reltype is null
  '
  INTO result
  using columns_ids, reltype;
  return result;
END;
$$ LANGUAGE plpgsql;
