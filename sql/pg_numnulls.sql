SET client_min_messages = warning;

CREATE OR REPLACE FUNCTION null_count(
  VARIADIC argument anyarray
) RETURNS int LANGUAGE sql IMMUTABLE AS $body$
  SELECT sum( CASE WHEN a IS NULL THEN 1 ELSE 0 END )::int
    FROM unnest( $1 ) a
$body$;

-- vi: expandtab sw=2 ts=2
