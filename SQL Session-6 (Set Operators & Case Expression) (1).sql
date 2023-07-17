
---SQL SESSION-7, 17.07.2023, (Set Operators & CASE Expression)


---*******SET OPERATIONS*******---
---////////////////////////////---


---UNION / UNION ALL-------------------------------------------------

---QUESTION: List the products sold in the cities of Charlotte and Aurora
---(Charlotte ve Aurora þehirlerinde satýlan ürünleri listeleyin)


SELECT
	product_name
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON c.order_id = b.order_id
	INNER JOIN product.product AS d ON d.product_id = c.product_id
WHERE
	a.city IN ('Charlotte' )
UNION
SELECT
	product_name
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON c.order_id = b.order_id
	INNER JOIN product.product AS d ON d.product_id = c.product_id
WHERE
	a.city IN ('Aurora')

----------------------------------
-------UNION ALL

SELECT
	product_name
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON c.order_id = b.order_id
	INNER JOIN product.product AS d ON d.product_id = c.product_id
WHERE
	a.city IN ('Charlotte' )
UNION ALL
SELECT
	product_name
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON c.order_id = b.order_id
	INNER JOIN product.product AS d ON d.product_id = c.product_id
WHERE
	a.city IN ('Aurora')



---UNION ALL/UNION vs IN 


SELECT
	DISTINCT product_name
FROM
	sale.customer AS a
	INNER JOIN sale.orders AS b ON b.customer_id = a.customer_id
	INNER JOIN sale.order_item AS c ON c.order_id = b.order_id
	INNER JOIN product.product AS d ON d.product_id = c.product_id
WHERE
	a.city IN ('Charlotte' , 'Aurora')






---SOME IMPORTANT RULES OF UNION / UNION ALL
---Even if the contents of to be unified columns are different, the data type must be the same.
---NOT: Sütunlarýn içeriði farklý da olsa veritipinin ayný olmasý yeterlidir.

SELECT
	brand_id
FROM
	product.brand
UNION ALL
SELECT
	category_id
FROM
	product.category

---When both column  is equal data types, we can convert them.





---The number of columns to be unified must be the same in both queries.
---Her iki sorguda da ayný sayýda column olmasý lazým.



SELECT
	*
FROM
	product.brand
UNION ALL
SELECT
	*
FROM 
	product.category





---other database


SELECT
	*
FROM
	employees_A
UNION
SELECT
	*
FROM
	employees_B



