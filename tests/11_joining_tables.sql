---- Inner join ----

--- can select columns from joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
SELECT a, b FROM t1 INNER JOIN t2 ON a = b;
--- returns no rows
--- with columns:
a, b

--- can select data from joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1, 3), (2, 4);
SELECT a, c FROM t1 INNER JOIN t2 ON a = b;
--- returns:
1, 3
2, 4
--- with columns:
a, c

--- duplicates rows from selected table when multiple matching rows in joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (1, 3), (1, 4);
SELECT a, c FROM t1 INNER JOIN t2 ON a = b;
--- returns:
1, 3
1, 4

--- does not return row in from table if no matching data in joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1, 3);
SELECT a, c FROM t1 INNER JOIN t2 ON a = b;
--- returns:
1, 3

--- returns all combinations of rows from tables when condition is TRUE (cross join)
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 INNER JOIN t2 ON TRUE;
--- returns:
1, 3
1, 4
2, 3
2, 4

--- returns no rows when join condition is FALSE
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 INNER JOIN t2 ON FALSE;
--- returns no rows

--- returns no rows when join condition is NULL
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 INNER JOIN t2 ON NULL;
--- returns no rows

--- returns a parsing error if missing ON
SELECT a FROM t1 INNER JOIN t2
--- returns error:
parsing_error


---- Join conditions ----

--- can use any condition to join table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (10), (20);
INSERT INTO t2 VALUES (5), (40);
SELECT a, b FROM t1 INNER JOIN t2 ON a < b;
--- returns:
10, 40
20, 40

--- returns a validation error if JOIN condition is not a boolean
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
SELECT a FROM t1 INNER JOIN t2 ON 4;
--- returns error:
validation_error

--- returns a validation error if columns joined are not comparable
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b BOOLEAN);
SELECT a FROM t1 INNER JOIN t2 ON a = b;
--- returns error:
validation_error


---- Referencing columns and tables in a join ----

--- can use a . to qualify column references with a table
CREATE TABLE t1(a INTEGER, b BOOLEAN);
CREATE TABLE t2(a INTEGER, b INTEGER);
INSERT INTO t1 VALUES (1, TRUE), (2, FALSE);
INSERT INTO t2 VALUES (1, 10), (2, 20);
SELECT t1.a, t2.a, t1.b, t2.b FROM t1 INNER JOIN t2 ON t1.a = t2.a;
--- returns:
1, 1, TRUE, 10
2, 2, FALSE, 20

--- can alias tables after JOIN keyword
CREATE TABLE t1(a INTEGER, b BOOLEAN);
CREATE TABLE t2(a INTEGER, b INTEGER);
INSERT INTO t1 VALUES (1, TRUE), (2, FALSE);
INSERT INTO t2 VALUES (1, 10), (2, 20);
SELECT t1.a, x2.a, t1.b, x2.b FROM t1 INNER JOIN t2 x2 ON t1.a = x2.a;
--- returns:
1, 1, TRUE, 10
2, 2, FALSE, 20

--- can join tables to themselves
CREATE TABLE t1(a INTEGER, b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1, 2, 10), (2, 3, 20), (3, 1, 30);
SELECT t1.a, dupe.c FROM t1 INNER JOIN t1 dupe ON t1.a = dupe.b;
--- returns:
1, 30
2, 10
3, 20

--- returns a validation error if join table has the same name as from table
CREATE TABLE t1(a INTEGER, b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1, 2, 10), (2, 3, 20), (3, 1, 30);
SELECT t1.a FROM t1 INNER JOIN t1 on true;
--- returns error:
validation_error

--- can reference joined table in WHERE
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (1, 3), (1, 4);
SELECT a, c FROM t1 INNER JOIN t2 ON a = b WHERE c = 4;
--- returns:
1, 4

--- returns a validation error if column in WHERE is ambiguous
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, a INTEGER);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (1, 3), (1, 4);
SELECT t1.a FROM t1 INNER JOIN t2 ON t1.a = t2.b WHERE a = 4;
--- returns error:
validation_error

