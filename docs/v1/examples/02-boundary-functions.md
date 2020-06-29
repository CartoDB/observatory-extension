- Insert all Census Tracts from Lower Manhattan and nearby areas within the supplied bounding box to a table named `manhattan_census_tracts` which has columns `the_geom` (geometry) and `geom_refs` (text).

```sql
INSERT INTO manhattan_census_tracts(the_geom, geom_refs)
SELECT *
FROM OBS_GetBoundariesByGeometry(
       ST_MakeEnvelope(-74.0251922607,40.6945658517,
                      -73.9651107788,40.7377626342,
                      4326),
       'us.census.tiger.census_tract')
```

- Insert points that lie on Census Tracts from Lower Manhattan and nearby areas within the supplied bounding box to a table named `manhattan_tract_points` which has columns `the_geom` (geometry) and `geom_refs` (text).

```sql
INSERT INTO manhattan_tract_points (the_geom, geom_refs)
SELECT *
FROM OBS_GetPointsByGeometry(
       ST_MakeEnvelope(-74.0251922607,40.6945658517,
                       -73.9651107788,40.7377626342,
                       4326),
       'us.census.tiger.census_tract')
```


- Overwrite a point geometry with a boundary geometry that contains it in your table

```SQL
UPDATE tablename
SET the_geom = OBS_GetBoundary(the_geom, 'us.census.tiger.block_group')
```


- Write the US Census block group geoid that contains the point geometry for every row as a new column in your table.

```SQL
UPDATE tablename
SET geometry_id = OBS_GetBoundaryId(the_geom, 'us.census.tiger.block_group')
```


- Use a table of `geometry_id`s (e.g., geoid from the U.S. Census) to select the unique boundaries that they correspond to and insert into a table called, `overlapping_polygons`. This is a useful method for creating new choropleths of aggregate data.

```SQL
INSERT INTO overlapping_polygons (the_geom, geometry_id, point_count)
SELECT
  OBS_GetBoundaryById(geometry_id, 'us.census.tiger.county') As the_geom,
  geometry_id,
  count(*)
FROM tablename
GROUP BY geometry_id
```


- Insert into table `denver_census_tracts` the census tract boundaries and geom_refs of census tracts which intersect within 10 miles of downtown Denver, Colorado.

```sql
INSERT INTO denver_census_tracts(the_geom, geom_refs)
SELECT *
FROM OBS_GetBoundariesByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  'us.census.tiger.census_tract')
```


- Insert into table `denver_tract_points` points on US census tracts and their corresponding geoids for census tracts which intersect within 10 miles of downtown Denver, Colorado, USA.

```sql
INSERT INTO denver_tract_points(the_geom, geom_refs)
SELECT *
FROM OBS_GetPointsByPointAndRadius(
  CDB_LatLng(39.7392, -104.9903), -- Denver, Colorado
  10000 * 1.609, -- 10 miles (10km * conversion to miles)
  'us.census.tiger.census_tract')
```