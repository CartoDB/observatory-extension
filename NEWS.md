1.0.7 (2016-09-20)

__Bugfixes__

* `NULL` geometries or geometry IDs no longer result in an exception from any
  augmentation functions ([#178](https://github.com/CartoDB/observatory-extension/issues/178))

__Improvements__

* Automatic tests work for Canada and Thailand

1.0.6 (2016-09-08)

__Improvements__

* New function structure for Table-level functions which allows to separate the
  framework logic from the observatory measure functions.

1.0.5 (2016-08-12)

__Improvements__

* Integration tests moved to `src/python/test/`, and can be run without hitting
  any HTTP SQL API.

1.0.4 (2016-07-26)

__Bugfixes__

* Always default arguments to `NULL`, which prevents duplication & overwrite by
  dataservices-api
  ([#173](https://github.com/CartoDB/observatory-extension/issues/173))

1.0.3 (2016-07-25)

__Bugfixes__

* Raise exception instead of crashing when `OBS_GetMeasure` is passed a polygon
  in combination with a non-summable measure ([cartodb/issues
  #9063](https://github.com/CartoDB/cartodb/issues/9063))
* Unnecessary dependencies on cartodb and plpythonu removed
  ([#161](https://github.com/CartoDB/observatory-extension/issues/161))
* Tests forced to run in-order on all systems
  ([#162](https://github.com/CartoDB/observatory-extension/issues/162))
* Area normalization done by square kilometer instead of square meter for
  polygons ([#158](https://github.com/CartoDB/observatory-extension/issues/158))
* `postgres-fdw` installed as required in unit test environment
  ([#166](https://github.com/CartoDB/observatory-extension/issues/166))

__Improvements__

* Added tests to make sure all functions can handle explicit NULL as default
  ([#159](https://github.com/CartoDB/observatory-extension/issues/159))
* Buffer and snaptogrid used to be far more liberal accepting problem geoms
  ([#170](https://github.com/CartoDB/observatory-extension/issues/160))


1.0.2 (2016-07-12)
---

__Bugfixes__

* Fix for `OBS_GetCategory` outside the US ([#135](https://github.com/CartoDB/observatory-extension/pull/137))
* `OBS_GetMeasure` now respects the `normalize` parameter even when passed
  a multi/polygon. Previously, no normalization was erroneously assumed.

__Improvements__

* Automated tests cover Mexico data
* `obs_meta` is now provisioned during unit tests
* `obs_meta` is now used during end-to-end tests
* `OBS_GetMeasureByID` uses `obs_meta` internally, which should help
  performance
* `OBS_GetCategory` uses `obs_meta` internally, which should help perfromance
* `OBS_GetCategory` will pick the correct category for an arbitrary polygon
  (the category covering the highest % of that polygon)
* `OBS_GetMeasure` has been updated to use `obs_meta` internally, which should
  help performance
* `OBS_GetMeasure` now can be passed "none" and skip normalization by area or
  denominator for points
* Fixtures are only loaded at the start of the unit test suite, and dropped at the end,
  instead of at the start/end of each individual test file
* Comment noisy NOTICEs ([#73](https://github.com/CartoDB/observatory-extension/issues/73))

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
