# Boundary Functions

Use the following functions to retrieve [Boundary](/cartodb-platform/data/overview/#boundary-data) data. Data ranges from small areas (e.g. US Census Block Groups) to large areas (e.g. Countries). You can access boundaries by point location lookup, bounding box lookup, direct ID access and several other methods described below.

You can [access](/cartodb-platform/data/accessing/#accessing-the-data-observatory) boundaries through the CartoDB Editor. The same methods will work if you are using the CartoDB Platform to develop your application. We [encourage you](/cartodb-platform/data/accessing/#best-practices) to use table modifying methods (UPDATE and INSERT) over dynamic methods (SELECT).

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
the_geom | a boundary geometry (e.g., US Census tract boundaries)
geom_refs | a string identifier for the geometry (e.g., geoids of US Census tracts)

If geometries are not found for the requested `polygon`, `geometry_id`, `timespan`, or `overlap_type`, then null values are returned.

#### Example

Insert all Census Tracts from Lower Manhattan and nearby areas within the supplied bounding box to a table named `manhattan_census_tracts` which has columns `the_geom` (geometry) and `geom_refs` (text).

```sql
INSERT INTO manhattan_census_tracts(the_geom, geom_refs)
SELECT *
FROM OBS_GetBoundariesByGeometry(
       ST_MakeEnvelope(-74.0251922607,40.6945658517,
                      -73.9651107788,40.7377626342,
                      4326),
       'us.census.tiger.census_tract')
```

#### Errors

* If a geometry other than a point is passed as the first argument, an error is thrown: `Invalid geometry type (ST_Polygon), expecting 'ST_Point'`
* If an `overlap_type` other than the valid ones listed above is entered, then an error is thrown

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
geom_refs| a string identifier for the geometry (e.g., the geoid of a US Census tract)

If geometries are not found for the requested geometry, `geometry_id`, `timespan`, or `overlap_type`, then NULL values are returned.

#### Example

Insert points that lie on Census Tracts from Lower Manhattan and nearby areas within the supplied bounding box to a table named `manhattan_tract_points` which has columns `the_geom` (geometry) and `geom_refs` (text).

```sql
INSERT INTO manhattan_tract_points (the_geom, geom_refs)
SELECT *
FROM OBS_GetPointsByGeometry(
       ST_MakeEnvelope(-74.0251922607,40.6945658517,
                       -73.9651107788,40.7377626342,
                       4326),
       'us.census.tiger.census_tract')
```

#### Errors

* If a geometry other than a point is passed as the first argument, an error is thrown: `Invalid geometry type (ST_Point), expecting 'ST_MultiPolygon' or 'ST_Polygon'`

## OBS_GetBoundary(point_geometry, boundary_id)

The ```OBS_GetBoundary(point_geometry, boundary_id)``` method returns a boundary geometry defined as overlapping the point geometry and from the desired boundary set (e.g. Census Tracts). See the [Boundary ID glossary table below](below). This is a useful method for performing aggregations of points.

#### Arguments

Name | Description
--- | ---
point_geometry | a WGS84 polygon geometry (the_geom)
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)

#### Returns

A boundary geometry. If no value is found at the requested `boundary_id` or `timespan`, a null value is returned.

Value | Description
--- | ---
geom | WKB geometry

#### Example

Overwrite a point geometry with a boundary geometry that contains it in your table

```SQL
UPDATE tablename
SET the_geom = OBS_GetBoundary(the_geom, 'us.census.tiger.block_group')
```

#### Errors

* If a geometry other than a point is passed, an error is thrown: `Invalid geometry type (ST_Line), expecting 'ST_Point'`

## OBS_GetBoundaryId(point_geometry, boundary_id)

The ```OBS_GetBoundaryId(point_geometry, boundary_id)``` returns a unique geometry_id for the boundary geometry that contains a given point geometry. See the [Boundary ID glossary table below](below). The method can be combined with ```OBS_GetBoundaryById(geometry_id)``` to create a point aggregation workflow.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 point geometry (the_geom)
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)

#### Returns

A TEXT boundary geometry id. If no value is found at the requested `boundary_id` or `timespan`, a null value is returned.

Value | Description
--- | ---
geometry_id | a string identifier of a geometry in the Boundaries

#### Example

Write the US Census block group geoid that contains the point geometry for every row as a new column in your table.

```SQL
UPDATE tablename
SET geometry_id = OBS_GetBoundaryId(the_geom, 'us.census.tiger.block_group')
```

#### Errors

* If a geometry other than a point is passed, an error is thrown: `Invalid geometry type (ST_Line), expecting 'ST_Point'`

## OBS_GetBoundaryById(geometry_id, boundary_id)

The ```OBS_GetBoundaryById(geometry_id, boundary_id)``` returns the boundary geometry for a unique geometry_id. A geometry_id can be found using the ```OBS_GetBoundaryId(point_geometry, boundary_id)``` method described above.

#### Arguments

Name | Description
--- | ---
geometry_id | a string identifier for a Boundary geometry
boundary_id | a boundary identifier from the [Boundary ID glossary table below](below)
timespan (optional) | year(s) to request from (`NULL` (default) gives most recent)

#### Returns

A boundary geometry. If a geometry is not found for the requested `geometry_id`, `boundary_id`, or `timespan`, then a null value is returned.

Key | Description
--- | ---
geom | a WGS84 polygon geometry

#### Example

Use a table of `geometry_id`s (e.g., geoid from the U.S. Census) to select the unique boundaries that they correspond to and insert into a table called, `overlapping_polygons`. This is a useful method for creating new choropleths of aggregate data.

```SQL
INSERT INTO overlapping_polygons (the_geom, geometry_id, point_count)
SELECT
  OBS_GetBoundaryById(geometry_id, 'us.census.tiger.county') As the_geom,
  geometry_id,
  count(*)
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
geom_refs| a string identifier for the geometry (e.g., the geoid of a US Census tract)

If geometries are not found for the requested point and radius, `geometry_id`, `timespan`, or `overlap_type`, then null values are returned.

#### Example

Insert into table `denver_census_tracts` the census tract boundaries and geom_refs of census tracts which intersect within 10 miles of downtown Denver, Colorado.

```sql
INSERT INTO denver_census_tracts(the_geom, geom_refs)
SELECT *
FROM OBS_GetBoundariesByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  'us.census.tiger.census_tract')
```

#### Errors

* If a geometry other than a point is passed, an error is thrown. E.g., `Invalid geometry type (ST_Line), expecting 'ST_Point'`

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
geom_refs | a string identifier for the geometry (e.g., the geoid of a US Census tract)

If geometries are not found for the requested point and radius, `geometry_id`, `timespan`, or `overlap_type`, then null values are returned.

#### Example

Insert into table `denver_tract_points` points on US census tracts and their corresponding geoids for census tracts which intersect within 10 miles of downtown Denver, Colorado, USA.

```sql
INSERT INTO denver_tract_points(the_geom, geom_refs)
SELECT *
FROM OBS_GetPointsByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  'us.census.tiger.census_tract')
```

#### Errors

* If a geometry other than a point is passed, an error is thrown. E.g., `Invalid geometry type (ST_Line), expecting 'ST_Point'`
