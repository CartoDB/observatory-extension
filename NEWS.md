1.0.1 (2016-07-01)
---

__Bugfixes__

* Fix for ERROR:  Operation on mixed SRID geometries #130


1.0.0 (6/27/2016)
-----

* Incremented to 1.0.0 to be in compliance with [SemVer](http://semver.org/),
  which disallows use of 0.x.x versions.  This also reflects that we are
  already in production.

__API Changes__

* Added `OBS_DumpVersion` to look up version data ([#118](https://github.com/CartoDB/observatory-extension/pull/118))

__Improvements__

* Whether data exists for a geom now determined by polygon intersection instead of
  BBOX overlap ([#119](https://github.com/CartoDB/observatory-extension/pull/119))
* Automated tests cover Spanish and UK data
  ([#115](https://github.com/CartoDB/observatory-extension/pull/115))
* Automated tests cover `OBS_GetUSCensusMeasure`
  ([#105](https://github.com/CartoDB/observatory-extension/pull/105))

__Bugfixes__

* Geom table can have different `geomref_colname` than the data table
  ([#123](https://github.com/CartoDB/observatory-extension/pull/123))


0.0.5 (5/27/2016)
-----
* Adds new function `OBS_GetMeasureById` ([#96](https://github.com/CartoDB/observatory-extension/pull/96))

0.0.4 (5/25/2016)
-----
* Updates queries involving US Census measure tags to be more generic ([#95](https://github.com/CartoDB/observatory-extension/pull/95))
* Fixes tests which relied on an erroneous subset of block groups ([#95](https://github.com/CartoDB/observatory-extension/pull/95))

0.0.3 (5/24/2016)
-----
* Generalizes internal queries to properly pull from multiple named geometry references
* Adds tests for Who's on First boundaries
* Improves automatic fixtures testing script

0.0.2 (5/19/2016)
-----
* Adds Data Observatory exploration functions
* Adds Data Observatory boundary functions
* Adds Data Observatory measure functions
* Adds script to generate fixtures for tests
* Adds script for the automatic testing of metadata
* Adds full documentation for all included functions
* removes `cartodb` extension dependency

0.0.1 (5/19/2016)
------------------
* First iteration of `OBS_GetDemographicSnapshot(location Geometry(Point,4326))`
