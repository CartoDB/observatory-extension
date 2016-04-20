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
SELECT * FROM json_each(OBS_GetMeasure(CDB_LatLng(40.7, -73.9), 'Male Population'))
```

<!--
Should add the SQL API call here too
-->

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
