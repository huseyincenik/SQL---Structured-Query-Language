/*1. Product Sales
You need to create a report on whether customers who purchased the product named '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD' buy the product below or not.

1. 'Polk Audio - 50 W Woofer - Black' -- (other_product)

To generate this report, you are required to use the appropriate SQL Server Built-in functions or expressions as well as basic SQL knowledge.*/

---PREPRATION

SELECT
	DISTINCT e.customer_id,
	e.first_name,
	e.last_name
FROM
	product.product AS a
	INNER JOIN sale.order_item AS b ON b.product_id = a.product_id
	INNER JOIN sale.orders AS c ON c.order_id = b.order_id
	INNER JOIN sale.customer AS e ON e.customer_id = c.customer_id
WHERE 
	a.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'

------SOLUTION

WITH T1 AS(
SELECT
	DISTINCT e.customer_id,
	e.first_name,
	e.last_name
FROM
	product.product AS a
	INNER JOIN sale.order_item AS b ON b.product_id = a.product_id
	INNER JOIN sale.orders AS c ON c.order_id = b.order_id
	INNER JOIN sale.customer AS e ON e.customer_id = c.customer_id
WHERE 
	a.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'),
T2 AS (
SELECT
	DISTINCT e.customer_id,
	e.first_name,
	e.last_name,
	'Yes' AS Other_Product
FROM
	product.product AS a
	INNER JOIN sale.order_item AS b ON b.product_id = a.product_id
	INNER JOIN sale.orders AS c ON c.order_id = b.order_id
	INNER JOIN sale.customer AS e ON e.customer_id = c.customer_id
WHERE 
	a.product_name = 'Polk Audio - 50 W Woofer - Black'
)

SELECT
	T1.*,
	ISNULL(T2.Other_Product, 'No') AS Other_Product --COALESCE(T2.Other_Product, 'No') AS Other_Product
FROM
	T1 LEFT JOIN T2 ON T1.customer_id = T2.customer_id


/*Below you see a table of the actions of customers visiting the website by clicking on two different types of advertisements given by an E-Commerce company. Write a query to return the conversion rate for each Advertisement type.*/

--PREPRATION
CREATE TABLE e_commerce(
	Visitor_ID INT,
	Adv_Type VARCHAR(1),
	Action VARCHAR(10)
);

INSERT INTO e_commerce (Visitor_ID, Adv_Type, Action)
VALUES
	(1, 'A', 'Left'),
	(2, 'A', 'Order'),
	(3, 'B', 'Left'),
	(4, 'A', 'Order'),
	(5, 'A', 'Review'),
	(6, 'A', 'Left'),
	(7, 'B', 'Left'),
	(8, 'B', 'Order'),
	(9, 'B', 'Review'),
	(10, 'A', 'Review');

SELECT 
	a.Adv_Type,
	COUNT(a.Action)
FROM
	e_commerce AS a
GROUP BY
	a.Adv_Type

SELECT 
	a.Adv_Type,
	COUNT(a.Action)
FROM
	e_commerce AS a
WHERE
	a.Action = 'Order'
GROUP BY
	a.Adv_Type

GO

--SOLUTION

WITH T1 AS(
SELECT 
	a.Adv_Type,
	COUNT(a.Action) AS count_order
FROM
	e_commerce AS a
WHERE
	a.Action = 'Order'
GROUP BY
	a.Adv_Type
), T2 AS(
SELECT 
	a.Adv_Type,
	COUNT(a.Action) AS count_action
FROM
	e_commerce AS a
GROUP BY
	a.Adv_Type
)

SELECT
	T1.Adv_Type,
	CAST((T1.count_order * 1.0 / T2.count_action ) AS decimal(10, 2)) AS Percentage
FROM	
	T1 INNER JOIN T2 ON T1.Adv_Type = T2.Adv_Type


