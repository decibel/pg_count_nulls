\set ECHO none
\set VERBOSITY verbose

BEGIN;
CREATE EXTENSION count_nulls;

-- Remember that JSON only accepts 'null'
SELECT null_count('{"a": null}'::jsonb);
SELECT null_count(1,NULL);

\echo TRANSACTION INTENTIONALLY LEFT OPEN
