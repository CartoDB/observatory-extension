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

\echo Loading obs_ab038198aaab3f3cb055758638ee4de28ad70146.sql fixture file...
\i test/fixtures/obs_ab038198aaab3f3cb055758638ee4de28ad70146.sql
\echo Done.

\echo Loading obs_a92e1111ad3177676471d66bb8036e6d057f271b.sql fixture file...
\i test/fixtures/obs_a92e1111ad3177676471d66bb8036e6d057f271b.sql
\echo Done.

\echo Loading obs_11ee8b82c877c073438bc935a91d3dfccef875d1.sql fixture file...
\i test/fixtures/obs_11ee8b82c877c073438bc935a91d3dfccef875d1.sql
\echo Done.

\echo Loading obs_d34555209878e8c4b37cf0b2b3d072ff129ec470.sql fixture file...
\i test/fixtures/obs_d34555209878e8c4b37cf0b2b3d072ff129ec470.sql
\echo Done.

\echo Loading obs_b0ef6dd68d5faddbf231fd7f02916b3d00ec43c4.sql fixture file...
\i test/fixtures/obs_b0ef6dd68d5faddbf231fd7f02916b3d00ec43c4.sql
\echo Done.

\unset ECHO
