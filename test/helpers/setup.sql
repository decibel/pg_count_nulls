BEGIN;
\i test/helpers/tap_setup.sql

-- Put dependencies here
--CREATE EXTENSION IF NOT EXISTS variant;

CREATE SCHEMA IF NOT EXISTS :schema;
SET search_path = :schema;

-- No IF NOT EXISTS because we'll be confused if we're not loading the new stuff
--\i sql/count_nulls.sql
CREATE EXTENSION count_nulls;
