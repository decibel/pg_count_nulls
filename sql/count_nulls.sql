SET client_min_messages = WARNING;

CREATE OR REPLACE FUNCTION null_count(
  VARIADIC argument anyarray
) RETURNS bigint LANGUAGE sql IMMUTABLE AS $body$
  SELECT sum( CASE WHEN a IS NULL THEN 1 ELSE 0 END )
    FROM unnest( $1 ) a
$body$;

CREATE OR REPLACE FUNCTION not_null_count(
  VARIADIC argument anyarray
) RETURNS bigint LANGUAGE sql IMMUTABLE AS $body$
  SELECT sum( CASE WHEN a IS NOT NULL THEN 1 ELSE 0 END )
    FROM unnest( $1 ) a
$body$;

-- vi: expandtab sw=2 ts=2
