-- Returns the polygon(s) that overlap with the input geometry.
-- Input:
-- :param geom geometry: input geometry
-- :param geometry_level text: table to get polygon from (can be approximate name)
-- :param use_literal boolean: use the literal table name (defaults to true)

-- From an input point geometry, find the boundary which intersects with the centroid of the input geometry

CREATE OR REPLACE FUNCTION OBS_Get_Geometry(
  geom geometry(Geometry, 4326),
  geometry_level text DEFAULT '"us.census.tiger".tract', -- TODO: from a specified column id list (e.g., list of available catalog)
  time_span text DEFAULT '2009 - 2013')
  RETURNS geometry(Geometry, 4326)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  target_table text;
  target_table_list text[];
BEGIN

  -- TODO: Check if SRID = 4326, if not transform?

  -- if not a point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  target_table_list := OBS_Search_Tables(geometry_level, time_span);

  -- if no tables are found, raise error
  IF array_length(target_table_list, 1) IS NULL
  THEN
    RAISE EXCEPTION 'No boundaries found for ''%'' ''%''', ST_AsText(geom), geometry_level;
  ELSE
  -- else, choose first result
    target_table = target_table_list[1];
  END IF;

  RAISE NOTICE 'target_table: %', target_table;

  -- return the first boundary in intersections
  EXECUTE format(
    'SELECT t.the_geom
     FROM observatory.%s As t
     WHERE ST_Intersects($1, t.the_geom)
     LIMIT 1', target_table)
  INTO boundary
  USING geom;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

-- TODO: add OBS_Get_Geometry_By_Address

CREATE OR REPLACE FUNCTION OBS_Get_Geometry(
  geom_ref text,      -- ex: '36047'
  geometry_level text -- ex: '"us.census.tiger".county'
)
RETURNS geometry(geometry, 4326)
AS $$
DECLARE
  boundary geometry;
  target_table text;
  geoid_colname text;
  geom_colname text;
BEGIN

  EXECUTE
  format(
    $string$
    SELECT geoid_ct.colname As geoid_colname,
           tablename,
           geom_ct.colname As geom_colname
    FROM observatory.obs_column_table As geoid_ct,
         observatory.obs_table As geom_t,
         observatory.obs_column_table As geom_ct,
         observatory.obs_column As geom_c
    WHERE geoid_ct.column_id
       IN (
         SELECT source_id
         FROM observatory.obs_column_to_column
         WHERE reltype = 'geom_ref'
           AND target_id = '%s'
         )
      AND geoid_ct.table_id = geom_t.id and
          geom_t.id = geom_ct.table_id and
          geom_ct.column_id = geom_c.id and
          geom_c.type ilike 'geometry'
    $string$, geometry_level
  ) INTO geoid_colname, target_table, geom_colname;

  IF target_table IS NULL
  THEN
    RAISE EXCEPTION 'No geometries found';
  END IF;

  -- retrieve boundary
  EXECUTE format(
    'SELECT t.%s
     FROM observatory.%s As t
     WHERE t.%s = ''%s''
     LIMIT 1', geom_colname, target_table, geoid_colname, geom_ref)
  INTO boundary;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

-- From text address (e.g., '201 Moore St., Brooklyn, NY 11206'), give back the --  bounding geometry for the requested feature (e.g., 'census blocks', 'dma', 'blocks', etc.)

CREATE OR REPLACE FUNCTION OBS_Get_Geometry(
  address text,
  geometry_level text DEFAULT 'observatory.obs_a6b7e2e5de1ba72555fa54c8bf3ecc717d6161b4',
  use_literal boolean DEFAULT false,
  time_span text DEFAULT '2009 - 2013'
)
RETURNS geometry(Geometry, 4326)
AS $$
DECLARE
  boundary geometry(Geometry, 4326);
  address_geom geometry(Geometry, 4326);
  target_table text;
  target_table_list text[];
BEGIN

  IF use_literal
  THEN
    target_table := geometry_level;
  ELSE
    target_table_list := OBS_Search_Tables(geometry_level, time_span);

    -- if no tables are found, raise error
    IF array_length(target_table_list, 1) IS NULL
    THEN
      RAISE EXCEPTION 'No boundaries found for ''%''', geometry_level;
    ELSE
    -- else, choose first result
      target_table = target_table_list[1];
    END IF;

    RAISE NOTICE 'target_table: %', target_table;
  END IF;

  -- get lat/long for street-level address
  address_geom := cdb_geocode_street_point(address);

  EXECUTE format(
    'SELECT t.the_geom
    FROM observatory.%s As t
    WHERE ST_Intersects($1, t.the_geom)
    LIMIT 1', target_table)
  INTO boundary
  USING address_geom;

  RETURN boundary;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION OBS_Get_Geometry_Id(
  geom geometry(Geometry, 4326),
  geometry_level text DEFAULT 'observatory.obs_a6b7e2e5de1ba72555fa54c8bf3ecc717d6161b4',
  use_literal boolean DEFAULT false,
  time_span text DEFAULT '2009 - 2013'
)
RETURNS text
AS $$
DECLARE
  output_id text;
  target_table text;
  target_table_list text[];
BEGIN

  -- If not point, raise error
  IF ST_GeometryType(geom) != 'ST_Point'
  THEN
    RAISE EXCEPTION 'Error: Invalid geometry type (%), expecting ''ST_Point''', ST_GeometryType(geom);
  END IF;

  -- find table
  IF use_literal
  THEN
    target_table := geometry_level;
  ELSE
    target_table_list := OBS_Search_Tables(geometry_level, time_span);

    -- if no tables are found, raise error
    IF target_table_list = '{}'
    THEN
      RAISE EXCEPTION 'Error: No boundaries found for ''%''', geometry_level;
    ELSE
      target_table = target_table_list[1];
    END IF;

    RAISE NOTICE 'target_table: %', target_table;
  END IF;

  -- return name of geometry id column

  EXECUTE format(
    'SELECT t.geoid
    FROM observatory.%s As t
    WHERE ST_Intersects($1, t.the_geom)
    LIMIT 1', target_table)
  INTO output_id
  USING geom;

  RETURN output_id;

END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION OBS_Get_Geometry_Id(
  address text,
  geometry_level text DEFAULT 'observatory.obs_a6b7e2e5de1ba72555fa54c8bf3ecc717d6161b4',
  use_literal boolean DEFAULT false,
  time_span text DEFAULT '2009 - 2013'
)
RETURNS text
AS $$
DECLARE
  output_id text;
  address_geom geometry(Geometry, 4326);
  target_table text;
  target_table_list text[];
BEGIN

  IF use_literal
  THEN
    -- use input table name
    target_table := geometry_level;
  ELSE
    -- find an appropriate table
    target_table_list := OBS_Search_Tables(geometry_level, time_span);

    -- if no tables are found, raise error
    IF target_table_list = '{}'
    THEN
      RAISE EXCEPTION 'Error: No boundaries found for ''%''', geometry_level;
    ELSE
      target_table = target_table_list[1];
    END IF;

    RAISE NOTICE 'target_table: %', target_table;
  END IF;

  -- find location of address
  address_geom := cdb_geocode_street_point(address);

  -- find geoid of polygon in target_table
  --  which intersects with this address
  EXECUTE format(
    'SELECT t.geoid
    FROM observatory.%s As t
    WHERE ST_Intersects($1, t.the_geom)
    LIMIT 1', target_table)
  INTO output_id
  USING address_geom;
  RAISE NOTICE 'geoid: %', output_id;

  RETURN output_id;

END;
$$ LANGUAGE plpgsql;
