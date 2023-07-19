--GROUPING OPERATIONS
--HAVING
--Write a query that checks if any product id is duplicated in product table.
SELECT
	DISTINCT product_id
FROM
	product.product AS a
INTERSECT
SELECT
	product_id
FROM
	product.product AS a

SELECT
	product_id,
	COUNT(*) AS row_cnt
FROM
	product.product
GROUP BY product_id
HAVING COUNT(*) > 1

-------------
----Write a query that returns category ids with conditions max list price above 4000 or a min list price below 500.
SELECT
	category_id,
	MAX(list_price) AS max_price,
	MIN(list_price) AS min_price
FROM
	product.product
GROUP BY
	category_id
HAVING
	MIN(list_price) < 500
	OR MAX(list_price) > 4000

----
SELECT
	*
FROM
	(
	SELECT
	category_id,
	MAX(list_price) AS max_price,
	MIN(list_price) AS min_price
FROM
	product.product
GROUP BY
	category_id
	) AS A
WHERE 
	A.max_price> 4000 OR A.min_price < 500

--Find the average product prices of the brands. Display brand name and average prices in descending order.

SELECT
	brand_name,
	AVG(list_price) avg_list_price
FROM
	product.brand AS a
	INNER JOIN product.product AS b ON b.brand_id = a.brand_id
GROUP BY
	a.brand_name
ORDER BY
	avg_list_price DESC
------------------
--Write a query that returns the list of brands whose average product prices are more than 1000
SELECT
	brand_name,
	AVG(list_price) avg_list_price
FROM
	product.brand AS a
	INNER JOIN product.product AS b ON b.brand_id = a.brand_id
GROUP BY
	a.brand_name
HAVING
	AVG(list_price) > 1000
ORDER BY
	2 
--Ortalama ürün fiyatýnýn 1000 dolardan yüksek olduðu markalarýn en çok satýldýðý þehir.
SELECT
	e.city,
	COUNT(d.order_id) AS cnt_order
FROM
	product.brand AS a
	INNER JOIN product.product AS b ON a.brand_id = b.brand_id
	INNER JOIN sale.order_item AS c ON c.product_id = b.product_id
	INNER JOIN sale.orders AS d ON d.order_id = c.order_id
	INNER JOIN sale.customer AS e ON e.customer_id = d.customer_id
WHERE
	a.brand_name IN (
SELECT
	a.brand_name
FROM
	product.brand AS a
	INNER JOIN product.product AS b ON b.brand_id = a.brand_id
GROUP BY
	a.brand_name
HAVING
	AVG(b.list_price) > 1000
	)
GROUP BY
	e.city
ORDER BY
	2 DESC
--devamý gelecek

;
--Write a query that returns the list of each order id and that order's total net price (please take into consideration of discounts and quantities)
SELECT	
	a.order_id,
	SUM(a.quantity * a.list_price * ( 1 - a.discount) ) AS net_price
FROM
	sale.order_item AS a
GROUP BY 
	a.order_id;

--Write a query that returns monthly order counts of the States.
SELECT
	a.state,
	YEAR(order_date) AS Years,
	MONTH(b.order_date) ord_month,
	COUNT(b.order_id) AS ord_cnt

FROM
	sale.customer AS a, sale.orders AS b
WHERE
	a.customer_id = b.customer_id
GROUP BY
	a.state,
	YEAR(order_date),
	MONTH(b.order_date)
ORDER BY
	a.state,
	2 

SELECT
DISTINCT YEAR(order_date)
FROM
	sale.orders

-----///////////////////////------

--GRUPING SETS

--1. Calculate the total sales price.

SELECT 
	SUM(list_price * quantity * ( 1 - discount)) AS total_sales
FROM
	sale.order_item

--2. Calculate the total sales price of the brands
SELECT
	c.brand_name,
	SUM(A.list_price * quantity * ( 1 - discount)) AS total_sales
FROM
	sale.order_item AS A , product.product AS B ,product.brand AS C
WHERE
	A.product_id = B.product_id
	AND B.brand_id = C.brand_id
GROUP BY
	c.brand_name
--3. Calculate the total sales price of the model year
SELECT
	model_year,
	SUM(A.list_price * quantity * ( 1 - discount)) AS total_sales
FROM
	sale.order_item AS A , product.product AS B 
WHERE
	A.product_id = B.product_id
GROUP BY
	model_year
