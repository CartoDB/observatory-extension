
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
----vals NUMERIC[];-
----q text;
----BEGIN
----target_cols := Array[<%=get_dimensions_for_tag(tag_name)%>],


--Functions for augmenting specific tables
--------------------------------------------------------------------------------

-- Creates a table of demographic snapshot

CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetDemographicSnapshotJ(geom geometry, time_span text default '2009 - 2013', geometry_level text default '"us.census.tiger".block_group')
RETURNS SETOF JSON
AS $$
  DECLARE 
  target_cols text[];
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
                  --'not_us_citizen_pop',
                  --'workers_16_and_over',
                  --'commuters_by_car_truck_van',
                  --'commuters_drove_alone',
                  --'commuters_by_carpool',
                  --'commuters_by_public_transportation',
                  --'commuters_by_bus',
                  --'commuters_by_subway_or_elevated',
                  --'walked_to_work',
                  --'worked_at_home',
                  --'children',
                  'households',
                  --'population_3_years_over',
                  --'in_school',
                  --'in_grades_1_to_4',
                  --'in_grades_5_to_8',
                  --'in_grades_9_to_12',
                  --'in_undergrad_college',
                  'pop_25_years_over',
                  'high_school_diploma',
                  'less_one_year_college',
                  'one_year_more_college',
                  'associates_degree',
                  'bachelors_degree',
                  'masters_degree',
                  --'pop_5_years_over',
                  --'speak_only_english_at_home',
                  --'speak_spanish_at_home',
                  --'pop_determined_poverty_status',
                  --'poverty',
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
                  --'pop_15_and_over',
                  --'pop_never_married',
                  --'pop_now_married',
                  --'pop_separated',
                  --'pop_widowed',
                  --'pop_divorced',
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
                  'income_150000_199999',
                  'income_200000_or_more',
                  'land_area'];
    RETURN QUERY 
    'select * from cdb_observatory._OBS_GetCensus($1, $2 )'
    USING geom, target_cols
    RETURN;
END;
$$ LANGUAGE plpgsql;

-- CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetDemographicSnapshot(geom geometry, time_span text default '2009 - 2013', geometry_level text default '"us.census.tiger".block_group' )
-- RETURNS TABLE(
--   total_pop NUMERIC,
--   male_pop NUMERIC,
--   female_pop NUMERIC,
--   median_age NUMERIC,
--   white_pop NUMERIC,
--   black_pop NUMERIC,
--   asian_pop NUMERIC,
--   hispanic_pop NUMERIC,
--   amerindian_pop NUMERIC,
--   other_race_pop NUMERIC,
--   two_or_more_races_pop NUMERIC,
--   not_hispanic_pop NUMERIC,
--   --not_us_citizen_pop NUMERIC,
--   --workers_16_and_over NUMERIC,
--   --commuters_by_car_truck_van NUMERIC,
--   --commuters_drove_alone NUMERIC,
--   --commuters_by_carpool NUMERIC,
--   --commuters_by_public_transportation NUMERIC,
--   --commuters_by_bus NUMERIC,
--   --commuters_by_subway_or_elevated NUMERIC,
--   --walked_to_work NUMERIC,
--   --worked_at_home NUMERIC,
--   --children NUMERIC, -- TODO we should be able to get this at BG
--   households NUMERIC,
--   --population_3_years_over NUMERIC,
--   --in_school NUMERIC,
--   --in_grades_1_to_4 NUMERIC,
--   --in_grades_5_to_8 NUMERIC,
--   --in_grades_9_to_12 NUMERIC,
--   --in_undergrad_college NUMERIC,
--   pop_25_years_over NUMERIC,
--   high_school_diploma NUMERIC,
--   less_one_year_college NUMERIC,
--   one_year_more_college NUMERIC,
--   associates_degree NUMERIC,
--   bachelors_degree NUMERIC,
--   masters_degree NUMERIC,
--   --pop_5_years_over NUMERIC,
--   --speak_only_english_at_home NUMERIC,
--   --speak_spanish_at_home NUMERIC,
--   --pop_determined_poverty_status NUMERIC,
--   --poverty NUMERIC,
--   median_income NUMERIC,
--   gini_index NUMERIC,
--   income_per_capita NUMERIC,
--   housing_units NUMERIC,
--   vacant_housing_units NUMERIC,
--   vacant_housing_units_for_rent NUMERIC,
--   vacant_housing_units_for_sale NUMERIC,
--   median_rent NUMERIC,
--   percent_income_spent_on_rent NUMERIC,
--   owner_occupied_housing_units NUMERIC,
--   million_dollar_housing_units NUMERIC,
--   mortgaged_housing_units NUMERIC,
--   --pop_15_and_over NUMERIC,
--   --pop_never_married NUMERIC,
--   --pop_now_married NUMERIC,
--   --pop_separated NUMERIC,
--   --pop_widowed NUMERIC,
--   --pop_divorced NUMERIC,
--   commuters_16_over NUMERIC,
--   commute_less_10_mins NUMERIC,
--   commute_10_14_mins NUMERIC,
--   commute_15_19_mins NUMERIC,
--   commute_20_24_mins NUMERIC,
--   commute_25_29_mins NUMERIC,
--   commute_30_34_mins NUMERIC,
--   commute_35_44_mins NUMERIC,
--   commute_45_59_mins NUMERIC,
--   commute_60_more_mins NUMERIC,
--   aggregate_travel_time_to_work NUMERIC,
--   income_less_10000 NUMERIC,
--   income_10000_14999 NUMERIC,
--   income_15000_19999 NUMERIC,
--   income_20000_24999 NUMERIC,
--   income_25000_29999 NUMERIC,
--   income_30000_34999 NUMERIC,
--   income_35000_39999 NUMERIC,
--   income_40000_44999 NUMERIC,
--   income_45000_49999 NUMERIC,
--   income_50000_59999 NUMERIC,
--   income_60000_74999 NUMERIC,
--   income_75000_99999 NUMERIC,
--   income_100000_124999 NUMERIC,
--   income_125000_149999 NUMERIC,
--   income_150000_199999 NUMERIC,
--   income_200000_or_more NUMERIC,
--   land_area NUMERIC)
-- AS $$
-- DECLARE
--  target_cols text[];
--  names text[];
--  vals NUMERIC[];
--  q text;
-- BEGIN
--  target_cols := Array['total_pop',
--                  'male_pop',
--                  'female_pop',
--                  'median_age',
--                  'white_pop',
--                  'black_pop',
--                  'asian_pop',
--                  'hispanic_pop',
--                  'amerindian_pop',
--                  'other_race_pop',
--                  'two_or_more_races_pop',
--                  'not_hispanic_pop',
--                  --'not_us_citizen_pop',
--                  --'workers_16_and_over',
--                  --'commuters_by_car_truck_van',
--                  --'commuters_drove_alone',
--                  --'commuters_by_carpool',
--                  --'commuters_by_public_transportation',
--                  --'commuters_by_bus',
--                  --'commuters_by_subway_or_elevated',
--                  --'walked_to_work',
--                  --'worked_at_home',
--                  --'children',
--                  'households',
--                  --'population_3_years_over',
--                  --'in_school',
--                  --'in_grades_1_to_4',
--                  --'in_grades_5_to_8',
--                  --'in_grades_9_to_12',
--                  --'in_undergrad_college',
--                  'pop_25_years_over',
--                  'high_school_diploma',
--                  'less_one_year_college',
--                  'one_year_more_college',
--                  'associates_degree',
--                  'bachelors_degree',
--                  'masters_degree',
--                  --'pop_5_years_over',
--                  --'speak_only_english_at_home',
--                  --'speak_spanish_at_home',
--                  --'pop_determined_poverty_status',
--                  --'poverty',
--                  'median_income',
--                  'gini_index',
--                  'income_per_capita',
--                  'housing_units',
--                  'vacant_housing_units',
--                  'vacant_housing_units_for_rent',
--                  'vacant_housing_units_for_sale',
--                  'median_rent',
--                  'percent_income_spent_on_rent',
--                  'owner_occupied_housing_units',
--                  'million_dollar_housing_units',
--                  'mortgaged_housing_units',
--                  --'pop_15_and_over',
--                  --'pop_never_married',
--                  --'pop_now_married',
--                  --'pop_separated',
--                  --'pop_widowed',
--                  --'pop_divorced',
--                  'commuters_16_over',
--                  'commute_less_10_mins',
--                  'commute_10_14_mins',
--                  'commute_15_19_mins',
--                  'commute_20_24_mins',
--                  'commute_25_29_mins',
--                  'commute_30_34_mins',
--                  'commute_35_44_mins',
--                  'commute_45_59_mins',
--                  'commute_60_more_mins',
--                  'aggregate_travel_time_to_work',
--                  'income_less_10000',
--                  'income_10000_14999',
--                  'income_15000_19999',
--                  'income_20000_24999',
--                  'income_25000_29999',
--                  'income_30000_34999',
--                  'income_35000_39999',
--                  'income_40000_44999',
--                  'income_45000_49999',
--                  'income_50000_59999',
--                  'income_60000_74999',
--                  'income_75000_99999',
--                  'income_100000_124999',
--                  'income_125000_149999',
--                  'income_150000_199999',
--                  'income_200000_or_more',
--                  'land_area'];
-- 
--   q :=
--     $query$
--       WITH a As (
--          SELECT
--            array_agg(_OBS_GetCensusJ->>'name') As names,
--            array_agg(_OBS_GetCensusJ->>'value')  As vals
--         FROM cdb_observatory._OBS_GetCensusJ($1,$2,$3,$4)
--       )$query$ ||
--       cdb_observatory._OBS_BuildSnapshotQuery(target_cols) ||
--       ' FROM a'
--     ;
-- 
--   RETURN QUERY
--   EXECUTE
--     q
--   USING geom, target_cols, time_span, geometry_level;
-- 
--   RETURN;
-- END;
-- $$ LANGUAGE plpgsql;


