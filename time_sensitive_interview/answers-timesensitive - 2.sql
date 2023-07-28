

SELECT
	*
FROM
	VALUES

SELECT
	*
FROM
	order AS a
	INNER JOIN
	customer AS b ON b.CustomerID = a.CustomerID


SELECT
	*
FROM
	color
WHERE
	C1 = 'Yellow'
UNION
SELECT
	*
FROM
	color
WHERE
	C2 = 'Yellow'
UNION
SELECT
	*
FROM
	color
WHERE
	C3 = 'Yellow'


WITH customer_table AS (SELECT
	*
FROM
(VALUES 
	(1, 'Edward', 'Smith' , '5.12.1981'),
	(2, 'Bety', 'Lake' , '14.07.1986'),
	(3, 'Kathie', 'Snow' , '20.11.1992'),
	(4, 'Robert', 'Myres' , '1.01.1990')) AS table1 ([id], [first_name], [last_name], [birth_date])), order_table AS (
SELECT
	*
FROM
(VALUES 
	(1, 3, '1.01.2022' , 10),
	(2, 2, '1.01.2022' , 11),
	(3, 3, '2.01.2022' , 12),
	(4, 4, '3.01.2022' , 13)) AS table1 ([ord_id], [cust_id], [ord_date], [prod_id]))

SELECT
	first_name,
	last_name
FROM
	customer_table AS A
WHERE NOT EXISTS (SELECT 1
FROM order_table AS B
WHERE ord_date >= '02.01.2022'
AND B.cust_id = A.id)


------------with except 
WITH customer_table AS (SELECT
	*
FROM
(VALUES 
	(1, 'Edward', 'Smith' , '5.12.1981'),
	(2, 'Bety', 'Lake' , '14.07.1986'),
	(3, 'Kathie', 'Snow' , '20.11.1992'),
	(4, 'Robert', 'Myres' , '1.01.1990')) AS table1 ([id], [first_name], [last_name], [birth_date])), order_table AS (
SELECT
	*
FROM
(VALUES 
	(1, 3, '1.01.2022' , 10),
	(2, 2, '1.01.2022' , 11),
	(3, 3, '2.01.2022' , 12),
	(4, 4, '3.01.2022' , 13)) AS table1 ([ord_id], [cust_id], [ord_date], [prod_id]))

SELECT
	first_name,
	last_name
FROM
	customer_table AS A
EXCEPT
SELECT
	first_name,
	last_name
FROM
	customer_table AS A
	INNER JOIN order_table AS B ON A.id = B.cust_id AND B.ord_date >= '02.01.2022'
--WHERE ord_date >= '02.01.2022')


------------

SELECT	
	TOP 2 first_name, last_name
FROM	
	sale.customer