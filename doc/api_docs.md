# Data Observatory Access

This file is for reference purposes only. It is intended for tracking the Data Observatory API functions that should be displayed from the Docs site. Like all API doc, the golden source of the code will live in this repo. I will pull the list of files below into the docs for the output.

## Documentation

### OBS_GetSegmentationSnapshot

API Example:

```text
https://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetSegmentationSnapshot(CDB_LatLng(40.760410,-73.964242))
```

## OBS_GetDemographicSnapshot

The Demographic Snapshot API call enables you to collect demographic details around a point location. For example, you can take the coordinates of a bus stop and find the average population characteristics in that location. If you need help creating coordinates from your addresses, [see our geocoding documentation].

Fields returned include information about income, education, transportation, race, and more. Not all fields will have information for every coordinate queried.


### API Syntax

```html
https://{{account name}}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot({{point geometry}})
```

#### Parameters

| Parameter  | Description  |  Example  |
|---|:-:|:-:|
| account name  | The name of your CartoDB account where the Data Observatory has been enabled  | example_account  |
| point geometry  |  A WKB point geometry. You can use the helper function, CDB_LatLng to quickly generate one from latitude and longitude | CDB_LatLng(CDB_LatLng(40.760410,-73.964242))  |

### API Example

```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot(CDB_LatLng(40.760410,-73.964242))
```

### API Response

[Click to expand](https://gist.github.com/ohasselblad/c9e59a6e8da35728d0d81dfed131ed17)
