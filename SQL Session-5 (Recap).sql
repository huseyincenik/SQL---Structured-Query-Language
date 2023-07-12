
-- SQL Session-6, RECAP, 12.07.2023
--------------------------------------------

--QUESTION-1
--Find the number of orders made by employee number 6 between '2018-01-04' and '2019-01-04'

--- documantation --https://learn.microsoft.com/en-us/sql/sql-server/?view=sql-server-ver15
SELECT
	COUNT(order_id) AS number_of_orders
FROM
	sale.orders AS a
WHERE
	a.staff_id = 6 
	AND a.order_date BETWEEN '2018-01-04' and '2019-01-04'






--QUESTION-2
--Report the number of orders made by each employee in store number 1 
--between '2018-01-04' and '2019-01-04'

SELECT
	staff_id,
	COUNT(order_id) cnt_order
FROM
	sale.orders AS a
WHERE
	a.store_id = 1
	AND order_date BETWEEN '2018.01.04' and '2019.01.04'
GROUP BY
	staff_id



--QUESTION-3
--Report the daily number of orders made by the employees in store number 1
--between '2018-01-04' and '2018-02-04'

SELECT
	a.staff_id,
	a.order_date,
	COUNT(a.order_id) AS cnt_order
FROM
	sale.orders AS a
WHERE
	a.store_id = 1
	AND order_date BETWEEN '2018.01.04' and '2018.02.04'
GROUP BY
	a.staff_id,
	a.order_date
ORDER BY
	1;




--QUESTION-4
--Find the store with the highest number of unshipped orders.

SELECT
	a.store_id
FROM
	sale.orders AS a
GROUP BY
	a.store_id
WHERE
	a.shipped_date IS NULL
--solution
SELECT
	TOP 1 store_id, --I CAN USE "WITH TIES", "PERCENT" FOR TOP 1
	COUNT(order_id) AS cnt_order
FROM
	sale.orders
WHERE
	shipped_date IS NULL
GROUP BY
	store_id
ORDER BY
	cnt_order DESC

---
SELECT TOP 10 PERCENT *-- 10%
FROM product.product


--QUESTION-5
--Find the distribution of the number of customers who placed orders before 2020 by stores.

SELECT
	a.store_id,
	COUNT(customer_id) AS cnt_order
FROM
	sale.orders AS a
WHERE
	DATEPART(YEAR, a.order_date) < 2021 --YEAR(order_date)
GROUP BY
	a.store_id


--QUESTION-6
--Find the employee with the lowest performance in the second quarter of 2020.

SELECT
	TOP 1 a.staff_id,
	COUNT(order_id) AS num_of_orders
FROM
	sale.orders AS a
WHERE 
	YEAR(a.order_date) = 2020
	AND DATEPART(QQ, a.order_date) = 2 --Q or QQ
GROUP BY
	a.staff_id
ORDER BY
	num_of_orders


-------------

SELECT
	TOP 1 a.staff_id,
	COUNT(order_id) AS num_of_orders
FROM
	sale.orders AS a
WHERE 
	a.order_date LIKE '2020-0[4-6]-%'
GROUP BY
	a.staff_id
ORDER BY
	num_of_orders


--QUESTION-7
--Find the product with the least profit.


SELECT
	TOP 1 a.product_id,
	SUM(quantity*list_price*(1 - discount)) AS total_income
FROM
	sale.order_item AS a
GROUP BY
	a.product_id
ORDER BY
	2



--QUESTION-8
--Find the store with the highest turnover in the 4th, 5th and 6th months of 2018.


SELECT
	a.store_name,
	SUM(quantity*list_price*(1 - discount)) AS total_income
FROM
	sale.store AS a,
	sale.orders AS b,
	sale.order_item AS c
WHERE a.store_id = b.store_id AND b.order_id = c.order_id AND 	b.order_date LIKE '2018-0[4-6]-%'
GROUP BY
	a.store_name
ORDER BY
	total_income DESC



--QUESTION-9
--Report the weekly sales performance of the employees for the 4th month of 2020.

SELECT
	first_name, last_name,
	DATEPART(ISOWK, order_date) AS ord_week,
	SUM(quantity) AS total_quantity,
	COUNT(a.order_id) AS total_order,
	SUM(quantity*list_price*(1 - discount)) AS total_sales
FROM
	sale.orders a
	INNER JOIN sale.order_item b ON a.order_id = b.order_id
	INNER JOIN sale.staff c ON a.staff_id = c.staff_id
WHERE YEAR(order_date) = 2020 AND MONTH(order_date) = 4
GROUP BY
	first_name, last_name,
	DATEPART(ISOWK, order_date)--What is difference between week and isowk ? week calculates different than isowk

SELECT DATEPART(w, '2018-01-01')
SELECT DATEPART(isowK, '2018-01-01')
SELECT DATENAME(DW, '2018-01-01')