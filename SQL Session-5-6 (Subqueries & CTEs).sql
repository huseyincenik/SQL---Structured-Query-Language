
-- SQL Session-5/6, 12.07.2023, (Subqueries & CTEs)

----SUBQUERIES----
--------------------------------------------

--A subquery is a query nested inside another statement such as SELECT, INSERT, UPDATE or DELETE.
--A subquery must be enclosed in parentheses.
--The inner query can be run by itself.
--The subquery in a SELECT clause must return a single value.
--The subquery in a FROM clause must be used with an alias.
--An ORDER BY clause is not allowed to use in a subquery.
--(unless TOP, OFFSET or FOR XML is also specified) "FOR XML" FOR "JSON XML"


-- ****Single-Row Subqueries**** --
--**************************************

SELECT *,(SELECT MAX(list_price) AS max_price FROM product.product)
FROM product.product

--QUESTION: Write a query that shows all employees in the store where Davis Thomas works.




SELECT
	store_id
FROM
	sale.staff
WHERE
	first_name = 'Davis' AND last_name = 'Thomas'---first_name + last_name = 'DavisThomas'

SELECT
	*
FROM
	sale.staff
WHERE
	store_id = (
SELECT
	store_id
FROM
	sale.staff
WHERE
	first_name = 'Davis' AND last_name = 'Thomas'	
	)




--QUESTION: Write a query that shows the employees for whom Charles Cussona is a first-degree manager.
--(To which employees are Charles Cussona a first-degree manager?)



SELECT
	*
FROM
	sale.staff
WHERE
	first_name + last_name = 'CharlesCussona'


SELECT
	*
FROM
	sale.staff
WHERE
	manager_id = (
	SELECT staff_id
	FROM
		sale.staff
	WHERE
		first_name + last_name = 'CharlesCussona'
	)




--QUESTION: Write a query that returns the list of products that are more expensive than the product
--named 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'.(Also show model year and list price)

SELECT
	list_price
FROM
	product.product
WHERE
	product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'

SELECT
	a.product_name,
	a.product_name,
	a.model_year,
	a.list_price
FROM
	product.product AS a
WHERE
	a.list_price > (
SELECT
	list_price
FROM
	product.product
WHERE
	product_name = 'Pro-Series 49-Class Full HD Outdoor LED TV (Silver)'	
	)


-- ****Multiple-Row Subqueries**** --
--**************************************
--They are used with multiple-row operators such as IN, NOT IN, ANY, and ALL.


---//////////////////////////---

--QUESTION: Write a query that returns the first name, last name, and order date of customers 
--who ordered on the same dates as Laurel Goldammer.


SELECT
	*
FROM
	sale.customer AS a
WHERE
	a.first_name + a.last_name = 'LaurelGoldamer'

SELECT 
	order_date
FROM
	sale.customer AS c
	INNER JOIN sale.orders AS b
	ON c.customer_id = b.customer_id

WHERE
	first_name = 'Laurel' AND last_name = 'Goldammer'

SELECT 
	first_name,
	last_name,
	order_date
FROM
	sale.customer AS c
	INNER JOIN sale.orders AS b
	ON c.customer_id = b.customer_id

WHERE
	order_date IN (
	SELECT 
	order_date
FROM
	sale.customer AS c
	INNER JOIN sale.orders AS b
	ON c.customer_id = b.customer_id

WHERE
	first_name = 'Laurel' AND last_name = 'Goldammer'
	)
	



--QUESTION: List the products that ordered in the last 10 orders in Buffalo city.

SELECT
	TOP 10 order_id
FROM
	sale.customer AS c
	INNER JOIN sale.orders AS o -- Customer which have never ordered be need to take . 
	ON c.customer_id = o.customer_id
WHERE
	city = 'Buffalo'
ORDER BY
	order_id DESC;

SELECT
	order_id,
	product_name
