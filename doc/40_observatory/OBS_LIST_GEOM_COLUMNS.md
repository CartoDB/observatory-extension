
## Name

OBS_LIST_GEOM_COLUMNS - List all available geometers in the data observatory

## Synopsis

```postgresql
OBS_LIST_GEOM_COLUMNS ();
```

## Description

Returns a list of the names of available region tables within the Data Observatory

Inputs:

None

Outputs:

A table with the following columns

- Name - the name of the geometry.

## Examples

```postgresql
SELECT * FROM OBS_LIST_GEOM_COLUMNS()
```

Result

|   | Name |
|---|------|
| 2 | "us.census.tiger".county |
| 3 | "us.census.tiger".state |
| 4 | "us.census.tiger".puma |
| 5 | "us.census.tiger".block_group |
| 6 | "us.census.tiger".census_tract |
| 7 | "us.census.tiger".congressional_district |
| 8 | "us.census.tiger".zcta5 |
| 9 | "us.census.tiger".block |  

## API Usage

Example:

```curl
http://observatory.cartodb.com/api/v2/sql?q=SELECT * FROM OBS_LIST_GEOM_COLUMNS()
```

Result:

```javascript
{
  time: 0.120,
  total_rows: 9,
  rows: [{
    Name: '"us.census.tiger".county'
  },
  {
    Name:  '"us.census.tiger".state'
  },
  ...
  ]
}
```

## See Also
