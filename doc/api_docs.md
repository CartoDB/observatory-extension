# Data Observatory Access

This file is for reference purposes only. It is intended for tracking the Data Observatory API functions that should be displayed from the Docs site. Like all API doc, the golden source of the code will live in this repo. I will pull the list of files below into the docs for the output.

## Documenation

### OBS_GetSegmentationSnapshot

API Example:
https://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetSegmentationSnapshot(CDB_LatLng(40.760410,-73.964242))

Response:
_Coming soon_


### OBS_GetDemographicSnapshot

SQL Example:
```sql
SELECT *
FROM OBS_GetDemographicSnapshot(CDB_LatLng(40.760410,-73.964242));
```




API Example:

```text
https://observatory.cartodb.com/api/v2/sql?q=SELECT%20*%20FROM%20OBS_GetDemographicSnapshot(CDB_LatLng(40.760410,-73.964242))
```

Response:

[Click to expand](https://gist.github.com/ohasselblad/c9e59a6e8da35728d0d81dfed131ed17)