FROM
	sale.order_item AS a
	INNER JOIN product.product AS b
	ON a.product_id = b.product_id


SELECT
	DISTINCT b.product_name
FROM
	sale.order_item AS a
	INNER JOIN product.product AS b
	ON a.product_id = b.product_id
WHERE a.order_id IN (
SELECT
	TOP 10 order_id
FROM
	sale.customer AS c
	INNER JOIN sale.orders AS o -- Customer which have never ordered be need to take . 
	ON c.customer_id = o.customer_id
WHERE
	city = 'Buffalo'
ORDER BY
	order_id DESC
)

SELECT ISNULL(phone, 0)
FROM sale.customer

SELECT COALESCE(phone, 0)
FROM sale.customer -- Coalesce try to convert from str to int . But it does not so .  

SELECT 1 + '1' --implicit conversion
--When datatype is not equal two columns ,SQL server try to convert data types .

-- NULLIF . it used to zero division errors .

SELECT NULLIF(1, '1')

SELECT 1/NULLIF(points, 0)

-- ****Correlated Subqueries**** --
--**************************************
--A correlated subquery is a subquery that uses the values of the outer query. In other words, the correlated subquery depends on the outer query for its values.
--Because of this dependency, a correlated subquery cannot be executed independently as a simple subquery.
--Correlated subqueries are used for row-by-row processing. Each subquery is executed once for every row
--of the outer query.
--A correlated subquery is also known as repeating subquery or synchronized subquery.

---//////////////////////////---


SELECT
	product_id,
	product_name,
	category_id,
	list_price,
	( SELECT AVG(list_price) FROM product.product) AS avg_price
FROM
	product.product

SELECT 
	category_id,
	AVG( list_price ) AS avg_price
FROM
	product.product
GROUP BY
	category_id
	
SELECT
	product_id,
	product_name,
	a.category_id,
	list_price,
	b.avg_price
FROM	
	product.product AS a
	INNER JOIN(SELECT 
	category_id,
	AVG( list_price ) AS avg_price
FROM
	product.product
GROUP BY
	category_id) AS b
	ON a.category_id = b.category_id
ORDER BY
	1

SELECT 
	avg(list_price) AS avg_price
FROM	
	product.product
WHERE	
	category_id = 5

SELECT
	product_id,
	product_name,
    category_id,
	list_price,
	(SELECT AVG(list_price) FROM product.product WHERE category_id = p.category_id) AS avg_price --like for loop
FROM product.product AS p ;

--EXISTS / NOT EXISTS

--QUESTION: Write a query that returns a list of States where 'Apple - Pre-Owned iPad 3 - 32GB - White'
--product is not ordered


SELECT
	DISTINCT STATE
FROM
	sale.customer
