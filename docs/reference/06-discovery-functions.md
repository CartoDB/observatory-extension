## Discovery Functions

If you are using the [discovery methods]({{ site.dataobservatory_docs}}/guides/overview/#discovery-methods) from the Data Observatory, use the following functions to retrieve [boundary]({{ site.dataobservatory_docs}}/guides/overview/#boundary-data) and [measures]({{ site.dataobservatory_docs}}/guides/overview/#measures-data) data.

### OBS_Search(search_term)

Use arbitrary text to search all available measures

#### Arguments

Name | Description
--- | ---
search_term | a string to search for available measures
boundary_id | a string identifier for a boundary geometry (optional)

#### Returns

A TABLE containing the following properties

Key | Description
--- | ---
id | the unique id of the measure for use with the ```OBS_GetMeasure``` function
name | the human readable name of the measure
description | a brief description of the measure
aggregate | **sum** are raw count values, **median** are statistical medians, **average** are statistical averages, **undefined** other (e.g. an index value)
source | where the data came from (e.g. US Census Bureau)

#### Example

```SQL
SELECT * FROM OBS_Search('home value')
```

### OBS_GetAvailableBoundaries(point_geometry)

Returns available `boundary_id`s at a given point geometry.

#### Arguments

Name | Description
--- | ---
point_geometry |  a WGS84 point geometry (e.g. the_geom)

#### Returns

A TABLE containing the following properties

Key | Description
--- | ---
boundary_id | a boundary identifier from the [Boundary ID Glossary]({{ site.dataobservatory_docs}}/guides/glossary/#boundary-ids)
description | a brief description of the boundary dataset
time_span | the timespan attached the boundary. this does not mean that the boundary is invalid outside of the timespan, but is the explicit timespan published with the geometry.

#### Example

```SQL
SELECT * FROM OBS_GetAvailableBoundaries(CDB_LatLng(40.7, -73.9))
```

### OBS_GetAvailableNumerators(bounds, filter_tags, denom_id, geom_id, timespan)

Return available numerators within a boundary and with the specified
`filter_tags`.

#### Arguments

Name | Type | Description
--- | --- | ---
bounds | Geometry(Geometry, 4326) | a geometry which some of the numerator's data must intersect with
filter_tags | Text[] | a list of filters.  Only numerators for which all of these apply are returned  `NULL` to ignore (optional)
denom_id | Text | the ID of a denominator to check whether the numerator is valid against.  Will not reduce length of returned table, but will change values for `valid_denom` (optional)
geom_id | Text | the ID of a geometry to check whether the numerator is valid against.  Will not reduce length of returned table, but will change values for `valid_geom` (optional)
timespan | Text | the ID of a timespan to check whether the numerator is valid against.  Will not reduce length of returned table, but will change values for `valid_timespan` (optional)

#### Returns

A TABLE containing the following properties

Key | Type | Description
--- | ---- | -----------
numer_id | Text | The ID of the numerator
numer_name | Text | A human readable name for the numerator
numer_description | Text | Description of the numerator.  Is sometimes NULL
numer_weight | Numeric | Numeric "weight" of the numerator.  Ignored.
numer_license | Text | ID of the license for the numerator
numer_source | Text | ID of the source for the numerator
numer_type | Text | Postgres type of the numerator
numer_aggregate | Text | Aggregate type of the numerator.  If `'SUM'`, this can be normalized by area
numer_extra | JSONB | Extra information about the numerator column.  Ignored.
numer_tags | Text[] | Array of all tags applying to this numerator
valid_denom | Boolean | True if the `denom_id` argument is a valid denominator for this numerator, False otherwise
valid_geom | Boolean | True if the `geom_id` argument is a valid geometry for this numerator, False otherwise
valid_timespan | Boolean | True if the `timespan` argument is a valid timespan for this numerator, False otherwise

#### Examples

Obtain all numerators that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326))
```

Obtain all numerators that are available within a small rectangle and are for
the United States only.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states}');
```

Obtain all numerators that are available within a small rectangle and are
employment related for the United States only.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states, subsection/tags.employment}');
```

Obtain all numerators that are available within a small rectangle and are
related to both employment and age & gender for the United States only.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states, subsection/tags.employment, subsection/tags.age_gender}');
```

