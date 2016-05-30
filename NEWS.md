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
