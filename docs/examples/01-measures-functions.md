
## Measures functions examples

- Add a measure to an empty numeric column based on point locations in your table.

```SQL
UPDATE tablename
SET total_population = OBS_GetUSCensusMeasure(the_geom, 'Total Population')


- Add a measure to an empty numeric column based on polygons in your table

```SQL
UPDATE tablename
SET local_male_population = OBS_GetUSCensusMeasure(the_geom, 'Male Population')
```

- Add a measure to an empty numeric column based on point locations in your table

```SQL
UPDATE tablename
SET median_home_value_sqft = OBS_GetMeasure(the_geom, 'us.zillow.AllHomes_MedianValuePerSqft')
```


- Add a measure to an empty column based on polygons in your table

```SQL
UPDATE tablename
SET household_count = OBS_GetMeasure(the_geom, 'us.census.acs.B11001001')
```


- Add the Category to an empty column text column based on point locations in your table

```SQL
UPDATE tablename
SET segmentation = OBS_GetCategory(the_geom, 'us.census.spielman_singleton_segments.X55')
```


- Obtain metadata that can augment with one additional column of US population
data, using a boundary relevant for the geometry provided and latest timespan.
Limit to only the most recent column most relevant to the extent & density of
input geometries in `tablename`.

```SQL
SELECT OBS_GetMeta(
  ST_SetSRID(ST_Extent(the_geom), 4326),
  '[{"numer_id": "us.census.acs.B01003001"}]',
  1, 1,
  COUNT(*)
) FROM tablename
```

- Obtain metadata that can augment with one additional column of US population
data, using census tract boundaries.

```SQL
SELECT OBS_GetMeta(
  ST_SetSRID(ST_Extent(the_geom), 4326),
  '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.census_tract"}]',
  1, 1,
  COUNT(*)
) FROM tablename
```

- Obtain metadata that can augment with two additional columns, one for total
population and one for male population.

```SQL
SELECT OBS_GetMeta(
  ST_SetSRID(ST_Extent(the_geom), 4326),
  '[{"numer_id": "us.census.acs.B01003001"}, {"numer_id": "us.census.acs.B01001002"}]',
  1, 1,
  COUNT(*)
) FROM tablename
```


- Validate metadata with two additional columns of US census data; using a boundary relevant for the geometry provided and the latest timespan. Limited to the most recent column, and the most relevant, based on the extent and density of input geometries in `tablename`.

```SQL
SELECT OBS_MetadataValidation(
  ST_SetSRID(ST_Extent(the_geom), 4326),
  ST_GeometryType(the_geom),
  '[{"numer_id": "us.census.acs.B01003001"}, {"numer_id": "us.census.acs.B01001002"}]',
  COUNT(*)::INTEGER
) FROM tablename
GROUP BY ST_GeometryType(the_geom)
```


- Obtain population densities for every geometry in a table, keyed by cartodb_id:

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(
    ST_SetSRID(ST_Extent(the_geom), 4326),
    '[{"numer_id": "us.census.acs.B01003001"}]',
    1, 1, COUNT(*)
) meta FROM tablename)
SELECT id AS cartodb_id, (data->0->>'value')::Numeric AS pop_density
FROM OBS_GetData((SELECT ARRAY_AGG((the_geom, cartodb_id)::geomval) FROM tablename),
                 (SELECT meta FROM meta))
```

- Update a table with a blank numeric column called `pop_density` with population
densities:

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(
    ST_SetSRID(ST_Extent(the_geom), 4326),
    '[{"numer_id": "us.census.acs.B01003001"}]',
    1, 1, COUNT(*)
) meta FROM tablename),
data AS (
  SELECT id AS cartodb_id, (data->0->>'value')::Numeric AS pop_density
  FROM OBS_GetData((SELECT ARRAY_AGG((the_geom, cartodb_id)::geomval) FROM tablename),
                   (SELECT meta FROM meta)))
UPDATE tablename
SET pop_density = data.pop_density
FROM data
WHERE cartodb_id = data.id
```

- Update a table with two measurements at once, population density and household
density.  The table should already have a Numeric column `pop_density` and
`household_density`.

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(
    ST_SetSRID(ST_Extent(the_geom),4326),
    '[{"numer_id": "us.census.acs.B01003001"},{"numer_id": "us.census.acs.B11001001"}]',
    1, 1, COUNT(*)
) meta from tablename),
data AS (
  SELECT id,
     data->0->>'value' AS pop_density,
     data->1->>'value' AS household_density
  FROM OBS_GetData((SELECT ARRAY_AGG((the_geom, cartodb_id)::geomval) FROM tablename),
                   (SELECT meta FROM meta)))
UPDATE tablename
SET pop_density = data.pop_density,
    household_density = data.household_density
FROM data
WHERE cartodb_id = data.id
```


- Obtain population densities for every row of a table with FIPS code county IDs
(USA).

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(
    ST_SetSRID(ST_Extent(the_geom), 4326),
    '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.county"}]'
) meta FROM tablename)
SELECT id AS fips, (data->0->>'value')::Numeric AS pop_density
FROM OBS_GetData((SELECT ARRAY_AGG(fips) FROM tablename),
                 (SELECT meta FROM meta))
```

- Update a table with population densities for every FIPS code county ID (USA).
This table has a blank column called `pop_density` and fips codes stored in a
column `fips`.

```SQL
WITH meta AS (
  SELECT OBS_GetMeta(
    ST_SetSRID(ST_Extent(the_geom), 4326),
    '[{"numer_id": "us.census.acs.B01003001", "geom_id": "us.census.tiger.county"}]'
) meta FROM tablename),
data as (
  SELECT id AS fips, (data->0->>'value') AS pop_density
  FROM OBS_GetData((SELECT ARRAY_AGG(fips) FROM tablename),
                   (SELECT meta FROM meta)))
UPDATE tablename
SET pop_density = data.pop_density
FROM data
WHERE fips = data.id
```
