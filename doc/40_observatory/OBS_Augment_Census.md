
## Name

OBS_Augment_Census - returns the census variable appropriately aggregated appropriately to the input geometry.

## Synopsis

```postgresql
OBS_Augment_Census (
  geom geometry (ST_Point),
  column_name text
);

OBS_Augment_Census (
  geom geometry (ST_Polygon),
  column_name text
);

OBS_Augment_Census (
  geom geometry (ST_Point),
  column_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
);

OBS_Augment_Census (
  geom geometry (ST_Polygon),
  column_name text,
  time_span text DEFAULT '2009 - 2013',
  geometry_level text DEFAULT '"us.census.tiger".block_group'
);
```

## Description

Inputs:

- geom - An input geometry, can be either points of polygons.
- dimension_name - the name of the target dimension.
- time_span (Optional defaults to '2009 -2013') - the time span you want the target dimension for.
- geometry_level (Optional defaults to '"us.census.tiger".block_group' ) - the census geometry you want the target dimension from. By default the function uses the highest resolution geometries, the block groups.

Outputs:

- value - the original value of the requested dimension.

If the input geometry is a point and the target dimension is not an aggregated type, for example a ratio or rate, then value is simply the value of that dimension in the census geometry that the input point lies in.

If the input geometry is a point and the target dimension is a count then value is the dimension divided by the area of the census area the input point is located in. So the value is in units of count per square meter.

If the input geometry is a polygon and the target dimension is a count, then the function find every census geometry which intersects the input geometry. It calculates the area of the intersection and performs a weighted sum of the dimension * area over all the geometries.

## Errors

 - 'Dimension does not exist' - Thrown if the requested dimension does not exist
 - 'Target dimension is not a sum value, cant aggregate!' - Thrown when the input geometry is a polygon and the target dimension is a rate. It's not clear how to aggregate those rates across the different polygons so we throw and error.

## Examples

With point input data:

```postgresql
SELECT OBS_Augment_Census(
  CDB_LATLNG(40.704512, -73.936669),
   'total_pop'
) as population per square meter
```

Result:

|   | population per square meter |
|---|------|
| 1 | 0.00951 |

With Polygon data:

```postgresql
SELECT OBS_Augment_Census(
  ST_BUFFER(
    CDB_LATLNG(40.704512, -73.936669)::geography
    , 5000
  )::geometry,
   'total_pop'
) as 'population'
```

Result

|   | population  |
|---|------|
| 1 | 1165820.828 |


## API Usage

Example:

```curl
http://observatory.cartodb.com/api/v2/sql?q=SELECT * FROM SELECT OBS_Augment_Census(CDB_LATLNG(40.704512, -73.936669),'total_pop') as population_per_square_meter
```

Result:

```javascript
{
  time: 0.120,
  total_rows: 9,
  rows: [{
    population_per_square_meter: 0.00951
  }]
}
```

## See Also
