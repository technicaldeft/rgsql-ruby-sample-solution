---- Using SELECT without a table ----

--- can select an integer
SELECT 1;
--- returns:
1

--- can select a larger integer
SELECT 37;
--- returns:
37

--- can select a negative integer
SELECT -30;
--- returns:
-30

--- treats negative 0 as 0
SELECT -0;
--- returns:
0

--- can select true
SELECT TRUE;
--- returns:
TRUE

--- can select false
SELECT FALSE;
--- returns:
FALSE

--- can select multiple items
SELECT 1, FALSE, 3;
--- returns:
1, FALSE, 3

--- can select no values
SELECT;
--- returns no rows

--- errors when there is an unknown statement
BANANA 1;
--- returns error:
parsing_error

--- errors when unexpected characters after the statement
SELECT 123; extra
--- returns error:
parsing_error

---- Naming columns ----

--- can give names to multiple columns with AS
SELECT 1 AS col_1, 2 AS col_2;
--- returns:
1, 2
--- with columns:
col_1, col_2

--- errors if name starts with a number
SELECT 1 AS 1a;
--- returns error:
parsing_error
