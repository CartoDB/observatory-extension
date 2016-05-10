# Measures Functions

[Data Observatory Measures](/cartodb-platform/dataobservatory/overview/#measures-methods) allow you to access geospatial measures for analysis workflows. Measures are used by sending an identifier or a geometry (Point or Polygon) and receiving back a measure or absolute value for that location. Every measure contained in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) can be accessed through the CartoDB Editor.

## OBS_GetUSCensusMeasure(point_geometry, measure_name);

The ```OBS_GetUSCensusMeasure(point_geometry, measure_name)``` function returns a measure based on a subset of the US Census variables at a point location. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetMeasure``` function below.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The list of measure_names is [available in the glossary](/cartodb-platform/dataobservatory/glossary/#obsgetuscensusmeasure-names-table).
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

The ```OBS_GetUSCensusMeasure(point_geometry, measure_name)``` function returns a measure based on a subset of the US Census variables within a given polygon. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetUSCensusMeasure``` function below.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 polygon geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The list of measure_names is [available in the glossary](/cartodb-platform/dataobservatory/glossary/#obsgetuscensusmeasure-names-table).
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) (optional)

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

The ```OBS_GetUSCensusCategory(point_geometry, category_name)``` function returns a categorical measure based on a subset of the US Census variables at a point location. It requires a different function from ```OBS_GetUSCensusMeasure``` because this function will always return TEXT, whereas ```OBS_GetUSCensusMeasure``` will always returna  NUMERIC value. 

#### Arguments

Name | Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The list of measure_names is [available in the glossary](/cartodb-platform/dataobservatory/glossary/#obsgetuscensusmeasure-names-table).

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

The ```OBS_GetMeasure(point_geometry, measure_id)``` function returns any Data Observatory measure at a point location.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) and 'none' which will return a raw value. (optional)

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

The ```OBS_GetMeasure(polygon_geometry, measure_id)``` function returns any Data Observatory measure calculated within a polygon.

#### Arguments

Name |Description
--- | ---
polygon_geometry | a WGS84 polygon geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) (optional)

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