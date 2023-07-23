--SQL SESSION-10, 22.07.2023, (Window Functions-2)

--*** Windowed functions can only appear in the SELECT or ORDER BY clauses.


--3. ANALYTIC NUMBERING FUNCTIONS--

--ROW_NUMBER() - RANK() - DENSE_RANK() - CUME_DIST() - PERCENT_RANK() - NTILE()

--The ORDER BY clause is mandatory because these functions are order sensitive.
--They are not used with window frames.


--/////////////////////////////////////

--QUESTION: Assign an ordinal number to the product prices for each category in ascending order.
--(Herbir kategori içinde ürünlerin fiyat sıralamasını yapınız - artan fiyata göre 1'den başlayıp birer birer artacak)


SELECT
	category_id,
	list_price,
	ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY list_price) rate_row
FROM
	product.product



--Lets try previous query again using RANK() and DENSE_RANK() functions.


SELECT
	category_id,
	list_price,
	ROW_NUMBER() OVER (PARTITION BY category_id ORDER BY list_price) rate_row,
	RANK() OVER (PARTITION BY category_id ORDER BY list_price) rank_row,
	DENSE_RANK() OVER (PARTITION BY category_id ORDER BY list_price) dense_row
FROM
	product.product






--/////////////////////////////////////recap

--QUESTION: Which orders' average product price is lower than the overall average price?
--(Hangi siparişlerin ortalama ürün fiyatı genel ortalama fiyattan daha düşüktür?)

SELECT *
FROM(
SELECT
	DISTINCT order_id,
	AVG(list_price) OVER() avg_price,
	AVG(list_price) OVER(PARTITION BY order_id) order_avg_price
FROM
	sale.order_item AS a) AS subq
WHERE
	order_avg_price < avg_price
	--In ctes , views ,subqueries , order_by clause must be out
--another solution
SELECT
	order_id,
	(SELECT AVG(list_price) FROM sale.order_item) avg_price,
	AVG(list_price) avg_price_by_orders
FROM
	sale.order_item AS a
GROUP BY
	order_id
HAVING
	AVG(list_price) < (SELECT AVG(list_price) FROM sale.order_item)
ORDER BY
	avg_price_by_orders DESC;








--/////////////////////////////////////

--QUESTION: Calculate the stores' weekly cumulative count of orders for 2018.
--(mağazaların 2018 yılına ait haftalık kümülatif sipariş sayılarını hesaplayınız)

SELECT
	a.store_id,
	a.store_name,
	b.order_date,
	DATEPART(WK, order_date) "week",
	COUNT(order_id) OVER(PARTITION BY a.store_id, DATEPART(WK, order_date)) AS weeks_order
FROM
	sale.store AS a
	LEFT JOIN
	sale.orders b ON a.store_id = b.store_id
WHERE
	YEAR(order_date) = 2018

----
SELECT
	DISTINCT
	a.store_id,
	a.store_name,
	DATEPART(WK, order_date) "week",
	COUNT(order_id) OVER(PARTITION BY a.store_id, DATEPART(WK, order_date)) AS weeks_order,
	COUNT(*) OVER(PARTITION BY a.store_id ORDER BY DATEPART(WK, order_date)) cume_total_order
FROM
	sale.store AS a
	LEFT JOIN
	sale.orders b ON a.store_id = b.store_id
WHERE
	YEAR(order_date) = 2018

--For cumulative count , we must use order by .




--/////////////////////////////////////

--QUESTION: Calculate 7-day moving average of the number of products sold between '2018-03-12' and '2018-04-12'.
--('2018-03-12' ve '2018-04-12' arasında satılan ürün sayısının 7 günlük hareketli ortalamasını hesaplayın)

SELECT
	DISTINCT order_date,
	SUM(quantity) OVER(PARTITION BY order_date) AS daily_quantity

FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id
WHERE	
	order_date BETWEEN '2018-03-12' AND '2018-04-12'
	-----
WITH cte AS(
SELECT
	DISTINCT order_date,
	SUM(quantity) OVER(PARTITION BY order_date) AS daily_quantity

FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id
WHERE	
	order_date BETWEEN '2018-03-12' AND '2018-04-12'
)
SELECT *, AVG(daily_quantity) OVER(ORDER BY order_date
				ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) AS sales_moving_average_7
