CREATE VIEW VW_first_product_customer AS(
SELECT
	DISTINCT D.customer_id,
	D.first_name,
	D.last_name
FROM
	product.product AS A
	INNER JOIN sale.order_item AS B ON A.product_id = B.product_id
	INNER JOIN sale.orders AS C ON B.order_id = C.order_id
	INNER JOIN sale.customer AS D ON C.customer_id = D.customer_id
WHERE
	a.product_name = '2TB Red 5400 rpm SATA III 3.5 Internal NAS HDD'
)

CREATE VIEW VW_second_product_customer AS(
SELECT
	DISTINCT D.customer_id,
	D.first_name,
	D.last_name
FROM
	product.product AS A
	INNER JOIN sale.order_item AS B ON A.product_id = B.product_id
	INNER JOIN sale.orders AS C ON B.order_id = C.order_id
	INNER JOIN sale.customer AS D ON C.customer_id = D.customer_id
WHERE
	a.product_name = 'Polk Audio - 50 W Woofer - Black'
)

SELECT
	A.*,
	--B.first_name,
	ISNULL(NULLIF(ISNULL(B.first_name, 'No'), B.first_name), 'Yes') AS other_product
	---ISNULL(ISNULL(B.first_name, 'No'), 'Yes')
	
FROM
	VW_first_product_customer AS A
	LEFT JOIN VW_second_product_customer AS B ON A.customer_id = B.customer_id

--------------------
SELECT Adv_type ,COUNT(*) total_cust,
	1.0 * SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END) AS order_cust,
	CAST(1.0 * SUM(CASE WHEN Action = 'Order' THEN 1 ELSE 0 END) / COUNT(*) AS DECIMAL(10,2)) Conversion_rate
FROM	(VALUES
	('A', 'Left'),
	('A', 'Order'),
	('B', 'Left'),
	('A', 'Order'),
	('A', 'Review'),
	('A', 'Left'),
	('B', 'Left'),
	('B', 'Order'),
	('B', 'Review'),
	('A', 'Review')
) AS table1 (Adv_type, [Action])
GROUP BY 
	Adv_type

CREATE TABLE #assignment_2 
(
Adv_type CHAR(1),
Action VARCHAR(10)
)

INSERT INTO #assignment_2
VALUES
	('A', 'Left'),
	('A', 'Order'),
	('B', 'Left'),
	('A', 'Order'),
	('A', 'Review'),
	('A', 'Left'),
	('B', 'Left'),
	('B', 'Order'),
	('B', 'Review'),
	('A', 'Review')

SELECT A.Adv_type,
	CAST( 1.0 * ordered_cust / total_cust AS DECIMAL (3, 2)) AS conversion_rate

FROM
(

SELECT Adv_type , COUNT(*) total_cust
FROM #assignment_2
GROUP BY
	Adv_type) A
	INNER JOIN
	(
	SELECT Adv_type , COUNT(*) ordered_cust
FROM #assignment_2
WHERE Action = 'Order'
GROUP BY
	Adv_type
	) B
ON A.Adv_type = B.Adv_type