---QUESTION: Write a query that returns all customers whose first or last name is Thomas.  
---(don't use 'OR')
SELECT
	first_name,
	last_name
FROM
	sale.customer
WHERE 
	first_name = 'Thomas'
UNION
SELECT
	first_name,
	last_name
FROM
	sale.customer
WHERE 
	last_name = 'Thomas'
 


---INTERSECT-------------------------------------------------

---QUESTION: Write a query that returns all brands with products for both 2018 and 2020 model year.


SELECT
	a.brand_id,
	a.brand_name
FROM
	product.brand AS a
	INNER JOIN product.product AS b ON b.brand_id = a.brand_id
WHERE
	b.model_year = 2018
INTERSECT
SELECT
	a.brand_id,
	a.brand_name
FROM
	product.brand AS a
	INNER JOIN product.product AS b ON b.brand_id = a.brand_id
WHERE
	b.model_year = 2020


---QUESTION: Write a query that returns the first and the last names of the customers who placed orders in all of 2018, 2019, and 2020.

SELECT
	customer_id
FROM
	sale.orders
WHERE 
	YEAR(order_date) = 2018
INTERSECT
SELECT
	customer_id
FROM
	sale.orders
WHERE 
	YEAR(order_date) = 2019
INTERSECT
SELECT
	customer_id
FROM
	sale.orders
WHERE 
	YEAR(order_date) = 2020



SELECT
	first_name,
	last_name
FROM
	sale.customer
WHERE customer_id IN(
SELECT
	customer_id
FROM
	sale.orders
WHERE 
	YEAR(order_date) = 2018
INTERSECT
SELECT
	customer_id
FROM
	sale.orders
WHERE 
	YEAR(order_date) = 2019
INTERSECT
SELECT
	customer_id
FROM
	sale.orders
WHERE 
	YEAR(order_date) = 2020
)




---EXCEPT-------------------------------------------------

---QUESTION: Write a query that returns the brands have 2018 model products but not 2019 model products.

SELECT
	b.brand_name,
	a.product_name
FROM
	product.product AS a
	INNER JOIN product.brand AS b ON b.brand_id = a.brand_id
WHERE
	a.model_year = 2018
EXCEPT
SELECT
	b.brand_name,
	a.product_name
FROM
	product.product AS a
	INNER JOIN product.brand AS b ON b.brand_id = a.brand_id
WHERE
	a.model_year = 2019

SELECT brand_id, brand_name
FROM product.brand
WHERE brand_id IN
              (
SELECT brand_id
FROM product.product
WHERE model_year=2018
EXCEPT
SELECT brand_id
FROM product.product
WHERE model_year=2019
                       );


----------------------------------
WITH T1 AS
(
SELECT brand_id
FROM product.product
WHERE model_year=2018
EXCEPT
SELECT brand_id
FROM product.product
WHERE model_year=2019
)
SELECT 
	T1.brand_id,
	brand_name
FROM	
	product.brand AS b, T1
WHERE
	b.brand_id = T1.brand_id






---QUESTION: Write a query that contains only products ordered in 2019 (The result should not include products ordered in other years)
---(Sadece 2019 yýlýnda sipariþ verilen diðer yýllarda sipariþ verilmeyen ürünleri getiriniz)



SELECT
	c.product_id,
	c.product_name
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON a.order_id = b.order_id
	INNER JOIN product.product AS c ON c.product_id = b.product_id
WHERE
	YEAR(a.order_date) = 2019
EXCEPT
SELECT
	c.product_id,
	c.product_name
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON a.order_id = b.order_id
	INNER JOIN product.product AS c ON c.product_id = b.product_id
WHERE
	YEAR(a.order_date) != 2019

--Except UNION ALL , set operators prodive unique conditional and they can not get dublicates value  .

---///////////////////////////////////////////////////////////////////////

---*******CASE EXPRESSION*******---
---////////////////////////////---


---Simple Case Expression-------------------------------------------------

---QUESTION: Create a new column with the meaning of the values in the Order_Status column. 
---(Order_Status isimli alandaki deðerlerin ne anlama geldiðini içeren yeni bir alan oluþturun)

---1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT 
	a.order_id,
	a.order_status,
	CASE a.order_status
		WHEN '1' THEN 'Pending'
		WHEN '2' THEN 'Processing'
		WHEN '3' THEN 'Rejected'
		ELSE 'Completed'
	END AS order_status_desc
FROM
	sale.orders AS a


---Searched Case Expression-------------------------------------------------

---QUESTION: Create a new column with the meaning of the values in the Order_Status column. 
---(use searched case expresion)

---1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed

SELECT 
	a.order_id,
	a.order_status,
	CASE 
		WHEN a.order_status = '1' THEN 'Pending'
		WHEN a.order_status= '2' THEN 'Processing'
		WHEN a.order_status = '3' THEN 'Rejected'
		ELSE 'Completed'
	END AS order_status_desc
FROM
	sale.orders AS a



---QUESTION: Create a new column that shows which email service provider ("Gmail", "Hotmail", "Yahoo" or "Other" ).
---(Müþterilerin e-mail adreslerindeki servis saðlayýcýlarýný yeni bir sütun oluþturarak belirtiniz)

SELECT
	a.first_name,
	a.last_name,
	a.email,
	CASE 
		WHEN a.email LIKE '%gmail%' THEN 'Gmail'
		WHEN a.email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN a.email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN a.email IS NOT NULL THEN 'Other' --for not null values , we created other as alias
	END AS email_service_provider
FROM	
	sale.customer AS a

SELECT
	*
FROM
	sale.customer 
WHERE
	email IS NULL

--------------------------------------------
--WITH BUILT-IN FUNCTIONS
SELECT
	a.first_name,
	a.last_name,
	a.email,
	LEN(CASE 
		WHEN a.email LIKE '%gmail%' THEN 'Gmail'
		WHEN a.email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN a.email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN a.email IS NOT NULL THEN 'Other' --for not null values , we created other as alias
	END ) AS email_service_provider
FROM	
	sale.customer AS a
-----------------------------------------
---WITH GROUP BY 
SELECT
	COUNT(customer_id)
FROM	
	sale.customer AS a
GROUP BY
	CASE 
		WHEN a.email LIKE '%gmail%' THEN 'Gmail'
		WHEN a.email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN a.email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN a.email IS NOT NULL THEN 'Other' --for not null values , we created other as alias
	END



---QUESTION: Write a query that gives the first and last names of customers who have ordered products from the computer accessories, speakers, and mp4 player categories in the same order.

SELECT
	DISTINCT c.category_id,
	c.product_name
	
FROM
	sale.orders AS a
	INNER JOIN sale.order_item AS b ON b.order_id = a.order_id
	INNER JOIN product.product AS c ON c.product_id = b.product_id
WHERE
	c.product_name = '%computer accessories%'


SELECT
	cus.customer_id,
	first_name,
	last_name,
	o.order_id,
	SUM(CASE WHEN category_name = 'Computer Accessories' THEN 1 ELSE 0 END) AS ca,
	SUM(CASE WHEN category_name = 'Speakers' THEN 1 ELSE 0 END) AS sp,
	SUM(CASE WHEN category_name = 'mp4 player' THEN 1 ELSE 0 END) AS mp4

FROM
	sale.customer AS cus
	INNER JOIN sale.orders AS o ON cus.customer_id = o.customer_id
	INNER JOIN sale.order_item AS oi ON o.order_id = oi.order_id
	INNER JOIN product.product AS p ON oi.product_id = p.product_id
	INNER JOIN product.category c ON p.category_id = c.category_id
GROUP BY
	cus.customer_id,
	first_name,
	last_name,
	o.order_id

;WITH cte AS(---if you dont want to take a warning, you must do ;
SELECT
	cus.customer_id,
	first_name,
	last_name,
	o.order_id,
	SUM(CASE WHEN category_name = 'Computer Accessories' THEN 1 ELSE 0 END) AS ca,
	SUM(CASE WHEN category_name = 'Speakers' THEN 1 ELSE 0 END) AS sp,
	SUM(CASE WHEN category_name = 'mp4 player' THEN 1 ELSE 0 END) AS mp4

FROM
	sale.customer AS cus
	INNER JOIN sale.orders AS o ON cus.customer_id = o.customer_id
	INNER JOIN sale.order_item AS oi ON o.order_id = oi.order_id
	INNER JOIN product.product AS p ON oi.product_id = p.product_id
	INNER JOIN product.category c ON p.category_id = c.category_id
GROUP BY
	cus.customer_id,
	first_name,
	last_name,
	o.order_id
)
SELECT 
	*
FROM
	cte
WHERE
	ca != 0 AND sp != 0 AND mp4 != 0 --- !=0 or >0

----------------------------------------------
SELECT
	*
FROM(
SELECT
	cus.customer_id,
	first_name,
	last_name,
	o.order_id,
	SUM(CASE WHEN category_name = 'Computer Accessories' THEN 1 ELSE 0 END) AS ca,
	SUM(CASE WHEN category_name = 'Speakers' THEN 1 ELSE 0 END) AS sp,
	SUM(CASE WHEN category_name = 'mp4 player' THEN 1 ELSE 0 END) AS mp4

FROM
	sale.customer AS cus
	INNER JOIN sale.orders AS o ON cus.customer_id = o.customer_id
	INNER JOIN sale.order_item AS oi ON o.order_id = oi.order_id
	INNER JOIN product.product AS p ON oi.product_id = p.product_id
	INNER JOIN product.category c ON p.category_id = c.category_id
GROUP BY
	cus.customer_id,
	first_name,
	last_name,
	o.order_id
) AS subq -- you have give to subquery a alias within from statements .
WHERE
	ca > 0 AND sp > 0 AND mp4 > 0



---QUESTION: Write a query that returns the count of the orders day by day in a pivot table format that has been shipped two days later.
---(2 günden geç kargolanan sipariþlerin haftanýn günlerine göre daðýlýmýný hesaplayýnýz)

SELECT
	*
FROM
	sale.orders AS a
WHERE
	DATEDIFF(DAY, a.order_date, a.shipped_date) > 2

SELECT
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Monday' THEN 1 ELSE 0 END) AS Monday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Tuesday' THEN 1 ELSE 0 END) AS Tuesday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Wednesday' THEN 1 ELSE 0 END) AS Wednesday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Thursday' THEN 1 ELSE 0 END) AS Thursday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Friday' THEN 1 ELSE 0 END) AS Friday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Saturday' THEN 1 ELSE 0 END) AS Saturday,
	SUM(CASE WHEN DATENAME(DW, order_date) = 'Sunday' THEN 1 ELSE 0 END) AS Sunday
