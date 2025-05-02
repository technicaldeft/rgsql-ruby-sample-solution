---- Working with NULL ----

--- can select NULL
SELECT NULL;
--- returns:
NULL

--- null to be lower case
select null;
--- returns:
NULL

--- can insert and select null values
CREATE TABLE t5(a INTEGER);
INSERT INTO t5 VALUES(NULL);
SELECT a FROM t5;
--- returns:
NULL

--- treats columns that haven't been set as NULL
CREATE TABLE t2(a INTEGER, b INTEGER);
INSERT INTO t2 VALUES(1);
SELECT a, b FROM t2;
--- returns:
1, NULL


---- NULL propagation ----

--- propagates NULL in mathematical operators
SELECT 1 + NULL;
--- returns:
NULL

SELECT NULL + 2;
--- returns:
NULL

SELECT null - (1 / NULL);
--- returns:
NULL

--- propagates NULL in logical operators
SELECT TRUE AND NULL;
--- returns:
NULL

SELECT null OR NULL;
--- returns:
NULL

SELECT NOT NULL;
--- returns:
NULL

--- does not propagate NULL when left side of an AND is TRUE
SELECT false AND NULL;
--- returns:
FALSE

--- does not propagate NULL when left side of an OR is TRUE
SELECT TRUE OR NULL;
--- returns:
TRUE

--- does not propagate NULL when right side of an OR is TRUE
SELECT NULL OR TRUE;
--- returns:
TRUE

--- propagates NULL in comparison operators
SELECT 1 < NULL;
--- returns:
NULL

SELECT NULL >= 2;
--- returns:
NULL

--- propagates NULL for equality operators
SELECT null = NULL;
--- returns:
NULL

SELECT null <> NULL;
--- returns:
NULL

--- propagates NULL for ABS
SELECT ABS(NULL);
--- returns:
NULL

--- propagates NULL for MOD
SELECT MOD(2, NULL);
--- returns:
NULL