--4. Calculate the total sales price by brands and model year.
SELECT
	c.brand_name,
	model_year,
	SUM(A.list_price * quantity * ( 1 - discount)) AS total_sales
FROM
	sale.order_item AS A , product.product AS B ,product.brand AS C
WHERE
	A.product_id = B.product_id
	AND B.brand_id = C.brand_id
GROUP BY
	c.brand_name, model_year
ORDER BY
	c.brand_name, model_year

--------------------------union ile birlestir . odev .

------GROUPING SETS


SELECT
	c.brand_name,
	model_year,
	SUM(A.list_price * quantity * ( 1 - discount)) AS total_sales
FROM
	sale.order_item AS A , product.product AS B ,product.brand AS C
WHERE
	A.product_id = B.product_id
	AND B.brand_id = C.brand_id
GROUP BY
	GROUPING SETS(
	(),
	(brand_name),
	(model_year),
	(brand_name, model_year))
ORDER BY
	c.brand_name, model_year

-----------------
SELECT
	c.brand_name,
	model_year,
	GROUPING(c.brand_name) brand_gr,-- if it is 0, it is grouped . 
	GROUPING(model_year) model_gr,
	SUM(A.list_price * quantity * ( 1 - discount)) AS total_sales
FROM
	sale.order_item AS A , product.product AS B ,product.brand AS C
WHERE
	A.product_id = B.product_id
	AND B.brand_id = C.brand_id
GROUP BY
	GROUPING SETS(
	(),
	(brand_name),
	(model_year),
	(brand_name, model_year))
HAVING
	GROUPING(c.brand_name) = 0 AND
	GROUPING(model_year) = 0
ORDER BY
	c.brand_name, model_year

-------------------------------------------------------------------
---summary table


--brand, category, model_year, total_sales_price


/*
SELECT ...
INTO	...
FROM ....

*/


SELECT
	c.brand_name,
	D.category_name,
	model_year,
	SUM(A.list_price * quantity * ( 1 - discount)) AS total_sales
INTO sale.sales_summary

FROM
	sale.order_item AS A , product.product AS B ,product.brand AS C, product.category AS D
WHERE
	A.product_id = B.product_id
	AND B.brand_id = C.brand_id
	AND B.category_id = D.category_id
GROUP BY
	c.brand_name, category_name, model_year
ORDER BY
	c.brand_name, category_name,  model_year

SELECT
	*
FROM
	sale.sales_summary

--Question : Write a query using summary table that returns the total_sales from each category by model year( in pivot table format )
---pivot olusturacagimiz temel tabloyu belirle
---tabloyu gecici olarak sabitle

SELECT 
	*
FROM(
SELECT brand_name,
	model_year,
	total_sales
FROM
	sale.sales_summary
) AS A
PIVOT
(
	SUM(total_sales)
	FOR model_year
	IN ([2018], [2019], [2020], [2021])
) AS PV_TABLE
-----------
SELECT 
	*
FROM(
SELECT brand_name,
	model_year,
	total_sales
FROM
	sale.sales_summary
) AS A
PIVOT
(
	SUM(total_sales)
	FOR model_year
	IN ([2018], [2019], [2020], [2021])
) AS PV_TABLE
-----
CREATE VIEW VW_TOTAL_SALES AS
(
SELECT brand_name,
	model_year,
	total_sales
FROM
	sale.sales_summary
)

SELECT *
FROM
	VW_TOTAL_SALES
PIVOT
(
	SUM(total_sales)
	FOR model_year
	IN ([2018], [2019], [2020], [2021])
) AS PV_TABLE --but vw_total_sales is sabit .

---Question : Write a query that returns count of the orders day by day in a pivot table format that has been shipped two days later

SELECT
	DATENAME(WEEKDAY, order_date) day_of_week ,
	COUNT(order_id) AS cnt_of_order
FROM
	sale.orders AS a
WHERE
	DATEDIFF(day, order_date, shipped_date) > 2
GROUP BY
	DATENAME(WEEKDAY, order_date)

---agg func must make in pivot

SELECT *
FROM
(SELECT
	DATENAME(WEEKDAY, order_date) day_of_week ,
	order_id
FROM
	sale.orders AS a
WHERE
	DATEDIFF(day, order_date, shipped_date) > 2
) A
PIVOT
(
	COUNT(order_id)
	FOR day_of_week
	IN([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) AS PVT