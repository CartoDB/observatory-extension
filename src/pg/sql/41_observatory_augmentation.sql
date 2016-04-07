
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
CREATE OR REPLACE FUNCTION OBS_GetDemographicSnapshot(address text)
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

  RETURN QUERY
    EXECUTE
    $query$
      SELECT * FROM OBS_GetDemographicSnapshot(cdb_geocode_street_point($1));
    $query$
    USING address;
  RETURN;
END;
$$ LANGUAGE plpgsql;


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


--Creates a table with the young family segment.

CREATE OR REPLACE FUNCTION OBS_GetSegmentFamiliesWithYoungChildren(address text)
RETURNS TABLE (
  families_with_young_children NUMERIC,
  two_parent_families_with_young_children NUMERIC,
  two_parents_in_labor_force_families_with_young_children NUMERIC,
  two_parents_father_in_labor_force_families_with_young_children NUMERIC,
  two_parents_mother_in_labor_force_families_with_young_children NUMERIC,
  two_parents_not_in_labor_force_families_with_young_children NUMERIC,
  one_parent_families_with_young_children NUMERIC,
  father_one_parent_families_with_young_children NUMERIC
)
AS $$
DECLARE
BEGIN
RETURN QUERY
  EXECUTE
  $query$
    SELECT * from OBS_GetSegmentFamiliesWithYoungChildren(cdb_geocode_street_point($1));
  $query$
  USING address;
RETURN;
END
$$ LANGUAGE plpgsql;

-- currently broken
-- TODO: get geometry associated with that point and return it along with the segmentation information

CREATE OR REPLACE FUNCTION OBS_GetSegmentFamiliesWithYoungChildren(the_geom geometry)
RETURNS TABLE (
  families_with_young_children NUMERIC,
  two_parent_families_with_young_children NUMERIC,
  two_parents_in_labor_force_families_with_young_children NUMERIC,
  two_parents_father_in_labor_force_families_with_young_children NUMERIC,
  two_parents_mother_in_labor_force_families_with_young_children NUMERIC,
  two_parents_not_in_labor_force_families_with_young_children NUMERIC,
  one_parent_families_with_young_children NUMERIC,
  father_one_parent_families_with_young_children NUMERIC
)
AS $$
DECLARE
  column_ids text[];
  q text;
  segment_name text;
BEGIN

  -- tag used to search for columns which define segment
  segment_name := '"us.census.segments".families_with_young_children';

  -- get array of column ids according to segment defined in segment_name
  EXECUTE
    $query$
    SELECT column_ids
    FROM OBS_DESCRIBE_SEGMENT('"us.census.segments".families_with_young_children')
    LIMIT 1;
    $query$
  INTO column_ids
  USING segment_name;

  IF column_ids IS NULL
  THEN
    RAISE EXCEPTION 'no segment information for this point';
  END IF;

  -- build query to get data in segment columns
  q = 'WITH a As (
    SELECT
      column_names As names,
      column_vals As vals
    FROM OBS_GetSegment($1, $2)
    ) ' ||
    OBS_BuildSnapshotQuery(column_ids) ||
    ' FROM a';

  RAISE NOTICE 'q: %', q;

  RETURN QUERY
  EXECUTE
  q
  USING the_geom, segment_name;
END;
$$ LANGUAGE plpgsql;

--Base functions for performing augmentation
----------------------------------------------------------------------------------------

--Creates an array-based report of the named segment given a point or geometry
-- TODO: remove or rename since it is based on address lookups

