# Boundaries Functions

Use the following functions to retrieve [Boundary](/cartodb-platform/dataobservatory/overview/#boundary-data) data. Data ranges from small areas (e.g. US Census Block Groups) to large areas (e.g. Countries). You can access boundaries by point location lookup, bounding box lookup, direct ID access and several other methods described below.

## OBS_GetBoundariesByGeometry(polygon geometry, geometry_id text)

The ```OBS_GetBoundariesByGeometry(geometry, geometry_id)``` method returns a set of boundary geometries that intersect a supplied geometry. This can be used to find all boundaries that are within or overlap a bounding box. You have the ability to choose whether to retrieve all boundaries that intersect your supplied bounding box or only those that fall entirely inside of your bounding box.

#### Arguments

Name |Description
--- | ---
polygon | a bounding box or other WGS84 geometry
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from ('NULL' (default) gives most recent)
overlap_type (optional) | one of '[intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html)' (default), '[contains](http://postgis.net/docs/manual-2.2/ST_Contains.html)', or '[within](http://postgis.net/docs/manual-2.2/ST_Within.html)'.

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a boundary geometry (e.g., US Census tracts)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get all Census Tracts in Lower Manhattan plus nearby areas within the supplied bounding box.

```sql
SELECT *
FROM OBS_GetBoundariesByGeometry(
  ST_MakeEnvelope(-74.0251922607,40.6945658517,
                  -73.9651107788,40.7377626342,
                  4326),
  'us.census.tiger.census_tract')
```

#### API Example

Retrieve all Census tracts contained in a bounding box around Denver, CO as a JSON response:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT * FROM OBS_GetBoundariesByGeometry(ST_MakeEnvelope(-105.4287704158,39.4600507935,-104.5089737248,40.0901569675,4326),'us.census.tiger.census_tract',  NULL, 'contains')
```

## OBS_GetPointsByGeometry(polygon geometry, geometry_id text)

The ```OBS_GetPointsByGeometry(polygon, geometry_id)``` method returns point geometries and their geographical identifiers that intersect (or are contained by) a bounding box polygon and lie on the surface of a boundary corresponding to the boundary with same geographical identifiers (e.g., a point that is on a census tract with the same geoid). This is a useful alternative to ```OBS_GetBoundariesByGeometry``` listed above because it returns much less data for each location.

#### Arguments

Name |Description
--- | ---
polygon | a bounding box or other geometry
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of '[intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html)' (default), '[contains](http://postgis.net/docs/manual-2.2/ST_Contains.html)', or '[within](http://postgis.net/docs/manual-2.2/ST_Within.html)'.

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a point geometry on a boundary (e.g., a point that lies on a US Census tract)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get all Census Tracts in Lower Manhattan plus nearby areas within the supplied bounding box.

```sql
SELECT *
FROM OBS_GetPointsByGeometry(
  ST_MakeEnvelope(-74.0251922607,40.6945658517,
                  -73.9651107788,40.7377626342,
                  4326),
  'us.census.tiger.census_tract')
```

#### API Example

Retrieve all Census tracts intersecting a bounding box around Denver, CO as a JSON response:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT * FROM OBS_GetPointsByGeometry(ST_MakeEnvelope(-105.4287704158,39.4600507935,-104.5089737248,40.0901569675,4326), 'us.census.tiger.census_tract', NULL ,'contains')
```

## OBS_GetBoundary(point geometry, boundary_id text)

The ```OBS_GetBoundary(point, boundary_id)``` method returns a boundary geometry defined as overlapping the point geometry and from the desired boundary set (e.g. Census Tracts). See the [Boundary ID glossary table below](below).

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
SET the_geom = OBS_GetBoundary(the_geom, 'us.census.tiger.block_group')
```

<!--
Should add the SQL API call here too
-->

## OBS_GetBoundaryId(point geometry, boundary_id text)

The ```OBS_GetBoundaryId(point, boundary_id)``` returns a unique geometry_id for the boundary geometry that contains a given point geometry. See the [Boundary ID glossary table below](below). The method can be combined with ```OBS_GetBoundaryById(geometry_id)``` to create a point aggregation workflow.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry (the_geom)
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

## OBS_GetBoundaryById(geometry_id text, boundary_id text)

The ```OBS_GetBoundaryById(geometry_id, boundary_id)``` returns the boundary geometry for a unique geometry_id. A geometry_id can be found using the ```OBS_GetBoundaryId(point, boundary_id)``` method described above.

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

## OBS_GetBoundariesByPointAndRadius(point geometry, radius numeric, boundary_id text)

The ```OBS_GetBoundariesByPointAndRadius(point, radius, boundary_id)``` method returns boundary geometries and their geographical identifiers that intersect (or are contained by) a circle centered on a point with a radius.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry
radius | a radius (in meters) from the center point
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of '[intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html)' (default), '[contains](http://postgis.net/docs/manual-2.2/ST_Contains.html)', or '[within](http://postgis.net/docs/manual-2.2/ST_Within.html)'.

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a boundary geometry (e.g., a US Census tract)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get Census tracts which intersect within 10 miles of Downtown, Colorado. In the Editor, you can simple use "Table from Query" to turn the result into a new dataset.

```sql
SELECT *
FROM OBS_GetBoundariesByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  'us.census.tiger.census_tract')
```

## OBS_GetPointsByPointAndRadius(point geometry, radius numeric, boundary_id text)

The ```OBS_GetPointsByPointAndRadius(point, radius, boundary_id)``` method returns point geometries on boundaries (e.g., a point that lies on a Census tract) and their geographical identifiers that intersect (or are contained by) a circle centered on a point with a radius.

#### Arguments

Name |Description
--- | ---
point | a WGS84 point geometry
radius | radius (in meters)
geometry_id | a string identifier for a boundary geometry
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)
overlap_type (optional) | one of '[intersects](http://postgis.net/docs/manual-2.2/ST_Intersects.html)' (default), '[contains](http://postgis.net/docs/manual-2.2/ST_Contains.html)', or '[within](http://postgis.net/docs/manual-2.2/ST_Within.html)'.

#### Returns

A table with the following columns:

Column Name | Description
--- | ---
the_geom | a point geometry (e.g., a point on a US Census tract)
geom_ref | a string identifier for the geometry (e.g., the geoid of a US Census tract)

#### Example

Get Census tracts which intersect within 10 miles of Downtown, Colorado. In the Editor, you can simple use "Table from Query" to turn the result into a new dataset.

```sql
SELECT *
FROM OBS_GetPointsByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  'us.census.tiger.census_tract')
```
