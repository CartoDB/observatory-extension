# Discovery Functions

If you are using the [discovery methods](/cartodb-platform/data/overview/#discovery-methods) from the Data Observatory, use the following functions to retrieve [boundary](/cartodb-platform/data/overview/#boundary-data) and [measures](/cartodb-platform/data/overview/#measures-data) data.

## OBS_Search(search_term)

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

## OBS_GetAvailableBoundaries(point_geometry)

Returns available `boundary_id`s at a given point geometry.

#### Arguments

Name | Description
--- | ---
point_geometry |  a WGS84 point geometry (e.g. the_geom)

#### Returns

A TABLE containing the following properties

Key | Description
--- | ---
boundary_id | a boundary identifier from the [boundary ID glossary](/cartodb-platform/data/glossary/#boundary-ids)
description | a brief description of the boundary dataset
time_span | the timespan attached the boundary. this does not mean that the boundary is invalid outside of the timespan, but is the explicit timespan published with the geometry.

#### Example

```SQL
SELECT * FROM OBS_GetAvailableBoundaries(CDB_LatLng(40.7, -73.9))
```
