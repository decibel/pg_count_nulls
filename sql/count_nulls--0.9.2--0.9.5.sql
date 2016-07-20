SET client_min_messages = WARNING;

-- Need to drop old functions because we're changing output type

DROP FUNCTION null_count(
  VARIADIC argument anyarray
);
CREATE OR REPLACE FUNCTION null_count(
  VARIADIC argument anyarray
) RETURNS int LANGUAGE sql IMMUTABLE AS $body$
  SELECT sum( CASE WHEN a IS NULL THEN 1 ELSE 0 END )::int
    FROM unnest( $1 ) a
$body$;

CREATE OR REPLACE FUNCTION null_count(
  argument jsonb
) RETURNS int LANGUAGE sql IMMUTABLE AS $body$
SELECT count(*)::int
  FROM jsonb_each_text( $1 ) a
  WHERE value IS NULL
$body$;
DROP FUNCTION null_count(
  argument json
);
CREATE OR REPLACE FUNCTION null_count(
  argument json
) RETURNS int LANGUAGE sql IMMUTABLE AS 'SELECT null_count($1::jsonb)';

DROP FUNCTION not_null_count(
  VARIADIC argument anyarray
);
CREATE OR REPLACE FUNCTION not_null_count(
  VARIADIC argument anyarray
) RETURNS int LANGUAGE sql IMMUTABLE AS $body$
  SELECT sum( CASE WHEN a IS NOT NULL THEN 1 ELSE 0 END )::int
    FROM unnest( $1 ) a
$body$;

CREATE OR REPLACE FUNCTION not_null_count(
  argument jsonb
) RETURNS int LANGUAGE sql IMMUTABLE AS $body$
SELECT count(*)::int
  FROM jsonb_each_text( $1 ) a
  WHERE value IS NOT NULL
$body$;
DROP FUNCTION not_null_count(
  argument json
);
CREATE OR REPLACE FUNCTION not_null_count(
  argument json
) RETURNS int LANGUAGE sql IMMUTABLE AS 'SELECT not_null_count($1::jsonb)';

