# Measures

Measures Services allow users to access geospatial measures for analysis workflows. Measures are used by sending an identifier or a geometry (Point or Polygon) and receiving back a measure or absolute value for that location. Every measure contained in the Data Catalog can be accessed through the CartoDB Editor.

Below are the methods. For detailed information for accessing any measures, see the catalog here, [Catalog PDF](http://cartodb.github.io/bigmetadata/index.html)

## OBS_GetUSCensusMeasure(point_geometry, measure_name);

The ```OBS_GetUSCensusMeasure(point_geometry, measure_name)``` method returns a measure based on a subset of the US Census variables at a point location. The ```OBS_GetUSCensusMeasure``` method is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetMeasure``` method below.

#### Arguments

Name |Description
--- | ---
geom | a WGS84 point geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The glossary of measure_names is [available below]('measure_name table').
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the

#### Returns

A JSON object containing the following properties

Key | Description
--- | ---
value | the raw or normalized measure
name | the human readable name of the measure
description | a brief description of the measure
type | the data type (text, number, boolean)

#### Example

Add a Measure to an empty column based on point locations in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetUSCensusMeasure(the_geom, 'Male Population') -> 'value'
```

Get a measure at a single point location

```SQL
SELECT * FROM json_each(OBS_GetUSCensusMeasure(CDB_LatLng(40.7, -73.9), 'Male Population'))
```

<!--
Should add the SQL API call here too
-->

#### OBS_GetUSCensusMeasure names table

Below is a list of human readable names accepted in the ```OBS_GetUSCensusMeasure``` method. For the more comprehensive list of columns available to the ```OBS_GetMeasure``` method, see the [Data Catalog]

"Aggregate travel time to work", "American Indian and Alaska Native Population", "Asian Men age 45 to 54", "Asian Men age 55 to 64", "Asian Population", "Black Men age 45 to 54", "Black Men age 55 to 64", "Black or African American Population", "Children under 18 Years of Age", "Commuters by Bus", "Commuters by Carpool", "Commuters by Car, Truck, or Van", "Commuters by Public Transportation", "Commuters by Subway or Elevated", "Commuters who drove alone", "Currently married", "Divorced", "Employed Population", "Families with young children (under 6 years of age)", "Female Population", "Gini Index", "Hispanic Men age 45 to 54", "Hispanic Men age 55 to 64", "Hispanic Population", "Households", "Households with income less than $10,000", "Households with income of $100,000 To $124,999", "Households with income of $10,000 to $14,999", "Households with income of $125,000 To $149,999", "Households with income of $150,000 To $199,999", "Households with income of $15,000 to $19,999", "Households with income of $200,000 Or More", "Households with income of $20,000 To $24,999", "Households with income of $25,000 To $29,999", "Households with income of $30,000 To $34,999", "Households with income of $35,000 To $39,999", "Households with income of $40,000 To $44,999", "Households with income of $45,000 To $49,999", "Households with income of $50,000 To $59,999", "Households with income of $60,000 To $74,999", "Households with income of $75,000 To $99,999", "Housing Units", "Income In The Past 12 Months Below Poverty Level", "Male Population", "Married but separated", "Median Age", "Median Household Income in the past 12 Months", "Median Rent", "Men age 45 to 49", "Men age 45 to 64 ("middle aged")", "Men age 45 to 64 who attained between 9th and 12th grade, no diploma", "Men age 45 to 64 who attained less than a 9th grade education", "Men age 45 to 64 who completed high school or obtained GED", "Men age 45 to 64 who completed some college, no degree", "Men age 45 to 64 who obtained a bachelor's degree", "Men age 45 to 64 who obtained a graduate or professional degree", "Men age 45 to 64 who obtained an associate's degree", "Men age 50 to 54", "Men age 55 to 59", "Men age 60 to 61", "Men age 62 to 64", "Never Married", "Not a U.S. Citizen Population", "Number of workers with a commute between 10 and 14 minutes", "Number of workers with a commute between 15 and 19 minutes", "Number of workers with a commute between 20 and 24 minutes", "Number of workers with a commute between 25 and 29 minutes", "Number of workers with a commute between 30 and 34 minutes", "Number of workers with a commute between 35 and 44 minutes", "Number of workers with a commute between 45 and 59 minutes", "Number of workers with a commute of over 60 minutes", "Number of workers with less than 10 minute commute", "One-parent families, father in labor force, with young children (under 6 years of age)", "One-parent families, father, with young children (under 6 years of age)", "One-parent families with young children (under 6 years of age)", "Other Race population", "Owner-occupied Housing Units", "Owner-occupied Housing Units valued at $1,000,000 or more.", "Owner-occupied Housing Units with a Mortgage", "Per Capita Income in the past 12 Months", "Percent of Household Income Spent on Rent", "Population 15 Years and Over", "Population 25 Years and Over", "Population 3 Years and Over", "Population 5 Years and Over", "Population age 16 and over", "Population Completed Associate's Degree", "Population Completed Bachelor's Degree", "Population Completed High School", "Population completed less than one year of college, no degree", "Population Completed Master's Degree", "Population completed more than one year of college, no degree", "Population for Whom Poverty Status Determined", "Population in Armed Forces", "Population in Civilian Labor Force", "Population in Labor Force", "Population not Hispanic", "Population Not in Labor Force", "Speaks only English at Home", "Speaks Spanish at Home", "Students Enrolled as Undergraduate in College", "Students Enrolled in Grades 1 to 4", "Students Enrolled in Grades 5 to 8", "Students Enrolled in Grades 9 to 12", "Students Enrolled in School", "Total Population", "Two or more races population", "Two-parent families, both parents in labor force with young children (under 6 years of age)", "Two-parent families, father only in labor force with young children (under 6 years of age)", "Two-parent families, mother only in labor force with young children (under 6 years of age)", "Two-parent families, neither parent in labor force with young children (under 6 years of age)", "Two-parent families with young children (under 6 years of age)", "Unemployed Population", "US Census Block Group Geoids", "Vacant Housing Units", "Vacant Housing Units for Rent", "Vacant Housing Units for Sale", "Walked to Work", "White Men age 45 to 54", "White Men age 55 to 64", "White Population", "Widowed", "Worked at Home", "Workers age 16 and over who do not work from home", "Workers over the Age of 16"


## OBS_GetUSCensusMeasure(polygon_geometry, measure_name);

The ```OBS_GetUSCensusMeasure(point_geometry, measure_name)``` method returns a measure based on a subset of the US Census variables within a given polygon. The ```OBS_GetUSCensusMeasure``` method is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetMeasure``` method below.

#### Arguments

Name |Description
--- | ---
geom | a WGS84 polygon geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The glossary of measure_names is [available below]('measure_name table').
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) (optional)

#### Returns

A JSON object containing the following properties

Key | Description
--- | ---
value | the raw or normalized measure
name | the human readable name of the measure
description | a brief description of the measure
type | the data type (text, number, boolean)

#### Example

Add a Measure to an empty column based on polygons in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetUSCensusMeasure(the_geom, 'Male Population') -> 'value'
```

Get a measure at a single polygon

```SQL
SELECT * FROM json_each(OBS_GetMeasure(ST_Buffer(CDB_LatLng(40.7, -73.9),0.001), 'Male Population'))
```

<!--
Should add the SQL API call here too
-->

## OBS_GetMeasure(point_geometry, measure_id);

The ```OBS_GetMeasure(point_geometry, measure_id)``` method returns any Data Observatory measure at a point location.

#### Arguments

Name |Description
--- | ---
geom | a WGS84 point geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](http://cartodb.github.io/bigmetadata/index.html))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) and 'none' which will return a raw value. (optional)

#### Returns

A JSON object containing the following properties

Key | Description
--- | ---
value | the raw or normalized measure
name | the human readable name of the measure
description | a brief description of the measure
type | the data type (text, number, boolean)

#### Example

Add a Measure to an empty column based on point locations in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetMeasure(the_geom, '"us.census.acs".B08134006') -> 'value'
```

Get a measure at a single point location

```SQL
SELECT * FROM json_each(OBS_GetMeasure(CDB_LatLng(40.7, -73.9), '"us.census.acs".B08134006'))
```

<!--
Should add the SQL API call here too
-->


## OBS_GetMeasure(polygon_geometry, measure_id);

The ```OBS_GetMeasure(polygon_geometry, measure_id)``` method returns any Data Observatory measure calculated within a polygon.

#### Arguments

Name |Description
--- | ---
geom | a WGS84 polygon geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](http://cartodb.github.io/bigmetadata/index.html))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) (optional)

#### Returns

A JSON object containing the following properties

Key | Description
--- | ---
value | the raw or normalized measure
name | the human readable name of the measure
description | a brief description of the measure
type | the data type (text, number, boolean)

#### Example

Add a Measure to an empty column based on polygons in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetMeasure(the_geom, '"us.census.acs".B08134006') -> 'value'
```

Get a measure within a polygon

```SQL
SELECT * FROM json_each(OBS_GetMeasure(ST_Buffer(CDB_LatLng(40.7, -73.9),0.001), '"us.census.acs".B08134006'))
```

<!--
Should add the SQL API call here too
-->

---

# Boundaries

# Discovery