--Base functions for performing augmentation
----------------------------------------------------------------------------------------


--Returns arrays of values for the given census dimension names for a given
--point or polygon
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetCensus(
  geom geometry,
  dimension_names text[],
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
)
RETURNS SETOF JSON
AS $$
DECLARE
  ids text[];
BEGIN

  ids := cdb_observatory._OBS_LookupCensusHuman(dimension_names);

  RETURN QUERY
    SELECT * FROM cdb_observatory._OBS_Get(geom, ids, time_span, geometry_level);
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetCensus(
  geom geometry,
  dimension_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
)
RETURNS NUMERIC
AS $$
DECLARE
  ids Text[];
  result_json json;
  result Numeric;
BEGIN

  ids := cdb_observatory._OBS_LookupCensusHuman(Array[dimension_name]);
  result_json := (SELECT a FROM cdb_observatory._OBS_Get(geom, ids, time_span, geometry_level) as a limit 1);
  EXECUTE
    format('select $1::numeric as "%s"', result_json->>'name')
  INTO result
  USING
    result_json->>'value';
    
  return result;
END;
$$ LANGUAGE plpgsql;


-- Base augmentation fucntion.
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_Get(
  geom geometry,
  column_ids text[],
  time_span text,
  geometry_level text
)
RETURNS SETOF JSON
AS $$
DECLARE
  results json[];
  geom_table_name text;
  names text[];
  query text;
  data_table_info json[];
