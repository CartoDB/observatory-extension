## Name

OBS_SEARCH - Allows you to search for a dimension within the Data Observatory.
Returns a list of matched variables with descriptions and meta data for each.

## Synopsis

```postgresql
OBS_SEARCH (search_term text);
````

## Description
***

The Data Observatory contains a lot of information from a lot of sources. This
method allows you to search for a given dimension. It does a fuzzy search on
the human readable variable name and its description.

Inputs:

- search_term text - the term to search fro

Outputs:

A table with the following columns

- Name - the matched variable name.
- Description - a description of the matched variable.
- Aggregate - how this dimension was aggregated if at all.
- Source - the data set that this dimension came from.


## Examples

```postgresql
SELECT * from OBS_SEARCH('salary')
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
