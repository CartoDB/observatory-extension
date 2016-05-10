# Measures Functions

[Data Observatory Measures](/cartodb-platform/dataobservatory/overview/#measures-methods) are the numerical location data you can access. The Measure Functions allow you to access individual measures to augment your own data or integrate in your analysis workflows. Measures are used by sending an identifier or a geometry (Point or Polygon) and receiving back a Measure (an absolute value) for that location.

There are hundreds of Measures and the list is growing with each release. You can currently discover and learn about measures contained in the Data Observatory by downloading our [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf).

We show here how you can access Measures through the CartoDB Editor. The same methods will work if you are using the CartoDB Platform to develop your application. We encourage you to use table modifying methods (UPDATE and INSERT) over dynamic methods (SELECT).

## OBS_GetUSCensusMeasure(point geometry, measure_name text);

The ```OBS_GetUSCensusMeasure(point, measure_name)``` function returns a measure based on a subset of the US Census variables at a point location. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all Measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetMeasure``` function below.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
measure_name | a human readable name of a US Census variable. The list of measure_names is [available in the glossary](/cartodb-platform/dataobservatory/glossary/#obsgetuscensusmeasure-names-table).
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

<!--
Should add the SQL API call here too
-->


## OBS_GetUSCensusMeasure(polygon geometry, measure_name text);

The ```OBS_GetUSCensusMeasure(point, measure_name)``` function returns a measure based on a subset of the US Census variables within a given polygon. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetUSCensusMeasure``` function below.

#### Arguments

Name |Description
--- | ---
polygon | a WGS84 polygon geometry (the_geom)
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

<!--
Should add the SQL API call here too
-->

## OBS_GetMeasure(point geometry, measure_id text);

The ```OBS_GetMeasure(point, measure_id)``` function returns any Data Observatory Measure at a point location. You can browse all available Measures in the [Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf)).

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf)). It is important to note that these are different than 'measure_name' used in the Census based functions above.
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) and 'none' which will return a raw value. (optional)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a Measure to an empty column based on point locations in your table

```SQL
UPDATE tablename SET local_male_population = OBS_GetMeasure(the_geom, 'us.census.acs.B08134006')
```

## OBS_GetMeasure(polygon geometry, measure_id text);

The ```OBS_GetMeasure(polygon, measure_id)``` function returns any Data Observatory Measure calculated within a polygon.

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
UPDATE tablename SET local_male_population = OBS_GetMeasure(the_geom, 'us.census.acs.B08134006')
```


## OBS_GetCategory(point geometry, category_id text);

The ```OBS_GetCategory(point, category_id)``` function returns any Data Observatory Category value at a point location. The Categories available are currently limited to Segmentation categories. See the Segmentation section of the [Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) for more detail.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
category_id | a category identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf)).

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | a text based category found at the supplied point

#### Example

Add the Category to an empty column based on point locations in your table

```SQL
UPDATE tablename SET segmentation = OBS_GetCategory(the_geom, 'X55')
```
