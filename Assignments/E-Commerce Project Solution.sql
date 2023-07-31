--SQL Project Solution, 31.07.2023
--E-Commerce Data and Customer Retention Analysis with SQL


--////////////////////////////////////////////////////////////////////////////////////
-- Analysis of Data
--************************************************************

----------------------------------------------------------------------------
-- 1. Using the columns of "market_fact", "cust_dimen", "orders_dimen", "prod_dimen", "shipping_dimen" 
-- create a new table, named as "combined_table".

SELECT *
INTO combined_table
FROM(
	SELECT 
		mf.Ord_ID, cd.Cust_ID, mf.Prod_ID, sd.Ship_ID, od.Order_Date, sd.Ship_Date, cd.Customer_Name, cd.Province, cd.Region, cd.Customer_Segment, mf.Sales, mf.Discount, mf.Order_Quantity, mf.Product_Base_Margin, od.Order_Priority, pd.Product_Category, pd.Product_Sub_Category, sd.Ship_Mode
	FROM market_fact mf
	INNER JOIN cust_dimen cd ON cd.Cust_ID = mf.Cust_ID
	INNER JOIN orders_dimen od ON od.Ord_ID = mf.Ord_ID
	INNER JOIN prod_dimen pd ON pd.Prod_ID = mf.Prod_ID
	INNER JOIN shipping_dimen sd ON sd.Ship_ID = mf.Ship_ID
) A;
GO

SELECT * FROM combined_table ORDER BY Order_Date


----------------------------------------------------------------------------
-- 2. Find the top 3 customers who have the maximum count of orders.

SELECT TOP 3 Cust_ID, COUNT(DISTINCT Ord_Id) num_of_orders
FROM combined_table
GROUP BY Cust_ID
ORDER BY num_of_orders DESC;


----------------------------------------------------------------------------
-- 3. Create a new column at combined_table as DaysTakenForShipping that contains 
-- the date difference of Order_Date and Ship_Date.

ALTER TABLE combined_table
ADD DaysTakenForShipping AS DATEDIFF(DAY, Order_Date, Ship_Date)


SELECT * FROM combined_table


----------------------------------------------------------------------------
-- 4. Find the customer whose order took the maximum time to get shipping.

SELECT TOP 1 Cust_ID, Customer_Name, DaysTakenForShipping
FROM combined_table
ORDER BY DaysTakenForShipping DESC;


----------------------------------------------------------------------------
-- 5. Count the total number of unique customers in January and 
-- how many of them came back every month over the entire year in 2011.

SELECT MONTH(Order_Date) ord_month, COUNT(DISTINCT Cust_ID) num_of_cust
FROM combined_table
WHERE YEAR(Order_Date)=2011
	AND Cust_ID IN (SELECT DISTINCT Cust_ID
					FROM combined_table
					WHERE YEAR(Order_Date)=2011 AND MONTH(Order_Date)=1
					)
GROUP BY MONTH(Order_Date)
ORDER BY ord_month


----------------------------------------------------------------------------
-- 6. Write a query to return for each user the time elapsed between the first purchasing 
-- and the third purchasing, in ascending order by Customer ID.

--Pay attention to the orders of customers with id 431, 799, 1445, 1680, 1730

SELECT DISTINCT Cust_ID, first_order, Order_Date AS third_order,
	DATEDIFF(DAY, first_order, Order_Date) day_diff
FROM(
	SELECT Cust_ID, Ord_ID, Order_Date,
		DENSE_RANK() OVER(PARTITION BY Cust_ID ORDER BY Order_Date, Ord_ID) nth_order,
		MIN(Order_Date) OVER(PARTITION BY Cust_ID) first_order
	FROM combined_table
) a
WHERE nth_order=3


----------------------------------------------------------------------------
-- 7. Write a query that returns customers who purchased both product 11 and product 14, 
-- as well as the ratio of these products to the total quantity of products purchased by the customer.

SELECT Cust_ID, prod_11_quantity, prod_14_quantity,
	ROUND(prod_11_quantity / total_quantity,2) "prod_11_ratio",
	ROUND(prod_14_quantity / total_quantity,2) "prod_14_ratio"
FROM(
	SELECT Cust_ID,
		(SELECT SUM(Order_Quantity) FROM combined_table 
			WHERE Prod_ID='Prod_11' AND Cust_ID=c.Cust_ID) prod_11_quantity,
		(SELECT SUM(Order_Quantity) FROM combined_table 
			WHERE Prod_ID='Prod_14' AND Cust_ID=c.Cust_ID) prod_14_quantity,
		(SELECT SUM(Order_Quantity) FROM combined_table 
			WHERE Cust_ID=c.Cust_ID) total_quantity
	FROM combined_table c
	WHERE Prod_ID IN ('Prod_11', 'Prod_14')
	GROUP BY Cust_ID
	HAVING COUNT(DISTINCT Prod_ID)=2
) subq
GO

------------------------------------
--CASE SOLUTION

SELECT Cust_Id, prod_11, prod_14,
	ROUND(prod_11/total_quantity, 2) prod_11_ratio,
	ROUND(prod_14/total_quantity, 2) prod_14_ratio
