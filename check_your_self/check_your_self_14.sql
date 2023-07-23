--Check Yourself-14

SELECT
	DISTINCT first_name,
	last_name
	--total_order,
	--order_status,
	--cnt_order,
	--order_status_sum
FROM(
SELECT
	subque.*,
	SUM(order_status) OVER(PARTITION BY customer_id) AS order_status_sum
FROM(
SELECT
	a.*,
	c.*,
	COUNT(b.order_id) OVER(PARTITION BY a.customer_id) cnt_order,
	SUM(quantity * list_price * ( 1 - discount)) OVER(PARTITION BY b.order_id) as total_order,
	CASE WHEN SUM(quantity * list_price * ( 1 - discount)) OVER(PARTITION BY b.customer_id, b.order_id) > 500 THEN 1 ELSE 0 END order_status
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON c.order_id = b.order_id
WHERE
	a.city = 'Charleston') AS subque) as final_result
WHERE
	order_status_sum = cnt_order
ORDER BY
	2,1

----------------------------------------------------------------
--List the store names in ascending order that did not have an order between "2018-07-22" and "2018-07-28".

--(Use SampleRetail Database and paste your result in the box below.)

SELECT
	store_name
FROM 
	sale.store AS a
EXCEPT
SELECT
	DISTINCT store_name
FROM
	sale.store AS a
	INNER JOIN sale.orders AS b ON b.store_id = a.store_id
WHERE
	b.order_date BETWEEN '2018-07-22' and '2018-07-28'
	