Obtain all numerators that work with US population (`us.census.acs.B01003001`)
as a denominator.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01003001')
WHERE valid_denom IS True;
```

Obtain all numerators that work with US states (`us.census.tiger.state`)
as a geometry.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, 'us.census.tiger.state')
WHERE valid_geom IS True;
```

Obtain all numerators available in the timespan `2011 - 2015`.

```SQL
SELECT * FROM OBS_GetAvailableNumerators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, '2011 - 2015')
WHERE valid_timespan IS True;
```

### OBS_GetAvailableDenominators(bounds, filter_tags, numer_id, geom_id, timespan)

Return available denominators within a boundary and with the specified
`filter_tags`.

#### Arguments

Name | Type | Description
--- | --- | ---
bounds | Geometry(Geometry, 4326) | a geometry which some of the denominator's data must intersect with
filter_tags | Text[] | a list of filters.  Only denominators for which all of these apply are returned  `NULL` to ignore (optional)
numer_id | Text | the ID of a numerator to check whether the denominator is valid against.  Will not reduce length of returned table, but will change values for `valid_numer` (optional)
geom_id | Text | the ID of a geometry to check whether the denominator is valid against.  Will not reduce length of returned table, but will change values for `valid_geom` (optional)
timespan | Text | the ID of a timespan to check whether the denominator is valid against.  Will not reduce length of returned table, but will change values for `valid_timespan` (optional)

#### Returns

A TABLE containing the following properties

Key | Type | Description
--- | ---- | -----------
denom_id | Text | The ID of the denominator
denom_name | Text | A human readable name for the denominator
denom_description | Text | Description of the denominator.  Is sometimes NULL
denom_weight | Numeric | Numeric "weight" of the denominator.  Ignored.
denom_license | Text | ID of the license for the denominator
denom_source | Text | ID of the source for the denominator
denom_type | Text | Postgres type of the denominator
denom_aggregate | Text | Aggregate type of the denominator.  If `'SUM'`, this can be normalized by area
denom_extra | JSONB | Extra information about the denominator column.  Ignored.
denom_tags | Text[] | Array of all tags applying to this denominator
valid_numer | Boolean | True if the `numer_id` argument is a valid numerator for this denominator, False otherwise
valid_geom | Boolean | True if the `geom_id` argument is a valid geometry for this denominator, False otherwise
valid_timespan | Boolean | True if the `timespan` argument is a valid timespan for this denominator, False otherwise

#### Examples

Obtain all denominators that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326));
```

Obtain all denominators that are available within a small rectangle and are for
the United States only.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states}');
```

Obtain all denominators for male population (`us.census.acs.B01001002`).

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01001002')
WHERE valid_numer IS True;
```

Obtain all denominators that work with US states (`us.census.tiger.state`)
as a geometry.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, 'us.census.tiger.state')
WHERE valid_geom IS True;
```

Obtain all denominators available in the timespan `2011 - 2015`.

```SQL
SELECT * FROM OBS_GetAvailableDenominators(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, '2011 - 2015')
WHERE valid_timespan IS True;
```

### OBS_GetAvailableGeometries(bounds, filter_tags, numer_id, denom_id, timespan, number_geometries)

Return available geometries within a boundary and with the specified
`filter_tags`.

#### Arguments

