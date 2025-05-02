---- Creating and dropping tables ----

--- can create and drop a table
CREATE TABLE t1(a INTEGER);
DROP TABLE t1;
--- returns status ok
 
--- can create and drop a table with multiple columns
CREATE TABLE t1(a INTEGER, b BOOLEAN);
DROP TABLE t1;
--- returns status ok
 
--- returns an error when creating a table that already exists
CREATE TABLE t1(a INTEGER);
CREATE TABLE t1(a INTEGER);
--- returns error:
validation_error

--- returns an error if multiple columns have the same name
CREATE TABLE t2(a INTEGER, a BOOLEAN);
--- returns error:
validation_error

--- returns an error when dropping a table that does not exist
DROP TABLE t2;
--- returns error:
validation_error

--- can reuse dropped table names
CREATE TABLE t3(a INTEGER);
DROP TABLE t3;
CREATE TABLE t3(a INTEGER);
--- returns status ok
 
--- can drop a table with IF EXISTS
CREATE TABLE t4(a INTEGER);
DROP TABLE IF EXISTS t4;
--- returns status ok
 
--- can drop a non-existent table with IF EXISTS without errors
DROP TABLE IF EXISTS t5;
--- returns status ok
 
--- returns an error when there is an unknown column type
CREATE TABLE t4(a VEGETABLE);
--- returns error:
parsing_error

--- errors when there are missing commas in a CREATE
CREATE TABLE t5(a INTEGER b BOOLEAN);
--- returns error:
parsing_error

--- errors when identifiers start with a number
CREATE TABLE t1(1a INTEGER);
--- returns error:
parsing_error


---- Selecting from a table ----

--- can select a column from a table
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES(1);
SELECT a FROM t1;
--- returns:
1

--- gives a default name to the columns in the result
CREATE TABLE t1(id INTEGER);
INSERT INTO t1 VALUES(6);
SELECT id FROM t1;
--- returns:
6
--- with columns:
id

--- can create and select multiple columns
CREATE TABLE t2(a INTEGER, b INTEGER);
INSERT INTO t2 VALUES(1, 2);
SELECT b, a FROM t2;
--- returns:
2, 1
--- with columns:
b, a

--- can select from a table with no rows
CREATE TABLE t4(a INTEGER);
SELECT a FROM t4;
--- returns no rows
--- with columns:
a

--- can select boolean values
CREATE TABLE t2(a BOOLEAN, b BOOLEAN);
INSERT INTO t2 VALUES(TRUE, FALSE);
SELECT a, b FROM t2;
--- returns:
TRUE, FALSE


---- Inserting rows ----

--- can insert multiple rows
CREATE TABLE t1(a INTEGER, b INTEGER);
INSERT INTO t1 VALUES (1, 2), (3, 4);
SELECT a, b FROM t1;
--- returns:
1, 2
3, 4

--- errors when there are missing brackets in a CREATE
CREATE TABLE t1(a INTEGER, b BOOLEAN;
--- returns error:
parsing_error

--- errors when there are missing brackets in INSERT columns
INSERT INTO t1 (b, a VALUES (2, 1);
--- returns error:
parsing_error

--- errors when there are missing brackets in INSERT values
INSERT INTO t1 (b, a) VALUES (2, 1;
--- returns error:
parsing_error