FROM cte
--range ler sayiyla kullanilamaz
--range UNBOUNDED ve CURRENT ILE kullanilabilir . 
--UNBOUNDED PREECEDING AND CURRENT ROW
--with group by
SELECT
	a.order_date,
	SUM(quantity) daily_quantity,
	AVG(SUM(quantity)) OVER(ORDER BY order_date ROWS 6 PRECEDING) sales_moving_average_7
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id
WHERE	
	order_date BETWEEN '2018-03-12' AND '2018-04-12'
GROUP BY
	a.order_date


---self
SELECT
	*,
	AVG(cnt_order_date) OVER(PARTITION BY order_date)
FROM(
SELECT
	a.order_id,
	order_date,
	quantity,
	list_price,
	discount,
	DATENAME(DW, order_date) AS date_name,
	COUNT(a.order_id) OVER(PARTITION BY a.order_id,DATENAME(DW, order_date)) AS cnt_order_date,
	AVG(a.order_id) OVER(PARTITION BY a.order_id,DATENAME(DW, order_date)) AS avg_date
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id
WHERE	
	order_date BETWEEN '2018-03-12' AND '2018-04-12'
	) AS subq






--/////////////////////////////////////

--QUESTION: Write a query that returns the highest daily turnover amount for each week on a yearly basis.
--(Yıl bazında her haftaya ait en yüksek günlük ciro miktarını döndüren bir sorgu yazınız)


SELECT	
	DISTINCT
	order_date,
	YEAR(order_date) AS ord_year,
	DATEPART(WK, order_date) AS ord_week,
	--we can use ww, week instead of wk
	SUM(quantity*list_price * (1 - discount))  OVER(PARTITION BY order_date) AS daily_turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id


select
	DISTINCT
	ord_year,
	ord_week,
	MAX(daily_turnover) OVER(PARTITION BY ord_year, ord_week) AS highest_turnover
FROM(
SELECT	
	DISTINCT
	order_date,
	YEAR(order_date) AS ord_year,
	DATEPART(ISOWK, order_date) AS ord_week,
	--we can use ww, week instead of wk
	--ısowk ile week arasindaki fark biri avrupa saati biri baska bir saatti .
	SUM(quantity*list_price * (1 - discount))  OVER(PARTITION BY order_date) AS daily_turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id) subq
----
---SOLUTION (WITH GROUP BY AND FIRST_VALUE)

SELECT	
	DISTINCT
	YEAR(order_date) AS ord_year,
	DATEPART(ISOWK, order_date) AS ord_week,
	--SUM(quantity*list_price * (1 - discount)) AS daily_turnover,
	FIRST_VALUE(SUM(quantity*list_price * (1 - discount))) OVER(PARTITION BY YEAR(order_date), DATEPART(ISOWK, order_date)
	ORDER BY SUM(quantity*list_price * (1 - discount)) DESC) AS highest_turnover
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id
GROUP BY
	order_date


--/////////////////////////////////////

--QUESTION: List customers whose have at least 2 consecutive orders are not shipped.
--(Peşpeşe en az 2 siparişi gönderilmeyen müşterileri bulunuz)


SELECT
	order_id,
	customer_id,
	order_date,
	shipped_date
FROM
	sale.orders
ORDER BY
	2,3

SELECT DISTINCT customer_id
FROM(
SELECT order_id,customer_id, order_date, shipped_date,
	LEAD(shipped_date, 1, '0001-01-01') OVER(PARTITION BY customer_id ORDER BY order_date) next_shipped_date
FROM sale.orders) T
WHERE (shipped_date IS NULL AND next_shipped_date IS NULL)

---with case
WITH t1 AS(
SELECT
	customer_id,
	order_id,
	CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END AS delivery_status
FROM
	sale.orders
), t2 AS(
	SELECT
		*,
		LEAD(delivery_status) OVER (PARTITION BY customer_id ORDER BY order_id) AS next_order_delivery_status
	FROM
		t1
)
SELECT
	*
FROM	
	t2
WHERE
	delivery_status = 'not delivered' AND next_order_delivery_status = 'not delivered'

