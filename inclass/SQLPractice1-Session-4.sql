--- INNER JOIN

--make a list of products showing the PRODUCT ID, product name, category ID, and category name.



SELECT
	p.product_id,
	p.product_name,
	p.category_id,
	c.category_name
FROM
	product.product AS p 
	INNER JOIN product.category AS c ON p.category_id = c.category_id

---List employees of stores with their store information
---	Select first name, last name, store name

SELECT
	a.first_name,
	a.last_name,
	b.store_name
FROM
	sale.staff AS a
	INNER JOIN sale.store AS b ON a.store_id = b.store_id 

--How many employees are in each store ? 

SELECT
	b.store_name,
	COUNT(a.staff_id) AS num_of_employees
FROM
	sale.staff AS a
	INNER JOIN sale.store AS b ON a.store_id = b.store_id 
GROUP BY
	b.store_name;

---LEFT JOIN

--Write a query that returns products that have never been ordered
--Select product ID, product name, orderID

SELECT
	a.product_id,
	a.product_name,
	b.order_id
FROM
	product.product AS a 
	LEFT JOIN sale.order_item AS b ON b.product_id = a.product_id
WHERE
	b.order_id IS NULL
ORDER BY
	1;

--Report the total number of products sold by each employee

SELECT
	b.staff_id,
	a.first_name,
	a.last_name,
	COUNT(c.quantity) AS num_of_products
FROM
	sale.staff AS a
	LEFT JOIN sale.orders AS b ON b.staff_id = a.staff_id
	LEFT JOIN sale.order_item AS c ON b.order_id = c.order_id
GROUP BY
	b.staff_id,
	a.first_name,
	a.last_name

-----RIGHT JOIN

---Write query that returns products that have never been ordered
---Select Product ID, product name, orderID

SELECT
	a.product_id,
	a.product_name,
	b.order_id
FROM
	sale.order_item AS b 
	RIGHT JOIN product.product AS a ON b.product_id = a.product_id
WHERE
	b.order_id IS NULL
ORDER BY
	1;

--FULL OUTER JOIN

-- Report the stock quantities of all products


SELECT
	b.product_name,
	SUM(a.quantity) AS total_quantity
FROM
	product.stock AS a
	FULL OUTER JOIN product.product AS b ON b.product_id = a.product_id
GROUP BY
	b.product_name
HAVING 
	SUM(a.quantity) IS NULL

--CROSS JOIN
/*The stock table does not have all the products in the product table, and you want to add these products to the stock table.
  You have to insert all these products for every three stores with “0 (zero)” quantity.
  Write a query to prepare this data.*/

SELECT
	a.product_id,
	a.product_name,
	COALESCE(b.quantity, 0)
FROM
	product.product AS a
	LEFT JOIN product.stock AS b ON b.product_id = a.product_id

GROUP BY
	a.product_id,
	a.product_name,
	b.quantity


SELECT 
	a.product_id,
	b.store_id,
	COALESCE(c.quantity, 0)
FROM
	product.product AS a
	CROSS JOIN sale.store AS b
	LEFT JOIN product.stock AS c ON a.product_id = c.product_id
	AND b.store_id = c.store_id
ORDER BY
	1,2


-- SELF JOIN
--Write a query that returns the staff names with their manager names.
--Expected columns : staff first name, staff last name, manager name

SELECT
	*
FROM
	sale.staff

SELECT
	a.staff_id,
	a.first_name,
	a.last_name,
	b.first_name,
	b.last_name
FROM
	sale.staff AS a
	LEFT JOIN sale.staff AS b ON b.manager_id = a.staff_id

SELECT
	a.staff_id,
	a.first_name,
	a.last_name,
	b.first_name,
	b.last_name
FROM
	sale.staff AS a
	LEFT JOIN sale.staff AS b ON a.manager_id = b.staff_id

-- Write a query that returns both the names of staff and the names their 1st and 2nd managers
SELECT
	a.staff_id,
	a.first_name,
	a.last_name,
	b.first_name,
	b.last_name,
	c.first_name,
	c.last_name
FROM
	sale.staff AS a
	LEFT JOIN sale.staff AS b ON a.manager_id = b.staff_id
	LEFT JOIN sale.staff AS c ON b.manager_id = c.staff_id


--- VIEWS

--Create a view that shows the products customers ordered

SELECT
	a.customer_id,
	a.first_name,
	a.last_name,
	b.order_id,
	c.product_id,
	d.product_name,
	c.list_price*c.quantity AS total_quantity
FROM 
	sale.customer AS a
	LEFT JOIN sale.orders AS b ON a.customer_id = b.customer_id
	LEFT JOIN sale.order_item AS c ON b.order_id = c.order_id
	LEFT JOIN product.product AS d ON c.product_id = d.product_id
GO

CREATE VIEW vw_customer_table AS
SELECT
	a.customer_id,
	a.first_name,
	a.last_name,
	b.order_id,
	c.product_id,
	d.product_name,
	c.list_price*c.quantity AS total_quantity
FROM 
	sale.customer AS a
	LEFT JOIN sale.orders AS b ON a.customer_id = b.customer_id
	LEFT JOIN sale.order_item AS c ON b.order_id = c.order_id
	LEFT JOIN product.product AS d ON c.product_id = d.product_id
GO


SELECT 
	* 
FROM 
	[dbo].[vw_customer_table]

exec sp_helptext [vw_customer_table]
GO

--FOR ALTER QUERY

ALTER VIEW vw_customer_table AS
SELECT
	a.customer_id,
	a.first_name,
	a.last_name,
	b.order_id,
	c.product_id,
	d.product_name,
	c.list_price*c.quantity AS total_quantity
FROM 
	sale.customer AS a
	LEFT JOIN sale.orders AS b ON a.customer_id = b.customer_id
	LEFT JOIN sale.order_item AS c ON b.order_id = c.order_id
	LEFT JOIN product.product AS d ON c.product_id = d.product_id
GO