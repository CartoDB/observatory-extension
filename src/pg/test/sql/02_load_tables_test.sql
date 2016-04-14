SET client_min_messages TO WARNING;
\set ECHO none
\echo Loading fixtures...
\i test/fixtures/obs_table.sql
\i test/fixtures/obs_column_table.sql
\i test/fixtures/obs_column.sql
\i test/fixtures/obs_column_to_column.sql
\echo Done.
\unset ECHO
