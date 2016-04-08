
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
  male_pop NUMERIC,
  female_pop NUMERIC,
  median_age NUMERIC,
  white_pop NUMERIC,
  black_pop NUMERIC,
  asian_pop NUMERIC,
  hispanic_pop NUMERIC,
  amerindian_pop NUMERIC,
  other_race_pop NUMERIC,
  two_or_more_races_pop NUMERIC,
  not_hispanic_pop NUMERIC,
  not_us_citizen_pop NUMERIC,
  workers_16_and_over NUMERIC,
  commuters_by_car_truck_van NUMERIC,
  commuters_drove_alone NUMERIC,
  commuters_by_carpool NUMERIC,
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
  less_one_year_college NUMERIC,
  one_year_more_college NUMERIC,
  associates_degree NUMERIC,
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
  mortgaged_housing_units NUMERIC,
  pop_15_and_over NUMERIC,
  pop_never_married NUMERIC,
  pop_now_married NUMERIC,
  pop_separated NUMERIC,
  pop_widowed NUMERIC,
  pop_divorced NUMERIC,
  commuters_16_over NUMERIC,
  commute_less_10_mins NUMERIC,
  commute_10_14_mins NUMERIC,
  commute_15_19_mins NUMERIC,
  commute_20_24_mins NUMERIC,
  commute_25_29_mins NUMERIC,
  commute_30_34_mins NUMERIC,
  commute_35_44_mins NUMERIC,
  commute_45_59_mins NUMERIC,
  commute_60_more_mins NUMERIC,
  aggregate_travel_time_to_work NUMERIC,
  income_less_10000 NUMERIC,
  income_10000_14999 NUMERIC,
  income_15000_19999 NUMERIC,
  income_20000_24999 NUMERIC,
  income_25000_29999 NUMERIC,
  income_30000_34999 NUMERIC,
  income_35000_39999 NUMERIC,
  income_40000_44999 NUMERIC,
  income_45000_49999 NUMERIC,
  income_50000_59999 NUMERIC,
  income_60000_74999 NUMERIC,
  income_75000_99999 NUMERIC,
  income_100000_124999 NUMERIC,
  income_125000_149999 NUMERIC,
  income_150000_199999 NUMERIC
)
AS $$
DECLARE
 target_cols text[];
 names text[];
 vals numeric[];
 q text;
 BEGIN
 target_cols := Array['total_pop',
                 'male_pop',
                 'female_pop',
                 'median_age',
                 'white_pop',
                 'black_pop',
                 'asian_pop',
                 'hispanic_pop',
                 'amerindian_pop',
                 'other_race_pop',
                 'two_or_more_races_pop',
                 'not_hispanic_pop',
                 'not_us_citizen_pop',
                 'workers_16_and_over',
                 'commuters_by_car_truck_van',
                 'commuters_drove_alone',
                 'commuters_by_carpool',
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
                 'less_one_year_college',
                 'one_year_more_college',
                 'associates_degree',
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
                 'mortgaged_housing_units',
                 'pop_15_and_over',
                 'pop_never_married',
                 'pop_now_married',
                 'pop_separated',
                 'pop_widowed',
                 'pop_divorced',
                 'commuters_16_over',
                 'commute_less_10_mins',
                 'commute_10_14_mins',
                 'commute_15_19_mins',
                 'commute_20_24_mins',
                 'commute_25_29_mins',
                 'commute_30_34_mins',
                 'commute_35_44_mins',
                 'commute_45_59_mins',
                 'commute_60_more_mins',
                 'aggregate_travel_time_to_work',
                 'income_less_10000',
                 'income_10000_14999',
                 'income_15000_19999',
                 'income_20000_24999',
                 'income_25000_29999',
                 'income_30000_34999',
                 'income_35000_39999',
                 'income_40000_44999',
                 'income_45000_49999',
                 'income_50000_59999',
                 'income_60000_74999',
                 'income_75000_99999',
                 'income_100000_124999',
                 'income_125000_149999',
                 'income_150000_199999'
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

CREATE OR REPLACE FUNCTION OBS_GET_SEGMENT(geom geometry)
RETURNS TABLE(
  segment_name TEXT,
  total_pop_quantile NUMERIC,
  female_pop_quantile NUMERIC,
  male_pop_quantile NUMERIC,
  median_age_quantile NUMERIC,
  white_pop_quantile NUMERIC,
  black_pop_quantile NUMERIC,
  asian_pop_quantile NUMERIC,
  hispanic_pop_quantile NUMERIC,
  not_us_citizen_pop_quantile NUMERIC,
  workers_16_and_over_quantile NUMERIC,
  commuters_by_car_truck_van_quantile NUMERIC,
  commuters_by_public_transportation_quantile NUMERIC,
  commuters_by_bus_quantile NUMERIC,
  commuters_by_subway_or_elevated_quantile NUMERIC,
  walked_to_work_quantile NUMERIC,
  worked_at_home_quantile NUMERIC,
  children_quantile NUMERIC,
  households_quantile NUMERIC,
  population_3_years_over_quantile NUMERIC,
  in_school_quantile NUMERIC,
  in_grades_1_to_4_quantile NUMERIC,
  in_grades_5_to_8_quantile NUMERIC,
  in_grades_9_to_12_quantile NUMERIC,
  in_undergrad_college_quantile NUMERIC,
  pop_25_years_over_quantile NUMERIC,
  high_school_diploma_quantile NUMERIC,
  bachelors_degree_quantile NUMERIC,
  masters_degree_quantile NUMERIC,
  pop_5_years_over_quantile NUMERIC,
  speak_only_english_at_home_quantile NUMERIC,
  speak_spanish_at_home_quantile NUMERIC,
  pop_determined_poverty_status_quantile NUMERIC,
  poverty_quantile NUMERIC,
  median_income_quantile NUMERIC,
  gini_index_quantile NUMERIC,
  income_per_capita_quantile NUMERIC,
  housing_units_quantile NUMERIC,
  vacant_housing_units_quantile NUMERIC,
  vacant_housing_units_for_rent_quantile NUMERIC,
  vacant_housing_units_for_sale_quantile NUMERIC,
  median_rent_quantile NUMERIC,
  percent_income_spent_on_rent_quantile NUMERIC,
  owner_occupied_housing_units_quantile NUMERIC,
  million_dollar_housing_units_quantile NUMERIC,
  mortgaged_housing_unit_quantile NUMERIC

) AS $$
DECLARE
  target_cols Numeric[];
BEGIN
target_cols := Array[
                'total_pop_quantile',
                'female_pop_quantile',
                'male_pop_quantile',
                'median_age_quantile',
                'white_pop_quantile',
                'black_pop_quantile',
                'asian_pop_quantile',
                'hispanic_pop_quantile',
                'not_us_citizen_pop_quantile',
                'workers_16_and_over_quantile',
                'commuters_by_car_truck_van_quantile',
                'commuters_by_public_transportation_quantile',
                'commuters_by_bus_quantile',
                'commuters_by_subway_or_elevated_quantile',
                'walked_to_work_quantile',
                'worked_at_home_quantile',
                'children_quantile',
                'households_quantile',
                'population_3_years_over_quantile',
                'in_school_quantile',
                'in_grades_1_to_4_quantile',
                'in_grades_5_to_8_quantile',
                'in_grades_9_to_12_quantile',
                'in_undergrad_college_quantile',
                'pop_25_years_over_quantile',
                'high_school_diploma_quantile',
                'bachelors_degree_quantile',
                'masters_degree_quantile',
                'pop_5_years_over_quantile',
                'speak_only_english_at_home_quantile',
                'speak_spanish_at_home_quantile',
                'pop_determined_poverty_status_quantile',
                'poverty_quantile',
                'median_income_quantile',
                'gini_index_quantile',
                'income_per_capita_quantile',
                'housing_units_quantile',
                'vacant_housing_units_quantile',
                'vacant_housing_units_for_rent_quantile',
                'vacant_housing_units_for_sale_quantile',
                'median_rent_quantile',
                'percent_income_spent_on_rent_quantile',
                'owner_occupied_housing_units_quantile',
                'million_dollar_housing_units_quantile',
                'mortgaged_housing_unit_quantile'
               ];

END $$ LANGUAGE plpgsql  ;

CREATE OR REPLACE FUNCTION OBS_GetDemographicSnapshot(geom geometry)
RETURNS TABLE(
  total_pop NUMERIC,
  male_pop NUMERIC,
  female_pop NUMERIC,
  median_age NUMERIC,
  white_pop NUMERIC,
  black_pop NUMERIC,
  asian_pop NUMERIC,
  hispanic_pop NUMERIC,
  amerindian_pop NUMERIC,
  other_race_pop NUMERIC,
  two_or_more_races_pop NUMERIC,
  not_hispanic_pop NUMERIC,
  not_us_citizen_pop NUMERIC,
  workers_16_and_over NUMERIC,
  commuters_by_car_truck_van NUMERIC,
  commuters_drove_alone NUMERIC,
  commuters_by_carpool NUMERIC,
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
  less_one_year_college NUMERIC,
  one_year_more_college NUMERIC,
  associates_degree NUMERIC,
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
  mortgaged_housing_units NUMERIC,
  pop_15_and_over NUMERIC,
  pop_never_married NUMERIC,
  pop_now_married NUMERIC,
  pop_separated NUMERIC,
  pop_widowed NUMERIC,
  pop_divorced NUMERIC,
  commuters_16_over NUMERIC,
  commute_less_10_mins NUMERIC,
  commute_10_14_mins NUMERIC,
  commute_15_19_mins NUMERIC,
  commute_20_24_mins NUMERIC,
  commute_25_29_mins NUMERIC,
  commute_30_34_mins NUMERIC,
  commute_35_44_mins NUMERIC,
  commute_45_59_mins NUMERIC,
  commute_60_more_mins NUMERIC,
  aggregate_travel_time_to_work NUMERIC,
  income_less_10000 NUMERIC,
  income_10000_14999 NUMERIC,
  income_15000_19999 NUMERIC,
  income_20000_24999 NUMERIC,
  income_25000_29999 NUMERIC,
  income_30000_34999 NUMERIC,
  income_35000_39999 NUMERIC,
  income_40000_44999 NUMERIC,
  income_45000_49999 NUMERIC,
  income_50000_59999 NUMERIC,
  income_60000_74999 NUMERIC,
  income_75000_99999 NUMERIC,
  income_100000_124999 NUMERIC,
  income_125000_149999 NUMERIC,
  income_150000_199999 NUMERIC
)
AS $$
DECLARE
 target_cols text[];
 names text[];
 vals numeric[];
 q text;
 BEGIN
 target_cols := Array['total_pop',
                 'male_pop',
                 'female_pop',
                 'median_age',
                 'white_pop',
                 'black_pop',
                 'asian_pop',
                 'hispanic_pop',
                 'amerindian_pop',
                 'other_race_pop',
                 'two_or_more_races_pop',
                 'not_hispanic_pop',
                 'not_us_citizen_pop',
                 'workers_16_and_over',
                 'commuters_by_car_truck_van',
                 'commuters_drove_alone',
                 'commuters_by_carpool',
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
                 'less_one_year_college',
                 'one_year_more_college',
                 'associates_degree',
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
                 'mortgaged_housing_units',
                 'pop_15_and_over',
                 'pop_never_married',
                 'pop_now_married',
                 'pop_separated',
                 'pop_widowed',
                 'pop_divorced',
                 'commuters_16_over',
                 'commute_less_10_mins',
                 'commute_10_14_mins',
                 'commute_15_19_mins',
                 'commute_20_24_mins',
                 'commute_25_29_mins',
                 'commute_30_34_mins',
                 'commute_35_44_mins',
                 'commute_45_59_mins',
                 'commute_60_more_mins',
                 'aggregate_travel_time_to_work',
                 'income_less_10000',
                 'income_10000_14999',
                 'income_15000_19999',
                 'income_20000_24999',
                 'income_25000_29999',
                 'income_30000_34999',
                 'income_35000_39999',
                 'income_40000_44999',
                 'income_45000_49999',
                 'income_50000_59999',
                 'income_60000_74999',
                 'income_75000_99999',
                 'income_100000_124999',
                 'income_125000_149999',
                 'income_150000_199999'
  ];

  q = 'WITH a As (
         SELECT
           dimension As names,
           dimension_value As vals
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
RETURNS TABLE( dimension text[], dimension_value numeric[]) as $$

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
  RETURN QUERY SELECT unnest(names), unnest(vals)
                 FROM OBS_Get(geom,
                              ARRAY[column_id],
                              time_span,
                              geometry_level);
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
RETURNS TABLE(dimension text[], dimension_value numeric[])
AS $$
DECLARE
  ids text[];

BEGIN

  ids  = OBS_LookupCensusHuman(dimension_names);

  RETURN QUERY
   SELECT * from OBS_Get(geom, ids, time_span, geometry_level);

END;
$$ LANGUAGE plpgsql;


--TODO: work on this
--Augments the target table with the desired census variable.
-- OLD: OBS_Get_TABLE_WITH_CENSUS
CREATE OR REPLACE FUNCTION OBS_GetTableWithCensus(
  table_name text,
  dimension_name text
) RETURNS VOID AS $$
BEGIN

    EXECUTE format('ALTER TABLE %I add column %I NUMERIC', table_name,dimension_name);
  EXCEPTION
    WHEN duplicate_column then
      RAISE NOTICE 'Column does not exist';
    END;

  EXECUTE format('
    UPDATE %I
    SET %I = v.%I
    FROM (
      SELECT cartodb_id,
             OBS_GetCensus(the_geom, %L) As %I
      FROM %I
    ) As v
    WHERE v.cartodb_id = %I.cartodb_id
  ', table_name,
     dimension_name,
     dimension_name,
     dimension_name,
     dimension_name,
     table_name,
     table_name);
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
