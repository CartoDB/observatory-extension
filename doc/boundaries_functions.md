# Boundaries Functions

If you are using the [boundary methods](/dataobservatory/overview/#boundary-methods) from the Data Observatory, use the following functions to retrieve [Boundary](/dataobservatory/overview/#boundary-data) data. You can get global boundary geometries by point or polygon geometries.

## OBS_GetGeometry(point_geometry, boundary_id)

The ```OBS_GetGeometry(point_geometry, boundary_id)``` function returns a boundary geometry defined as overlapping the point geometry and from the desired boundary set (e.g. Census Tracts). See the [Boundary ID glossary](/dataobservatory/glossary/#boundary-ids). This is useful for performing aggregations of points.

#### Arguments

Name | Description
--- | ---
point_geometry | a WGS84 polygon geometry (the_geom)
boundary_id | a boundary identifier from the [Boundary ID glossary](/dataobservatory/glossary/#boundary-ids)  

#### Returns

Value | Description
--- | ---
geom | WKB geometry

#### Example

Overwrite a point geometry with a boundary geometry that contains it in your table

```SQL
UPDATE tablename SET the_geom = OBS_GetGeometry(the_geom, ' "us.census.tiger".block_group')
```

<!--
Should add the SQL API call here too
-->

## OBS_GetGeometryId(point_geometry, boundary_id)

The ```OBS_GetGeometryId(point_geometry, boundary_id)``` returns a unique geometry_id for the boundary geometry that contains a given point geometry. See the [Boundary ID glossary](/dataobservatory/glossary/#boundary-ids). The function can be combined with ```OBS_GetGeometryById(geometry_id)``` to create a point aggregation workflow.

#### Arguments

Name |Description
--- | ---
point_geometry | a WGS84 polygon geometry (the_geom)
boundary_id | a boundary identifier from the [Boundary ID glossary](/dataobservatory/glossary/#boundary-ids)  

#### Returns

Value | Description
--- | ---
geometry_id | a string identifier of a geometry in the Boundaries

#### Example

Write the geometry_id that contains the point geometry for every row as a new column in your table

```SQL
UPDATE tablename SET new_column_name = OBS_GetGeometryId(the_geom, ' "us.census.tiger".block_group')
```

## OBS_GetGeometryById(geometry_id)

The ```OBS_GetGeometryById(geometry_id)``` returns the boundary geometry for a unique geometry_id. A geometry_id can be found using the ```OBS_GetGeometryId(point_geometry, boundary_id)``` function described above.

#### Arguments

Name |Description
--- | ---
geometry_id | a string identifier for a Boundary geometry

#### Returns

A JSON object containing the following properties

Key | Description
--- | ---
geom | a WGS84 polygon geometry

#### Example

Use a table of geometry_id to select the unique boundaries. Useful with the ```Table from query``` option in CartoDB.

```SQL
SELECT OBS_GetGeometryById(geometry_id) the_geom, geometry_id FROM tablename GROUP BY geometry_id
```