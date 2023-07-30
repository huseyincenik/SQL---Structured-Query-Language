---STEP BY STEP NORMALIZATION (1NF, 2NF, 3NF respectively)


USE ornek;


--1
ALTER TABLE [dbo].[e_commerce_data_1]
ADD first_name VARCHAR(100),
	last_name VARCHAR(100);
--2
UPDATE [dbo].e_commerce_data_1
SET first_name = SUBSTRING(Customer_Name, 1 , CHARINDEX(' ', Customer_Name) - 1),
	last_name = SUBSTRING(Customer_Name, CHARINDEX(' ', Customer_Name) + 1, LEN(Customer_Name) - CHARINDEX(' ', Customer_Name));

--------
SELECT
	*
FROM
	e_commerce_data_1

---customer_name drop

ALTER TABLE [dbo].[e_commerce_data_1]
DROP COLUMN Customer_Name;

SELECT
	*
FROM
	e_commerce_data_1

---ord_id, cust_id, prod_id, ship_id update 
SELECT
	TOP 1000 *,
	SUBSTRING(Ord_ID, CHARINDEX('_', Ord_ID) + 1 , LEN(Ord_ID)),
	SUBSTRING(Cust_ID, CHARINDEX('_', Cust_ID) + 1 , LEN(Cust_ID)),
	SUBSTRING(Prod_ID, CHARINDEX('_', Prod_ID) + 1 , LEN(Prod_ID)),
	SUBSTRING(Ship_ID, CHARINDEX('_', Ship_ID) + 1 , LEN(Ship_ID))
FROM
	[dbo].[e_commerce_data_1]

ORDER BY
	Ord_ID

--update 

UPDATE [dbo].e_commerce_data_1
SET Ord_ID = SUBSTRING(Ord_ID, CHARINDEX('_', Ord_ID) + 1 , LEN(Ord_ID)),
	Cust_ID = SUBSTRING(Cust_ID, CHARINDEX('_', Cust_ID) + 1 , LEN(Cust_ID)),
	Prod_ID = SUBSTRING(Prod_ID, CHARINDEX('_', Prod_ID) + 1 , LEN(Prod_ID)),
	Ship_ID = SUBSTRING(Ship_ID, CHARINDEX('_', Ship_ID) + 1 , LEN(Ship_ID));

--control

SELECT
	TOP 10 *
FROM
	e_commerce_data_1

-- create schemas
go
CREATE SCHEMA [order];
go

CREATE SCHEMA [customer];
go


---create table

CREATE TABLE order_table

SELECT
	DISTINCT Cust_ID AS cust_id, first_name, last_name,Province AS province,Region AS region,Customer_Segment customer_segment 
	INTO customer.customer_table
FROM
	e_commerce_data_1

SELECT
	*
FROM
	customer.customer_table
---cust_id data type convert
ALTER TABLE customer.customer_table
ALTER COLUMN cust_id INT NOT NULL

ALTER TABLE customer.customer_table 
ADD CONSTRAINT pk_customer PRIMARY KEY(cust_id)


SELECT
	*
FROM
	customer.customer_table

-------------order_table
SELECT
	DISTINCT Ord_ID AS ord_id, Cust_ID AS cust_id, Order_Date AS order_date , Order_Priority AS order_priority , Ship_ID AS ship_id 
	INTO [order].[order_table]
FROM	
	e_commerce_data_1

SELECT
	*
FROM
	[order].order_table

ALTER TABLE [order].order_table
ALTER COLUMN ord_id INT NOT NULL

ALTER TABLE [order].order_table
ALTER COLUMN cust_id INT NOT NULL

ALTER TABLE [order].order_table
ALTER COLUMN ship_id INT NOT NULL

ALTER TABLE [order].order_table
ADD CONSTRAINT pk_order PRIMARY KEY(ord_id);
go
ALTER TABLE [order].order_table
ADD CONSTRAINT fk_order FOREIGN KEY(cust_id) REFERENCES customer.customer_table(cust_id);

----order_item table

SELECT
	Ord_ID AS ord_id,ROW_NUMBER() OVER(PARTITION BY Ord_ID ORDER BY Ord_ID) AS ord_item_id, 
	Prod_ID AS prod_id, Sales AS sales, Order_Quantity AS order_quantity
	INTO [order].order_item
	
FROM
	e_commerce_data_1

SELECT
	*
FROM
	[order].order_item

ALTER TABLE [order].order_item
ALTER COLUMN ord_id INT NOT NULL

ALTER TABLE [order].order_item
ALTER COLUMN ord_item_id INT NOT NULL

ALTER TABLE [order].order_item
ADD CONSTRAINT fk_order_item FOREIGN KEY(ord_id) REFERENCES [order].order_table(ord_id)

ALTER TABLE [order].order_item
ADD CONSTRAINT pk_order_item PRIMARY KEY(ord_id, ord_item_id) 

SELECT
	*
FROM
	customer.customer_table

SELECT
	*
FROM
	[order].order_table

-----order_priority_table
SELECT
	ROW_NUMBER() OVER(ORDER BY order_priority) AS order_priority_id, order_priority
	INTO [order].order_priority_table
FROM(
SELECT
	DISTINCT order_priority

FROM
	[order].order_table) AS subquery

ALTER TABLE [order].order_priority_table
ALTER COLUMN order_priority_id INT NOT NULL