BEGIN

  geom_table_name := cdb_observatory._OBS_GeomTable(geom, geometry_level);

  IF geom_table_name IS NULL
  THEN
     RAISE NOTICE 'Point % is outside of the data region', geom;
     RETURN QUERY SELECT '{}'::text[], '{}'::NUMERIC[];
  END IF;

  execute'
  select array_agg( _obs_getcolumndata)  from cdb_observatory._OBS_GetColumnData($1,
                                       $2,
                                       $3);'
  INTO   data_table_info
  using geometry_level, column_ids, time_span;
    
  IF ST_GeometryType(geom) = 'ST_Point'
  THEN
    results := cdb_observatory._OBS_GetPoints(geom,
                             geom_table_name,
                             data_table_info);

  ELSIF ST_GeometryType(geom) IN ('ST_Polygon', 'ST_MultiPolygon')
  THEN
    -- RAISE EXCEPTION 'polygons not supported for now';
    results := cdb_observatory._OBS_GetPolygons(geom,
                               geom_table_name,
                               data_table_info);
  END IF;
  
  RETURN QUERY
  EXECUTE
  $query$
    SELECT unnest($1)
  $query$
  USING results;
  
END;
$$ LANGUAGE plpgsql;


-- If the variable of interest is just a rate return it as such,
--  otherwise normalize it to the census block area and return that
CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetPoints(
  geom geometry,
  geom_table_name text,
  data_table_info json[]
)
RETURNS json[]
AS $$
DECLARE
  result NUMERIC[];
  json_result json[];
  query  text;
  i int;
  geoid text;
  area  NUMERIC;
BEGIN

  -- TODO: does 'geoid' need to be generalized to geom_ref??
  EXECUTE
    format('SELECT geoid
            FROM observatory.%I
            WHERE ST_WITHIN($1, the_geom)',
            geom_table_name)
  USING geom
  INTO geoid;

  RAISE NOTICE 'geoid is %, geometry table is % ', geoid, geom_table_name;

  EXECUTE
    format('SELECT ST_Area(the_geom::geography) / (1000 * 1000)
            FROM observatory.%I
            WHERE geoid = %L',
            geom_table_name,
            geoid)
  INTO area;

  IF area IS NULL
  THEN
    RAISE NOTICE 'No geometry at %', ST_AsText(geom);
  END IF;

  query := 'SELECT Array[';
  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    IF area is NULL OR area = 0
    THEN
      -- give back null values
      query := query || format('NULL::numeric ');
    ELSIF ((data_table_info)[i])->>'aggregate' != 'sum'
    THEN
      -- give back full variable
      query := query || format('%I ', ((data_table_info)[i])->>'colname');
    ELSE
      -- give back variable normalized by area of geography
      query := query || format('%I/%s ',
        ((data_table_info)[i])->>'colname',
        area);
    END IF;

    IF i < array_upper(data_table_info, 1)
    THEN
      query := query || ',';
    END IF;
  END LOOP;

  query := query || format(' ]::numeric[]
    FROM observatory.%I
    WHERE %I.geoid  = %L
  ',
  ((data_table_info)[1])->>'tablename',
  ((data_table_info)[1])->>'tablename',
  geoid
  );
  
  EXECUTE
    query
  INTO result
  USING geom;
  
  EXECUTE 
    $query$
     select array_agg(row_to_json(t)) from(
      select values as value,
              meta->>'name'  as name, 
              meta->>'tablename' as tablename,
              meta->>'aggregate' as aggregate,
              meta->>'type'  as type,
              meta->>'description' as description
             from (select unnest($1) as values, unnest($2) as meta) b
      ) t
    $query$
    INTO json_result
    USING result, data_table_info;
  
  RETURN json_result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory.OBS_GetMeasure(
  geom GEOMETRY,
  measure_id TEXT,
  normalize TEXT DEFAULT 'area', -- TODO denominator, none
  boundary_id TEXT DEFAULT NULL,
  time_span TEXT DEFAULT NULL
)
RETURNS JSON
AS $$
DECLARE
  result json;
BEGIN

  IF boundary_id IS NULL THEN
    -- TODO we should determine best boundary for this geom
    boundary_id := '"us.census.tiger".block_group';
  END IF;

  IF time_span IS NULL THEN
    -- TODO we should determine latest timespan for this measure
    time_span := '2009 - 2013';
  END IF;

  
  EXECUTE  '
    SELECT * FROM cdb_observatory._OBS_Get($1, ARRAY[$2], $3, $4)  LIMIT 1
  '
  INTO result
  USING geom, measure_id, time_span, boundary_id;

  RETURN result;
