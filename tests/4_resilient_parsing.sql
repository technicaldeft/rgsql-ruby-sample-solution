---- Whitespace ----

--- allows extra whitespace
  SELECT   2 , 3 ;
--- returns:
2, 3

--- allows newlines
SELECT
1,
6,
3;
--- returns:
1, 6, 3

--- allows whitespace in create and insert statements
CREATE TABLE t1 (
    a INTEGER,
    b INTEGER
);
INSERT   INTO t1 VALUES 
  (
    1,  2
  );
SELECT a, b FROM t1;
--- returns:
1, 2

--- requires whitespace between keywords and literals
SELECTa FROM t1;
--- returns error:
parsing_error

--- Unexpected values ---

--- errors when unexpected symbols in a query
SELECT @, $, %, &;
--- returns error:
parsing_error


--- Case insensitivity ---

--- allows keywords and literals to be lower case
select true, false as wrong;
--- returns:
TRUE, FALSE

--- can write keywords in mixed case
CreaTe tabLe t1(a Integer);
inserT INTo t1 Values(6);
SeLeCt a from t1;
--- returns:
6

--- Mixing keywords and literals ---

--- does not allow keywords to be used as table names
CREATE TABLE from(a INTEGER);
--- returns error:
parsing_error

--- does not allow keywords to be used as columns names
CREATE TABLE x(AS INTEGER);
--- returns error:
parsing_error

--- does not allow the keyword 'into' to be used as a table name
CREATE TABLE into(INTO INTEGER);
--- returns error:
parsing_error

--- allows columns and aliases to start with keywords
CREATE TABLE t1(from_count INTEGER, a INTEGER);
INSERT INTO t1 VALUES (1, 2);
SELECT from_count, a AS from_number FROM t1;
--- returns:
1, 2

--- allows columns and aliases to start with the names of booleans
CREATE TABLE t1(a INTEGER, falseness BOOLEAN);
INSERT INTO t1 VALUES (1, TRUE);
SELECT a AS true_count, falseness FROM t1;
--- returns:
1, TRUE

