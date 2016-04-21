# Data Observatory Access

This file is for reference purposes only. It is intended for tracking the Data Observatory API functions that should be displayed from the Docs site. Like all API doc, the golden source of the code will live in this repo. I will pull the list of files below into the docs for the output.

## Documentation

## OBS_GetDemographicSnapshot

The Demographic Snapshot API call enables you to collect demographic details around a point location. For example, you can take the coordinates of a bus stop and find the average population characteristics in that location. If you need help creating coordinates from addresses, [see our geocoding documentation].

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
| point geometry  |  A WKB point geometry. You can use the helper function, CDB_LatLng to quickly generate one from latitude and longitude | CDB_LatLng(40.760410,-73.964242)  |

#### Geographic Scope

The Demographic Snapshot API is available for the following countries:

* United States

### API Examples

__Get the Demographic Snapshot at Camp David__

```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot(CDB_LatLng(39.648333, -77.465))
```
__Get the Demographic Snapshot in the Upper West Side__

```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetDemographicSnapshot(CDB_LatLng(40.80, -73.960))
```

### API Response

[Click to expand](https://gist.github.com/ohasselblad/c9e59a6e8da35728d0d81dfed131ed17)

### Available fields

The Demographic Snapshot contains a broad subset of demographic measures in the Data Observatory. Over 80 measurements are returned by a single API request.

__todo: turn this spreadsheet into a markdown table__

https://docs.google.com/spreadsheets/d/1U3Uajw_PsIy3_YgeujnJ7AiL2VREdT-ozdaulx07q2g/edit#gid=430723120

## OBS_GetSegmentationSnapshot

The Segmentation Snapshot API call enables you to determine the pre-calculated population segment for a location. For example, you can take the location of a store location and determine what classification of population exists around that location. If you need help creating coordinates from addresses, [see our geocoding documentation].

### API Syntax

```html
https://{{account name}}.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot({{point geometry}})
```

#### Parameters

| Parameter  | Description  |  Example  |
|---|:-:|:-:|
| account name  | The name of your CartoDB account where the Data Observatory has been enabled  | example_account  |
| point geometry  |  A WKB point geometry. You can use the helper function, CDB_LatLng to quickly generate one from latitude and longitude | CDB_LatLng(40.760410,-73.964242)  |

#### Geographic Scope

The Segmentation Snapshot API is available for the following countries:

* United States

### API Examples

__Get the Segmentation Snapshot around the MGM Grand__

```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot(CDB_LatLng(36.10222, -115.169516))
```
__Get the Segmentation Snapshot at CartoDB's NYC HQ__

```text
https://example_account.cartodb.com/api/v2/sql?q=SELECT * FROM
OBS_GetSegmentationSnapshot(CDB_LatLng(40.704512, -73.936669))
```

### API Response

__todo__

### Available segments

__todo__

### Methodology

Segmentation is a method that divides a target market into subgroups based on shared common traits. While we plan to make many different segmentation methods available, our first release includes a segmentation profile first defined in a paper, _Understanding America's Neighborhoods Using Uncertain Data from the American Community Survey: Output Data: US_tract_clusters_new_. [See here](http://www.tandfonline.com/doi/pdf/10.1080/00045608.2015.1052335) for further information on the work in that paper.  
