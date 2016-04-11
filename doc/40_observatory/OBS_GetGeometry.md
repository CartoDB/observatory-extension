## Name

OBS_Get_Geometry - Gets the geometric boundary that a point falls in or matches a geographic reference.

## Synopsis

### Accepts a geometry

```sql
OBS_Get_Geometry(geometry the_geom);
OBS_Get_Geometry(geometry the_geom, text geometry_level);
```

### Accepts a geometry identifier

```sql
OBS_Get_Geometry_By_Address(text geom_ref, text geometry_level);
```


## Description

### Accepts a geometry version

Returns the polygon from the `geometry_level` that `the_geom` intersects. If `use_literal` is `false` (default behavior), then a table is guessed (e.g., `census tract` finds the most recent Census Tract boundary which intersects with the point). If `use_literal` is `true`, then the table entered in `geometry_level` is used.

Inputs:

- the_geom geometry - geometry where you want to know the given boundary for (e.g., find the Digital Marketing Area for this point)
- geometry_level text - description of the table where you want information (e.g., Census Block Group)
- use_literal boolean - whether to use the `geometry_level` table as given, or find one that matches

Outputs:

- geometry - geographic boundary where point intersects

### Accepts a geometry identifier version

Returns the polygon from the `geometry_level` which matches the `geom_ref` identifier.

## Examples

```postgresql
SELECT
  OBS_Get_Geometry(the_geom, '"us.census.tiger".county')
FROM
  mobile_ad_data
```

Result

|   | Name                                          | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        | Aggregate | Source        |
|---|-----------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------|---------------|
| 1 | Median Household Income in the past 12 Months | Within a geographic area, the median income received by every household on a regular basis before payments for personal income taxes, social security, union dues, medicare deductions, etc.,It includes income received from wages, salary, commissions, bonuses, and tips; self-employment income from own nonfarm or farm businesses, including proprietorships and partnerships; interest, dividends, net rental income, royalty income, or income from estates and trusts; Social Security or Railroad Retirement income; Supplemental Security Income (SSI); any cash public assistance or welfare payments from the state or local welfare office; retirement, survivor, or disability benefits; and any other sources of income received regularly such as Veterans' (VA) payments, unemployment and/or worker's compensation, child support, and alimony. | median    | us.census.acs |

## API Usage

Example:

```curl
http://observatory.cartodb.com/api/v2/sql?q=select * from OBS_SEARCH('salary')
```

Result:

```javascript
{
  time: 0.120,
  total_rows: 1,
  rows: [{
    Name: "Median Household Income in the past 12 Months",
    Description: "Within a geographic area, the median income received by every household on a regular basis before payments for personal income taxes, social security, union dues, medicare deductions, etc.,It includes income received from wages, salary, commissions, bonuses, and tips; self-employment income from own nonfarm or farm businesses, including proprietorships and partnerships; interest, dividends, net rental income, royalty income, or income from estates and trusts; Social Security or Railroad Retirement income; Supplemental Security Income (SSI); any cash public assistance or welfare payments from the state or local welfare office; retirement, survivor, or disability benefits; and any other sources of income received regularly such as Veterans' (VA) payments, unemployment and/or worker's compensation, child support, and alimony.",
    Aggregate: "median"
    Source: "us.census.acs"

  }]
}
```

## See Also
