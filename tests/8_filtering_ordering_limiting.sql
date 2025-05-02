---- Filtering rows with where ----

--- shows all records when true
CREATE TABLE t1(b INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT b FROM t1 WHERE TRUE;
--- returns:
1
2

--- can filter to a specific value
CREATE TABLE t1(b INTEGER);
INSERT INTO t1 VALUES (3), (4);
SELECT b FROM t1 WHERE b = 4;
--- returns:
4

--- filters out all records when condition is false
CREATE TABLE t1(b INTEGER);
INSERT INTO t1 VALUES (5), (6);
SELECT b FROM t1 WHERE false;
--- returns no rows

--- filters out all records when condition is null
CREATE TABLE t1(b INTEGER);
INSERT INTO t1 VALUES (7), (8);
SELECT b FROM t1 WHERE NULL;
--- returns no rows

--- can handle more complex nested expressions
CREATE TABLE t1(b INTEGER, c BOOLEAN);
INSERT INTO t1 VALUES (1, TRUE), (3, false), (2, false);
SELECT b FROM t1 WHERE (b > 2) AND (NOT c);
--- returns:
3

--- returns a parsing error there is no expression
CREATE TABLE t1(b BOOLEAN);
SELECT b FROM t1 WHERE;
--- returns error:
parsing_error

--- returns a validation error when condition has a type miss-match
CREATE TABLE t1(b BOOLEAN);
SELECT b FROM t1 WHERE b = 1;
--- returns error:
validation_error

--- returns a validation error when does not evaluate to a boolean
CREATE TABLE t1(b BOOLEAN);
SELECT b FROM t1 WHERE 3;
--- returns error:
validation_error

--- returns a validation error if filtering by a non-existent reference
CREATE TABLE t1(b BOOLEAN);
SELECT b FROM t1 WHERE c;
--- returns error:
validation_error

--- returns a validation error if filtering by select list alias
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT a AS i FROM t1 WHERE i = 2;
--- returns error:
validation_error

--- can use a column name that shares name with a select list alias
CREATE TABLE t1(i INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT i, i * 4 AS i FROM t1 WHERE i = 2;
--- returns:
2, 8

---- Ordering rows with order ----

--- orders rows ascending by default
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (6), (4), (2);
SELECT a FROM t1 ORDER BY a;
--- returns in order:
2
4
6

--- can explicitly order by rows ascending
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (9), (8), (0);
SELECT a FROM t1 ORDER BY a ASC;
--- returns in order:
0
8
9

--- can order rows descending
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (0), (12), (100);
SELECT a FROM t1 ORDER BY a DESC;
--- returns in order:
100
12
0

--- can sort by an expression
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (0), (8), (9);
SELECT a FROM t1 ORDER BY -a ASC;
--- returns in order:
9
8
0

--- does not need to select a column to order by it
CREATE TABLE t1(a INTEGER, b INTEGER);
INSERT INTO t1 VALUES (1, 30), (2, 20), (3, 10);
SELECT a FROM t1 ORDER BY b ASC;
--- returns in order:
3
2
1

--- can use aliases in the select list
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (10), (10), (0);
SELECT a AS sort_key FROM t1 ORDER BY sort_key ASC;
--- returns in order:
0
10
10

--- errors when using the select list name in an expression
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (10), (10), (0);
SELECT a AS sort_key FROM t1 ORDER BY sort_key + 2 ASC;
--- returns error:
validation_error

--- treats false as less than true
CREATE TABLE t1(a BOOLEAN);
INSERT INTO t1 VALUES (true), (false), (true), (false);
SELECT a FROM t1 ORDER BY a ASC;
--- returns in order:
FALSE
FALSE
TRUE
TRUE

--- treats nulls as larger than non-null values
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (NULL), (1), (6);
SELECT a FROM t1 ORDER BY a ASC;
--- returns in order:
1
6
NULL

--- does not confuse ORDER with OR
CREATE TABLE t1(a BOOLEAN);
INSERT INTO t1 VALUES (false), (true);
SELECT a FROM t1 WHERE a ORDER BY a ASC;
--- returns in order:
TRUE

--- returns a parse error if order expression is missing
SELECT a FROM t1 ORDER BY ASC;
--- returns error:
parsing_error

--- returns a parse error if order is followed by an unknown keyword
SELECT a FROM t1 ORDER BY a CLOCKWISE;
--- returns error:
parsing_error

--- returns a validation error if ordering by a non-existent reference
CREATE TABLE t1(a INTEGER);
SELECT a FROM t1 ORDER BY x;
--- returns error:
validation_error


---- Limiting rows with limit ----

--- shows all rows when limit is greater than number of rows
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT a FROM t1 LIMIT 10;
--- returns:
1
2

--- shows no rows when limit is 0
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2);
SELECT a FROM t1 LIMIT 0;
--- returns no rows

--- can limit number of rows
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (1), (1);
SELECT a FROM t1 LIMIT 2;
--- returns:
1
1

--- can limit by an expression
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (1);
SELECT a FROM t1 LIMIT 3 - 2;
--- returns:
1

--- applies limit after WHERE
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2), (3), (4);
SELECT a FROM t1 WHERE 0 = MOD(a, 2) LIMIT 2;
--- returns:
2
4

--- applies limit after ORDER BY
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2), (3), (4);
SELECT a FROM t1 ORDER BY a DESC LIMIT 2;
--- returns in order:
4
3

--- shows all rows when limit is null
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (10), (20), (30);
SELECT a FROM t1 LIMIT NULL;
--- returns:
10
20
30

--- can provide an OFFSET to the limit
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2), (3), (4);
SELECT a FROM t1 ORDER BY a DESC LIMIT 2 OFFSET 1;
--- returns in order:
3
2

--- can provide an OFFSET without a limit
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2), (3);
SELECT a FROM t1 ORDER BY a DESC OFFSET 1;
--- returns in order:
2
1

--- starts from offset 0 if offset is null
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (2), (3);
SELECT a FROM t1 ORDER BY a DESC OFFSET NULL;
--- returns in order:
3
2
1

--- returns a parse error if no limit is provided
SELECT a FROM t1 LIMIT;
--- returns error:
parsing_error

--- returns a parse error if no offset is provided
SELECT a FROM t1 LIMIT 1 OFFSET;
--- returns error:
parsing_error

--- returns a validation error if using a reference in LIMIT
CREATE TABLE t1(a INTEGER);
SELECT a FROM t1 LIMIT a;
--- returns error:
validation_error

--- returns a validation error if using a reference in OFFSET
CREATE TABLE t1(a INTEGER);
SELECT a FROM t1 LIMIT 1 OFFSET a;
--- returns error:
validation_error

--- returns a validation error if using a boolean in LIMIT
CREATE TABLE t1(a INTEGER);
SELECT a FROM t1 LIMIT true;
--- returns error:
validation_error

--- returns a validation error if using a boolean in OFFSET
CREATE TABLE t1(a INTEGER);
SELECT a FROM t1 LIMIT 1 OFFSET true;
--- returns error:
validation_error