--- returns a validation error if column in SELECT is ambiguous
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, a INTEGER);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (1, 3), (1, 4);
SELECT a FROM t1 INNER JOIN t2 ON t1.a = t2.b;
--- returns error:
validation_error

---- Left outer join ----

--- returns matching data from the joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1, 3), (2, 4);
SELECT a, c FROM t1 LEFT OUTER JOIN t2 ON a = b;
--- returns:
1, 3
2, 4
--- with columns:
a, c

--- returns all the rows from the selected table even when it has no matches
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT a FROM t1 LEFT OUTER JOIN t2 ON a = b;
--- returns:
1
2

--- uses NULL if no matching data in joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1, 3);
SELECT a, c FROM t1 LEFT OUTER JOIN t2 ON a = b;
--- returns:
1, 3
2, NULL


--- duplicates rows from selected table when multiple matching rows in joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (1, 3), (1, 4);
SELECT a, c FROM t1 LEFT OUTER JOIN t2 ON a = b;
--- returns:
1, 3
1, 4

--- returns all rows across both tables when condition is TRUE (cross join)
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 LEFT OUTER JOIN t2 ON TRUE;
--- returns:
1, 3
1, 4
2, 3
2, 4

--- returns all rows from source table when join condition is FALSE
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 LEFT OUTER JOIN t2 ON FALSE;
--- returns:
1, NULL
2, NULL

--- returns all rows in source table when join condition is NULL
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 LEFT OUTER JOIN t2 ON NULL;
--- returns:
1, NULL
2, NULL


---- Right outer join ----

--- includes data from the joined table
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER, c INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (1, 3), (2, 4);
SELECT a, c FROM t1 RIGHT OUTER JOIN t2 ON a = b;
--- returns:
1, 3
2, 4
--- with columns:
a, c

--- returns all the rows from the joined table even when there are no matches
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t2 VALUES (1), (2);
SELECT b FROM t1 RIGHT OUTER JOIN t2 ON a = b;
--- returns:
1
2

--- uses NULL if no matching data in source table
CREATE TABLE t1(a INTEGER, b INTEGER);
CREATE TABLE t2(c INTEGER);
INSERT INTO t1 VALUES (1, 3);
INSERT INTO t2 VALUES (1), (2);
SELECT c, b FROM t1 RIGHT OUTER JOIN t2 ON a = c;
--- returns:
1, 3
2, NULL

--- duplicates rows from joined table when multiple matching rows in source table
CREATE TABLE t1(a INTEGER, b INTEGER);
CREATE TABLE t2(c INTEGER);
INSERT INTO t1 VALUES (1, 3), (1, 4);
INSERT INTO t2 VALUES (1);
SELECT c, b FROM t1 RIGHT OUTER JOIN t2 ON a = c;
--- returns:
1, 3
1, 4

--- returns all rows across both tables when condition is TRUE (cross join)
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 RIGHT OUTER JOIN t2 ON TRUE;
--- returns:
1, 3
1, 4
2, 3
2, 4

--- returns all rows from joined table when join condition is FALSE
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 RIGHT OUTER JOIN t2 ON FALSE;
--- returns:
NULL, 3
NULL, 4

--- returns all rows in joined table when join condition is NULL
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (3), (4);
SELECT a, b FROM t1 RIGHT OUTER JOIN t2 ON NULL;
--- returns:
NULL, 3
NULL, 4


---- Full outer join ----

--- returns rows from both tables even when they don't match
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
INSERT INTO t2 VALUES (2), (3);
SELECT a,b FROM t1 FULL OUTER JOIN t2 ON a = b;
--- returns:
1, NULL
2, 2
NULL, 3

--- returns all rows from both tables when join condition is FALSE
CREATE TABLE t1(a INTEGER);
CREATE TABLE t2(b INTEGER);
INSERT INTO t1 VALUES (1);
INSERT INTO t2 VALUES (3);
SELECT a, b FROM t1 FULL OUTER JOIN t2 ON FALSE;
--- returns:
1, NULL
NULL, 3

