---- Count ----

--- counts the number of rows in a group
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (7), (7), (7);
SELECT COUNT(true) FROM t1 GROUP BY a;
--- returns:
3

--- counts the number of rows multiple groups
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (20), (20), (20), (10), (10);
SELECT a, COUNT(true) FROM t1 GROUP BY a;
--- returns:
20, 3
10, 2

--- returns no rows when there are no rows to count
CREATE TABLE t1(a INTEGER);
SELECT COUNT(true) FROM t1 GROUP BY a;
--- returns no rows

--- returns 0 when COUNT expression is NULL
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (3), (3);
SELECT COUNT(NULL) FROM t1 GROUP BY a;
--- returns:
0

--- can refer to a column in COUNT expression
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (NULL);
SELECT COUNT(a) FROM t1 GROUP BY a;
--- returns:
1
0

--- can use multiple aggregate functions in the same query
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1), (NULL);
SELECT COUNT(true), COUNT(a) FROM t1 GROUP BY a;
--- returns:
2, 2
1, 0

---- Sum ----

--- can use SUM to add up a column
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (3), (3);
SELECT SUM(a) FROM t1 GROUP BY a;
--- returns:
6

--- returns NULL when there are only NULL values
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (NULL), (NULL);
SELECT SUM(a) FROM t1 GROUP BY a;
--- returns:
NULL

--- returns no rows when there are no rows to sum
CREATE TABLE t1(a INTEGER);
SELECT SUM(a) FROM t1 GROUP BY a;
--- returns no rows

--- can SUM a constant for each row
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (3), (3);
SELECT SUM(2) FROM t1 GROUP BY a;
--- returns:
4

--- can use SUM to sum an expression for each row
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (10), (10);
SELECT SUM(1 + 2) FROM t1 GROUP by a;
--- returns:
6

---- More aggregate function uses ----

--- can use aggregate functions on ungrouped columns
CREATE TABLE t1(a BOOLEAN, b INTEGER);
INSERT INTO t1 VALUES (true, 1), (false, 10), (true, 2), (false, 20);
SELECT SUM(b) FROM t1 GROUP BY a;
--- returns:
3
30

--- can use multiple aggregate functions in a select list
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (2), (2), (2), (2);
SELECT COUNT(a), SUM(a) FROM t1 GROUP BY a;
--- returns:
4, 8

--- can use aggregate functions within an expression
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (1), (1);
SELECT 10 + COUNT(true) FROM t1 GROUP BY a;
--- returns:
12

--- can use multiple aggregate functions in the same select list item
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (2), (2), (2), (2);
SELECT COUNT(a) + SUM(a) FROM t1 GROUP BY a;
--- returns:
12

--- can order by the result of aggregate functions
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (5), (5), (5), (6), (7), (7);
SELECT a, COUNT(a) as c FROM t1 GROUP BY a ORDER BY c ASC;
--- returns in order:
6, 1
7, 2
5, 3

---- Validating aggregate functions ----

--- returns a validation error when SUM used on a non-integer column
CREATE TABLE t1(a BOOLEAN);
INSERT INTO t1 VALUES (true), (false);
SELECT SUM(a) FROM t1;
--- returns error:
validation_error

--- returns a validation error if using an a aggregate function on the result of an aggregate function
CREATE TABLE t1(a INTEGER);
SELECT COUNT(COUNT(true)) FROM t1 GROUP BY a;
--- returns error:
validation_error

--- returns a validation error if using an aggregate function in a WHERE
CREATE TABLE t1(a INTEGER);
SELECT COUNT(a) FROM t1 WHERE COUNT(1) > 0 GROUP BY a;
--- returns error:
validation_error

--- returns a validation error if using an aggregate function in a LIMIT
CREATE TABLE t1(a INTEGER);
SELECT COUNT(a) FROM t1 GROUP BY a LIMIT COUNT(1);
--- returns error:
validation_error


---- Aggregation functions creating an implicit group ----

--- can count all rows
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (10), (20), (30);
SELECT COUNT(a) FROM t1;
--- returns:
3

--- returns 0 if there are no rows to count
CREATE TABLE t1(a INTEGER);
SELECT COUNT(a) FROM t1;
--- returns:
0

--- can sum all rows
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES (10), (20), (30);
SELECT SUM(a) FROM t1;
--- returns:
60

--- returns NULL if there are no rows to SUM
CREATE TABLE t1(a INTEGER);
SELECT SUM(a) FROM t1;
--- returns:
NULL

--- returns a validation error if using a non-aggregated column
CREATE TABLE t1(a INTEGER, b INTEGER);
INSERT INTO t1 VALUES (1, 10), (2, 6);
SELECT COUNT(a), b FROM t1;
--- returns error:
validation_error


---- Putting it all together ----

--- running a complex query
DROP TABLE IF EXISTS items;
DROP TABLE IF EXISTS order_lines;
CREATE TABLE items(item_no INTEGER, price INTEGER);
INSERT INTO items VALUES (1, 100), (2, 200), (3, 300);
CREATE TABLE order_lines(order_no INTEGER, item_no INTEGER, quantity INTEGER, dispatched BOOLEAN, year INTEGER);
INSERT INTO order_lines VALUES
    (1, 1, 1, true, 2020), (1, 2, 1, true, 2020), 
    (2, 3, 20, false, 2022), 
    (3, 1, 3, true, 2020), (3, 2, 1, true, 2020), (3, 3, 1, true, 2020),
    (4, 2, 1, true, 2021), (4, 3, 4, true, 2021),
    (5, 2, 10, true, 2019);
SELECT order_no, SUM(price * quantity) AS total_price, SUM(quantity) AS total_items FROM order_lines
    INNER JOIN items ON order_lines.item_no = items.item_no
    WHERE order_lines.dispatched AND (year >= 2020)
    GROUP BY order_no
    ORDER BY total_price DESC
    LIMIT 2;
--- returns:
4, 1400, 5
3, 800, 5