ALTER TABLE [order].order_priority_table
ADD CONSTRAINT pk_order_priority PRIMARY KEY(order_priority_id) 

SELECT
	*
FROM
	[order].order_priority_table

---recoding

---column name change
EXEC sp_rename '[order].order_table.order_priority' , 'order_priority_id' , 'COLUMN'

SELECT
	*
FROM
	[order].order_table
GO

UPDATE [order].order_table
SET order_priority_id = B.order_priority_id
FROM
	[order].order_table AS A,
	[order].order_priority_table AS B
WHERE
	A.order_priority_id = B.order_priority

SELECT
	*
FROM
	[order].order_table

ALTER TABLE [order].order_table
ALTER COLUMN order_priority_id INT NOT NULL

ALTER TABLE [order].order_table
ADD CONSTRAINT fk_order_priority_id FOREIGN KEY (order_priority_id) REFERENCES [order].order_priority_table(order_priority_id)

--create ship table

SELECT
	DISTINCT Ship_ID AS ship_id, Ship_Date AS ship_date ,DaysTakenForShipping AS days_taken_for_shipping
	INTO customer.ship_table
FROM
	e_commerce_data_1

SELECT
	*
FROM
	customer.ship_table

--make primary key to ship_id
ALTER TABLE customer.ship_table
ALTER COLUMN ship_id INT NOT NULL

ALTER TABLE customer.ship_table
ADD CONSTRAINT pk_ship_table PRIMARY KEY(ship_id)

SELECT
	*
FROM
	customer.ship_table

--make foreign key to ship id in order.order_table
GO
ALTER TABLE [order].order_table
ADD CONSTRAINT fk_order_ship_id FOREIGN KEY(ship_id) REFERENCES customer.ship_table(ship_id);


--province_table

SELECT
	ROW_NUMBER() OVER (ORDER BY province) AS province_id , province
	INTO customer.province_table

FROM(
	SELECT	
		DISTINCT province
	FROM
		customer.customer_table
) AS subquery


ALTER TABLE customer.province_table
ALTER COLUMN  province_id INT NOT NULL

ALTER TABLE customer.province_table
ADD CONSTRAINT pk_province_table PRIMARY KEY(province_id)

SELECT
	*
FROM
	customer.province_table
--recoding

EXEC sp_rename 'customer.customer_table.province' , 'province_id' , 'COLUMN'

SELECT
	*
FROM
	customer.customer_table

GO

UPDATE customer.customer_table
SET province_id = B.province_id
FROM
	customer.customer_table AS A,
	customer.province_table AS B
WHERE
	A.province_id = B.province
GO
SELECT
	*
FROM
	customer.customer_table

ALTER TABLE customer.customer_table
ALTER COLUMN province_id INT NOT NULL

ALTER TABLE customer.customer_table
ADD CONSTRAINT fk_customer_province FOREIGN KEY(province_id) REFERENCES customer.province_table(province_id)

--region_table
SELECT
	ROW_NUMBER() OVER(ORDER BY region) AS region_id, region
	INTO customer.region_table
FROM
(
	SELECT 
		DISTINCT region
	FROM
		customer.customer_table

) AS subquery

ALTER TABLE customer.region_table 
ALTER COLUMN region_id INT NOT NULL

ALTER TABLE customer.region_table
ADD CONSTRAINT pk_region PRIMARY KEY(region_id)

SELECT
	*
FROM
	customer.region_table

--recoding
--make change column name

EXEC sp_rename 'customer.customer_table.region', 'region_id', 'COLUMN'

SELECT
	*
FROM
	customer.customer_table

GO

UPDATE customer.customer_table
SET region_id = B.region_id
FROM
	customer.customer_table AS A,
	customer.region_table AS B
WHERE
	A.region_id = B.region

SELECT
	*
FROM
	customer.customer_table


ALTER TABLE customer.customer_table
ALTER COLUMN region_id INT NOT NULL

ALTER TABLE customer.customer_table
ADD CONSTRAINT fk_customer_region FOREIGN KEY(region_id) REFERENCES customer.region_table(region_id)

---customer_segment table
SELECT
	ROW_NUMBER() OVER(ORDER BY customer_segment) AS customer_segment_id , customer_segment
	INTO customer.segment_table

FROM
	(
	SELECT
		DISTINCT customer_segment
	FROM
		customer.customer_table
	) AS subquery

ALTER TABLE customer.segment_table
ALTER COLUMN customer_segment_id INT NOT NULL

ALTER TABLE customer.segment_table
ADD CONSTRAINT pk_customer_segment PRIMARY KEY(customer_segment_id)

SELECT
	*
FROM
	customer.segment_table

--recoding
---make change column name

EXEC sp_rename 'customer.customer_table.customer_segment' , 'customer_segment_id', 'COLUMN'

SELECT
	*
FROM
	customer.customer_table

GO

UPDATE customer.customer_table
SET customer_segment_id = B.customer_segment_id
FROM
	customer.customer_table AS A,
	customer.segment_table AS B
WHERE
	A.customer_segment_id = B.customer_segment

SELECT
	*
FROM
	customer.customer_table

ALTER TABLE customer.customer_table 
ALTER COLUMN customer_segment_id INT NOT NULL

ALTER TABLE customer.customer_table
ADD CONSTRAINT fk_customer_segment FOREIGN KEY (customer_segment_id) REFERENCES customer.segment_table(customer_segment_id)
