# Measures

Measures Services allow users to access geospatial measures for analysis workflows. Measures are used by sending an identifier or a geometry (Point or Polygon) and receiving back a measure or absolute value for that location. Every measure contained in the Data Catalog can be accessed through the CartoDB Editor.

Below are the methods. For detailed information for accessing any measures, see the catalog here, [Catalog PDF](http://cartodb.github.io/bigmetadata/index.html)

## OBS_GetUSCensusMeasure(point_geometry, measure_name);

The ```OBS_GetUSCensusMeasure(point_geometry, measure_name)``` method returns a measure based on a subset of the US Census variables at a point location. The ```OBS_GetUSCensusMeasure``` method is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetMeasure``` method below.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The glossary of measure_names is [available below]('measure_name table').
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the

#### Returns

A NUMERIC value containing the following properties

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a Measure to an empty column based on point locations in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetUSCensusMeasure(the_geom, 'Male Population')
```

Get a measure at a single point location

```SQL
SELECT OBS_GetUSCensusMeasure(CDB_LatLng(40.7, -73.9), 'Male Population')
```

<!--
Should add the SQL API call here too
-->


## OBS_GetUSCensusMeasure(polygon_geometry, measure_name);

The ```OBS_GetUSCensusMeasure(point_geometry, measure_name)``` method returns a measure based on a subset of the US Census variables within a given polygon. The ```OBS_GetUSCensusMeasure``` method is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetUSCensusMeasure``` method below.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 polygon geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The glossary of measure_names is [available below]('measure_name table').
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) (optional)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a Measure to an empty column based on polygons in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetUSCensusMeasure(the_geom, 'Male Population')
```

Get a measure at a single polygon

```SQL
SELECT OBS_GetMeasure(ST_Buffer(CDB_LatLng(40.7, -73.9),0.001), 'Male Population')
```

<!--
Should add the SQL API call here too
-->


## OBS_GetUSCensusCategory(point_geometry, measure_name);

The ```OBS_GetUSCensusCategory(point_geometry, category_name)``` method returns a categorical measure based on a subset of the US Census variables at a point location. It requires a different function from ```OBS_GetUSCensusMeasure``` because this function will always return TEXT, whereas ```OBS_GetUSCensusMeasure``` will always returna  NUMERIC value.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The glossary of measure_names is [available below]('measure_name table').
#### Returns

A NUMERIC value containing the following properties

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a Measure to an empty column based on point locations in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetUSCensusCategory(the_geom, 'Spielman Singleton Category 10')
```

Get a measure at a single point location

```SQL
SELECT OBS_GetUSCensusCategory(CDB_LatLng(40.7, -73.9), 'Spielman Singleton Category 10')
```

<!--
Should add the SQL API call here too
-->

## OBS_GetMeasure(point_geometry, measure_id);

The ```OBS_GetMeasure(point_geometry, measure_id)``` method returns any Data Observatory measure at a point location.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](http://cartodb.github.io/bigmetadata/index.html))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) and 'none' which will return a raw value. (optional)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a Measure to an empty column based on point locations in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetMeasure(the_geom, '"us.census.acs".B08134006')
```

Get a measure at a single point location

```SQL
SELECT OBS_GetMeasure(CDB_LatLng(40.7, -73.9), '"us.census.acs".B08134006')
```

<!--
Should add the SQL API call here too
-->


## OBS_GetMeasure(polygon_geometry, measure_id);

The ```OBS_GetMeasure(polygon_geometry, measure_id)``` method returns any Data Observatory measure calculated within a polygon.

#### Arguments

Name |Description
--- | ---
polygon_geometry | a WGS84 polygon geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](http://cartodb.github.io/bigmetadata/index.html))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) (optional)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a Measure to an empty column based on polygons in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetMeasure(the_geom, '"us.census.acs".B08134006')
```

Get a measure within a polygon

```SQL
SELECT OBS_GetMeasure(ST_Buffer(CDB_LatLng(40.7, -73.9),0.001), '"us.census.acs".B08134006')


```

<!--
Should add the SQL API call here too
-->

---

# Boundaries


## OBS_GetBoundary(point_geometry, boundary_id)

The ```OBS_GetBoundary(point_geometry, boundary_id)``` method returns a boundary geometry defined as overlapping the point geometry and from the desired boundary set (e.g. Census Tracts). See the [Boundary ID glossary table below](below). This is a useful method for performing aggregations of points.

#### Arguments

Name | Description
--- | ---
point_geometry | a WGS84 polygon geometry (the_geom)
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)

#### Returns

Value | Description
--- | ---
geom | WKB geometry

#### Example

Overwrite a point geometry with a boundary geometry that contains it in your table

```SQL
UPDATE tablename
SET the_geom = OBS_GetBoundary(the_geom, '"us.census.tiger".block_group')
```

<!--
Should add the SQL API call here too
-->

## OBS_GetBoundaryId(point_geometry, boundary_id)

The ```OBS_GetBoundaryId(point_geometry, boundary_id)``` returns a unique geometry_id for the boundary geometry that contains a given point geometry. See the [Boundary ID glossary table below](below). The method can be combined with ```OBS_GetBoundaryById(geometry_id)``` to create a point aggregation workflow.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)

#### Returns

Value | Description
--- | ---
geometry_id | a string identifier of a geometry in the Boundaries

#### Example

Write the geometry_id that contains the point geometry for every row as a new column in your table

```SQL
UPDATE tablename
SET new_column_name = OBS_GetBoundaryId(the_geom, ' "us.census.tiger".block_group')
```

## OBS_GetBoundaryById(geometry_id, boundary_id)

The ```OBS_GetBoundaryById(geometry_id, boundary_id)``` returns the boundary geometry for a unique geometry_id. A geometry_id can be found using the ```OBS_GetBoundaryId(point_geometry, boundary_id)``` method described above.

#### Arguments

Name | Description
--- | ---
geometry_id | a string identifier for a Boundary geometry
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)

#### Returns

A JSON object containing the following properties

Key | Description
--- | ---
geom | a WGS84 polygon geometry

#### Example

Use a table of geometry_id to select the unique boundaries. Useful with the ```Create Dataset from Query``` option in CartoDB.

```SQL
SELECT OBS_GetBoundaryById(geometry_id) As the_geom, geometry_id
FROM tablename
GROUP BY geometry_id
```

## OBS_GetBoundariesByGeometry(geometry, geometry_id)

The ```OBS_GetBoundariesByGeometry(geometry, geometry_id)``` method returns the boundary geometries and their geographical identifiers that intersect (or are contained by) a bounding box polygon.

#### Arguments

Name |Description
--- | ---
geometry | a bounding box
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of 'intersects' (default), 'contains', or 'within'. See [ST_Intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html), [ST_Contains](http://postgis.net/docs/manual-2.2/ST_Contains.html), or [ST_Within](http://postgis.net/docs/manual-2.2/ST_Within.html) for more

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a boundary geometry (e.g., US Census tracts)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get all Census Tracts in Lower Manhattan (geoids beginning with `36061`) without getting Brooklyn or New Jersey

```sql
SELECT *
FROM OBS_GetBoundariesByGeometry(
  ST_MakeEnvelope(-74.0251922607,40.6945658517,
                  -73.9651107788,40.7377626342,
                  4326),
  '"us.census.tiger".census_tract')
WHERE geom_ref like '36061%'
```

#### API Example

Retrieve all Census tracts contained in a bounding box around Denver, CO as a JSON response:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetBoundariesByGeometry(ST_MakeEnvelope(-105.4287704158,39.4600507935,-104.5089737248,40.0901569675,4326),%27%22us.census.tiger%22.census_tract%27,%272009%27,%27contains%27)
```

## OBS_GetPointsByGeometry(geometry, geometry_id)

The ```OBS_GetPointsByGeometry(geometry, geometry_id)``` method returns point geometries and their geographical identifiers that intersect (or are contained by) a bounding box polygon and lie on the surface of a boundary corresponding to the boundary with same geographical identifiers (e.g., a point that is on a census tract with the same geoid).

#### Arguments

Name |Description
--- | ---
geometry | a bounding box
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of 'intersects' (default), 'contains', or 'within'. See [ST_Intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html), [ST_Contains](http://postgis.net/docs/manual-2.2/ST_Contains.html), or [ST_Within](http://postgis.net/docs/manual-2.2/ST_Within.html) for more

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a point geometry on a boundary (e.g., a point that lies on a US Census tract)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get points in all Census Tracts in Lower Manhattan (geoids beginning with `36061`) without getting Brooklyn or New Jersey

```sql
SELECT *
FROM OBS_GetPointsByGeometry(
  ST_MakeEnvelope(-74.0251922607,40.6945658517,
                  -73.9651107788,40.7377626342,
                  4326),
  '"us.census.tiger".census_tract')
WHERE geom_ref like '36061%'
```

#### API Example

Retrieve all Census tracts contained in a bounding box around Denver, CO as a JSON response:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetPointsByGeometry(ST_MakeEnvelope(-105.4287704158,39.4600507935,-104.5089737248,40.0901569675,4326),%27%22us.census.tiger%22.census_tract%27,%272009%27,%27contains%27)
```

## OBS_GetBoundariesByPointAndRadius(geometry, radius, boundary_id)

The ```OBS_GetBoundariesByPointAndRadius(geometry, radius, boundary_id)``` method returns boundary geometries and their geographical identifiers that intersect (or are contained by) a circle centered on a point with a radius.

#### Arguments

Name |Description
--- | ---
geometry | a point geometry
radius | a radius (in meters) from the center point
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of 'intersects' (default), 'contains', or 'within'. See [ST_Intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html), [ST_Contains](http://postgis.net/docs/manual-2.2/ST_Contains.html), or [ST_Within](http://postgis.net/docs/manual-2.2/ST_Within.html) for more

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a boundary geometry (e.g., a US Census tract)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get Census tracts which intersect within 10 miles of Downtown, Colorado.

```sql
SELECT *
FROM OBS_GetBoundariesByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  '"us.census.tiger".census_tract')
```

#### API Example

Retrieve all Census tracts contained in a bounding box around Denver, CO as a JSON response:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetBoundariesByPointAndRadius(CDB_LatLng(39.7392,-104.9903),10000*1609),%27%22us.census.tiger%22.census_tract%27,%272009%27,%27contains%27)
```

## OBS_GetPointsByPointAndRadius(geometry, radius, boundary_id)

The ```OBS_GetPointsByPointAndRadius(geometry, radius, boundary_id)``` method returns point geometries on boundaries (e.g., a point that lies on a Census tract) and their geographical identifiers that intersect (or are contained by) a circle centered on a point with a radius.

#### Arguments

Name |Description
--- | ---
geometry | a point geometry
radius | radius (in meters)
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of 'intersects' (default), 'contains', or 'within'. See [ST_Intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html), [ST_Contains](http://postgis.net/docs/manual-2.2/ST_Contains.html), or [ST_Within](http://postgis.net/docs/manual-2.2/ST_Within.html) for more

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a point geometry (e.g., a point on a US Census tract)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get Census tracts which intersect within 10 miles of Downtown, Colorado.

```sql
SELECT *
FROM OBS_GetPointsByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  '"us.census.tiger".census_tract')
```

#### API Example

Retrieve all Census tracts contained in a bounding box around Denver, CO as a JSON response:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetPointsByPointAndRadius(CDB_LatLng(39.7392,-104.9903),10000*1609),%27%22us.census.tiger%22.census_tract%27,%272009%27,%27contains%27)
```

# Discovery

## OBS_Search(search_term)

Use arbitrary text to search all available Measures

#### Arguments

Name | Description
--- | ---
search_term | a string to search for available Measures
boundary_id | a string identifier for a Boundary geometry (optional)

#### Returns

Key | Description
--- | ---
measure_id | the unique id of the measure for use with the ```OBS_GetMeasure``` method
name | the human readable name of the measure
description | a brief description of the measure
aggregate_type | **sum** are raw count values, **median** are statistical medians, **average** are statistical averages, **undefined** other (e.g. an index value)
sources | where the data came from (e.g. US Census Bureau)

#### Example

```SQL
SELECT * FROM OBS_Search('inequality')
```

## OBS_GetAvailableBoundaries(point_geometry)

Returns available boundary_ids at a given point geometry.

#### Arguments

Name | Description
--- | ---
point_geometry |  a WGS84 point geometry (e.g. the_geom)

#### Returns

Key | Description
--- | ---
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)  
description | a brief description of the boundary dataset
timespan | the timespan attached the boundary. this does not mean that the boundary is invalid outside of the timespan, but is the explicit timespan published with the geometry.

#### Example

```SQL
SELECT * FROM OBS_GetAvailableBoundaries(CDB_LatLng(40.7, -73.9))
```

# Glossary

#### Boundary IDs

Boundary name   |  Boundary ID
--------------------- | ---
US Census Block Groups  |  "us.census.tiger".block_group
US Census Tracts  |  "us.census.tiger".census_tract
US States  |  "us.census.tiger".state
US County  |  "us.census.tiger".county
US Census Public Use Microdata Areas  |  "us.census.tiger".puma
US Census Zip Code Tabulation Areas  |  "us.census.tiger".zcta5
Unified School District  |  "us.census.tiger".school_district_unified
US Congressional Districts  |  "us.census.tiger".congressional_district
Elementary School District  |  "us.census.tiger".school_district_elementary
Secondary School District  |  "us.census.tiger".school_district_secondary
US Census Blocks  |  "us.census.tiger".block

#### OBS_GetUSCensusMeasure names table

Below is a list of human readable names accepted in the ```OBS_GetUSCensusMeasure``` method. For the more comprehensive list of columns available to the ```OBS_GetMeasure``` method, see the [Data Catalog]

Measure name   |  Measure description
--------------------- | ---
Total Population  |  The total number of all people living in a given geographic area.  This is a very useful catch-all denominator when calculating rates.
Male Population  |  The number of people within each geography who are male.
Female Population  |  The number of people within each geography who are female.
Median Age  |  The median age of all people in a given geographic area.
White Population  |  The number of people identifying as white, non-Hispanic in each geography.
Black or African American Population  |  The number of people identifying as black or African American, non-Hispanic in each geography.
Asian Population  |  The number of people identifying as Asian, non-Hispanic in each geography.
Hispanic Population  |  The number of people identifying as Hispanic or Latino in each geography.
American Indian and Alaska Native Population  |  The number of people identifying as American Indian or Alaska native in each geography.
Other Race population  |  The number of people identifying as another race in each geography
Two or more races population  |  The number of people identifying as two or more races in each geography
Population not Hispanic  |  The number of people not identifying as Hispanic or Latino in each geography.
Not a U.S. Citizen Population  |  The number of people within each geography who indicated that they are not U.S. citizens.
Workers over the Age of 16  |  The number of people in each geography who work. Workers include those employed at private for-profit companies, the self-employed, government workers and non-profit employees.
Commuters by Car, Truck, or Van  |  The number of workers age 16 years and over within  a geographic area who primarily traveled to work by car, truck or  van.  This is the principal mode of travel or type of conveyance,  by distance rather than time, that the worker usually used to get  from home to work.
Commuters who drove alone  |  The number of workers age 16 years and over within a geographic area who primarily traveled by car driving alone. This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work.
Commuters by Carpool  |  The number of workers age 16 years and over within a geographic area who primarily traveled to work by carpool.  This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work.
Commuters by Public Transportation  |  The number of workers age 16 years and over within a geographic area who primarily traveled to work by public transportation.  This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work.
Commuters by Bus  |  The number of workers age 16 years and over within a geographic area who primarily traveled to work by bus.  This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work.  This is a subset of workers who commuted by public transport.
Commuters by Subway or Elevated  |  The number of workers age 16 years and over within a geographic area who primarily traveled to work by subway or elevated train.  This is the principal mode of travel or type of conveyance, by distance rather than time, that the worker usually used to get from home to work.  This is a subset of workers who commuted by public transport.
Walked to Work  |  The number of workers age 16 years and over within a geographic area who primarily walked to work.  This would mean that of any way of getting to work, they travelled the most distance walking.
Worked at Home  |  The count within a geographical area of workers over the age of 16 who worked at home.
Children under 18 Years of Age  |  The number of people within each geography who are under 18 years of age.
Households  |  A count of the number of households in each geography. A household consists of one or more people who live in the same dwelling and also share at meals or living accommodation, and may consist of a single family or some other grouping of people.
Population 3 Years and Over  |  The total number of people in each geography age 3 years and over.  This denominator is mostly used to calculate rates of school enrollment.
Students Enrolled in School  |  The total number of people in each geography currently enrolled at any level of school, from nursery or pre-school to advanced post-graduate education.  Only includes those over the age of 3.
Students Enrolled in Grades 1 to 4  |  The total number of people in each geography currently enrolled in grades 1 through 4 inclusive.  This corresponds roughly to elementary school.
Students Enrolled in Grades 5 to 8  |  The total number of people in each geography currently enrolled in grades 5 through 8 inclusive.  This corresponds roughly to middle school.
Students Enrolled in Grades 9 to 12  |  The total number of people in each geography currently enrolled in grades 9 through 12 inclusive.  This corresponds roughly to high school.
Students Enrolled as Undergraduate in College  |  The number of people in a geographic area who are enrolled in college at the undergraduate level. Enrollment refers to being registered or listed as a student in an educational program leading to a college degree. This may be a public school or college, a private school or college.
Population 25 Years and Over  |  The number of people in a geographic area who are over the age of 25.  This is used mostly as a denominator of educational attainment.
Population Completed High School  |  The number of people in a geographic area over the age of 25 who completed high school, and did not complete a more advanced degree.
Population completed less than one year of college, no degree  |  The number of people in a geographic area over the age of 25 who attended college for less than one year and no further.
Population completed more than one year of college, no degree  |  The number of people in a geographic area over the age of 25 who attended college for more than one year but did not obtain a degree
Population Completed Associates Degree  |  The number of people in a geographic area over the age of 25 who obtained a associates degree, and did not complete a more advanced degree.
Population Completed Bachelors Degree  |  The number of people in a geographic area over the age of 25 who obtained a bachelors degree, and did not complete a more advanced degree.
Population Completed Masters Degree  |  The number of people in a geographic area over the age of 25 who obtained a masters degree, but did not complete a more advanced degree.
Population 5 Years and Over  |  The number of people in a geographic area who are over the age of 5.  This is primarily used as a denominator of measures of language spoken at home.
Speaks only English at Home  |  The number of people in a geographic area over age 5 who speak only English at home.
Speaks Spanish at Home  |  The number of people in a geographic area over age 5 who speak Spanish at home, possibly in addition to other languages.
Population for Whom Poverty Status Determined  |  The number of people in each geography who could be identified as either living in poverty or not.  This should be used as the denominator when calculating poverty rates, as it excludes people for whom it was not possible to determine poverty.
Income In The Past 12 Months Below Poverty Level  |  The number of people in a geographic area who are part of a family (which could be just them as an individual) determined to be in poverty following the Office of Management and Budgets Directive 14. (https://www.census.gov/hhes/povmeas/methodology/ombdir14.html)
Median Household Income in the past 12 Months  |  Within a geographic area, the median income received by every household on a regular basis before payments for personal income taxes, social security, union dues, medicare deductions, etc.  It includes income received from wages, salary, commissions, bonuses, and tips; self-employment income from own nonfarm or farm businesses, including proprietorships and partnerships; interest, dividends, net rental income, royalty income, or income from estates and trusts; Social Security or Railroad Retirement income; Supplemental Security Income (SSI); any cash public assistance or welfare payments from the state or local welfare office; retirement, survivor, or disability benefits; and any other sources of income received regularly such as Veterans (VA) payments, unemployment and/or workers compensation, child support, and alimony.
Gini Index  |
Per Capita Income in the past 12 Months  |
Housing Units  |  A count of housing units in each geography.  A housing unit is a house, an apartment, a mobile home or trailer, a group of rooms, or a single room occupied as separate living quarters, or if vacant, intended for occupancy as separate living quarters.
Vacant Housing Units  |  The count of vacant housing units in a geographic area. A housing unit is vacant if no one is living in it at the time of enumeration, unless its occupants are only temporarily absent. Units temporarily occupied at the time of enumeration entirely by people who have a usual residence elsewhere are also classified as vacant.
Vacant Housing Units for Rent  |  The count of vacant housing units in a geographic area that are for rent. A housing unit is vacant if no one is living in it at the time of enumeration, unless its occupants are only temporarily absent. Units temporarily occupied at the time of enumeration entirely by people who have a usual residence elsewhere are also classified as vacant.
Vacant Housing Units for Sale  |  The count of vacant housing units in a geographic area that are for sale. A housing unit is vacant if no one is living in it at the time of enumeration, unless its occupants are only temporarily absent. Units temporarily occupied at the time of enumeration entirely by people who have a usual residence elsewhere are also classified as vacant.
Median Rent  |  The median contract rent within a geographic area. The contract rent is the monthly rent agreed to or contracted for, regardless of any furnishings, utilities, fees, meals, or services that may be included. For vacant units, it is the monthly rent asked for the rental unit at the time of interview.
Percent of Household Income Spent on Rent  |  Within a geographic area, the median percentage of household income which was spent on gross rent.  Gross rent is the amount of the contract rent plus the estimated average monthly cost of utilities (electricity, gas, water, sewer etc.) and fuels (oil, coal, wood, etc.) if these are paid by the renter.  Household income is the sum of the income of all people 15 years and older living in the household.
Owner-occupied Housing Units  |
Owner-occupied Housing Units valued at $1,000,000 or more.  |  The count of owner occupied housing units in a geographic area that are valued at $1,000,000 or more.  Value is the respondents estimate of how much the property (house and lot, mobile home and lot, or condominium unit) would sell for if it were for sale.
Owner-occupied Housing Units with a Mortgage  |  The count of housing units within a geographic area that are mortagaged. Mortgage refers to all forms of debt where the property is pledged as security for repayment of the debt, including deeds of trust, trust deed, contracts to purchase, land contracts, junior mortgages, and home equity loans.
Families with young children (under 6 years of age)  |
Two-parent families with young children (under 6 years of age)  |
Two-parent families, both parents in labor force with young children (under 6 years of age)  |
Two-parent families, father only in labor force with young children (under 6 years of age)  |
Two-parent families, mother only in labor force with young children (under 6 years of age)  |
Two-parent families, neither parent in labor force with young children (under 6 years of age)  |
One-parent families with young children (under 6 years of age)  |
One-parent families, father, with young children (under 6 years of age)  |
Men age 45 to 64 (middle aged)  |  0
Men age 45 to 49  |
Men age 50 to 54  |
Men age 55 to 59  |
Men age 60 to 61  |
Men age 62 to 64  |
Black Men age 45 to 54  |
Black Men age 55 to 64  |
Hispanic Men age 45 to 54  |
Hispanic Men age 55 to 64  |
White Men age 45 to 54  |
White Men age 55 to 64  |
Asian Men age 45 to 54  |
Asian Men age 55 to 64  |
Men age 45 to 64 who attained less than a 9th grade education  |
Men age 45 to 64 who attained between 9th and 12th grade, no diploma  |
Men age 45 to 64 who completed high school or obtained GED  |
Men age 45 to 64 who completed some college, no degree  |
Men age 45 to 64 who obtained an associates degree  |
Men age 45 to 64 who obtained a bachelors degree  |
Men age 45 to 64 who obtained a graduate or professional degree  |
One-parent families, father in labor force, with young children (under 6 years of age)  |
Population 15 Years and Over  |  The number of people in a geographic area who are over the age of 15.  This is used mostly as a denominator of marital status.
Never Married  |  The number of people in a geographic area who have never been married.
Currently married  |  The number of people in a geographic area who are currently married
Married but separated  |  The number of people in a geographic area who are married but separated
Widowed  |  The number of people in a geographic area who are widowed
Divorced  |  The number of people in a geographic area who are divorced
Workers age 16 and over who do not work from home  |  The number of workers over the age of 16 who do not work from home in a geographic area
Number of workers with less than 10 minute commute  |  The number of workers over the age of 16 who do not work from home and commute in less than 10 minutes in a geographic area
Number of workers with a commute between 10 and 14 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 10 and 14 minutes in a geographic area
Number of workers with a commute between 15 and 19 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 15 and 19 minutes in a geographic area
Number of workers with a commute between 20 and 24 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 20 and 24 minutes in a geographic area
Number of workers with a commute between 25 and 29 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 25 and 29 minutes in a geographic area
Number of workers with a commute between 30 and 34 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 30 and 34 minutes in a geographic area
Number of workers with a commute between 35 and 44 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 35 and 44 minutes in a geographic area
Number of workers with a commute between 45 and 59 minutes  |  The number of workers over the age of 16 who do not work from home and commute in between 45 and 59 minutes in a geographic area
Number of workers with a commute of over 60 minutes  |  The number of workers over the age of 16 who do not work from home and commute in over 60 minutes in a geographic area
Aggregate travel time to work  |  The total number of minutes every worker over the age of 16 who did not work from home spent spent commuting to work in one day in a geographic area
Households with income less than $10,000  |  The number of households in a geographic area whose annual income was less than $10,000.
Households with income of $10,000 to $14,999  |  The number of households in a geographic area whose annual income was between $10,000 and $14,999.
Households with income of $15,000 to $19,999  |  The number of households in a geographic area whose annual income was between $15,000 and $19,999.
Households with income of $20,000 To $24,999  |  The number of households in a geographic area whose annual income was between $20,000 and $24,999.
Households with income of $25,000 To $29,999  |  The number of households in a geographic area whose annual income was between $20,000 and $24,999.
Households with income of $30,000 To $34,999  |  The number of households in a geographic area whose annual income was between $30,000 and $34,999.
Households with income of $35,000 To $39,999  |  The number of households in a geographic area whose annual income was between $35,000 and $39,999.
Households with income of $40,000 To $44,999  |  The number of households in a geographic area whose annual income was between $40,000 and $44,999.
Households with income of $45,000 To $49,999  |  The number of households in a geographic area whose annual income was between $45,000 and $49,999.
Households with income of $50,000 To $59,999  |  The number of households in a geographic area whose annual income was between $50,000 and $59,999.
Households with income of $60,000 To $74,999  |  The number of households in a geographic area whose annual income was between $60,000 and $74,999.
Households with income of $75,000 To $99,999  |  The number of households in a geographic area whose annual income was between $75,000 and $99,999.
Households with income of $100,000 To $124,999  |  The number of households in a geographic area whose annual income was between $100,000 and $124,999.
Households with income of $125,000 To $149,999  |  The number of households in a geographic area whose annual income was between $125,000 and $149,999.
Households with income of $150,000 To $199,999  |  The number of households in a geographic area whose annual income was between $150,000 and $1999,999.
Population age 16 and over  |  The number of people in each geography who are age 16 or over.
Population in Labor Force  |  The number of people in each geography who are either in the civilian labor force or are members of the U.S. Armed Forces (people on active duty with the United States Army, Air Force, Navy, Marine Corps, or Coast Guard).
Population in Civilian Labor Force  |  The number of civilians 16 years and over in each geography who can be classified as either employed or unemployed below.
Employed Population  |  The number of civilians 16 years old and over in each geography who either (1) were at work, that is, those who did any work at all during the reference week as paid employees, worked in their own business or profession, worked on their own farm, or worked 15 hours or more as unpaid workers on a family farm or in a family business; or (2) were with a job but not at work, that is, those who did not work during the reference week but had jobs or businesses from which they were temporarily absent due to illness, bad weather, industrial dispute, vacation, or other personal reasons. Excluded from the employed are people whose only activity consisted of work around the house or unpaid volunteer work for religious, charitable, and similar organizations; also excluded are all institutionalized people and people on active duty in the United States Armed Forces.
Unemployed Population  |  The number of civilians in each geography who are 16 years old and over are classified as unemployed if they (1) were neither at work nor with a job but not at work during the reference week, and (2) were actively looking for work during the last 4 weeks, and (3) were available to start a job. Also included as unemployed are civilians who did not work at all during the reference week, were waiting to be called back to a job from which they had been laid off, and were available for work except for temporary illness. Examples of job seeking activities are:
              * Registering at a public or private employment office
              * Meeting with prospective employers
              * Investigating possibilities for starting a professional
                practice or opening a business
              * Placing or answering advertisements
              * Writing letters of application
              * Being on a union or professional register
Population in Armed Forces  |  The number of people in each geography who are members of the U.S. Armed Forces (people on active duty with the United States Army, Air Force, Navy, Marine Corps, or Coast Guard).
Population Not in Labor Force  |  The number of people in each geography who are 16 years old and over who are not classified as members of the labor force. This category consists mainly of students, homemakers, retired workers, seasonal workers interviewed in an off season who were not looking for work, institutionalized people, and people doing only incidental unpaid family work (less than 15 hours during the reference week).
Households with income of $200,000 Or More  |  The number of households in a geographic area whose annual income was more than $200,000.
