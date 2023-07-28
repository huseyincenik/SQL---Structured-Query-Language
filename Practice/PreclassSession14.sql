SELECT customer_id, city FROM sale.customer WHERE city = 'Allen';

ALTER INDEX ix_customers_city ON sale.customer(city) DISABLE;

ALTER INDEX PK__customer__CD65CB8531DF4FEC ON sale.customer REBUILD;


--CREATE UNIQUE INDEX index_name ON table_name(column_list);

--ALTER INDEX ALL ON sale.customer DISABLE; WARNING!!!!!

SELECT
	COUNT(DISTINCT  email)
FROM
	sale.customer

SELECT  COUNT(DISTINCT email), COUNT(customer_id) FROM sale.customer

SELECT
		first_name,
		last_name,
		email
FROM
	sale.customer
GROUP BY first_name,
		last_name,
		email		
HAVING COUNT(email) > 1

SELECT
	*
FROM
	sale.customer