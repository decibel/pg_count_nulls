\set ECHO none

\set schema public
\i test/helpers/setup.sql

\set schema schema_to_load_count_nulls
CREATE SCHEMA :schema;
ALTER EXTENSION count_nulls SET SCHEMA :schema;

\i test/core/functions.sql

CREATE FUNCTION shutdown__drop_all
() RETURNS SETOF text LANGUAGE plpgsql AS $body$
BEGIN
    RETURN NEXT lives_ok(
        $$DROP EXTENSION count_nulls$$
    );

    RETURN NEXT lives_ok(
        $$DROP SCHEMA schema_to_load_count_nulls$$
    );
END
$body$;

--SET client_min_messages = debug;

SELECT * FROM runtests( '_null_count_test'::name );
