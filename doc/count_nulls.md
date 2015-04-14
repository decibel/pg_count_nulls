count_nulls
===========

Creates functions for testing whether a set of fields are NULL or not. This is
most useful for ensuring a set of columns are set correctly.

## null_count( VARIADIC anyarray ) ##
Returns the number of supplied arguments that are NULL. Note that all the
arguments must be of the same type. See the examples.

You also need to do something special to pass arrays to a VARIADIC function.
See the Postgres docs.

## not_null_count( VARIADIC anyarray ) ##
Same as null_count() except this returns the number of fields that are NOT NULL.

## Examples ##

If you expect only one of a, b, or c to be set:

    CREATE TABLE my_table(
        my_table_id         SERIAL NOT NULL PRIMARY KEY
        , a                 int
        , b                 bigint
        , c                 smallint
        , CHECK( not_null_count( a::bigint, b, c::bigint ) = 1 )
    );
    INSERT INTO my_table VALUES( DEFAULT, NULL, NULL, NULL );
    ERROR:  new row for relation "my_table" violates check constraint "my_table_check"
    DETAIL:  Failing row contains (1, null, null, null).

Note that because of the different data types you need to manually cast everything to one data type (in this case, bigint, because it's the largest).


On the other hand, if you expect all fields except 1 to be set:

    CREATE TABLE my_table(
        my_table_id         SERIAL NOT NULL PRIMARY KEY
        , a                 int
        , b                 int
        , c                 smallint
        , CHECK( null_count( a, b, c::int ) = 1 )
    );
    INSERT INTO my_table VALUES( DEFAULT, NULL, NULL, NULL );
    ERROR:  new row for relation "my_table" violates check constraint "my_table_check"
    DETAIL:  Failing row contains (1, null, null, null).
    

Support
-------

  Please report issues at <https://github.com/decibel/pg_count_nulls/issues>.
  

Author
------

Jim Nasby, [Blue Treble Consulting](http://BlueTreble.com)

Copyright and License
---------------------

Copyright (c) 2015 Jim Nasby, Blue Treble Consulting http://BlueTreble.com

