SET client_min_messages TO WARNING;
\set ECHO none

-- metadata
\echo Loading obs_table.sql fixture file...
\i test/fixtures/obs_table.sql
\echo Done.

\echo Loading obs_column.sql fixture file...
\i test/fixtures/obs_column.sql
\echo Done.

\echo Loading obs_column_table.sql fixture file...
\i test/fixtures/obs_column_table.sql
\echo Done.

\echo Loading obs_column_to_column.sql fixture file...
\i test/fixtures/obs_column_to_column.sql
\echo Done.

-- data
\echo Loading obs_85328201013baa14e8e8a4a57a01e6f6fbc5f9b1.sql fixture file...
\i test/fixtures/obs_85328201013baa14e8e8a4a57a01e6f6fbc5f9b1.sql
\echo Done.

\echo Loading obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb.sql fixture file...
\i test/fixtures/obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb.sql
\echo Done.

\unset ECHO
