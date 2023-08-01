----1. Retrieve products with at least 3 quantities in stock by stores.
USE SampleRetail;

SELECT
	store_id,
	quantity,
	product_id
FROM
	product.stock AS a
GROUP BY
	store_id,
	quantity,
	product_id
HAVING
	quantity >=3
ORDER BY
	1


----2. Write a query that returns the monthly average number of orders for 2020.
SELECT
	AVG(cnt_order) AS avg_of_order
FROM
(SELECT
	DISTINCT MONTH(order_date) AS month_num,
	COUNT(order_id) OVER(PARTITION BY MONTH(order_date)) cnt_order
FROM
	sale.orders
WHERE
	YEAR(order_date) = 2020) AS subquery


----3. Write a query that returns the top three most expensive products in each category.


SELECT
	category_id, 
	list_price
FROM(
SELECT
	category_id,
	product_name,
	list_price,
	ROW_NUMBER() OVER(PARTITION BY category_id ORDER BY list_price DESC) AS row_number_category
FROM
	product.product) AS subquery
WHERE
	row_number_category = 1 OR row_number_category = 2 OR row_number_category = 3
ORDER BY
	1, 2 DESC




----4. Write a query that returns the highest daily turnover amount for each week on a yearly basis.
SELECT
	DISTINCT
	year_basis,
	week_yearly_basis,
	MAX(quantity * list_price * ( 1- discount)) OVER(PARTITION BY week_yearly_basis , DATEPART(WEEK, order_date)) AS week_daily_turnover
FROM(
SELECT
	A.*,
	B.quantity,
	B.list_price,
	B.discount,
	YEAR(A.order_date) AS year_basis,
	DENSE_RANK() OVER(PARTITION BY YEAR(A.order_date) ORDER BY DATEPART(WEEK, A.order_date)) AS week_yearly_basis
FROM
	sale.orders AS A
	INNER JOIN sale.order_item AS B ON B.order_id = A.order_id) AS subquery
ORDER BY
	year_basis

----5. List customers who have at least 2 consecutive orders are not shipped.
WITH CTE AS(
SELECT
	customer_id,
	--num_of_orders,
	lead_shipped_date,
	COUNT(num_of_orders) OVER(PARTITION BY customer_id) AS cnt_order
FROM(
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY customer_id ORDER BY order_date) AS num_of_orders,
	LEAD(shipped_date, 1, '0100-01-01') OVER(PARTITION BY customer_id ORDER BY customer_id) AS lead_shipped_date 
FROM
	sale.orders) AS subquery
WHERE
	lead_shipped_date IS NULL )
SELECT
	DISTINCT *
FROM
	CTE
WHERE
	cnt_order != 1
ORDER BY
	customer_id
