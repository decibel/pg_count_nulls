CREATE SCHEMA _null_count_test;
SET SEARCH_PATH = _null_count_test, :schema, tap, "$user";

/*
 * NOTE! Do not use create or replace function in here. If you do that and
 * accidentally try to define the same function twice you'll never detect that
 * mistake!
 */

/*
CREATE FUNCTION test__
() RETURNS SETOF text LANGUAGE plpgsql AS $body$
DECLARE
BEGIN
END
$body$;
*/

/*
 * function definition
 */
CREATE FUNCTION test__definition
() RETURNS SETOF text LANGUAGE plpgsql AS $body$
DECLARE
  f_name name;
  t text;
  f_args text[];
BEGIN
  FOREACH f_name IN ARRAY '{null_count,not_null_count}'::name[] LOOP
    FOREACH t IN ARRAY '{anyarray,json}'::text[] LOOP
      f_args := array[t];
      RETURN NEXT function_returns(
        f_name, f_args
        , 'bigint'
      );

      -- TODO: isnt_definer
      RETURN NEXT isnt_strict(
        f_name, f_args
      );

      RETURN NEXT volatility_is(
        f_name, f_args
        , 'immutable'
      );
    END LOOP;
  END LOOP;

  FOREACH f_name IN ARRAY '{null_count_trigger,not_null_count_trigger}'::name[] LOOP
    f_args := '{}';
    RETURN NEXT function_returns(
      f_name, f_args
      , 'trigger'
    );

    -- TODO: isnt_definer
    RETURN NEXT isnt_strict(
      f_name, f_args
    );

    RETURN NEXT volatility_is(
      f_name, f_args
      , 'immutable'
    );
  END LOOP;
END
$body$;

/*
 * Operation
 */

CREATE FUNCTION pg_temp.test_trigger_raw(
  trigger_name name
  , ba text
  , exec text
  , errmsg text
  , errdesc text

) RETURNS SETOF text LANGUAGE plpgsql AS $body$
DECLARE
  c_command CONSTANT text :=
    format( $$CREATE TRIGGER %s %s INSERT ON test_data FOR EACH ROW EXECUTE PROCEDURE %s$$
      , trigger_name
      , ba
      , exec
    )
  ;
BEGIN
  RETURN NEXT lives_ok( c_command, c_command );
  RETURN NEXT throws_ok(
    $$INSERT INTO test_data VALUES (1,1,NULL)$$
    , 'P0001'
    , errmsg
    , errdesc
  );

  RETURN NEXT lives_ok(
    format( 'DROP TRIGGER %s ON test_data', trigger_name )
    , format( 'DROP TRIGGER %s', trigger_name )
  );
END
$body$;

CREATE FUNCTION pg_temp.test_trigger(
  ba text
  , nn text
  , err text
) RETURNS SETOF text LANGUAGE plpgsql AS $body$
DECLARE
  c_trigger_name CONSTANT text := quote_ident(format('%s_%s_%s', nn, ba, err));
BEGIN
  RETURN QUERY
    SELECT pg_temp.test_trigger_raw(
      c_trigger_name
      , ba
      , exec := format(
          $$%s_count_trigger(1, %L)$$
          , nn
          , err
        )
      , errmsg := coalesce( err, format( 'test_data must contain 1 %s fields', upper( replace( nn, '_', ' ' ) ) ) )
      , errdesc := 'Test ' || c_trigger_name
    )
  ;
END
$body$;

CREATE FUNCTION test__functionality
() RETURNS SETOF text LANGUAGE plpgsql AS $body$
DECLARE
BEGIN
  CREATE TEMP TABLE test_data AS
    SELECT * FROM (
    VALUES
      -- Can't make first argument bigint without variant
        ( 1::int, 2::int, 3::int, 0 )
      , ( 1,    2,    NULL, 1 )
      , ( 1,    NULL, 3,    1 )
      , ( 1,    NULL, NULL, 2 )
      , ( NULL, 2,    3,    1 )
      , ( NULL, 2,    NULL, 2 )
      , ( NULL, NULL, 3,    2 )
      , ( NULL, NULL, NULL, 3 )
    ) AS a( a, b, c, null_count )
  ;

  RETURN NEXT bag_eq(
    $$SELECT a, b, c, null_count( a, b, c ), not_null_count( a, b, c ) FROM test_data$$
    , $$SELECT *, 3-null_count AS not_null_count FROM test_data$$
    , 'Test null_count(a, b, c)'
  );

  -- Test JSON versions
  RETURN NEXT bag_eq(
    $$SELECT a, b, c, null_count( row_to_json( row(a, b, c) ) ), not_null_count( row_to_json( row(a, b, c) ) ) FROM test_data$$
    , $$SELECT *, 3-null_count AS not_null_count FROM test_data$$
    , 'Test null_count(a, b, c)'
  );

  -- Doesn't work for array types
  /*
  RETURN NEXT bag_eq(
    $$SELECT a, b, c, null_count( array[a], array[b], array[c] ) FROM test_data$$
    , $$SELECT * FROM test_data$$
    , 'Test null_count(array[a], array[b], array[c])'
  );
  */

  RETURN QUERY
    SELECT pg_temp.test_trigger_raw(
          '"test trigger"'
          , 'BEFORE'
          , trig
          , CASE
              WHEN args = '' AND not_ = 'not_'  THEN $$test trigger usage: number of NOT NULL columns[, error message]$$
              WHEN args = '' AND not_ = ''      THEN $$test trigger usage: number of NULL columns[, error message]$$
              ELSE 'test trigger: first argument must not be null'
            END
          , 'Test ' || trig
        )
      FROM (
        SELECT *, format( '%snull_count_trigger( %s )', not_, args ) AS trig
          FROM
            unnest( array['not_', ''] ) not_
            , unnest( array['NULL', ''] ) args
        ) a
  ;

  RETURN QUERY
    SELECT pg_temp.test_trigger( ba, nn, err )
      FROM
        unnest( '{"null",not_null}'::text[] ) AS nn(nn)
        , unnest( '{BEFORE,AFTER}'::text[] ) AS ba(ba)
        , unnest( '{"error_message",NULL}'::text[] ) AS err(err)
  ;

END
$body$;


-- vi: expandtab sw=2 ts=2
