# Measures Functions

[Data Observatory Measures](https://carto.com/docs/carto-engine/data/overview/#measures-methods) are the numerical location data you can access. The measure functions allow you to access individual measures to augment your own data or integrate in your analysis workflows. Measures are used by sending an identifier or a geometry (point or polygon) and receiving back a measure (an absolute value) for that location.

There are hundreds of measures and the list is growing with each release. You can currently discover and learn about measures contained in the Data Observatory by downloading our [Data Catalog](https://cartodb.github.io/bigmetadata/index.html).

You can [access](https://carto.com/docs/carto-engine/data/accessing) measures through CARTO Builder. The same methods will work if you are using the CARTO Engine to develop your application. We [encourage you](https://carto.com/docs/carto-engine/data/accessing/#best-practices) to use table modifying methods (UPDATE and INSERT) over dynamic methods (SELECT).

## OBS_GetUSCensusMeasure(point geometry, measure_name text)

The ```OBS_GetUSCensusMeasure(point, measure_name)``` function returns a measure based on a subset of the US Census variables at a point location. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory. To access the full list, use measure IDs with the ```OBS_GetMeasure``` function below.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
measure_name | a human-readable name of a US Census variable. The list of measure_names is [available in the Glossary](https://carto.com/docs/carto-engine/data/glossary/#obsgetuscensusmeasure-names-table).
normalize | for measures that are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/index.html) (optional)
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

The ```OBS_GetUSCensusMeasure(polygon, measure_name)``` function returns a measure based on a subset of the US Census variables within a given polygon. The ```OBS_GetUSCensusMeasure``` function is limited to only a subset of all measures that are available in the Data Observatory. To access the full list, use the ```OBS_GetMeasure``` function below.

#### Arguments

Name |Description
--- | ---
polygon | a WGS84 polygon geometry (the_geom)
measure_name | a human readable string name of a US Census variable. The list of measure_names is [available in the Glossary](https://carto.com/docs/carto-engine/data/glossary/#obsgetuscensusmeasure-names-table).
normalize | for measures that are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/index.html) (optional)
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

The ```OBS_GetMeasure(point, measure_id)``` function returns any Data Observatory measure at a point location. You can browse all available Measures in the [Catalog](https://cartodb.github.io/bigmetadata/index.html).

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf)). It is important to note that these are different than 'measure_name' used in the Census based functions above.
normalize | for measures that are **sums** (e.g. population) the default normalization is 'area' and response comes back as a rate per square kilometer. The other option is 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/index.html). (optional)
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
normalize | for measures that are **sums** (e.g. population) the default normalization is 'none' and response comes back as a raw value. Other options are 'denominator', which will use the denominator specified in the [Data Catalog](https://cartodb.github.io/bigmetadata/index.html) (optional)
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

## OBS_GetMeasureById(geom_ref text, measure_id text, boundary_id text)

The ```OBS_GetMeasureById(geom_ref, measure_id, boundary_id)``` function returns any Data Observatory measure that corresponds to the boundary in ```boundary_id``` that has a geometry reference of ```geom_ref```.

#### Arguments

Name |Description
--- | ---
geom_ref | a geometry reference (e.g., a US Census geoid)
measure_id | a measure identifier from the Data Observatory ([see available measures](https://cartodb.github.io/bigmetadata/observatory.pdf))  
boundary_id | source of geometries to pull measure from (e.g., 'us.census.tiger.census_tract')
time_span (optional) | time span of interest (e.g., 2010 - 2014). If `NULL` is passed, the measure from the most recent data will be used.

#### Returns

A NUMERIC value

Key | Description
--- | ---
value | the raw measure associated with `geom_ref`

#### Example

Add a measure to an empty column based on county geoids in your table

```SQL
UPDATE tablename
SET household_count = OBS_GetMeasureById(geoid_column, 'us.census.acs.B11001001', 'us.census.tiger.county')
```

#### Errors

* Returns `NULL` if there is a mismatch between the geometry reference and the boundary id such as using the geoid of a county with the boundary of block groups

## OBS_GetCategory(point geometry, category_id text)

The ```OBS_GetCategory(point, category_id)``` function returns any Data Observatory Category value at a point location. The Categories available are currently limited to Segmentation categories. See the Segmentation section of the [Catalog](https://cartodb.github.io/bigmetadata/index.html) for more detail.

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

## OBS_GetMeta(extent geometry, metadata json)

The ```OBS_GetMeta(extent, metadata)``` function returns a completed Data
Observatory metadata JSON Object for use in ```OBS_GetData(geomvals,
metadata)``` or ```OBS_GetData(ids, metadata)```.  It is not possible to pass
metadata to those functions if it is not processed by ```OBS_GetMeta(extent,
metadata)``` first.

#### Arguments

Name | Description
---- | -----------
extent | A geometry of the extent of the input geometries
metadata | A JSON array composed of metadata input objects.  Each indicates one desired measured for an output column, and optionally additional parameters about that column

The schema of the metadata input objects are as follows:

Metadata Input Key | Description
--- | -----------
numer_id | The identifier for the desired measurement.  If left blank, but a `geom_id` is specified, the column will return a geometry instead of a measurement.
geom_id | Identifier for a desired geographic boundary level to use when calculating measures.  Will be automatically assigned if undefined.  If defined but `numer_id` is blank, then the column will return a geometry instead of a measurement.
normalization | The desired normalization.  One of 'area', 'prenormalized', or 'denominated'.  'Area' will normalize the measure per square kilometer, 'prenormalized' will return the original value, and 'denominated' will normalize by a denominator.  Ignored if this metadata object specifies a geometry.
denom_id | Identifier for a desired normalization column in case `normalization` is 'denominated'.  Will be automatically assigned if necessary.  Ignored if this metadata object specifies a geometry.
numer_timespan | The desired timespan for the measurement.  Defaults to most recent timespan available if left unspecified.
geom_timespan | The desired timespan for the geometry.  Defaults to most recent timespan available if left unspecified.

#### Returns

A JSON array composed of metadata output objects.

Key | Description
--- | -----------
meta | A JSON array with completed metadata for the requested data, including all keys below

The schema of the metadata output objects are as follows.  You should pass this
array as-is to ```OBS_GetData```.  If you modify any values the function will
fail.

Metadata Output Key | Description
--- | -----------
numer_id | Identifier for desired measurement
numer_timespan | Timespan that will be used of the desired measurement
numer_name | Human-readable name of desired measure
numer_type | PostgreSQL/PostGIS type of desired measure
numer_colname | Internal identifier for column name
numer_tablename | Internal identifier for table
numer_geomref_colname | Internal identifier for geomref column name
denom_id | Identifier for desired normalization
denom_timespan | Timespan that will be used of the desired normalization
denom_name | Human-readable name of desired measure's normalization
denom_type | PostgreSQL/PostGIS type of desired measure's normalization
denom_colname | Internal identifier for normalization column name
denom_tablename | Internal identifier for normalization table
denom_geomref_colname | Internal identifier for normalization geomref column name
geom_id | Identifier for desired boundary geometry
geom_timespan | Timespan that will be used of the desired boundary geometry
geom_name | Human-readable name of desired boundary geometry
geom_type | PostgreSQL/PostGIS type of desired boundary geometry
geom_colname | Internal identifier for boundary geometry column name
geom_tablename | Internal identifier for boundary geometry table
geom_geomref_colname | Internal identifier for boundary geometry ref column name

#### Examples

Obtain metadata that can augment with one additional column of US population
data, using a boundary relevant for the geometry provided and latest timespan.

```SQL
SELECT OBS_GetMeta(ST_Extent(the_geom),
       '[{"numer_id": "us.census.acs.B01003001"}]')
```

Obtain metadata that can augment with one additional column of US population
data, using census tract boundaries.

```SQL
SELECT OBS_GetMeta(ST_Extent(the_geom),
       '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.census_tract"}]')
```

Obtain metadata that can augment with two additional columns, one for total
population and one for male population.

```SQL
SELECT OBS_GetMeta(ST_Extent(the_geom),
       '[{"numer_id": "us.census.acs.B01003001"}, {"numer_id": "us.census.acs.B01001002"}]')
```

## OBS_GetData(geomvals array[geomval], metadata json)

The ```OBS_GetData(geomvals, metadata)``` function returns a measure and/or
geometry corresponding to the `metadata` JSON array for each every Geometry of
the `geomval` element in the `geomvals` array. The metadata argument must be
obtained from ```OBS_GetMeta(extent, metadata)```.

#### Arguments

Name | Description
---- | -----------
geomvals | An array of `geomval` elements, which are obtained by casting together a `Geometry` and a `Numeric`.  This should be obtained by using `ARRAY_AGG((the_geom, cartodb_id)::geomval)` from the CARTO table one wishes to obtain data for.
metadata | A JSON array composed of metadata output objects from `OBS_GetMeta(extent, metadata)`.  The schema of the elements of the `metadata` JSON array corresponds to that of the output of ```OBS_GetMeta(extent, metadata)```, and this argument must be obtained from that function in order for the call to be valid.

#### Returns

A TABLE with the following schema, where each element of the input `geomvals`
array corresponds to one row:

Column | Type    | Description
------ | ----    | -----------
id     | Numeric | ID corresponding to the `val` component of an element of the input `geomvals` array
data   | JSON    | A JSON array with elements corresponding to the input `metadata` JSON array

Each `data` object has the following keys:

Key   | Description
---   | -----------
value | The value of the measurement or geometry for the geometry corresponding to this row and measurement corresponding to this position in the `metadata` JSON array

To determine the appropriate cast for `value`, one can use the `numer_type`
or `geom_type` key corresponding to that value in the input `metadata` JSON
array.

#### Examples

Obtain population densities for every geometry in a table, keyed by cartodb_id:

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(ST_Extent(the_geom),
                     '[{"numer_id": "us.census.acs.B01003001"}]') meta)
SELECT id AS cartodb_id, (data->1->>'value') AS pop_density
FROM OBS_GetData((SELECT ARRAY_AGG((the_geom, cartodb_id)::geomval) FROM tablename),
                 (SELECT meta FROM meta))
```

Update a table with population densities:

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(ST_Extent(the_geom),
                     '[{"numer_id": "us.census.acs.B01003001"}]') meta),
data AS (
  SELECT id AS cartodb_id, (data->1->>'value') AS pop_density
  FROM OBS_GetData((SELECT ARRAY_AGG((the_geom, cartodb_id)::geomval) FROM tablename),
                   (SELECT meta FROM meta)))
UPDATE tablename
SET pop_density = data.pop_density
FROM data
WHERE cartodb_id = data.id
```

## OBS_GetData(ids array[text], metadata json)

The ```OBS_GetData(ids, metadata)``` function returns a measure and/or
geometry corresponding to the `metadata` JSON array for each every id of
the `ids` array. The metadata argument must be obtained from
```OBS_GetMeta(extent, metadata)```.  When obtaining metadata, one must include
the `geom_id` corresponding to the boundary that the `ids` refer to.

#### Arguments

Name | Description
---- | -----------
ids | An array of `TEXT` elements.  This should be obtained by using `ARRAY_AGG(col_of_geom_refs)` from the CARTO table one wishes to obtain data for.
metadata | A JSON array composed of metadata output objects from `OBS_GetMeta(extent, metadata)`.  The schema of the elements of the `metadata` JSON array corresponds to that of the output of ```OBS_GetMeta(extent, metadata)```, and this argument must be obtained from that function in order for the call to be valid.

For this function to work, the `metadata` argument must include a `geom_id`
that corresponds to the ids found in `col_of_geom_refs`.

#### Returns

A TABLE with the following schema, where each element of the input `ids` array
corresponds to one row:

Column | Type | Description
------ | ---- | -----------
id     | Text | ID corresponding to an element of the input `ids` array
data   | JSON | A JSON array with elements corresponding to the input `metadata` JSON array

Each `data` object has the following keys:

Key   | Description
---   | -----------
value | The value of the measurement or geometry for the geometry corresponding to this row and measurement corresponding to this position in the `metadata` JSON array

To determine the appropriate cast for `value`, one can use the `numer_type`
or `geom_type` key corresponding to that value in the input `metadata` JSON
array.

#### Examples

Obtain population densities for every row of a table with FIPS code county IDs
(USA).

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(ST_Extent(the_geom),
                     '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.county"}]') meta)
SELECT id AS fips, (data->1->>'value') AS pop_density
FROM OBS_GetData((SELECT ARRAY_AGG((fips) FROM tablename),
                 (SELECT meta FROM meta))
```

Update a table with population densities for every FIPS code county ID (USA).

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(ST_Extent(the_geom),
                     '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.county"}]') meta),
data as (
  SELECT id AS fips, (data->1->>'value') AS pop_density
  FROM OBS_GetData((SELECT ARRAY_AGG((fips) FROM tablename),
                   (SELECT meta FROM meta)))
UPDATE tablename
SET pop_density = data.pop_density
FROM data
WHERE fips = data.id
```

