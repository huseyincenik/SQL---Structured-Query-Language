/* Set Operators

Introduction
Set operations allow the results of multiple queries to be combined into a single result set. Set operators include UNION, INTERSECT, and EXCEPT.

The UNION set operator returns the combined results of the two SELECT statements. Essentially, It removes duplicates from the results i.e. only one row will be listed for each duplicated result. 

To counter this behavior, use the UNION ALL set operator which retains the duplicates in the final result.

INTERSECT lists only records that are common to both the SELECT queries; the EXCEPT set operator removes the second query's results from the output if they are also found in the first query's results. INTERSECT and EXCEPT set operations produce unduplicated results.

Important: 
Both SELECT statements must contain the same number of columns.
In the SELECT statements, the corresponding columns must have the same data type.
Positional ordering must be used to sort the result set. The individual result set ordering is not allowed with Set operators. ORDER BY can appear once at the end of the query.
UNION and INTERSECT operators are commutative, i.e. the order of queries is not important; it doesn't change the final result.
Performance-wise, UNION ALL shows better performance as compared to UNION because resources are not wasted in filtering duplicates and sorting the result set.

Set operators can be the part of subqueries. */

CREATE TABLE employees_A
(
emp_id BIGINT,
first_name VARCHAR(20),
last_name VARCHAR(20),
salary BIGINT,
job_title VARCHAR (30),
gender VARCHAR(10),
);

INSERT employees_A VALUES
 (17679,  'Robert'    , 'Gilmore'       ,   110000 ,  'Operations Director', 'Male')
,(26650,  'Elvis'    , 'Ritter'        ,   86000 ,  'Sales Manager', 'Male')
,(30840,  'David'   , 'Barrow'        ,   85000 ,  'Data Scientist', 'Male')
,(49714,  'Hugo'    , 'Forester'    ,   55000 ,  'IT Support Specialist', 'Male')
,(51821,  'Linda'    , 'Foster'     ,   95000 ,  'Data Scientist', 'Female')
,(67323,  'Lisa'    , 'Wiener'      ,   75000 ,  'Business Analyst', 'Female')

CREATE TABLE employees_B
(
emp_id BIGINT,
first_name VARCHAR(20),
last_name VARCHAR(20),
salary BIGINT,
job_title VARCHAR (30),
gender VARCHAR(10),
);
INSERT employees_B VALUES
 (49714,  'Hugo'    , 'Forester'       ,   55000 ,  'IT Support Specialist', 'Male')
,(67323,  'Lisa'    , 'Wiener'        ,   75000 ,  'Business Analyst', 'Female')
,(70950,  'Rodney'   , 'Weaver'        ,   87000 ,  'Project Manager', 'Male')
,(71329,  'Gayle'    , 'Meyer'    ,   77000 ,  'HR Manager', 'Female')
,(76589,  'Jason'    , 'Christian'     ,   99000 ,  'Project Manager', 'Male')
,(97927,  'Billie'    , 'Lanning'      ,   67000 ,  'Web Developer', 'Female')

---------------------------------------------
/*Union Operator
In some cases, you may need to combine data from two or more tables into a result set. Union clause is used to perform this operation. The tables that you need to combine can be tables with similar data in the same database, or in different databases.

You will use the UNION operator to combine rows from two or more queries into a single result set.*/

SELECT
	*
FROM
	employees_A
UNION
SELECT
	*
FROM
	employees_B
	----with dublicates
/*Union All Operator
The UNION ALL clause is used to print all the records including duplicate records when combining the two tables.*/



SELECT
	*
FROM
	employees_A
UNION ALL
SELECT
	*
FROM
	employees_B

----WARNING : All queries combined using a UNION, INTERSECT or EXCEPT operator must have an equal number of expressions in their target lists.
SELECT
	first_name
FROM
	employees_A
UNION ALL
SELECT
	*
FROM
	employees_B


--- Here, the Type column is created to indicate which table the employees belong to.

SELECT 'Employees A' AS Type, emp_id, first_name, last_name, job_title
  FROM employees_A
UNION ALL
SELECT 'Employees B' AS Type, emp_id, first_name, last_name, job_title
  FROM employees_B;

/*Intersect Operator
INTERSECT operator compares the result sets of two queries and returns distinct rows that are output by both queries.*/

SELECT emp_id, first_name, last_name, job_title
  FROM employees_A
INTERSECT
SELECT emp_id, first_name, last_name, job_title
  FROM employees_B
  ORDER BY emp_id;

SELECT first_name, last_name, job_title
  FROM employees_A
INTERSECT
SELECT first_name, last_name, job_title
  FROM employees_B

/* Except Operator
EXCEPT operator compares the result sets of the two queries and returns the rows of the previous query that differ from the next query. */

SELECT emp_id, first_name, last_name, job_title
  FROM employees_A
EXCEPT
SELECT emp_id, first_name, last_name, job_title
  FROM employees_B;

SELECT 'Employees A' AS TYPE, emp_id, first_name, last_name, job_title
  FROM employees_A
EXCEPT
SELECT 'Employees B' AS TYPE, emp_id, first_name, last_name, job_title
  FROM employees_B;
  
/* Simple CASE Expression
The simple CASE expression compares an expression to a set of expressions to return the result. */

SELECT
	*
FROM
	product.brand

SELECT
	brand_id,
	CASE brand_name
		WHEN 'Samsung' THEN 'Samsung'
		WHEN 'Apple' THEN 'Apple'
		ELSE 'others'
	END AS Samsung	
FROM
	product.brand
/* Searched CASE Expression
The searched CASE expression evaluates a set of expressions to determine the result. In the simple CASE expression, it's only compared for equivalence whereas the searched CASE expression can include any type of comparison. In this type of CASE statement, we don't specify any expression right after the CASE keyword. */

SELECT
	product_name,
	product_id,
	list_price,
	CASE
		WHEN list_price <=100 THEN 'Low'
		WHEN list_price > 100 AND list_price < 1000 THEN 'Middle'
		WHEN list_price >= 1000 THEN 'High'
	END AS list_price_category
FROM
	product.product


SELECT
	product_name,
	product_id,
	list_price,
	CASE
		WHEN list_price < (SELECT AVG(list_price) FROM product.product) THEN 'Low'
		ELSE 'Middle'
	END AS list_price_category
FROM
	product.product

SELECT
	product_name,
	product_id,
	list_price
FROM
	product.product
WHERE
	CASE
		WHEN list_price <=100 THEN 'Low'
		WHEN list_price > 100 AND list_price < 1000 THEN 'Middle'
		WHEN list_price >= 1000 THEN 'High'
	END = 'High'

WITH T1 AS
(SELECT
	*,
	CASE
	WHEN DATEPART(WEEKDAY, order_date) > 4 THEN 'Weekend'
	WHEN DATEPART(WEEKDAY, order_date) < 5 THEN 'Weekday'
	END AS day_type
FROM
	sale.orders AS a)
SELECT
	T1.day_type,
	COUNT(T1.day_type)
FROM 
    T1
GROUP BY
	T1.day_type




SELECT
	SUM(CASE WHEN DATEPART(WEEKDAY, a.order_date) IN (1, 2, 3, 4, 5) THEN 1 ELSE 0 END) AS Weekend,
	SUM(CASE WHEN DATEPART(WEEKDAY, a.order_date) IN (0 ,6)  THEN 1 ELSE 0 END) AS Weekday
	
FROM
	sale.orders AS a