CREATE OR REPLACE FUNCTION OBS_GetSegment(
  address text,
  segment_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group')
RETURNS TABLE (column_names text[], column_vals numeric[])
AS $$
BEGIN

  RETURN QUERY
  EXECUTE
  $query$
    SELECT *
      FROM OBS_GetSegment(cdb_geocode_street_point($1), $2, $3, $4);
  $query$
  USING address,
        segment_name,
        time_span,
        geometry_level;
  RETURN;
END;
$$ LANGUAGE plpgsql;



CREATE OR REPLACE FUNCTION OBS_GetSegment(
  geom geometry,
  segment_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group')
RETURNS TABLE (column_names text[], column_vals numeric[])
AS $$
DECLARE
 column_ids text[];
BEGIN

  EXECUTE
    $query$
    SELECT column_ids
      FROM OBS_DESCRIBE_SEGMENT($1)
     LIMIT 1;
    $query$
  INTO column_ids
  USING segment_name;

  IF column_ids IS NULL THEN
    RAISE EXCEPTION 'Could not find segment ''%''', segment_name;
  END IF;

  RETURN QUERY
    EXECUTE
    $query$
      SELECT * FROM OBS_Get($1, $2, $3, $4);
    $query$
    USING geom,
          column_ids,
          time_span,
          geometry_level;
  RETURN;
END
$$ LANGUAGE plpgsql;


--Grabs the value of a census dimension for given a point or geometry.
-- TODO: remove or move to different function name since it relies on address
CREATE OR REPLACE FUNCTION OBS_GetCensus(
  address text,
  dimension_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
  )
RETURNS numeric as $$
DECLARE
  result numeric;
BEGIN

  EXECUTE
  $query$
    SELECT * from OBS_GetCensus(cdb_geocode_street_point($1), $2, $3, $4);
  $query$
  USING
  address,
  dimension_name,
  time_span,
  geometry_level
  INTO result;

  RETURN result;
END;
$$ LANGUAGE plpgsql;

--Grabs multiple values of census dimensions for given a point or geometry.

CREATE OR REPLACE FUNCTION OBS_GetCensus(
  address text,
  dimension_names text[],
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
  )
RETURNS TABLE( colnames text[], colvalues numeric[]) as $$

BEGIN
  RETURN QUERY
  EXECUTE
  $query$
    SELECT * from OBS_GetCensus(cdb_geocode_street_point($1), $2, $3, $4);
  $query$
  USING
  address,
  dimension_names,
  time_span,
  geometry_level;
  RETURN;
END;
$$ LANGUAGE plpgsql;

--Grabs the value of a census dimension for given a point or geometry.

CREATE OR REPLACE FUNCTION OBS_GetCensus(
  geom geometry,
  dimension_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
)
RETURNS TABLE(dimension text, dimension_value numeric) As $$
DECLARE
  column_id text;
BEGIN
  column_id = OBS_LookupCensusHuman(dimension_name);
  if column_id is null then
    RAISE EXCEPTION 'Column % does not exist ', dimension_name;
  end if;
  RETURN QUERY SELECT unnest(names), unnest(vals) FROM OBS_GET(geom, ARRAY[column_id], time_span, geometry_level);
END;
$$ LANGUAGE plpgsql;


--Returns arrays of values for the given census dimension names for a given
--point or polygon
CREATE OR REPLACE FUNCTION OBS_GetCensus(
  geom geometry,
  dimension_names text[],
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
)
RETURNS TABLE( colnames text[], colvalues numeric[])
AS $$
DECLARE
  ids text[];
BEGIN

  ids  = OBS_LookupCensusHuman(dimension_names);

  RETURN query(SELECT unnest(names), unnest(vals)
               FROM OBS_Get(geom, ids, time_span, geometry_level));
END;
$$ LANGUAGE plpgsql;

--Augments the target table with the desired census variable.
CREATE OR REPLACE FUNCTION OBS_Get_TABLE_WITH_CENSUS(
  table_name text,
  dimension_name text
) RETURNS VOID AS $$
BEGIN
  BEGIN

    EXECUTE format('ALTER TABLE %I add column %I NUMERIC', table_name,dimension_name);
  EXCEPTION
    WHEN duplicate_column then
      RAISE NOTICE 'Column does not exist';
    END;

  EXECUTE format('UPDATE %I
    SET %I = v.%I
    FROM (
      select cartodb_id, OBS_GetCensus(the_geom, %L) as %I
      from %I
    ) v
    WHERE v.cartodb_id= %I.cartodb_id;
  ', table_name, dimension_name,dimension_name,dimension_name,dimension_name,table_name,table_name);

END;
$$ LANGUAGE plpgsql ;


-- Base augmentation fucntion.
CREATE OR REPLACE FUNCTION OBS_GET(
  geom geometry,
  column_ids text[],
  time_span text,
  geometry_level text
)
RETURNS TABLE(names text[], vals NUMERIC[] )
AS $$
DECLARE
	results numeric[];
  geom_table_name text;
  names         text[];
  q             text;
  data_table_info OBS_ColumnData[];
BEGIN

  geom_table_name := OBS_GeomTable(geom,geometry_level);

  if geom_table_name is null then
     RAISE EXCEPTION 'Point % is outside of the data region.', geom;
  end if;

  data_table_info = OBS_GetColumnData(geometry_level, column_ids, time_span);
  names  = (select array_agg((d).colname) from unnest(data_table_info) as  d );

  IF ST_GeometryType(geom) = 'ST_Point' then
    results  = OBS_Get_POINTS(geom, geom_table_name, data_table_info);
  ELSIF ST_GeometryType(geom) in ('ST_Polygon', 'ST_MultiPolygon') then
    results  = OBS_Get_POLYGONS(geom,geom_table_name, data_table_info);
  end if;

  if results is null then
    results= Array[];
  end if;

  return query (select  names, results) ;
END;
$$  LANGUAGE plpgsql;


-- IF the variable of interest is just a rate return it as such, othewise normalize
-- it to the census block area and return that
CREATE OR REPLACE FUNCTION OBS_Get_Points(
  geom geometry,
  geom_table_name text,
  data_table_info OBS_ColumnData[]

) RETURNS NUMERIC[] AS $$
DECLARE
  result NUMERIC[];
  query  text;
  i NUMERIC;
  geoid text;
  area  numeric;
BEGIN

  EXECUTE
    format('select geoid from observatory.%I where  the_geom && $1',  geom_table_name)
    using
    geom
    INTO geoid;

  EXECUTE
    format('select ST_AREA(the_geom::geography) from observatory.%I  where geoid = %L', geom_table_name, geoid)
    INTO
    area ;


  query = 'select Array[';
  FOR i in 1..array_upper(data_table_info,1)
  loop
    IF ((data_table_info)[i]).aggregate != 'sum' THEN
      query = query || format('%I ',((data_table_info)[i]).colname);
    else
      query = query || format('%I/%s ',
        ((data_table_info)[i]).colname,
        area);
    end if;
    IF i <  array_upper(data_table_info,1) THEN
      query = query || ',';
    end if;
  end loop;

  query = query || format(' ]
    from observatory.%I
    where %I.geoid  = %L
  ',
  ((data_table_info)[1]).tablename,
  ((data_table_info)[1]).tablename,
  geoid
  );


  EXECUTE  query  INTO result USING geom ;
  return result;

END
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION OBS_Get_Polygons (
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


  q_select = 'select geoid, ';
  q_sum    = 'select Array[';

  FOR i IN 1..array_upper(data_table_info, 1) LOOP
    q_select = q_select || format( '%I ', ((data_table_info)[i]).colname);

    IF ((data_table_info)[i]).aggregate ='sum' then
      q_sum    = q_sum || format('sum(overlap_fraction * COALESCE(%I,0)) ',((data_table_info)[i]).colname,((data_table_info)[i]).colname);
    else
      q_sum    = q_sum || ' null ';
    end if;

    IF i < array_upper(data_table_info,1) THEN
      q_select = q_select || format(',');
      q_sum     = q_sum || format(',');
	  end IF;
   end LOOP;

  q = format('
    WITH _overlaps AS(
      select  ST_AREA(ST_INTERSECTION($1, a.the_geom))/ST_AREA(a.the_geom) overlap_fraction, geoid
      from observatory.%I as a
      where $1 && a.the_geom
    ),
    values AS(
    ',geom_table_name );

  q = q || q_select || format('from observatory.%I ', ((data_table_info)[1].tablename)) ;

  q = q || ' ) ' || q_sum || ' ] from _overlaps, values
  where values.geoid  = _overlaps.geoid';

  execute q into result using geom;
  RETURN result;

END;
$$ LANGUAGE plpgsql;