WHERE
	state NOT IN(
SELECT
	state
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON a.customer_id = b.customer_id
	INNER JOIN sale.order_item AS c ON b.order_id = c.order_id
	INNER JOIN product.product AS d ON c.product_id = d.product_id
WHERE
	product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White') ;

-----------------------
SELECT
	DISTINCT STATE
FROM
	sale.customer AS e
WHERE
	NOT EXISTS(
SELECT
	state
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON a.customer_id = b.customer_id
	INNER JOIN sale.order_item AS c ON b.order_id = c.order_id
	INNER JOIN product.product AS d ON c.product_id = d.product_id
WHERE
	product_name = 'Apple - Pre-Owned iPad 3 - 32GB - White'
	AND state = e.state ) ; --corelated subquery don t run itself .





--QUESTION: Write a query that returns stock information of the products in Davi techno Retail store. 
--The BFLO Store hasn't got any stock of that products.

GO

SELECT
	*
FROM
	product.stock AS d
	INNER JOIN sale.store AS c ON d.store_id = c.store_id
WHERE 
	NOT EXISTS(
SELECT
	a.product_id
FROM
	product.stock AS a
	INNER JOIN sale.store AS b ON b.store_id = a.store_id
WHERE 
	b.store_name = 'Davi techno Retail' )

SELECT
    s.product_id,
    s.quantity
FROM
    product.stock AS s
    INNER JOIN sale.store AS st ON s.store_id = st.store_id
WHERE
    st.store_name = 'The BFLO Store'
    AND EXISTS (
        SELECT 1
        FROM product.stock AS s2
        INNER JOIN sale.store AS st2 ON s2.store_id = st2.store_id
        WHERE s2.product_id = s.product_id
        AND st2.store_name = 'Davi techno Retail'
    );


---teacher solution


SELECT
	aa.store_id,
	aa.store_name,
	bb.product_id,
	bb.quantity
FROM
	sale.store AS aa,
	product.stock AS bb
WHERE
	aa.store_id = bb.store_id
AND 
	aa.store_name = 'Davi techno Retail'




SELECT
	a.store_id,
	a.store_name,
	b.product_id,
	b.quantity
FROM
	sale.store AS a,
	product.stock AS b
WHERE
	a.store_id = b.store_id
AND 
	a.store_name = 'The BFLO Store'
AND
	b.quantity > 0

SELECT
	aa.store_id,
	aa.store_name,
	bb.product_id,
	bb.quantity
FROM
	sale.store AS aa,
	product.stock AS bb
WHERE
	aa.store_id = bb.store_id
AND 
	aa.store_name = 'Davi techno Retail'
AND
	NOT EXISTS(SELECT
	a.store_id,
	a.store_name,
	b.product_id,
	b.quantity
FROM
	sale.store AS a,
	product.stock AS b
WHERE
	a.store_id = b.store_id
AND 
	a.store_name = 'The BFLO Store'
AND
	b.quantity > 0
AND product_id = bb.product_id)

----///////////////////////////

--Subquery in SELECT Statement

--QUESTION: Write a query that creates a new column named "total_price" calculating 
--the total prices of the products on each order.


SELECT
	a.order_id,
	SUM(a.list_price * a.quantity * (1 - a.discount)) AS total_price
FROM
	sale.order_item AS a
GROUP BY
	a.order_id

SELECT
	(SELECT
	a.order_id,
	SUM(a.list_price * a.quantity * (1 - a.discount)) AS total_price
FROM
	sale.order_item AS a

GROUP BY
	a.order_id)
FROM
	sale.order_item AS b

SELECT
    order_id,
    (
        SELECT SUM(list_price * quantity * (1 - discount))
        FROM sale.order_item
        WHERE order_id = o.order_id
    ) AS total_price
FROM
    sale.orders AS o

--teacher solution

SELECT
	distinct order_id,
	(SELECT SUM(list_price) FROM sale.order_item WHERE order_id = a.order_id) total_price
FROM
	sale.order_item AS a
-- liste fiyati bulunduðu kategorideki ürünlerin ortalama fiyatindan fazla yuksek olan urunleri listeleyiniz .

SELECT
	*
FROM
	product.product AS a
WHERE
	a.list_price > (
	SELECT 
		AVG(list_price)
	FROM
		product.product AS b
	WHERE
		b.category_id = a.category_id 
	GROUP BY
		b.category_id)


--/////////////////////////////////////////////////////////////

----CTE's (Common Table Expression)----
--********************************************

--Common Table Expression exists for the duration of a single statement. That means 
--they are only usable inside of the query they belong to.
--It is also called "with statement".
--CTE is just syntax so in theory it is just a subquery. But it is more readable.
--An ORDER BY clause is not allowed to use in a subquery.
--(unless TOP, OFFSET or FOR XML is also specified)
--Each column must have a name.

---//////////////////////////---

--QUESTION: List customers who have an order prior to the last order date of a customer named 
--Jerald Berray and are residents of the city of Austin. 


SELECT
	MAX(order_date)
FROM
	sale.customer c ,sale.orders o
WHERE
	c.customer_id = o.customer_id
AND
	first_name + last_name = 'JeraldBerray'

	
WITH 
	cte AS (
SELECT
	MAX(order_date) AS max_date
FROM
	sale.customer c ,sale.orders o
WHERE
	c.customer_id = o.customer_id
AND
	first_name + last_name = 'JeraldBerray')
SELECT
	a.customer_id,
	a.first_name,
	a.last_name,
	city,
	order_date,
	max_date
FROM
	sale.customer AS a, sale.orders AS b, cte
WHERE
	a.customer_id = b.customer_id
	AND b.order_date < max_date
	AND a.city = 'Austin'





--QUESTION: List the stores whose turnovers are under the average store turnovers in 2018.


WITH cte AS (
	SELECT
	AVG(list_price * quantity * (1 - discount )) AS avg_turnover
)

SELECT
	store_name,
	SUM(quantity * list_price * ( 1 - discount)) AS turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b
	ON a.order_id = b.order_id
	INNER JOIN sale.store AS c
	ON a.store_id = c.store_id
WHERE YEAR(order_date) = 2018
GROUP BY store_name

GO

WITH t1
AS(
SELECT
	store_name,
	SUM(quantity * list_price * ( 1 - discount)) AS turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b
	ON a.order_id = b.order_id
	INNER JOIN sale.store AS c
	ON a.store_id = c.store_id
WHERE YEAR(order_date) = 2018
GROUP BY store_name), t2 AS
(
	SELECT
		AVG(turnover) AS avg_earn
	FROM t1
)
SELECT *
FROM t1, t2
WHERE
	turnover < avg_earn

--------------------------------------------
WITH t1
AS(
SELECT
	store_id,
	SUM(quantity * list_price * ( 1 - discount)) AS turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b
	ON a.order_id = b.order_id
WHERE YEAR(order_date) = 2018
GROUP BY store_id), t2 AS
(
	SELECT
		AVG(turnover) AS avg_earn
	FROM t1
)
SELECT store_name, turnover, avg_earn 
FROM t1, t2 , sale.store AS s
WHERE t1.store_id = s.store_id
AND turnover < avg_earn

------ after comma , two digit
WITH t1
AS(
SELECT
	store_id,
	SUM(quantity * list_price * ( 1 - discount)) AS turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b
	ON a.order_id = b.order_id
WHERE YEAR(order_date) = 2018
GROUP BY store_id), t2 AS
(
	SELECT
		AVG(turnover) AS avg_earn
	FROM t1
)
SELECT store_name,CAST( turnover AS DECIMAL(9, 2)) turnover, CONVERT(DECIMAL( 10, 2) , avg_earn ) avg_earn
FROM t1, t2 , sale.store AS s
WHERE t1.store_id = s.store_id
AND turnover < avg_earn


--QUESTION: Write a query that returns the net amount of their first order for customers who placed 
--their first order after 2019-10-01.
SELECT
	customer_id,
	MIN(order_date)
FROM
	sale.orders
WHERE--it runs before group by
	order_date > '2019-10-01'
GROUP BY
	customer_id




SELECT
	customer_id,
	MIN(order_date)
FROM
	sale.orders
GROUP BY
	customer_id
HAVING--it runs after group by
	MIN(order_date) > '2019-10-01'

WITH t1
AS(
SELECT
	customer_id,
	MIN(order_id)  AS first_order
FROM
	sale.orders
GROUP BY
	customer_id
)
SELECT
	a.customer_id,
	first_name,
	last_name,
	a.order_id,
	SUM(quantity*list_price*(1 - discount)) AS net_price
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b  ON a.order_id = b.order_id
	INNER JOIN sale.customer AS c ON a.customer_id = c.customer_id
	INNER JOIN t1 ON a.order_id = t1.first_order
WHERE
	a.order_date > '2019-10-01'
GROUP BY
	a.customer_id,
	first_name,
	last_name,
	a.order_id