FROM
	sale.orders AS a
WHERE
	DATEDIFF(DAY, a.order_date, a.shipped_date) > 2

---another solution

---WITH GROUP BY 
SELECT
	CASE
		WHEN DATENAME(DW, order_date) = 'Monday' THEN 'Monday'
		WHEN DATENAME(DW, order_date) = 'Tuesday' THEN 'Tuesday'
		WHEN DATENAME(DW, order_date) = 'Wednesday' THEN 'Wednesday'
		WHEN DATENAME(DW, order_date) = 'Thursday' THEN 'Thursday'
		WHEN DATENAME(DW, order_date) = 'Friday' THEN 'Friday'
		WHEN DATENAME(DW, order_date) = 'Saturday' THEN 'Saturday'
		WHEN DATENAME(DW, order_date) = 'Sunday' THEN 'Sunday'
	END AS [Day] ,
	COUNT(a.order_id) AS count_of_days
FROM
	sale.orders AS a
WHERE
	DATEDIFF(DAY, a.order_date, a.shipped_date) > 2
GROUP BY
	CASE
		WHEN DATENAME(DW, order_date) = 'Monday' THEN 'Monday'
		WHEN DATENAME(DW, order_date) = 'Tuesday' THEN 'Tuesday'
		WHEN DATENAME(DW, order_date) = 'Wednesday' THEN 'Wednesday'
		WHEN DATENAME(DW, order_date) = 'Thursday' THEN 'Thursday'
		WHEN DATENAME(DW, order_date) = 'Friday' THEN 'Friday'
		WHEN DATENAME(DW, order_date) = 'Saturday' THEN 'Saturday'
		WHEN DATENAME(DW, order_date) = 'Sunday' THEN 'Sunday'
	END 



SELECT
	COUNT(customer_id)
FROM	
	sale.customer AS a
GROUP BY
	CASE 
		WHEN a.email LIKE '%gmail%' THEN 'Gmail'
		WHEN a.email LIKE '%hotmail%' THEN 'Hotmail'
		WHEN a.email LIKE '%yahoo%' THEN 'Yahoo'
		WHEN a.email IS NOT NULL THEN 'Other' --for not null values , we created other as alias
	END
