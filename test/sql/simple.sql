\set ECHO none

\set schema public

\i test/helpers/setup.sql

\i test/core/functions.sql

--SET client_min_messages = debug;

SELECT * FROM runtests( '_null_count_test'::name );
