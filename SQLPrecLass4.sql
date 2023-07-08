-- We use COUNT function to count the numbers of records (a.k.a row) in a table.


SELECT * 
FROM sale.orders;


SELECT COUNT(store_id) 
FROM sale.orders;

SELECT COUNT(*) 
FROM sale.orders;

-- An important point for COUNT(*) function is that the result table includes NULL and duplicate values.
SELECT COUNT(*)
FROM sale.orders AS A
WHERE A.store_id = '1';

--If you want the number of non-null values, use the syntax COUNT(column_name).
SELECT COUNT(store_id)
FROM sale.orders AS A
WHERE A.store_id = '1';

--If you notice that the header of the output query is displayed as COUNT(name). However, we can customize the header using AS keyword

SELECT COUNT(store_id) AS num_of_store_id_1
FROM sale.orders AS A
WHERE A.store_id = '1';

SELECT COUNT(DISTINCT store_id) AS num_of_store_id_1
FROM sale.orders AS A
--WHERE A.store_id = '1';

SELECT COUNT(*) AS num_of_null_shipped_date
FROM sale.orders AS A
WHERE A.shipped_date IS NULL;

--MIN function returns the minimum value in the selected column.

SELECT MIN(list_price) AS min_price
FROM product.product


-- Date Data Types

SELECT GETDATE() AS now;

SELECT DATENAME(WEEKDAY, GETDATE()) AS 'DAY'

SELECT DATENAME(DAY, GETDATE()) 

SELECT DATENAME(MONTH, GETDATE())

SELECT DATEPART(DAY, GETDATE())

SELECT DATEPART(DAYOFYEAR , GETDATE()) AS 'DAY_OF_YEAR'

SELECT DATEPART(DAY, GETDATE())

SELECT DAY('2021-07-22')

SELECT YEAR('2021-07-22')

SELECT MONTH('2021-07-22')

SELECT DATEDIFF(DAY, '2021-07-22', GETDATE())

SELECT DATEADD(DAY , 15, GETDATE()) AS Deadline

SELECT CONVERT(DATE, DATEADD(DAY , 15, GETDATE())) AS Deadline --convert tarihleri aliyor . 

SELECT CONVERT(DATE, DATEADD(MONTH , 15, GETDATE())) AS Deadline

SELECT *
FROM sale.orders

SELECT DATENAME(WEEKDAY , order_date) AS Day_Order, DATENAME(WEEKDAY, shipped_date) AS Day_shipped
FROM sale.orders

SELECT DATEDIFF(DAY , order_date, shipped_date) AS Duration
FROM sale.orders

SELECT DATEDIFF(DAY , order_date, shipped_date) AS Duration
FROM sale.orders
WHERE Duration = '0' -- ??

SELECT DATEADD(DAY , 90, order_date) AS Deadline
FROM sale.orders

-- String Functions
-- LEN

SELECT LEN('Lenovo')

SELECT LEN(' Le No Vo')

SELECT LEN('NULL')

SELECT LEN(0)

SELECT *
FROM sale.customer

SELECT LEN(first_name)
FROM sale.customer
WHERE sale.customer.email = '%msn%';


-- CHARINDEX

SELECT CHARINDEX('@', email)
FROM sale.customer

-- PATINDEX

SELECT PATINDEX('%@msn%', email)
FROM sale.customer

-- UPPER LOWER

SELECT UPPER('bar')

SELECT LOWER('BaR') AS 'lower'

SELECT LOWER(email)
FROM sale.customer

SELECT string_split(email, '@')
FROM sale.customer

SELECT *
FROM STRING_SPLIT(sale.customer.email, '@')

SELECT 
FROM STRING_SPLIT(email, '@')
FROM sale.customer

SELECT value
FROM sale.customer
CROSS APPLY STRING_SPLIT(email, '@')

SELECT SUBSTRING(email, CHARINDEX('@', email) + 1 , LEN(email)) AS after_at
FROM sale.customer

