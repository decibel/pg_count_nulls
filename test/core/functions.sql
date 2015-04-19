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
END
$body$;

/*
 * Operation
 */
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

END
$body$;



-- vi: expandtab sw=2 ts=2