END;
$$ LANGUAGE plpgsql;


CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetPolygons(
  geom geometry,
  geom_table_name text,
  data_table_info json[]
)
RETURNS json[]
AS $$
DECLARE
  result numeric[];
  json_result json[];
  q_select text;
  q_sum text;
  q text;
  i NUMERIC;
BEGIN

  q_select := 'SELECT geoid, ';
  q_sum    := 'SELECT Array[';

  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    q_select := q_select || format( '%I ', ((data_table_info)[i])->>'colname');

    IF ((data_table_info)[i])->>'aggregate' ='sum'
    THEN
      q_sum := q_sum || format('sum(overlap_fraction * COALESCE(%I, 0)) ',((data_table_info)[i])->>'colname',((data_table_info)[i])->>'colname');
    ELSE
      q_sum := q_sum || ' NULL::numeric ';
    END IF;

    IF i < array_upper(data_table_info,1)
    THEN
      q_select := q_select || format(',');
      q_sum := q_sum || format(',');
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

  q := q || q_select || format('FROM observatory.%I ', ((data_table_info)[1]->>'tablename'));

  q := q || ' ) ' || q_sum || ' ]::numeric[] FROM _overlaps, values
  WHERE values.geoid = _overlaps.geoid';
  
  EXECUTE
    q
  INTO result
  USING geom;
  
  EXECUTE 
    $query$
     select array_agg(row_to_json(t)) from(
      select values as value,
              meta->>'name'  as name, 
              meta->>'tablename' as tablename,
              meta->>'aggregate' as aggregate,
              meta->>'type'  as type,
              meta->>'description' as description
             from (select unnest($1) as values, unnest($2) as meta) b
      ) t
    $query$
    INTO json_result
    USING result, data_table_info;
  
  RETURN json_result;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION OBS_GetSegmentSnapshot(geom geometry, geometry_level text default '"us.census.tiger".census_tract')
RETURNS json
AS $$
  BEGIN
    RETURN row_to_json(cdb_observatory._OBS_GetSegmentSnapshot(geom, geometry_level));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION _OBS_GetSegmentSnapshot(
  geom geometry,
  geometry_level text DEFAULT '"us.census.tiger".census_tract'
 )
RETURNS TABLE(
  segment_name TEXT,
  total_pop_quantile NUMERIC,
  male_pop_quantile NUMERIC,
  female_pop_quantile NUMERIC,
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
  million_dollar_housing_units_quantile NUMERIC
) 
AS $$
DECLARE
  target_cols text[];
  seg_name    Text;
  geom_id     Text;
  q           Text;
