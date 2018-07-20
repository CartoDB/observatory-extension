-- Install dependencies
CREATE EXTENSION postgis;
CREATE LANGUAGE plpythonu;

-- Install the extension
CREATE EXTENSION observatory VERSION 'dev';

\i test/fixtures/load_fixtures.sql
