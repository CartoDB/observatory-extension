# Data Observatory

This module contains a series of PL/pgSQL functions designed to make joining
your data with data in the Data Observatory seamless.

## Search functions

- [OBS_Search](40_observatory/OBS_Search.md) - Search the Data Observatory for a dimension
- [OBS_ListGeomColumns](40_observatory/OBS_ListGeomColumns.md) List the geometries that are available on the Data Observatory

## Augmentation functions

- [OBS_Augment_Census](40_observatory/OBS_AugmentCensus.md) - For a given input geometry get the request census dimension aggregated in a sensible way.


## Geometry functions

- [OBS_GetGeometryId](40_observatory/OBS_GetGeometry.md) - For a given point (lat/long or address) and approximate dataset name, return the polygon boundary identifier (e.g., the census tract that the point falls within).

- [OBS_GetGeometryId](40_observatory/OBS_GetGeometryId.md) - For a given point (lat/long or address) and approximate dataset name, return the polygon boundary (e.g., the census tract that the point falls within).
