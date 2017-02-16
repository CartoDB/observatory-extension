1.3.1 (2017-02-16)

__Improvements__

* It is now possible to obtain measures that are averages or medians over
  arbitrary polygons ([#254](https://github.com/CartoDB/observatory-extension/pull/254).
* Added test point for Australian data

1.3.0 (2017-01-17)

__API Changes__

* `OBS_GetMeasureDataMulti()` is now called `OBS_GetData()`
* `OBS_GetMeasureMetaMulti()` is now called `OBS_GetMeta()`
* Additional signature for `OBS_GetData` which can take an array of `TEXT`,
  mimicking functionality of `OBS_GetMeasureByID`

__Improvements__

* Generate fixtures from `obs_meta`
* Remove unused table-level code
* Refactor all augmentation and geometry functions to obtain data from
  `OBS_GetMeta()` and `OBS_GetData()`.
* Improvements to `OBS_GetMeta()` so it can still fill in metadata in cases
  where only a geometry is being requested.
* `OBS_GetData()` returns two-column table instead of anonymous record.
* `OBS_GetData()` can return categorical (text) and geometries

__Bugfixes__

* Remove unnecessary dependency on `postgres_fdw`
* `OBS_GetData()` now aggregates measures with mixed geoms correctly

__API Changes__

1.2.1 (2017-01-17)

__Improvements__

* Support Point/LineString in responses from `OBS_GetBoundary`.
  ([#243](https://github.com/CartoDB/observatory-extension/pull/233))

1.2.0 (2016-12-28)

__API Changes__

* Added `OBS_GetMeasureDataMulti`, which takes an array of geomvals and
  parameters as JSON, and returns a set of RECORDs keyed by the vals of the
  geomvals.
* Added `OBS_GetMeasureMetaMulti`, which takes sparse metadata as JSON (for
  example, the measure ID) and returns a filled-out version of the metadata
  sufficient for use with `OBS_GetMeasureDataMulti`.

__Improvements__

* Move tests to 2015
* Fixes to `_OBS_GetGeometryScores` to avoid spamming NOTICEs about all pixels
  for a band being NULL
* Tests for `_OBS_GetGeometryScores` with complex geometries
* Performance tests for `OBS_GetMeasureDataMulti`
* Return both `table_id` and `column_id` from `_OBS_GetGeometryScores`

1.1.7 (2016-12-15)

__Improvements__

* Use simpler raster table and simplified `_OBSGetGeometryScores` functions to
  improve performance
* In cases where geometry passed into geometry scoring function has greater
  than 10K points, simply use its buffer instead
* Add `IMMUTABLE` to `_OBSGetGeometryScores`
* Add tests explicitly for `_OBSGetGeometryScores` in perftest.py
* Yields a ~50% improvement in performance for `_OBSGetGeomeryScores`.

1.1.6 (2016-12-08)

__Bugfixes__

* Fix divide by zero condition in "denominator" branch of `OBS_GetMeasure`
  when passing in a polygon ([#233](https://github.com/CartoDB/observatory-extension/pull/233)).

__Improvements__

* Use `ST_Subdivide` to improve performance when functions are called on very
  complex geometries (with many points) ([#232](https://github.com/CartoDB/observatory-extension/pull/232))
* Improve raster scoring to more heavily weight boundaries with nearer to
  correct number of points, and penalize boundaries with lots of blank space
  ([#232](https://github.com/CartoDB/observatory-extension/pull/232))
* Remove some redundant area calculations in `OBS_GetMeasure`
  ([#232](https://github.com/CartoDB/observatory-extension/pull/232))
* Replace use of `format('%L', var)` with proper use of `EXECUTE` and `$1` etc.
  variables ([#231](https://github.com/CartoDB/observatory-extension/pull/231))
* Add test point for Brazil
  ([#229](https://github.com/CartoDB/observatory-extension/pull/229))
* Improvements to performance tests
  ([#229](https://github.com/CartoDB/observatory-extension/pull/229))
  - Support simple and complex geometries
  - Handle all code branches
  - Add ability to persist results to JSON for graph visualization later

1.1.5 (2016-11-29)

__Bugfixes__

* Return `NULL` instead of raising an exception when a measure is requested for
  a geometry where it does not exist ([#220](https://github.com/CartoDB/observatory-extension/issues/220)).

1.1.4 (2016-11-21)

__Bugfixes__

* Fix duplicate subsections with only a partial set of measures appearing from
  `OBS_GetLegacyMetadata` ([#216](https://github.com/CartoDB/observatory-extension/issues/216)).

1.1.3 (2016-11-15)

* Temporarily ignore EU data for the sake of testing

1.1.2 (2016-11-09)

__Improvements__

* Update public `OBS_GetMeasure` to use highest ranked boundary, aiming for 500
  geoms. ([#190](https://github.com/CartoDB/observatory-extension/issues/190))
* Update test generation to capture our raster tiles
* Standardize the way we generate our test points for `autotest.py`
* Add points for epa and eurostat
* Should support database dump generated 20161109

__API Changes (Internal)__

* Add internal `_OBS_GetGeometryScores`

1.1.1 (2016-10-14)

__Improvements__

* Test points for Canada and France ([#204](https://github.com/CartoDB/observatory-extension/issues/120))

1.1.0 (2016-10-04)

__Bugfixes__

* Fixed some minor errors in test suite

__Improvements__

* We now generate test fixtures from local data instead of remote server
  ([#120](https://github.com/CartoDB/observatory-extension/issues/120))

__API Changes__

* New function, `OBS_LegacyBuilderMetadata`, which resolves
  ([#133]( https://github.com/CartoDB/observatory-extension/issues/133))
* Creates "dimensional" metadata grabbing functions
  (`OBS_GetAvailableNumerators`, `OBS_GetAvailableDenominators`,
  `OBS_GetAvailableGeometries`, `OBS_GetAvailableTimespans`) which will be
  used for obtaining metadata in the replacement for the Data Library
  ([CartoDB/design#104](https://github.com/CartoDB/design/issues/104)). This
  is also referred to here ([CartoDB/design#68](https://github.com/CartoDB/design/issues/68)).

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
