
--For Longer term Dev


--Break out table definitions to types
--Automate type creation from a script, something like
----CREATE OR REPLACE FUNCTION OBS_Get<%=tag_name%>(geom GEOMETRY)
----RETURNS TABLE(
----<%=get_dimensions_for_tag(tag_name)%>
----AS $$
----DECLARE
----target_cols text[];
----names text[];
----vals numeric[];-
----q text;
----BEGIN
----target_cols := Array[<%=get_dimensions_for_tag(tag_name)%>],


--Functions for augmenting specific tables
--------------------------------------------------------------------------------

-- Creates a table of demographic snapshot
-- TODO: Remove since it does address geocoding?

CREATE OR REPLACE FUNCTION OBS_GetDemographicSnapshot(geom geometry)
RETURNS TABLE(
  total_pop NUMERIC,
  female_pop NUMERIC,
  male_pop NUMERIC,
  median_age NUMERIC,
  white_pop NUMERIC,
  black_pop NUMERIC,
  asian_pop NUMERIC,
  hispanic_pop NUMERIC,
  not_us_citizen_pop NUMERIC,
  workers_16_and_over NUMERIC,
  commuters_by_car_truck_van NUMERIC,
  commuters_by_public_transportation NUMERIC,
  commuters_by_bus NUMERIC,
  commuters_by_subway_or_elevated NUMERIC,
  walked_to_work NUMERIC,
  worked_at_home NUMERIC,
  children NUMERIC,
  households NUMERIC,
  population_3_years_over NUMERIC,
  in_school NUMERIC,
  in_grades_1_to_4 NUMERIC,
  in_grades_5_to_8 NUMERIC,
  in_grades_9_to_12 NUMERIC,
  in_undergrad_college NUMERIC,
  pop_25_years_over NUMERIC,
  high_school_diploma NUMERIC,
  bachelors_degree NUMERIC,
  masters_degree NUMERIC,
  pop_5_years_over NUMERIC,
  speak_only_english_at_home NUMERIC,
  speak_spanish_at_home NUMERIC,
  pop_determined_poverty_status NUMERIC,
  poverty NUMERIC,
  median_income NUMERIC,
  gini_index NUMERIC,
  income_per_capita NUMERIC,
  housing_units NUMERIC,
  vacant_housing_units NUMERIC,
  vacant_housing_units_for_rent NUMERIC,
  vacant_housing_units_for_sale NUMERIC,
  median_rent NUMERIC,
  percent_income_spent_on_rent NUMERIC,
  owner_occupied_housing_units NUMERIC,
  million_dollar_housing_units NUMERIC,
  mortgaged_housing_unit NUMERIC)
AS $$
DECLARE
 target_cols text[];
 names text[];
 vals numeric[];
 q text;
 BEGIN
 target_cols := Array[
                 'total_pop',
                 'female_pop',
                 'male_pop',
                 'median_age',
                 'white_pop',
                 'black_pop',
                 'asian_pop',
                 'hispanic_pop',
                 'not_us_citizen_pop',
                 'workers_16_and_over',
                 'commuters_by_car_truck_van',
                 'commuters_by_public_transportation',
                 'commuters_by_bus',
                 'commuters_by_subway_or_elevated',
                 'walked_to_work',
                 'worked_at_home',
                 'children',
                 'households',
                 'population_3_years_over',
                 'in_school',
                 'in_grades_1_to_4',
                 'in_grades_5_to_8',
                 'in_grades_9_to_12',
                 'in_undergrad_college',
                 'pop_25_years_over',
                 'high_school_diploma',
                 'bachelors_degree',
                 'masters_degree',
                 'pop_5_years_over',
                 'speak_only_english_at_home',
                 'speak_spanish_at_home',
                 'pop_determined_poverty_status',
                 'poverty',
                 'median_income',
                 'gini_index',
                 'income_per_capita',
                 'housing_units',
                 'vacant_housing_units',
                 'vacant_housing_units_for_rent',
                 'vacant_housing_units_for_sale',
                 'median_rent',
                 'percent_income_spent_on_rent',
                 'owner_occupied_housing_units',
                 'million_dollar_housing_units',
                 'mortgaged_housing_unit'
                ];

  q = 'WITH a As (
         SELECT
           colnames As names,
           colvalues As vals
        FROM OBS_GetCensus($1,$2)
      )' ||
      OBS_BuildSnapshotQuery(target_cols) ||
      ' FROM  a';

  RETURN QUERY
  EXECUTE
    q
  USING geom, target_cols;

  RETURN;
END;
$$ LANGUAGE plpgsql;


--Base functions for performing augmentation
----------------------------------------------------------------------------------------


--Returns arrays of values for the given census dimension names for a given
--point or polygon
CREATE OR REPLACE FUNCTION OBS_GetCensus(
  geom geometry,
  dimension_names text[],
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
)
RETURNS TABLE(dimension text, dimension_value numeric)
AS $$
DECLARE
  ids text[];
