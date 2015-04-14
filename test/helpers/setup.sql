BEGIN;
\i test/helpers/tap_setup.sql

-- Put dependencies here
--CREATE EXTENSION IF NOT EXISTS variant;

SET search_path = :schema;

-- No IF NOT EXISTS because we'll be confused if we're not loading the new stuff
--\i sql/pg_count_nulls.sql
CREATE EXTENSION pg_count_nulls;