BEGIN
target_cols := Array[
          '"us.census.acs".B01001001_quantile',
          '"us.census.acs".B01001002_quantile',
          '"us.census.acs".B01001026_quantile',
          '"us.census.acs".B01002001_quantile',
          '"us.census.acs".B03002003_quantile',
          '"us.census.acs".B03002004_quantile',
          '"us.census.acs".B03002006_quantile',
          '"us.census.acs".B03002012_quantile',
          '"us.census.acs".B05001006_quantile',--
          '"us.census.acs".B08006001_quantile',--
          '"us.census.acs".B08006002_quantile',--
          '"us.census.acs".B08006008_quantile',--
          '"us.census.acs".B08006009_quantile',--
          '"us.census.acs".B08006011_quantile',--
          '"us.census.acs".B08006015_quantile',--
          '"us.census.acs".B08006017_quantile',--
          '"us.census.acs".B09001001_quantile',--
          '"us.census.acs".B11001001_quantile',
          '"us.census.acs".B14001001_quantile',--
          '"us.census.acs".B14001002_quantile',--
          '"us.census.acs".B14001005_quantile',--
          '"us.census.acs".B14001006_quantile',--
          '"us.census.acs".B14001007_quantile',--
          '"us.census.acs".B14001008_quantile',--
          '"us.census.acs".B15003001_quantile',
          '"us.census.acs".B15003017_quantile',
          '"us.census.acs".B15003022_quantile',
          '"us.census.acs".B15003023_quantile',
          '"us.census.acs".B16001001_quantile',--
          '"us.census.acs".B16001002_quantile',--
          '"us.census.acs".B16001003_quantile',--
          '"us.census.acs".B17001001_quantile',--
          '"us.census.acs".B17001002_quantile',--
          '"us.census.acs".B19013001_quantile',
          '"us.census.acs".B19083001_quantile',
          '"us.census.acs".B19301001_quantile',
          '"us.census.acs".B25001001_quantile',
          '"us.census.acs".B25002003_quantile',
          '"us.census.acs".B25004002_quantile',
          '"us.census.acs".B25004004_quantile',
          '"us.census.acs".B25058001_quantile',
          '"us.census.acs".B25071001_quantile',
          '"us.census.acs".B25075001_quantile',
          '"us.census.acs".B25075025_quantile'
               ];

    EXECUTE
      $query$
      SELECT (categories)[1]
      FROM cdb_observatory._OBS_GetCategories(
         $1,
         Array['"us.census.spielman_singleton_segments".X10'],
         $2)
      LIMIT 1
      $query$
    INTO segment_name
    USING geom, geometry_level;

    q :=
      format($query$
      WITH a As (
           SELECT
             names As names,
             vals As vals
           FROM cdb_observatory._OBS_Get($1,
                        $2,
                        '2009 - 2013',
                        $3)

        ), percentiles As (
           %s
         FROM  a)
        SELECT $4, percentiles.*
          FROM percentiles
       $query$, cdb_observatory._OBS_BuildSnapshotQuery(target_cols));

    RETURN QUERY
    EXECUTE
      q
    USING geom, target_cols, geometry_level, segment_name;

END;
$$ LANGUAGE plpgsql;

--Get categorical variables from point

CREATE OR REPLACE FUNCTION cdb_observatory._OBS_GetCategories(
  geom geometry,
  dimension_names text[],
  geometry_level text DEFAULT '"us.census.tiger".block_group',
  time_span text DEFAULT '2009 - 2013'
)
RETURNS SETOF JSON as $$
DECLARE
  geom_table_name text;
  geoid text;
  names text[];
  results text[];
  query text;
  data_table_info json[];
BEGIN

  geom_table_name := cdb_observatory._OBS_GeomTable(geom, geometry_level);

  IF geom_table_name IS NULL
  THEN
     RAISE NOTICE 'Point % is outside of the data region', ST_AsText(geom);
     RETURN QUERY SELECT '{}'::text[], '{}'::text[];
  END IF;

  execute'
  select array_agg( _obs_getcolumndata)  from cdb_observatory._OBS_GetColumnData($1,
                                       $2,
                                       $3);'
  INTO   data_table_info
  using geometry_level, dimension_names, time_span;


  EXECUTE
    format('SELECT geoid
            FROM observatory.%I
            WHERE the_geom && $1',
            geom_table_name)
  USING geom
  INTO geoid;

  query := 'SELECT ARRAY[';
  FOR i IN 1..array_upper(data_table_info, 1)
  LOOP
    query = query || format('%I ', lower(((data_table_info)[i])->>'colname'));
    IF i <  array_upper(data_table_info, 1)
    THEN
      query := query || ',';
    END IF;
  END LOOP;

  query := query || format(' ]::text[]
    FROM observatory.%I
    WHERE %I.geoid  = %L
  ',
  ((data_table_info)[1])->>'tablename',
  ((data_table_info)[1])->>'tablename',
  geoid
  );

  EXECUTE
    query
  INTO results
  USING geom;
  
  RETURN QUERY
  EXECUTE 
    $query$
     select row_to_json(t) from(
      select categories as category,
              meta->>'name'  as name, 
              meta->>'tablename' as tablename,
              meta->>'aggregate' as aggregate,
              meta->>'type'  as type,
              meta->>'description' as description
             from (select unnest($1) as categories, unnest($2) as meta) b
      ) t
    $query$
    USING results, data_table_info;
  RETURN;

END;
$$ LANGUAGE plpgsql;
