---- Referencing tables and columns ----

--- can use a . to qualify column references with a table
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT t1.a FROM t1;
--- returns:
1
2

--- can use use uppercase references to a column
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT T1.A FROM t1;
--- returns:
1
2

--- can used qualified references in where
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (3), (4);
SELECT a FROM t1 WHERE t1.a = 4;
--- returns:
4

--- returns a validation error if referenced table does not exist
CREATE TABLE t1(a INTEGER);
SELECT t4.a FROM t1;
--- returns error:
validation_error

--- returns a validation error if qualified column does not exist
CREATE TABLE t1(a INTEGER);
SELECT t1.b FROM t1;
--- returns error:
validation_error

--- returns a validation error when there are more qualifiers than expected
CREATE TABLE t1(a INTEGER);
SELECT t1.a.z FROM t1;
--- returns error:
validation_error

--- returns a validation error when referencing names of other items within the select list
SELECT 2 AS two, two * 3;
--- returns error:
validation_error

--- allows you to have many result columns with the same name
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT a AS a, a, 6 as a FROM t1;
--- returns:
1, 1, 6
2, 2, 6
--- with columns:
a, a, a

--- names in the select list take precedence over column names in order
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2), (3);
SELECT -a AS a FROM t1 ORDER BY a ASC;
--- returns in order:
-3
-2
-1

--- can use a table qualified reference to access field from table
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT -a AS a FROM t1 ORDER BY t1.a;
--- returns in order:
-1
-2