BEGIN

  ids  = OBS_LookupCensusHuman(dimension_names);

  RETURN QUERY SELECT unnest(names), unnest(vals)
               FROM OBS_Get(geom, ids, time_span, geometry_level);
END;
$$ LANGUAGE plpgsql;



-- Base augmentation fucntion.
CREATE OR REPLACE FUNCTION OBS_Get(
  geom geometry,
  column_ids text[],
  time_span text,
  geometry_level text
)
RETURNS TABLE(names text[], vals NUMERIC[])
AS $$
DECLARE
	results numeric[];
  geom_table_name text;
  names text[];
  query text;
  data_table_info OBS_ColumnData[];
BEGIN

  geom_table_name := OBS_GeomTable(geom, geometry_level);

  IF geom_table_name IS NULL
  THEN
     RAISE EXCEPTION 'Point % is outside of the data region', geom;
  END IF;

  data_table_info := OBS_GetColumnData(geometry_level,
                                       column_ids,
                                       time_span);

  names := (SELECT array_agg((d).colname)
            FROM unnest(data_table_info) As d);

  IF ST_GeometryType(geom) = 'ST_Point'
  THEN
    results := OBS_GetPoints(geom,
                             geom_table_name,
                             data_table_info);

  ELSIF ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon')
  THEN
    results := OBS_GetPolygons(geom,
                               geom_table_name,
                               data_table_info);
  END IF;

  IF results IS NULL
  THEN
    results := Array[];
  END IF;

  RETURN QUERY (SELECT names, results);
END;
$$ LANGUAGE plpgsql;


-- If the variable of interest is just a rate return it as such,
--  otherwise normalize it to the census block area and return that
CREATE OR REPLACE FUNCTION OBS_GetPoints(
  geom geometry,
  geom_table_name text,
  data_table_info OBS_ColumnData[]

) RETURNS NUMERIC[] AS $$
DECLARE
  result NUMERIC[];
  query  text;
  i int;
  geoid text;
  area  numeric;
BEGIN

  EXECUTE
    format('SELECT geoid
            FROM observatory.%I
            WHERE the_geom && $1',
            geom_table_name)
  USING geom
  INTO geoid;

  EXECUTE
    format('SELECT ST_Area(the_geom::geography)
            FROM observatory.%I
            WHERE geoid = %L',
            geom_table_name,
            geoid)
  INTO area;


  query := 'SELECT ARRAY[';
  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    IF ((data_table_info)[i]).aggregate != 'sum'
    THEN
      query = query || format('%I ', ((data_table_info)[i]).colname);
    ELSE
      query = query || format('%I/%s ',
        ((data_table_info)[i]).colname,
        area);
    END IF;

    IF i <  array_upper(data_table_info, 1)
    THEN
      query = query || ',';
    END IF;
  END LOOP;

  query = query || format(' ]
    FROM observatory.%I
    WHERE %I.geoid  = %L
  ',
  ((data_table_info)[1]).tablename,
  ((data_table_info)[1]).tablename,
  geoid
  );

  EXECUTE
    query
  INTO result
  USING geom;

  RETURN result;

END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION OBS_GetPolygons (
  geom geometry,
  geom_table_name text,
  data_table_info OBS_ColumnData[]
) returns numeric[] AS $$
DECLARE
  result numeric[];
  q_select text;
  q_sum text;
  q text;
  i numeric;
BEGIN

  q_select := 'select geoid, ';
  q_sum    := 'select Array[';

  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    q_select = q_select || format( '%I ', ((data_table_info)[i]).colname);

    IF ((data_table_info)[i]).aggregate ='sum'
    THEN
      q_sum    = q_sum || format('sum(overlap_fraction * COALESCE(%I, 0)) ',((data_table_info)[i]).colname,((data_table_info)[i]).colname);
    ELSE
      q_sum    = q_sum || ' null ';
    END IF;

    IF i < array_upper(data_table_info,1)
    THEN
      q_select = q_select || format(',');
      q_sum     = q_sum || format(',');
    END IF;
 END LOOP;

  q = format('
    WITH _overlaps As (
      SELECT ST_Area(
        ST_Intersection($1, a.the_geom)
      ) / ST_Area(a.the_geom) As overlap_fraction,
      geoid
      FROM observatory.%I As a
      WHERE $1 && a.the_geom
    ),
    values As (
    ', geom_table_name);

  q = q || q_select || format('FROM observatory.%I ', ((data_table_info)[1].tablename));

  q = q || ' ) ' || q_sum || ' ] FROM _overlaps, values
  WHERE values.geoid = _overlaps.geoid';

  EXECUTE
    q
  INTO result
  USING geom;

  RETURN result;
END;
$$ LANGUAGE plpgsql;
