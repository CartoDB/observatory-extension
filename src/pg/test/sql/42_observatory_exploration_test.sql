\i test/sql/load_fixtures.sql

SELECT cdb_observatory.OBS_Search('total_pop');

SELECT * from cdb_observatory.OBS_GetAvailableBoundaries(_test_point());
