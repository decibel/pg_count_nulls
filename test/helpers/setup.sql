BEGIN;
\i test/helpers/tap_setup.sql

-- Put dependencies here
--CREATE EXTENSION IF NOT EXISTS variant;

-- No IF NOT EXISTS because we'll be confused if we're not loading the new stuff
--\i sql/pg_numnulls.sql
CREATE EXTENSION pg_numnulls;

\i test/core/functions.sql
