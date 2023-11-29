/*
Instructions:  
There are multiple questions.
Use SampleRetail database to answer the questions.
Please submit your answers (statements) using the related question with the .sql file format.
*/

-- 1. How many customers are in each city? Your solution should include the city name and the number of customers sorted from highest to lowest.

SELECT
	customer.city,
	COUNT(customer.customer_id) AS num_of_customers
FROM
	sale.customer

GROUP BY 
	customer.city
ORDER BY
	num_of_customers DESC;

-- 2. Find the total product quantity of the orders. Your solution should include order ids and quantity of products.

SELECT
	order_item.order_id,
	SUM(order_item.quantity) AS total_product_quantity
FROM
	sale.order_item
GROUP BY 
	order_item.order_id;

--3. Find the first order date for each customer_id.

SELECT
	orders.customer_id,
	MIN(orders.order_date) AS first_order_date
FROM
	sale.orders
GROUP BY
	orders.customer_id;

--4. Find the total amount of each order. Your solution should include order id and total amount sorted from highest to lowest.

SELECT
	order_item.order_id,
	SUM(order_item.quantity*order_item.list_price) AS total_amount
FROM
	sale.order_item
GROUP BY
	order_item.order_id 
ORDER BY
	total_amount DESC;

--5. Find the order id that has the maximum average product price. Your solution should include only one row with the order id and average product price.
SELECT
	TOP 1 order_item.order_id,
	AVG(order_item.list_price) AS max_average_product
FROM
	sale.order_item
GROUP BY
	order_item.order_id
ORDER BY
	max_average_product DESC;

--6. Write a query that displays brand_id, product_id and list_price sorted first by brand_id (in ascending order), and then by list_price  (in descending order).

SELECT
	product.brand_id, 
	product.product_id, 
	product.list_price
FROM
	product.product
ORDER BY
	brand_id ,
	list_price DESC;

--7. Write a query that displays brand_id, product_id and list_price, but this time sorted first by list_price (in descending order), and then by brand_id (in ascending order).

SELECT
	product.brand_id,
	product.product_id,
	product.list_price
FROM
	product.product
ORDER BY
	list_price DESC,
	brand_id;

--8. Compare the results of these two queries above. How are the results different when you switch the column you sort on first? (Explain it in your own words.)

--First query is used firstly order by according to brand_id's ascending sort and secondly order by list_price's descending sort.
--On the contrary , second query does it in the opposite order . Resulty, I can say that first of all , I can see affect of first sort. it is more obvious than other sort . 

--9. Write a query to pull the first 10 rows and all columns from the product table that have a list_price greater than or equal to 3000.

SELECT 
	TOP 10 *
FROM
	product.product
WHERE
	product.list_price >= 3000;
--10. Write a query to pull the first 5 rows and all columns from the product table that have a list_price less than 3000.
SELECT
	TOP 5 *
FROM
	product.product
WHERE
	product.list_price < 3000;
--11. Find all customer last names that start with 'B' and end with 's'.

SELECT
	*
FROM
	sale.customer
WHERE
	customer.last_name LIKE 'B%s';

--12. Use the customer table to find all information regarding customers whose address is Allen or Buffalo or Boston or Berkeley.

SELECT
	*
FROM
	sale.customer
WHERE
	customer.city IN ('Allen', 'Buffalo', 'Boston');

-- THE END , THANK YOU 💐💐💐