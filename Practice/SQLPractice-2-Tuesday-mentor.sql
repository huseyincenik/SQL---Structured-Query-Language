---- 1. List all the cities in the Texas and the numbers of customers in each city.----

SELECT 
	a.city,
	COUNT(a.customer_id) AS num_of_customers
FROM
	sale.customer AS a
WHERE
	a.state = 'TX'
GROUP BY
	a.city

SELECT city, COUNT(*)
FROM sale.customer
WHERE state = 'tx'
GROUP BY city

HAVING
	sale.customer.state = "TX"

---- 2. List all the cities in the California which has more than 5 customer, by showing the cities which have more customers first.---

SELECT
	*
FROM 
	sale.customer

SELECT
	TOP 1 a.city,
	COUNT(DISTINCT customer_id) AS customer_number
FROM
	sale.customer AS a
WHERE
	a.state = 'CA'
GROUP BY
	a.city
ORDER BY
	customer_number DESC

---- 3. List the top 10 most expensive products----

SELECT
	TOP 10 *
FROM
	product.product AS a
ORDER BY
	a.list_price DESC


---- 4. List store_id, product name and list price and the quantity of the products which are located in the store id 2 and the quantity is greater than 25----

SELECT
	b.store_id,
	a.product_name,
	a.list_price,
	b.quantity
FROM
	product.product AS a
	LEFT JOIN product.stock AS b ON b.product_id = a.product_id
WHERE
	b.store_id = 2 AND b.quantity > 25


---- 5. Find the sales order of the customers who lives in Boulder order by order date----

SELECT
	order_id,
	order_date
FROM
	sale.customer AS a
	JOIN sale.orders AS b ON b.customer_id = a.customer_id --- defaultu Inner
WHERE
	a.city = 'Boulder'
ORDER BY
	b.order_date DESC;
	



SELECT 
	*
FROM
	sale.customer




---- 6. Get the sales by staffs and years using the AVG() aggregate function.



SELECT
    staff_id,
    SUM(order_count) / 3 As total_sales
FROM (
    SELECT
        a.staff_id,
        COUNT(a.order_id) AS order_count
    FROM
        sale.orders AS a
        INNER JOIN sale.staff AS b ON b.staff_id = a.staff_id
    GROUP BY
        a.staff_id,
        DATEPART(YEAR, a.order_date)
) AS subquery
GROUP BY
    staff_id
ORDER BY
    staff_id

SELECT  s.staff_id, DATEPART(YEAR, o.order_date),count(DATEPART(YEAR, o.order_date)), round(avg((oi.list_price * oi.quantity) - (oi.list_price * oi.quantity * oi.discount)),1) AS avg_salesFROM sale.orders o, sale.staff s, sale.order_item oiwhere s.staff_id=o.staff_idand o.order_id = oi.order_idGROUP BY s.staff_id,DATEPART(YEAR, o.order_date)ORDER BY staff_id ASC



SELECT 
	*
FROM
	

SELECT  s.staff_id, DATEPART(YEAR, o.order_date), count(DATEPART(YEAR, o.order_date)) FROM sale.orders oINNER JOIN sale.staff sON s.staff_id=o.staff_idGROUP BY s.staff_id,DATEPART(YEAR, o.order_date)ORDER BY staff_id ASC




---- 7. What is the sales quantity of product according to the brands and sort them highest-lowest----


SELECT p.brand_id, SUM(o.quantity) AS product_quantity
FROM sale.order_item as o
INNER JOIN product.product AS p
ON p.product_id=o.product_id
INNER JOIN product.brand as b
ON b.brand_id=p.brand_id
GROUP BY p.brand_id
ORDER BY product_quantity
