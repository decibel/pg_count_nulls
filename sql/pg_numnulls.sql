/*
 * Author: Jim C. Nasby
 * Created at: 2015-04-13 16:25:52 -0500
 *
 */

--
-- This is a example code genereted automaticaly
-- by pgxn-utils.

SET client_min_messages = warning;

-- If your extension will create a type you can
-- do somenthing like this
CREATE TYPE pg_numnulls AS ( a text, b text );

-- Maybe you want to create some function, so you can use
-- this as an example
CREATE OR REPLACE FUNCTION pg_numnulls (text, text)
RETURNS pg_numnulls LANGUAGE SQL AS 'SELECT ROW($1, $2)::pg_numnulls';

-- Sometimes it is common to use special operators to
-- work with your new created type, you can create
-- one like the command bellow if it is applicable
-- to your case

CREATE OPERATOR #? (
	LEFTARG   = text,
	RIGHTARG  = text,
	PROCEDURE = pg_numnulls
);
