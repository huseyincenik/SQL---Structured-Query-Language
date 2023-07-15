---- 1. Find the store that generated the highest revenue in the 4th, 5th, and 6th months of 2019.----

SELECT
	c.store_name,
	SUM(a.quantity * a.list_price * ( 1 - a.discount)) AS revenue
FROM
	sale.order_item AS a
	INNER JOIN sale.orders AS b ON b.order_id = a.order_id
	INNER JOIN sale.store AS c ON c.store_id = b.store_id
WHERE
	b.order_date LIKE '2019-0[4-6]-%'
GROUP BY
	c.store_name
ORDER BY
	2

SELECT
	TOP 1 c.store_name,
	SUM(a.quantity * a.list_price * ( 1 - a.discount)) AS revenue
FROM
	sale.order_item AS a
	INNER JOIN sale.orders AS b ON b.order_id = a.order_id
	INNER JOIN sale.store AS c ON c.store_id = b.store_id
WHERE
	b.order_date LIKE '2019-0[4-6]-%'
GROUP BY
	c.store_name
ORDER BY
	2 DESC

--ANOTHER SOLUTION
SELECT
	TOP 1 c.store_name,
	SUM(a.quantity * a.list_price * ( 1 - a.discount)) AS revenue
FROM
	sale.order_item AS a
	INNER JOIN sale.orders AS b ON b.order_id = a.order_id
	INNER JOIN sale.store AS c ON c.store_id = b.store_id
WHERE
	DATEPART(QUARTER, b.order_date) = 2
	AND YEAR(b.order_date) = 2019
GROUP BY
	c.store_name
ORDER BY
	2 DESC
---- 2. Report the name, surname, and city information of the customers who placed orders in both 2017 and 2018.----
WITH T1 AS(
SELECT
	DISTINCT
	a.customer_id,
	a.first_name,
	a.last_name,
	a.city
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
WHERE
	YEAR(b.order_date) = 2018), T2 AS
(SELECT
	DISTINCT
	a.customer_id,
	a.first_name,
	a.last_name,
	a.city
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
WHERE
	YEAR(b.order_date) = 2019)

SELECT
	T1.first_name,
	T1.last_name,
	T1.city
FROM
	T1 INNER JOIN T2 ON T1.customer_id = T2.customer_id

---- 3. Products sold in cities where more than 10 orders were placed in the state of Texas in 2019.----

SELECT
	a.city,
	COUNT(b.order_id) AS count_orders
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
WHERE
	a.state = 'TX'
	AND YEAR(b.order_date ) = 2019
GROUP BY
	a.city
HAVING
	COUNT(b.order_id) > 15



SELECT
	d.product_name
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON b.order_id = c.order_id
	INNER JOIN product.product AS d ON c.product_id = d.product_id
WHERE
	YEAR(b.order_date ) = 2019
	AND a.city IN (
SELECT
	a.city
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
WHERE
	a.state = 'TX'
	AND YEAR(b.order_date ) = 2019
GROUP BY
	a.city
HAVING
	COUNT(b.order_id) > 15
	)