FROM(
	SELECT Cust_ID, 
		(SELECT SUM(Order_Quantity) FROM combined_table 
			WHERE Prod_ID='Prod_11' AND Cust_ID=c.Cust_ID) prod_11,
		(SELECT SUM(Order_Quantity) FROM combined_table 
			WHERE Prod_ID='Prod_14' AND Cust_ID=c.Cust_ID) prod_14,
		(SELECT SUM(Order_Quantity) FROM combined_table 
			WHERE Cust_ID=c.Cust_ID) total_quantity
	FROM combined_table c
	WHERE Prod_ID IN ('Prod_11','Prod_14')
	GROUP BY Cust_ID
	HAVING COUNT(DISTINCT Prod_ID) = 2
) subq
GO


--////////////////////////////////////////////////////////////////////////////////////

-- Customer Segmentation
--************************************************************

-- Categorize customers based on their frequency of visits.

-- 1. Create a “view” that keeps visit logs of customers on a monthly basis. 
-- (For each log, three field is kept: Cust_id, Year, Month)

CREATE VIEW visit_logs AS
SELECT Cust_ID, YEAR(Order_Date) ord_year, MONTH(Order_Date) ord_month
FROM combined_table
GO

-- 2. Create a “view” that keeps the number of monthly visits by users. 
-- (Show separately all months from the beginning business)

ALTER VIEW visit_logs AS
SELECT Cust_ID, YEAR(Order_Date) ord_year, MONTH(Order_Date) ord_month,
	COUNT(DISTINCT Ord_ID) num_of_orders
FROM combined_table
GROUP BY Cust_ID, YEAR(Order_Date), MONTH(Order_Date)
GO

SELECT * FROM visit_logs


-- 3. For each visit of customers, create the next/previous month of the visit as a separate column.

SELECT *,
	LAG(current_month) OVER(PARTITION BY Cust_ID ORDER BY current_month) prev_month 	
FROM(
	SELECT DISTINCT *,
		DENSE_RANK() OVER(ORDER BY ord_year, ord_month) current_month
	FROM visit_logs
) subq
GO


-- 4. Calculate the monthly time gap between two consecutive visits by each customer.

CREATE VIEW time_gaps AS
SELECT *,
	LAG(current_month) OVER(PARTITION BY Cust_ID ORDER BY current_month) prev_month,
	current_month - LAG(current_month) OVER(PARTITION BY Cust_ID ORDER BY current_month) time_gap
FROM(
	SELECT DISTINCT *,
		DENSE_RANK() OVER(ORDER BY ord_year, ord_month) current_month
	FROM visit_logs
) subq
GO

SELECT * FROM time_gaps


-- 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.

-- For example:
-- Labeled as "churn" if the customer hasn't made another purchase in the months 
-- since they made their first purchase.
-- Labeled as "regular" if the customer has made a purchase every month.

SELECT Cust_ID, AVG(time_gap) avg_time_gap, COUNT(*) num_of_visits
FROM time_gaps
GROUP BY Cust_ID

---------------------------------------------

SELECT Cust_ID, AVG(time_gap) avg_time_gap, COUNT(*) num_of_visits,
	CASE
		WHEN AVG(time_gap) IS NULL THEN 'CHURN'
		WHEN AVG(time_gap) < 4 AND COUNT(*) > 8 THEN 'LOYAL'
		WHEN COUNT(*) > 8 THEN 'REGULAR'
		WHEN AVG(time_gap) < 8 AND COUNT(*) > 5 THEN 'NEED ATTENTION'
		ELSE 'IRREGULAR'
	END cust_segmentation
FROM time_gaps
GROUP BY Cust_ID
ORDER BY cust_segmentation DESC;


--////////////////////////////////////////////////////////////////////////////////////

-- Month-Wise Retention Rate
--************************************************************

-- Find month-by-month customer retention rate since the start of the business.
-- 1. Find the number of customers retained month-wise. (You can use time gaps)
-- 2. Calculate the month-wise retention rate.

SELECT *
FROM time_gaps


SELECT current_month, COUNT(Cust_ID) num_of_cust,
	SUM(CASE WHEN time_gap=1 THEN 1 END) retained_cust,
	CAST(1.0*SUM(CASE WHEN time_gap=1 THEN 1 END) / (SELECT COUNT(Cust_ID) FROM time_gaps WHERE
								current_month=a.current_month-1) AS DEC(10,2)) retention_rate
FROM time_gaps a
GROUP BY current_month
ORDER BY current_month

---------------------------------
--SOLUTION-2

SELECT current_month,
	CAST(1.0*retained_cust / prev_cust AS DEC(10,2)) retention_rate
FROM(
	SELECT *,
		LAG(num_of_cust) OVER(ORDER BY current_month) prev_cust
	FROM(
		SELECT current_month, COUNT(Cust_ID) num_of_cust,
			SUM(CASE WHEN time_gap=1 THEN 1 END) retained_cust
		FROM time_gaps a
		GROUP BY current_month
	) subq1
) subq2
