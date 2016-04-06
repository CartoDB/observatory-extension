-- Version number of the extension release
CREATE OR REPLACE FUNCTION cdb_observatory_version()
RETURNS text AS $$
  SELECT '@@VERSION@@'::text;
$$ language 'sql' STABLE STRICT;

-- Internal identifier of the installed extension instence
-- e.g. 'dev' for current development version
CREATE OR REPLACE FUNCTION _cdb_observatory_internal_version()
RETURNS text AS $$
  SELECT installed_version FROM pg_available_extensions where name='observatory' and pg_available_extensions IS NOT NULL;
$$ language 'sql' STABLE STRICT;
