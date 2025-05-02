---- Typing mathematical operators ----

--- returns a validation error unless operands are integers
SELECT 1 + TRUE;
--- returns error:
validation_error

SELECT false - 0;
--- returns error:
validation_error

SELECT TRUE / 60;
--- returns error:
validation_error

SELECT 22 * false;
--- returns error:
validation_error

---- Typing comparison operators ----

--- returns a validation error for mixed operands
SELECT 1 < TRUE;
--- returns error:
validation_error

SELECT false <= 0;
--- returns error:
validation_error

SELECT TRUE > 60;
--- returns error:
validation_error

SELECT 22 >= false;
--- returns error:
validation_error


---- Typing equality operators ----

--- returns a validation error unless operands are of the same type
SELECT 100 = false;
--- returns error:
validation_error

SELECT false <> 4;
--- returns error:
validation_error


---- Typing boolean operators ----

--- returns a validation error unless operands are booleans
SELECT 1 OR false;
--- returns error:
validation_error

SELECT false AND 2;
--- returns error:
validation_error

SELECT NOT 2;
--- returns error:
validation_error


---- Typing functions ----

--- returns a validation error if booleans are passed to ABS
SELECT ABS(TRUE);
--- returns error:
validation_error

--- returns a validation error if booleans are passed to MOD
SELECT MOD(TRUE, FALSE);
--- returns error:
validation_error

--- returns a validation error when the function doesn't exist
SELECT CABBAGES(2);
--- returns error:
validation_error

--- returns a validation error when the function has too few arguments
SELECT MOD(1);
--- returns error:
validation_error

--- returns a validation error when the function has too many arguments
SELECT ABS(1,2) ;
--- returns error:
validation_error


---- Typing select statements ----

--- errors when the referenced table does not exist
SELECT a FROM t1;
--- returns error:
validation_error

--- errors when the referenced column does not exist
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES(1);
SELECT b FROM t1;
--- returns error:
validation_error

--- returns a validation error when performing an integer operation on a boolean
CREATE TABLE t1(a BOOLEAN);
SELECT  a + 2 FROM t1;
--- returns error:
validation_error

--- returns a validation error when performing a boolean operation on an integer
CREATE TABLE t1(a INTEGER);
SELECT a AND TRUE FROM t1;
--- returns error:
validation_error


---- Typing insert statements ----

--- errors when the referenced table does not exist
INSERT INTO t1 VALUES(1);
--- returns error:
validation_error

--- returns a validation error when saving an integer in a boolean column
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES(TRUE);
--- returns error:
validation_error

--- returns a validation error when saving a boolean in an integer column
CREATE TABLE t1(b BOOLEAN);
INSERT INTO t1 VALUES(1);
--- returns error:
validation_error

--- returns a validation error when inserting more values than columns
CREATE TABLE t1(b BOOLEAN);
INSERT INTO t1 VALUES(true, false, true);
--- returns error:
validation_error

--- does not insert any rows when there is a validation error
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 values (1), (TRUE);
--- returns error:
validation_error

SELECT a FROM t1;
--- returns no rows

---- Dividing by 0 ----

--- returns an error when dividing by zero
SELECT 1 / 0;
--- returns error:
division_by_zero_error

--- can return a division by zero error when selecting from a table
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES(1), (0);
SELECT 10 / a FROM t1;
--- returns error:
division_by_zero_error

--- it checks types before evaluating
SELECT (1 / 0) + (2 * FALSE);
--- returns error:
validation_error

--- does not insert any rows when there is a division by zero error
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 values (1), (2 / 0);
--- returns error:
division_by_zero_error

SELECT a FROM t1;
--- returns no rows

