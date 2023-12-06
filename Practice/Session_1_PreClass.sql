SELECT *
FROM sale.staff;

SELECT A.first_name, A.email
FROM sale.staff as A;

SELECT A.staff_id, A.first_name, A.email
FROM sale.staff AS A
WHERE A.first_name = 'Davis';

SELECT top(5) *
FROM sale.order_item;

SELECT*
FROM sale.customer;

SELECT A.city
FROM sale.customer AS A;

SELECT DISTINCT A.city
FROM sale.customer AS A;

-- ORDER BY ASC is default

SELECT*
FROM sale.order_item
ORDER BY order_item.list_price;

SELECT *
FROM sale.order_item
ORDER BY order_item.list_price ASC;

SELECT *
FROM sale.order_item
ORDER BY order_item.list_price DESC;

SELECT *
FROM sale.customer
ORDER BY customer.first_name ASC, customer.last_name ASC;

SELECT *
FROM sale.customer
WHERE sale.customer.state = 'MA'
ORDER BY customer.first_name ASC;


SELECT *
FROM sale.customer
WHERE sale.customer.state = 'MA'
ORDER BY customer.first_name ASC, customer.last_name ASC;

--WHERE
SELECT item.product_id, item.list_price
FROM sale.order_item AS item
WHERE item.list_price >= 200
ORDER BY item.list_price;

-- BETWEEN
SELECT item.product_id, item.list_price
FROM sale.order_item AS item
WHERE item.list_price BETWEEN 200 AND 230
ORDER BY item.list_price;

-- BETWEEN
SELECT item.product_id, item.list_price
FROM sale.order_item AS item
WHERE item.list_price >= 200 AND item.list_price < = 230
ORDER BY item.list_price;

-- BETWEEN
SELECT item.product_id, item.list_price
FROM sale.order_item AS item
WHERE item.list_price NOT BETWEEN 200 AND 230
ORDER BY item.list_price;

-- IN 
SELECT staff.first_name, staff.last_name
FROM sale.staff AS staff
WHERE staff.first_name = 'Barbara'
OR
staff.first_name = 'Taylor'
OR
staff.first_name = 'Linda'
ORDER BY staff.first_name;

SELECT staff.first_name, staff.last_name
FROM sale.staff AS staff
WHERE staff.first_name IN ('Barbara', 'Taylor', 'Linda')
ORDER BY staff.first_name;

SELECT staff.first_name, staff.last_name
FROM sale.staff AS staff
WHERE staff.first_name NOT IN ('Barbara', 'Taylor', 'Linda')
ORDER BY staff.first_name;


-- LIKE

SELECT customer.first_name, customer.last_name
FROM sale.customer AS customer
WHERE customer.first_name LIKE 't%' AND customer.first_name IN ('Barbara', 'Taylor', 'Linda')
ORDER BY customer.first_name;
-- any value that starts with t

SELECT customer.first_name, customer.last_name
FROM sale.customer AS customer
WHERE customer.first_name LIKE '%z' 
ORDER BY customer.first_name;
-- any value that starts with t

SELECT customer.first_name, customer.last_name
FROM sale.customer AS customer
WHERE customer.first_name LIKE '%ald%' 
ORDER BY customer.first_name;
-- any value that starts with t

SELECT customer.first_name, customer.last_name
FROM sale.customer AS customer
WHERE customer.first_name LIKE '_e%' 
ORDER BY customer.first_name;

SELECT customer.first_name, customer.last_name
FROM sale.customer AS customer
WHERE customer.first_name LIKE 't%y' 
ORDER BY customer.first_name;

SELECT customer.first_name, customer.last_name
FROM sale.customer AS customer
WHERE customer.first_name LIKE 't_m' 
ORDER BY customer.first_name;

-- AND

SELECT item.product_id, item.list_price
FROM sale.order_item AS item
WHERE item.list_price >= 200 AND item.list_price < = 230
ORDER BY item.list_price;

SELECT *
FROM sale.customer AS customer
WHERE customer.street LIKE '%Dorigo' AND customer.city = 'Birmingham';

SELECT stock.product_id, stock.quantity, stock.store_id
FROM product.stock AS stock
WHERE stock.quantity = 0 AND stock.store_id = '2'
ORDER BY stock.product_id;

--OR
SELECT stock.product_id, stock.quantity, stock.store_id
FROM product.stock AS stock
WHERE stock.quantity = 0 OR stock.store_id = '1'
ORDER BY stock.product_id;

--NOT
SELECT stock.product_id, stock.quantity, stock.store_id
FROM product.stock AS stock
WHERE stock.quantity = 0
ORDER BY stock.quantity;

-- BETWEEN with Date Example
SELECT *
FROM sale.orders as orders
WHERE orders.shipped_date BETWEEN orders.order_date AND orders.shipped_date
ORDER BY orders.order_date;

SELECT *
FROM sale.orders as orders
WHERE orders.shipped_date BETWEEN '2020-03-20' AND '2020-04-20' 
ORDER BY orders.order_date;

SELECT *
FROM sale.orders as orders
WHERE orders.shipped_date BETWEEN orders.order_date AND orders.required_date
ORDER BY orders.order_date;

SELECT COUNT(*)
FROM sale.customer;

SELECT COUNT(*) as number_of_orders
FROM sale.orders;

SELECT *
FROM product.product;

SELECT SUM(list_price) as Total_Revenue
FROM product.product;

SELECT AVG(list_price) as Average_Price
FROM product.product;

SELECT COUNT(DISTINCT brand_id) AS Number_of_Brands
FROM product.product;

SELECT MIN(list_price) as Min_Price
FROM product.product;

SELECT MIN(list_price) as Min_Price
FROM product.product;


SELECT MAX(list_price) as Max_Price
FROM product.product
where product_name like '%samsung%';

SELECT *
FROM product.product
where product_name like '%samsung%';


SELECT AVG(list_price) as AVG_Price_SMSNG
FROM product.product
where product_name like '%samsung%'
GROUP BY brand_id;

SELECT SUM(list_price) as SUM_Price_SMSNG
FROM product.product
where product_name like '%samsung%';

SELECT SUM(list_price)
FROM product.product
GROUP BY category_id;

SELECT SUM(list_price) AS sum_price
FROM product.product
GROUP BY category_id
ORDER BY sum_price DESC

SELECT AVG(list_price) AS AVG_price
FROM product.product
GROUP BY category_id
ORDER BY AVG_price DESC


