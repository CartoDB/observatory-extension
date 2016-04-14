SET client_min_messages TO NOTICE;
\set ECHO none

-- metadata
\echo Dropping obs_table.sql fixture table...
DROP TABLE observatory.obs_table;
\echo Done.

\echo Dropping obs_column.sql fixture table...
DROP TABLE observatory.obs_column;
\echo Done.

\echo Dropping obs_column_table.sql fixture table...
DROP TABLE observatory.obs_column_table;
\echo Done.

\echo Dropping obs_column_to_column.sql fixture table...
DROP TABLE observatory.obs_column_to_column;
\echo Done.

-- data
\echo Dropping obs_85328201013baa14e8e8a4a57a01e6f6fbc5f9b1 fixture table...
DROP TABLE observatory.obs_85328201013baa14e8e8a4a57a01e6f6fbc5f9b1;
\echo Done.

\echo Dropping obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb fixture table...
DROP TABLE observatory.obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb;
\echo Done.

\unset ECHO
