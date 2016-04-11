
## Name

OBS_ListGeomColumns - List all available geometers in the data observatory

## Synopsis

```postgresql
setof text OBS_ListGeomColumns();
```

## Description

Returns a list of the names of available region tables within the Data Observatory

Inputs:

None

Outputs:

A table with the following columns

- Name - the name of the geometry.

## Examples

```sql
SELECT * FROM OBS_ListGeomColumns()
```

Result

| Name |
|------|
| "us.census.tiger".county |
| "us.census.tiger".state |
| "us.census.tiger".puma |
| "us.census.tiger".block_group |
| "us.census.tiger".census_tract |
| "us.census.tiger".congressional_district |
| "us.census.tiger".zcta5 |
| "us.census.tiger".block |  

## API Usage

Example:

```text
http://observatory.cartodb.com/api/v2/sql?q=SELECT * FROM OBS_ListGeomColumns()
```

Result:

```json
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
