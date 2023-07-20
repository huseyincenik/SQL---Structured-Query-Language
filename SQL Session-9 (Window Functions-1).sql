--SQL SESSION-9, 20.07.2023, (Window Functions-1)

--Window Functions (WF) vs. GROUP BY
--Let's review the following two queries for differences between GROUP BY and WF.
---------------------------------------------------------------------

--QUESTION: Write a query that returns the total stock amount of each product in the stock table.
--(ürünlerin stock sayýlarýný bulunuz)

-----with Group By

SELECT
	product_id,
	SUM(a.quantity) AS total_stock
FROM
	product.stock AS a
GROUP BY
	product_id
ORDER BY
	1






-----with WF

SELECT
	*,
	SUM(quantity) OVER() total_stock
FROM
	product.stock


SELECT
	DISTINCT product_id,
	SUM(quantity) OVER(PARTITION BY product_id) total_stock
FROM
	product.stock




--///////////////////////////////
--QUESTION: Write a query that returns average product prices of brands. 
--(markalara göre ort. ürün fiyatlarýný hem Group By hem de Window Functions ile hesaplayýnýz)

-----with Group By
SELECT
	brand_id,
	AVG(list_price) AS avg_price
FROM
	product.product AS a
GROUP BY
	a.brand_id


---with WF

SELECT
	DISTINCT brand_id,
	AVG(list_price) OVER(PARTITION BY brand_id) AS avg_price
FROM
	product.product





-------------------------------------------------------------------------
--1. ANALYTIC AGGREGATE FUNCTIONS
--MIN() - MAX() - AVG() - SUM() - COUNT()
-------------------------------------------------------------------------

--QUESTION: What is the cheapest product price for each category?
--(Her bir kategorideki en ucuz ürünün fiyatý)


SELECT
	DISTINCT category_id,

	MIN(list_price) OVER(PARTITION BY category_id) AS cheapest_by_cat
FROM
	product.product AS a








--///////////////////////////////
--QUESTION:	How many different product in the product table?
--(product tablosunda toplam kaç farklý ürün bulunmaktadýr)

SELECT
	COUNT(*) AS num_of_product
FROM
	product.product AS a

SELECT
	DISTINCT COUNT(*) OVER() AS num_of_products
FROM	
	product.product








--///////////////////////////////
--QUESTION: How many different product in the order_item table?
--(order_item tablosunda kaç farklý ürün bulunmaktadýr)



SELECT
	COUNT(*) OVER(PARTITION BY product_id) AS num_of_product
FROM
	sale.order_item AS a


-----not with wf
SELECT
	COUNT(DISTINCT product_id) AS num_of_product
FROM
	sale.order_item
	
-------------------
SELECT
	DISTINCT COUNT(product_id) OVER() cnt_product
FROM
(
	SELECT DISTINCT product_id
	FROM sale.order_item
) AS subq


--///////////////////////////////
--QUESTION: Write a query that returns how many products are in each order?
--(her sipariþte kaç ürün olduðunu döndüren bir sorgu yazýn)



SELECT
	DISTINCT a.order_id,
	SUM(quantity) OVER(PARTITION BY a.order_id) [quantity]
FROM
	sale.order_item AS a






--///////////////////////////////
--QUESTION: Write a query that returns the number of products in each category of brands.
--(her bir markanýn farklý kategorilerdeki ürün sayýlarý)

SELECT
	DISTINCT category_id,
	brand_id,
	COUNT(product_id) OVER(PARTITION BY category_id, brand_id) AS num_of_products
FROM
	product.product AS a



-------------------------------------------------------------------------
--WINDOW FRAMES
-------------------------------------------------------------------------


SELECT
	brand_id,
	model_year,
	COUNT(product_id) OVER() AS cnt_order,
	COUNT(product_id) OVER(PARTITION BY brand_id) AS cnt,
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year) AS cnt_2,
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
							RANGE BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
							ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
							ROWS BETWEEN 1 PRECEDING AND CURRENT ROW),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
							ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
	COUNT(product_id) OVER(PARTITION BY brand_id ORDER BY model_year
							RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)--
FROM
	product.product
ORDER BY
	1,
	2


-------------------------------------------------------------------------
--2. ANALYTIC NAVIGATION FUNCTIONS
-------------------------------------------------------------------------

--It's mandatory to use ORDER BY.

--******FIRST_VALUE()*****--
--/////////////////////////////////


select *, first_value(first_name) over(order by first_name) 
from sale.staff

select *, first_value(first_name) over(order by last_name) 
from sale.staff


--QUESTION: Write a query that returns first order date by month.
--(Her ay için ilk sipariþ tarihini bulunuz)

SELECT
	DISTINCT YEAR(order_date) [Year],
	MONTH(order_date) [Month],
	FIRST_VALUE(order_date) OVER(PARTITION BY  YEAR(order_date), MONTH(order_date)
									ORDER BY order_date) AS first_order_date