SELECT SUBSTRING(email, 1, CHARINDEX('@', email) - 1) AS before_at
FROM sale.customer


SELECT * FROM STRING_SPLIT('ali, veli, deli', ',')

SELECT 
    SUBSTRING(email, 1, CHARINDEX('@', email) - 1) AS email_username,
    SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email)) AS email_domain
FROM 
    sale.customer;


SELECT VALUE FROM STRING_SPLIT('bar, mer, hel, cer', ',')

SELECT *
FROM STRING_SPLIT('bar, mer, hel, cer', ',')

-- Substring

SELECT SUBSTRING('Clarusway', 1, 3)

SELECT SUBSTRING('Clarusway', -1, 3)

SELECT SUBSTRING('Clarusway', -1, 10)

SELECT SUBSTRING('Clarusway', -1, 11)

SELECT LEFT('Clarusway', 2)

SELECT RIGHT('Clarusway', 4)

SELECT RIGHT('Clarusway', 1)

SELECT TRIM('. ' FROM '...   le no vo .')

SELECT TRIM('. ' FROM '. LEN .ovo . ')

SELECT RTRIM('. ' FROM '. LEN .ovo . ')

SELECT RTRIM('. ' FROM '. LEN .ovo . ') AS result

SELECT LTRIM( '. LEN .ovo . ')

SELECT RTRIM('. ' + '. LEN .ovo . ') AS result

-- Replace

SELECT REPLACE('REIMVENT', 'M', 'N')

SELECT REPLACE(email, '@', '-')
FROM sale.customer

 -- STR
 SELECT STR(123.45, 6, 2) 

 -- NUMBER, LEN , DECIMAL

 SELECT FLOOR (123.45) AS num_to_str

 SELECT STR(FLOOR (123.45), 8, 3) AS num_to_str;

 -- CONCAT

 SELECT CONCAT('ROBERT' , ' ', 'GILBERT')

 SELECT RTRIM('ROBERT' + ' '+ 'GILBERT')

 SELECT TRIM(' ROBERT ' + ' '+ ' GILBERT ')

 SELECT 'ROBERT' + ' ' + 'GILBERT'

 SELECT CONCAT(first_name, ' ', last_name)
 FROM sale.customer

 SELECT 
    SUBSTRING(email, 1, CHARINDEX('@', email) - 1) AS email_username,
    SUBSTRING(email, CHARINDEX('@', email) + 1, LEN(email)) AS email_domain
FROM 
    sale.customer;

-- Other Functions

-- CAST

SELECT CAST(4599.9999 AS numeric( 9 , 4)) AS col


SELECT CAST(99.1011 AS numeric(3,1)) AS col

-- VARCHAR

SELECT 'customer' + '_' + CAST(1 AS varchar(1)) AS col


SELECT 'customer' + '_' + CAST(2134 AS varchar(4)) AS col -- 4 , HANE SAYISI


SELECT CONVERT(DATE, GETDATE())

SELECT CONVERT(varchar(4), GETDATE(), yyyy) AS year

SELECT CONVERT(varchar(4), GETDATE(), 120) AS year

SELECT CONVERT(varchar(7), GETDATE(), 120) AS year

SELECT MONTH(GETDATE()) AS month

SELECT DAY(GETDATE()) AS day

SELECT YEAR(GETDATE()) AS day

-- ROUND

SELECT ROUND(565.59, 2)

SELECT ROUND(123.4545, 2) col1, ROUND(123.45, -2) AS col2;

SELECT ROUND(123.4545, 2) col1, ROUND(123.45, -3) AS col2;

SELECT ROUND(123.4545, 2) col1, ROUND(699.45, -2) AS col2;


SELECT CAST(ROUND(565.59, 2) AS INT)


SELECT CAST(ROUND(123.4545, 2) AS INT) AS col1,
       CAST(ROUND(123.45, -2) AS INT) AS col2;


SELECT FLOOR(123.4545) AS col1,
       CEILING(123.45) AS col2;


SELECT ISNULL(NULL, 'Not null yet.') AS col;

