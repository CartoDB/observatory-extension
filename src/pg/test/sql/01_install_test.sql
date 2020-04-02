-- Install the extension
\set ECHO none
\set QUIET on
SET client_min_messages TO ERROR;

-- For Postgis 3+ install postgis_raster. Otherwise observatory will fail to install
DO $$
BEGIN
    IF EXISTS (SELECT 1 FROM pg_available_extensions WHERE name = 'postgis_raster') THEN
        CREATE EXTENSION postgis_raster WITH SCHEMA public CASCADE;
    END IF;
END$$;

CREATE EXTENSION observatory VERSION 'dev' CASCADE;

\i test/fixtures/load_fixtures.sql
