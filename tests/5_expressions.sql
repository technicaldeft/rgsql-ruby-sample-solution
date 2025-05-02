---- Mathematical operators ----

--- can add two numbers
SELECT 1 + 2;
--- returns:
3

--- can subtract a number
SELECT 4 - 2;
--- returns:
2

--- can multiply two numbers
SELECT 3 * 2;
--- returns:
6

--- can divide two numbers, truncating remainder
SELECT 10 / 3;
--- returns:
3

--- can nest multiple operators
SELECT 1 + (2 + 3);
--- returns:
6

SELECT (2 * 3) - 1;
--- returns:
5

--- can wrap operators in brackets
SELECT (1);
--- returns:
1

SELECT (1 + 2);
--- returns:
3

SELECT ((2 * 2));
--- returns:
4

--- can turn a number in brackets negative
SELECT -(2);
--- returns:
-2

--- can turn an expression in brackets negative
SELECT -(2 + 2);
--- returns:
-4


---- Logical operators ----

--- can evaluate NOT
SELECT NOT TRUE;
--- returns:
FALSE

SELECT NOT false;
--- returns:
TRUE

--- can evaluate AND
SELECT true AND TRUE;
--- returns:
TRUE

SELECT TRUE AND false;
--- returns:
FALSE

--- can evaluate OR
SELECT TRUE OR false;
--- returns:
TRUE

SELECT false OR false;
--- returns:
FALSE

--- can evaluate more complex expressions
SELECT (NOT true) OR ((true AND false) OR TRUE);
--- returns:
TRUE


---- Comparisons ----

--- can evaluate < (Less Than)
SELECT 1 < 2;
--- returns:
TRUE

SELECT 1 < 1;
--- returns:
FALSE

--- can evaluate > (Greater Than)
SELECT 2 > 1;
--- returns:
TRUE

SELECT 2 > 2;
--- returns:
FALSE

--- can evaluate <= (Less Than or Equal)
SELECT 1 <= 1;
--- returns:
TRUE

SELECT 1 <= 0;
--- returns:
FALSE

--- can evaluate >= (Greater Than or Equal)
SELECT 2 >= 2;
--- returns:
TRUE

SELECT 2 >= 3;
--- returns:
FALSE

--- treats TRUE as greater than FALSE when comparing
SELECT TRUE > false;
--- returns:
TRUE

SELECT TRUE < FALSE;
--- returns:
FALSE

SELECT false <= true;
--- returns:
TRUE

SELECT TRUE <= false;
--- returns:
FALSE

--- can evaluate = (equality) for integers
SELECT 0 = 0;
--- returns:
TRUE

SELECT 0 = 234;
--- returns:
FALSE

--- can evaluate = (equality) for booleans
SELECT true = TRUE;
--- returns:
TRUE

SELECT false = false;
--- returns:
TRUE

SELECT TRUE = false;
--- returns:
FALSE

--- can evaluate <> (inequality) for integers
SELECT 0 <> 0;
--- returns:
FALSE

SELECT 0 <> 234;
--- returns:
TRUE

--- can evaluate <> (inequality) for booleans
SELECT true <> TRUE;
--- returns:
FALSE

SELECT false <> false;
--- returns:
FALSE

SELECT TRUE <> false;
--- returns:
TRUE


---- Using expressions with tables ----

--- can use expression in select to transform values
CREATE TABLE t1(a INTEGER, b INTEGER);
INSERT INTO t1 VALUES(7, 6);
SELECT a * b FROM t1;
--- returns:
42

--- can use expressions in an INSERT to transform values
CREATE TABLE t1(a INTEGER);
INSERT INTO t1 VALUES(10 * 5);
SELECT a FROM t1;
--- returns:
50


---- Error handling expressions ----

--- errors when there are missing closing brackets
SELECT (1 * 2;
--- returns error:
parsing_error

--- errors when there are missing opening brackets
SELECT 1 * 2);
--- returns error:
parsing_error

--- errors when there are no values between binary operators
SELECT 1 * / 2;
--- returns error:
parsing_error


---- Functions ----

--- ABS function returns the absolute value
SELECT ABS(1);
--- returns:
1

SELECT ABS(-1);
--- returns:
1

--- MOD function returns the modulo (remainder) of the division
SELECT MOD(10, 3);
--- returns:
1

--- can mix expressions and functions
SELECT ABS(1 - 10);
--- returns:
9

SELECT MOD(5, 3) * 2;
--- returns:
4

--- errors when there are missing closing brackets
SELECT ABS(1;
--- returns error:
parsing_error

--- errors when there are missing opening brackets
SELECT ABS 1);
--- returns error:
parsing_error

--- errors when there are no values between operators
SELECT MOD(1 2);
--- returns error:
parsing_error

--- errors when using functions like operators
SELECT MOD 1, 2;
--- returns error:
parsing_error

--- errors when using operators like functions
SELECT *(1, 2);
--- returns error:
parsing_error