-------
---with case within lead

WITH T1 AS(SELECT
	customer_id,
	order_id,
	CASE WHEN shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END AS delivery_status
FROM
	sale.orders ), T2 AS(
	SELECT
		T1.*,
		LEAD(CASE WHEN a.shipped_date IS NULL THEN 'not delivered' ELSE 'delivered' END) OVER(PARTITION BY T1.customer_id ORDER BY T1.order_id) AS next_order_delivery_status
	FROM
		T1 INNER JOIN sale.orders AS a ON a.order_id = T1.order_id
	)
SELECT
	T2.*
FROM
	T2
WHERE
	T2.delivery_status = 'not delivered' AND T2.next_order_delivery_status = 'not delivered'


--/////////////////////////////////////

--QUESTION: Write a query that returns how many days are between the third and fourth order dates of each staff.
--(Her bir personelin üçüncü ve dördüncü siparişleri arasındaki gün farkını bulunuz)


SELECT subq.staff_id, first_name,last_name,order_date, previous_order,
	DATEDIFF(DAY, previous_order, order_date) day_diff
FROM(
	SELECT staff_id, order_id, order_date,
		ROW_NUMBER() OVER(PARTITION BY staff_id ORDER BY order_id) nth_order,
		LAG(order_date) OVER(PARTITION BY staff_id ORDER BY order_id) previous_order
	FROM sale.orders
) subq
INNER JOIN sale.staff b ON subq.staff_id=b.staff_id
WHERE nth_order=4

--with lead
SELECT
	*,
	DATEDIFF(DAY,order_date, previous_cnt_order) AS difference_day
FROM(
SELECT
	DISTINCT staff_id,
	order_date,
	ROW_NUMBER() OVER(PARTITION BY staff_id ORDER BY order_date) as cnt_order,
	LEAD(order_date) OVER(PARTITION BY staff_id ORDER BY order_date) as previous_cnt_order
FROM
	sale.orders 
) AS subquery

WHERE
	  cnt_order = 3







--------------------------------------------------------------------------------------
--------------------------------------------------------------------------------------

--////////////////////////

--CUME_DIST()

--creates a column that contain cumulative distribution of the sorted column values.
--cume_dist = row number / total rows

--////////////////////////

--QUESTION: Write a query that returns the cumulative distribution of the list price in product table by brand.
--(product tablosundaki list price' ların kümülatif dağılımını marka kırılımında hesaplayınız)


SELECT
	brand_id,
	list_price,
	CUME_DIST() OVER(PARTITION BY brand_id ORDER BY list_price) AS cume_dist
FROM
	product.product





--////////////////////////

-- PERCENT_RANK()

--creates a column that contain relative standing of a value in the sorted column values.
--percent_rank = (row number-1) / (total rows-1)

--////////////////////////

--QUESTION: Write a query that returns the relative standing of the list price in the product table by brand.


SELECT
	brand_id,
	list_price,
	ROUND(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3) AS prc_rank
FROM
	product.product


-----
SELECT
	brand_id,
	list_price,
	FORMAT(ROUND(PERCENT_RANK() OVER(PARTITION BY brand_id ORDER BY list_price), 3), 'p') AS prc_rank --we use format for percent
FROM
	product.product




--////////////////////////

--NTILE()

--divides the sorted column into equal groups according to the given parameter (N) value and returns which group the each values are in.

--////////////////////////

SELECT
	list_price,
	NTILE(5) OVER(ORDER BY list_price) "ntile"
FROM
	product.product

----------------------------------------------------------

--FORMAT function

SELECT
	list_price
FROM
	product.product

SELECT
	FORMAT(list_price, 'c') list_price
FROM
	product.product

SELECT FORMAT(GETDATE(), 'D') "date"

SELECT FORMAT(GETDATE(), 'd') "date"
------------------------------------------------------

SELECT
	*
FROM
	sale.customer
WHERE
	first_name LIKE '%an%'

SELECT
	*
FROM
	sale.customer
WHERE
	first_name LIKE N'%an%'--We use national character, namely N, because it gets unicode character

SELECT 'yağız'

SELECT '😀' 

SELECT N'😀' 