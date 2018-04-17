-- Install dependencies
CREATE EXTENSION postgis;

-- Install the extension
CREATE EXTENSION observatory VERSION 'dev';

\i test/fixtures/load_fixtures.sql