Name | Type | Description
--- | --- | ---
bounds | Geometry(Geometry, 4326) | a geometry which must intersect the geometry
filter_tags | Text[] | a list of filters.  Only geometries for which all of these apply are returned  `NULL` to ignore (optional)
numer_id | Text | the ID of a numerator to check whether the geometry is valid against.  Will not reduce length of returned table, but will change values for `valid_numer` (optional)
denom_id | Text | the ID of a denominator to check whether the geometry is valid against.  Will not reduce length of returned table, but will change values for `valid_denom` (optional)
timespan | Text | the ID of a timespan to check whether the geometry is valid against.  Will not reduce length of returned table, but will change values for `valid_timespan` (optional)
number_geometries | Integer | an additional variable that is used to adjust the calculation of the [score]({{ site.dataobservatory_docs}}/guides/discovery-functions/#returns-4) (optional)

#### Returns

A TABLE containing the following properties

Key | Type | Description
--- | ---- | -----------
geom_id | Text | The ID of the geometry
geom_name | Text | A human readable name for the geometry
geom_description | Text | Description of the geometry.  Is sometimes NULL
geom_weight | Numeric | Numeric "weight" of the geometry.  Ignored.
geom_aggregate | Text | Aggregate type of the geometry.  Ignored.
geom_license | Text | ID of the license for the geometry
geom_source | Text | ID of the source for the geometry
geom_type | Text | Postgres type of the geometry
geom_extra | JSONB | Extra information about the geometry column.  Ignored.
geom_tags | Text[] | Array of all tags applying to this geometry
valid_numer | Boolean | True if the `numer_id` argument is a valid numerator for this geometry, False otherwise
valid_denom | Boolean | True if the `geom_id` argument is a valid geometry for this geometry, False otherwise
valid_timespan | Boolean | True if the `timespan` argument is a valid timespan for this geometry, False otherwise
score | Numeric | Score between 0 and 100 for this geometry, higher numbers mean that this geometry is a better choice for the passed extent
numtiles | Numeric | How many raster tiles were read for score, numgeoms, and percentfill estimates
numgeoms | Numeric | About how many of these geometries fit inside the passed extent
percentfill | Numeric | About what percentage of the passed extent is filled with these geometries
estnumgeoms | Numeric | Ignored
meanmediansize | Numeric | Ignored

#### Examples

Obtain all geometries that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326));
```

Obtain all geometries that are available within a small rectangle and are for
the United States only.

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), '{section/tags.united_states}');
```

Obtain all geometries that work with total population (`us.census.acs.B01003001`).

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01003001')
WHERE valid_numer IS True;
```

Obtain all geometries with timespan  `2015`.

```SQL
SELECT * FROM OBS_GetAvailableGeometries(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, '2015')
WHERE valid_timespan IS True;
```

## OBS_GetAvailableTimespans(bounds, filter_tags, numer_id, denom_id, geom_id)

Return available timespans within a boundary and with the specified
`filter_tags`.

#### Arguments

Name | Type | Description
--- | --- | ---
bounds | Geometry(Geometry, 4326) | a geometry which some of the timespan's data must intersect with
filter_tags | Text[] | a list of filters.  Ignore
numer_id | Text | the ID of a numerator to check whether the timespans is valid against.  Will not reduce length of returned table, but will change values for `valid_numer` (optional)
denom_id | Text | the ID of a denominator to check whether the timespans is valid against.  Will not reduce length of returned table, but will change values for `valid_denom` (optional)
geom_id | Text | the ID of a geometry to check whether the timespans is valid against.  Will not reduce length of returned table, but will change values for `valid_geom` (optional)

#### Returns

A TABLE containing the following properties

Key | Type | Description
--- | ---- | -----------
timespan_id | Text | The ID of the timespan
timespan_name | Text | A human readable name for the timespan
timespan_description | Text | Ignored
timespan_weight | Numeric | Ignored
timespan_aggregate | Text | Ignored
timespan_license | Text | Ignored
timespan_source | Text | Ignored
timespan_type | Text | Ignored
timespan_extra | JSONB | Ignored
timespan_tags | JSONB | Ignored
valid_numer | Boolean | True if the `numer_id` argument is a valid numerator for this timespan, False otherwise
valid_denom | Boolean | True if the `timespan` argument is a valid timespan for this timespan, False otherwise
valid_geom | Boolean | True if the `geom_id` argument is a valid geometry for this timespan, False otherwise

#### Examples

Obtain all timespans that are available within a small rectangle.

```SQL
SELECT * FROM OBS_GetAvailableTimespans(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326));
```

Obtain all timespans for total population (`us.census.acs.B01003001`).

```SQL
SELECT * FROM OBS_GetAvailableTimespans(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, 'us.census.acs.B01003001')
WHERE valid_numer IS True;
```

Obtain all timespans that work with US states (`us.census.tiger.state`)
as a geometry.

```SQL
SELECT * FROM OBS_GetAvailableTimespans(
  ST_MakeEnvelope(-74, 41, -73, 40, 4326), NULL, NULL, NULL, 'us.census.tiger.state')
WHERE valid_geom IS True;
```
