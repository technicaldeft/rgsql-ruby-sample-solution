---- Using GROUP BY ----

--- applies the select list to every unique group
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (2);
SELECT 99 FROM t1 GROUP BY a;
--- returns:
99
99

--- returns unique values from specified column
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (2);
SELECT a FROM t1 GROUP BY a;
--- returns:
1
2

--- returns no rows when grouping no rows
CREATE TABLE t1(a INTEGER);
SELECT a FROM t1 GROUP BY a;
--- returns no rows

--- can use columns in a group within expressions
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (2);
SELECT a + 10 FROM t1 GROUP BY a;
--- returns:
11
12

--- can group after a join
CREATE TABLE t1(b INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1), (2), (3);
INSERT INTO t2 VALUES (4, 10), (2, 20), (3, 20), (3, 30);
SELECT c FROM t1 INNER JOIN t2 ON t1.b = t2.b GROUP BY c;
--- returns:
20
30

---- References in a GROUP BY ----

--- returns a validation error if reference does not exist
CREATE TABLE t1(a INTEGER, b BOOLEAN);
SELECT a FROM t1 GROUP BY z;
--- returns error:
validation_error

--- returns a validation error if column used in select is not in the group
CREATE TABLE t1(a INTEGER, b BOOLEAN);
SELECT a, b FROM t1 GROUP BY a;
--- returns error:
validation_error

--- can use table qualified column reference in select
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (2);
SELECT t1.a FROM t1 GROUP BY a;
--- returns:
1
2

---- Grouping by expressions ----

--- can use an expression for the GROUP BY
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (-1), (2), (-2);
SELECT 77 FROM t1 GROUP BY ABS(a);
--- returns:
77
77

--- checks the GROUP BY expression for type errors
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (2);
SELECT 10 FROM t1 GROUP BY a + TRUE;
--- returns error:
validation_error

--- can use the expression in the select list
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (-1), (2), (-2);
SELECT ABS(a) FROM t1 GROUP BY ABS(a);
--- returns:
1
2

--- can use the expression in the select list even if the reference is written differently
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (-1), (2), (-2);
SELECT ABS(t1.A) FROM t1 GROUP BY ABS(a);
--- returns:
1
2

--- can use the expression in the select list within another expression
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (-1), (2), (-2);
SELECT 10 + ABS(a) FROM t1 GROUP BY ABS(a);
--- returns:
11
12

--- can't use a different expression in the select list
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (-1), (2), (-2);
SELECT MOD(a, 10) FROM t1 GROUP BY ABS(a);
--- returns error:
validation_error

--- can't use the expression with a different column in the select list
CREATE TABLE t1(a INTEGER, b BOOLEAN);
INSERT INTO t1 VALUES (1, TRUE), (-1, FALSE);
SELECT ABS(b) FROM t1 GROUP BY ABS(a);
--- returns error:
validation_error