FROM
	sale.orders








--QUESTION: Write a query that returns customers and their most valuable order with total amount of it.

SELECT
	DISTINCT customer_id,
	FIRST_VALUE(order_id) OVER(PARTITION BY customer_id ORDER BY total_amount DESC) AS mv_order,
	FIRST_VALUE(total_amount) OVER(PARTITION BY customer_id ORDER BY total_amount DESC) AS mv_order_price
FROM
	(
	SELECT
	customer_id,
	b.order_id,
	SUM(quantity * list_price * ( 1 - discount)) AS total_amount
	FROM
	sale.orders AS a, sale.order_item AS b
	WHERE
	a.order_id = b.order_id
	GROUP BY
	customer_id,
	b.order_id
	--ORDER BY customer_id
) subq






--/////////////////////////////////
--******LAST_VALUE()*****--


--QUESTION: Write a query that returns last order date by month.
--(Her ay için son sipariþ tarihini bulunuz)




SELECT
	DISTINCT YEAR(order_date) [Year],
	MONTH(order_date) [Month],
	LAST_VALUE(order_date) OVER(PARTITION BY  YEAR(order_date), MONTH(order_date)
									ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS last_order_date
FROM
	sale.orders -- in last value , we must change default window frame . if not , we make a result same as order_date







--/////////////////////////////////
--******LAG() & LEAD()*****--


--LAG() SYNTAX

/*LAG(return_value ,offset [,default]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)*/


--QUESTION: Write a query that returns the order date of the one previous sale of each staff (use the LAG function)
--(Her bir personelin bir önceki satýþýnýn sipariþ tarihini yazdýrýnýz)

SELECT
	order_id,
	first_name,
	last_name,
	order_date,
	LAG(order_date) OVER(PARTITION BY o.staff_id ORDER BY order_id) AS previous_order
FROM
	sale.orders o
	INNER JOIN sale.staff AS s ON s.staff_id = o.staff_id

--------------------
SELECT
	order_id,
	first_name,
	last_name,
	order_date,
	LAG(order_date, 3, '1001-01-01') OVER(PARTITION BY o.staff_id ORDER BY order_id) AS previous_order
FROM
	sale.orders o
	INNER JOIN sale.staff AS s ON s.staff_id = o.staff_id

----------------------------------

--LEAD() SYNTAX

/*LEAD(return_value ,offset [,default]) 
OVER (
    [PARTITION BY partition_expression, ... ]
    ORDER BY sort_expression [ASC | DESC], ...
)*/

--QUESTION: Write a query that returns the order date of the one next sale of each staff (use the LEAD function)
--(Her bir personelin bir sonraki satýþýnýn sipariþ tarihini yazdýrýnýz)


SELECT
	order_id,
	first_name,
	last_name,
	order_date,
	LEAD(order_date) OVER(PARTITION BY o.staff_id ORDER BY order_id) AS next_order
FROM
	sale.orders o
	INNER JOIN sale.staff AS s ON s.staff_id = o.staff_id
-- While you study for repeat this query , please different try pattern like order by ... . 


--QUESTION: Write a query that returns the difference order count between the current month and the next month for each year. 
--(Her bir yýl için peþ peþe gelen aylarýn sipariþ sayýlarý arasýndaki farklarý bulunuz)



SELECT
	DISTINCT YEAR(order_date) [Year],
	MONTH(order_date) [Month],
	COUNT(order_id) OVER(PARTITION BY  YEAR(order_date), MONTH(order_date) )AS cnt_order,
	LEAD(order_id) OVER(PARTITION BY  YEAR(order_date), MONTH(order_date) ORDER BY order_id) AS next_order
FROM
	sale.orders 

------------teacher solution

SELECT
	ord_year,
	ord_month,
	cnt_ord,
	cnt_ord - LEAD(cnt_ord) OVER(PARTITION BY ord_year ORDER BY ord_year)
FROM(
SELECT
	DISTINCT
	YEAR(order_date) [ord_year],
	MONTH(order_date) [ord_month],
	COUNT(order_id) OVER(PARTITION BY YEAR(order_date) , MONTH(order_date)) AS cnt_ord
FROM
	sale.orders
) subq

------------------- for previous month  , we must use Lag

SELECT
	ord_year,
	ord_month,
	cnt_ord,
	cnt_ord - LAG(cnt_ord) OVER(PARTITION BY ord_year ORDER BY ord_year)
FROM(
SELECT
	DISTINCT
	YEAR(order_date) [ord_year],
	MONTH(order_date) [ord_month],
	COUNT(order_id) OVER(PARTITION BY YEAR(order_date) , MONTH(order_date)) AS cnt_ord
FROM
	sale.orders
) subq




