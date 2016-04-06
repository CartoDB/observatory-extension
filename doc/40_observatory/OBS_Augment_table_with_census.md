
## Name

OBS_AUGMENT_TABLE_WITH_CENSUS - adds the requested dimension to the input table aggregating appropriately depending on the tables
geometry type.

## Synopsis

```postgresql
OBS_AUGMENT_TABLE_WITH_CENSUS (
  target_table_name text,
  column_name text
);

OBS_AUGMENT_TABLE_WITH_CENSUS (
  target_table_name text,
  column_name text
);

OBS_AUGMENT_TABLE_WITH_CENSUS (
  target_table_name text,
  column_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
);

OBS_AUGMENT_TABLE_WITH_CENSUS (
  target_table_name text,
  column_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
);
```

## Description

Inputs:

- target_table_name - The name of the table to augment with the requested census dimension.
- dimension_name - the name of the target dimension.
- time_span (Optional defaults to '2009 -2013') - the time span you want the target dimension for.
- geometry_level (Optional defaults to '"us.census.tiger".block_group' ) - the census geometry you want the target dimension from. By default the function uses the highest resolution geometries, the block groups.

Outputs:

None

If the input table geometry is points and the target dimension is not an aggregated type, for example a ratio or rate, then the value appended to the table is simply the value of that dimension in the census geometry that the input point lies in.

If the input table geometry is points and the target dimension is a count then value that is appended to the table is the dimension divided by the area of the census area the input point is located in. So the value is in units of count per square meter.

If the input table geometry is polygons and the target dimension is a count, then the function find every census geometry which intersects the input geometry. It calculates the area of the intersection and performs a weighted sum of the dimension * area over all the geometries.

## Errors

 - 'Dimension does not exist' - Thrown if the requested dimension does not exist
 - 'Target dimension is not a sum value, cant aggregate!' - Thrown when the input table geometry is polygons and the target dimension is a rate. It's not clear how to aggregate those rates across the different polygons so we throw and error.

## Examples

With a target table that looks like

|   | the_geom | some_value |
|---|----------|------------|
| 1 | ST_POINT(40.704512, -73.936669) | 2 |


```postgresql
SELECT OBS_AUGMENT_TABLE_WITH_CENSUS(
  'target_table',
   'total_pop'
)
```

Then the resultant table looks like:

|   | the_geom | some_value |
|---|----------|------------|
| 1 | ST_POINT(40.704512, -73.936669) | 2 |



With Polygon data:

|   | the_geom | some_value | population per square meter |
|---|----------|------------|-----------------------------|
| 1 |   ST_BUFFER(CDB_LATLNG(40.704512, -73.936669)::geography, 5000)::geometry,| 2 | 0.00951 |

```postgresql
SELECT OBS_Augment_Census(
  ST_BUFFER(
    CDB_LATLNG(40.704512, -73.936669)::geography
    , 5000
  )::geometry,
   'total_pop'
)
```

Result

|   | the_geom | some_value | population |
|---|----------|------------|-----------------------------|
| 1 |   ST_BUFFER(CDB_LATLNG(40.704512, -73.936669)::geography, 5000)::geometry,| 2 | 1165820.828 |


## API Usage

Example:

```curl
http://observatory.cartodb.com/api/v2/sql?q=SELECT OBS_AUGMENT_TABLE_WITH_CENSUS('target_table','total_pop')
```

Result:

```javascript
{
  time: 0.120,
  total_rows: 0,
  rows: [
  ]
}
```

## See Also
