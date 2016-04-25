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

\echo Dropping obs_column_tag.sql fixture table...
DROP TABLE observatory.obs_column_tag;
\echo Done.

\echo Dropping obs_tag.sql fixture table...
DROP TABLE observatory.obs_tag;
\echo Done.

-- data
\echo Dropping obs_85328201013baa14e8e8a4a57a01e6f6fbc5f9b1 fixture table...
DROP TABLE observatory.obs_85328201013baa14e8e8a4a57a01e6f6fbc5f9b1;
\echo Done.

\echo Dropping obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb fixture table...
DROP TABLE observatory.obs_3e7cc9cfd403b912c57b42d5f9195af9ce2f3cdb;
\echo Done.

\echo Dropping obs_ab038198aaab3f3cb055758638ee4de28ad70146 fixture table...
DROP TABLE observatory.obs_ab038198aaab3f3cb055758638ee4de28ad70146;
\echo Done.

\echo Dropping obs_a92e1111ad3177676471d66bb8036e6d057f271b fixture table...
DROP TABLE observatory.obs_a92e1111ad3177676471d66bb8036e6d057f271b;
\echo Done.

\echo Dropping obs_11ee8b82c877c073438bc935a91d3dfccef875d1 fixture table...
DROP TABLE observatory.obs_11ee8b82c877c073438bc935a91d3dfccef875d1;
\echo Done.

\echo Dropping obs_d34555209878e8c4b37cf0b2b3d072ff129ec470 fixture table...
DROP TABLE observatory.obs_d34555209878e8c4b37cf0b2b3d072ff129ec470;
\echo Done.

\echo Dropping obs_b0ef6dd68d5faddbf231fd7f02916b3d00ec43c4 fixture table...
DROP TABLE observatory.obs_b0ef6dd68d5faddbf231fd7f02916b3d00ec43c4;
\echo Done.

DROP TABLE observatory.obs_65f29658e096ca1485bf683f65fdbc9f05ec3c5d.sql;

\unset ECHO
