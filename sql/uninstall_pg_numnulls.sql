/*
 * Author: Jim C. Nasby
 * Created at: 2015-04-13 16:25:52 -0500
 *
 */

--
-- This is a example code genereted automaticaly
-- by pgxn-utils.

SET client_min_messages = warning;

BEGIN;

-- You can use this statements as
-- template for your extension.

DROP OPERATOR #? (text, text);
DROP FUNCTION pg_numnulls(text, text);
DROP TYPE pg_numnulls CASCADE;
COMMIT;
