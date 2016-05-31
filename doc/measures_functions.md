# Measures Functions

[Data Observatory Measures](/carto-engine/data/overview/#measures-methods) are the numerical location data you can access. The measure functions allow you to access individual measures to augment your own data or integrate in your analysis workflows. Measures are used by sending an identifier or a geometry (point or polygon) and receiving back a measure (an absolute value) for that location.

There are hundreds of measures and the list is growing with each release. You can currently discover and learn about measures contained in the Data Observatory by downloading our [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf).

You can [access](/carto-engine/data/accessing/#accessing-the-data-observatory) measures through the CARTO Editor. The same methods will work if you are using the CARTO Engine to develop your application. We [encourage you](/carto-engine/data/accessing/#best-practices) to use table modifying methods (UPDATE and INSERT) over dynamic methods (SELECT).

## OBS_GetUSCensusMeasure(point geometry, measure_name text)

The ```OBS_GetUSCensusMeasure(point, measure_name)``` function returns a measure based on a subset of the US Census variables at a point location. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use measure IDs with the ```OBS_GetMeasure``` function below.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
measure_name | a human readable name of a US Census variable. The list of measure_names is [available in the glossary](/carto-engine/data/glossary/#obsgetuscensusmeasure-names-table).
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](http://cartodb.github.io/bigmetadata/index.html) (optional)
boundary_id | source of geometries to pull measure from (e.g., 'us.census.tiger.census_tract')
time_span | time span of interest (e.g., 2010 - 2014)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a measure to an empty numeric column based on point locations in your table.

```SQL
UPDATE tablename
SET total_population = OBS_GetUSCensusMeasure(the_geom, 'Total Population')
```

## OBS_GetUSCensusMeasure(polygon geometry, measure_name text)

The ```OBS_GetUSCensusMeasure(point, measure_name)``` function returns a measure based on a subset of the US Census variables within a given polygon. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory, to access the full list, use the ```OBS_GetUSCensusMeasure``` function below.

#### Arguments

Name |Description
--- | ---
polygon | a WGS84 polygon geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The list of measure_names is [available in the glossary](/carto-engine/data/glossary/#obsgetuscensusmeasure-names-table).
normalize | for measures that are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) (optional)
boundary_id | source of geometries to pull measure from (e.g., 'us.census.tiger.census_tract')
time_span | time span of interest (e.g., 2010 - 2014)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a measure to an empty numeric column based on polygons in your table

```SQL
UPDATE tablename
SET local_male_population = OBS_GetUSCensusMeasure(the_geom, 'Male Population')
```

## OBS_GetMeasure(point geometry, measure_id text)

The ```OBS_GetMeasure(point, measure_id)``` function returns any Data Observatory measure at a point location. You can browse all available Measures in the [Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf)).

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf)). It is important to note that these are different than 'measure_name' used in the Census based functions above.
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. The other option is 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf). (optional)
boundary_id | source of geometries to pull measure from (e.g., 'us.census.tiger.census_tract')
time_span | time span of interest (e.g., 2010 - 2014)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a measure to an empty numeric column based on point locations in your table

```SQL
UPDATE tablename
SET median_home_value_sqft = OBS_GetMeasure(the_geom, 'us.zillow.AllHomes_MedianValuePerSqft')
```

## OBS_GetMeasure(polygon geometry, measure_id text)

The ```OBS_GetMeasure(polygon, measure_id)``` function returns any Data Observatory measure calculated within a polygon.

#### Arguments

Name |Description
--- | ---
polygon_geometry | a WGS84 polygon geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf))  
normalize | for measures that are are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) (optional)
boundary_id | source of geometries to pull measure from (e.g., 'us.census.tiger.census_tract')
time_span | time span of interest (e.g., 2010 - 2014)

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw or normalized measure

#### Example

Add a measure to an empty column based on polygons in your table

```SQL
UPDATE tablename
SET household_count = OBS_GetMeasure(the_geom, 'us.census.acs.B11001001')
```

#### Errors

* If an unrecognized normalization type is input, raise an error: `'Only valid inputs for "normalize" are "area" (default) and "denominator".`

## OBS_GetCategory(point geometry, category_id text)

The ```OBS_GetCategory(point, category_id)``` function returns any Data Observatory Category value at a point location. The Categories available are currently limited to Segmentation categories. See the Segmentation section of the [Catalog](https://cartodb.github.io/bigmetadata/observatory.pdf) for more detail.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
category_id | a category identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf)).

#### Returns

A TEXT value

Key | Description
--- | ---
value | a text based category found at the supplied point

#### Example

Add the Category to an empty column text column based on point locations in your table

```SQL
UPDATE tablename
SET segmentation = OBS_GetCategory(the_geom, 'us.census.spielman_singleton_segments.X55')
```
