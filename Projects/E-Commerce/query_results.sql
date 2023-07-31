USE ornek;

/* Analyze the data by finding the answers to the questions below:

1.Find the top 3 customers who have the maximum count of orders.

*/
SELECT
	TOP 3 *
FROM(
SELECT
	DISTINCT B.cust_id, first_name, last_name,
	COUNT(ord_id) OVER(PARTITION BY B.cust_id) AS cnt_order
FROM
	customer.customer_table AS A,
	[order].order_table AS B
WHERE
	A.cust_id = B.cust_id

) AS Subquery
ORDER BY cnt_order DESC

/* RESULT

cust_id	first_name	last_name	cnt_order
1140	PATRICK	JONES	17
576	MICHAEL	DOMINGUEZ	16
999	SALLY	HUGHSBY	15 */

/* 2. Find the customer whose order took the maximum time to get shipping. */

WITH T1 AS(
SELECT
	A.first_name,
	A.last_name,
	C.days_taken_for_shipping
FROM
	customer.customer_table AS A
	INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id
	INNER JOIN customer.ship_table AS C ON C.ship_id = B.ship_id)
SELECT
	TOP 1 *
FROM
	T1
ORDER BY
	days_taken_for_shipping DESC

/* RESULT

first_name	last_name	days_taken_for_shipping
DEAN	PERCER	92 */


/* 3. Count the total number of unique customers in January and how many of them came back every month over the entire year in 2011 */
GO
;
WITH T1 AS(
SELECT
	A.*,
	DATENAME(MONTH, B.order_date) AS month_name
FROM
	customer.customer_table AS A
	INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id

WHERE 
	YEAR(B.order_date) = 2011 AND
	A.cust_id IN(
		SELECT
			DISTINCT A.cust_id
		FROM
			customer.customer_table AS A
			INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id

		WHERE
			YEAR(B.order_date) = 2011 AND MONTH(B.order_date) = 1 ))

SELECT
	SUM(CASE WHEN month_name = 'January' THEN 1 ELSE 0 END) AS January,
	SUM(CASE WHEN month_name = 'February' THEN 1 ELSE 0 END) AS February,
	SUM(CASE WHEN month_name = 'March' THEN 1 ELSE 0 END) AS March,
	SUM(CASE WHEN month_name = 'April' THEN 1 ELSE 0 END) AS April,
	SUM(CASE WHEN month_name = 'May' THEN 1 ELSE 0 END) AS May,
	SUM(CASE WHEN month_name = 'June' THEN 1 ELSE 0 END) AS June,
	SUM(CASE WHEN month_name = 'July' THEN 1 ELSE 0 END) AS July,
	SUM(CASE WHEN month_name = 'August' THEN 1 ELSE 0 END) AS August,
	SUM(CASE WHEN month_name = 'September' THEN 1 ELSE 0 END) AS September,
	SUM(CASE WHEN month_name = 'October' THEN 1 ELSE 0 END) AS October,
	SUM(CASE WHEN month_name = 'November' THEN 1 ELSE 0 END) AS November,
	SUM(CASE WHEN month_name = 'December' THEN 1 ELSE 0 END) AS December
FROM
	T1;

/* 4. Write a query to return for each user the time elapsed between the first purchasing and the third purchasing, in ascending order by Customer ID. */

GO


SELECT
	cust_id,
	first_purchasing,
	date_diff,
	third_purchasing
FROM(
SELECT
	DISTINCT *,
	ROW_NUMBER() OVER(PARTITION BY cust_id ORDER BY first_purchasing) AS row_number
FROM(
SELECT
	A.cust_id,
	order_date AS first_purchasing,
	DATEDIFF(DAY,order_date , LEAD(order_date, 2) OVER(PARTITION BY A.cust_id ORDER BY B.order_date,ord_id)) AS date_diff,
	LEAD(order_date, 2) OVER(PARTITION BY A.cust_id ORDER BY B.order_date,ord_id) AS third_purchasing
FROM
	customer.customer_table AS A
	INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id
) AS subquery
WHERE 
	third_purchasing IS NOT NULL) AS subquery_2
WHERE
	[row_number] = 1
ORDER BY
	cust_id;


/* 5 . Write a query that returns customers who purchased both product 11 and product 14, as well as the ratio of these products to the total number of products purchased by the customer. */
GO


WITH T1 AS (
SELECT
	DISTINCT A.cust_id,
	SUM(C.order_quantity) OVER(PARTITION BY A.cust_id) AS prod_id_11,
	A.first_name,
	A.last_name
	---CASE WHEN C.prod_id = 11 AND C.order_quantity ! = 0 THEN SUM(order_quantity) OVER(PARTITION BY A.cust_id) ELSE 0 END AS prod_id_11
FROM
	customer.customer_table AS A
	INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id
	INNER JOIN [order].order_item AS C ON C.ord_id = B.ord_id
WHERE
	C.prod_id = 11

), T2 AS(
SELECT
	DISTINCT A.cust_id,
	SUM(C.order_quantity) OVER(PARTITION BY A.cust_id) AS prod_id_14,
	A.first_name,
	A.last_name
	---CASE WHEN C.prod_id = 14 AND C.order_quantity ! = 0 THEN SUM(order_quantity) OVER(PARTITION BY A.cust_id) ELSE 0 END AS prod_id_14
FROM
	customer.customer_table AS A
	INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id
	INNER JOIN [order].order_item AS C ON C.ord_id = B.ord_id
WHERE
	C.prod_id = 14
), T3 AS(
SELECT
	DISTINCT A.cust_id,
	SUM(C.order_quantity) OVER(PARTITION BY A.cust_id) AS sum_quantity,
	A.first_name,
	A.last_name
	---CASE WHEN C.prod_id = 14 AND C.order_quantity ! = 0 THEN SUM(order_quantity) OVER(PARTITION BY A.cust_id) ELSE 0 END AS prod_id_14
FROM
	customer.customer_table AS A
	INNER JOIN [order].order_table AS B ON B.cust_id = A.cust_id
	INNER JOIN [order].order_item AS C ON C.ord_id = B.ord_id
)
SELECT
	T1.cust_id,
	T1.first_name,
	T1.last_name,
	T3.sum_quantity,
	T1.prod_id_11,
	CAST(T1.prod_id_11 * 1.0 / T3.sum_quantity * 1.0 AS DECIMAL(3,2)) AS ratio_of_product_11,
	T2.prod_id_14,
	CAST(T2.prod_id_14 * 1.0 / T3.sum_quantity * 1.0 AS DECIMAL(3,2)) AS ratio_of_product_14
	
FROM
	T1
	INNER JOIN T2 ON T1.cust_id = T2.cust_id
	INNER JOIN	T3 ON T3.cust_id = T2.cust_id
ORDER BY
	T1.cust_id




-----------------------

/* Customer Segmentation

Categorize customers based on their frequency of visits. The following steps will guide you. If you want, you can track your own way.
1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month)
2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business)
3. For each visit of customers, create the next month of the visit as a separate column.
4. Calculate the monthly time gap between two consecutive visits by each customer.
5. Categorise customers using average time gaps. Choose the most fitted labeling model for you.
For example:
o Labeled as churn if the customer hasn't made another purchase in the months since they made their first purchase.
o Labeled as regular if the customer has made a purchase every month. */

/* 1. Create a “view” that keeps visit logs of customers on a monthly basis. (For each log, three field is kept: Cust_id, Year, Month) */
GO
;CREATE VIEW vw_visit_logs AS(
SELECT
	DISTINCT cust_id,
	YEAR(order_date) AS 'year',
	MONTH(order_date) AS 'month'
FROM
	[order].order_table)

SELECT
	*
FROM
	vw_visit_logs

/* 2. Create a “view” that keeps the number of monthly visits by users. (Show separately all months from the beginning business) */

ALTER VIEW vw_number_of_visits AS(
SELECT
    cust_id,
        [2009_January], [2009_February], [2009_March], [2009_April], [2009_May], [2009_June], [2009_July],[2009_August], [2009_September], [2009_October], [2009_November], [2009_December],
        [2010_January], [2010_February], [2010_March], [2010_April], [2010_May], [2010_June], [2010_July],[2010_August], [2010_September], [2010_October], [2010_November], [2010_December],
        [2011_January], [2011_February], [2011_March], [2011_April], [2011_May], [2011_June], [2011_July],[2011_August], [2011_September], [2011_October], [2011_November], [2011_December],
        [2012_January], [2012_February], [2012_March], [2012_April], [2012_May], [2012_June], [2012_July],[2012_August], [2012_September], [2012_October], [2012_November], [2012_December]
FROM (
    SELECT
        cust_id,
        CONCAT(YEAR(order_date), '_', DATENAME(MONTH, order_date)) AS YearMonth
    FROM
        [order].order_table

) AS subquery
PIVOT (
    COUNT(YearMonth)
    FOR YearMonth IN (
        [2009_January], [2009_February], [2009_March], [2009_April], [2009_May], [2009_June], [2009_July],[2009_August], [2009_September], [2009_October], [2009_November], [2009_December],
        [2010_January], [2010_February], [2010_March], [2010_April], [2010_May], [2010_June], [2010_July],[2010_August], [2010_September], [2010_October], [2010_November], [2010_December],
        [2011_January], [2011_February], [2011_March], [2011_April], [2011_May], [2011_June], [2011_July],[2011_August], [2011_September], [2011_October], [2011_November], [2011_December],
        [2012_January], [2012_February], [2012_March], [2012_April], [2012_May], [2012_June], [2012_July],[2012_August], [2012_September], [2012_October], [2012_November], [2012_December]
    )
) AS pivot_table);



----
GO

SELECT
	*
FROM
	vw_number_of_visits
ORDER BY
	cust_id
GO

SELECT
	*
FROM
	[order].order_table
;



/* 3. For each visit of customers, create the next month of the visit as a separate column. */

SELECT
	DISTINCT cust_id,
	order_date AS [1_visit],
	LEAD(order_date) OVER(PARTITION BY cust_id ORDER BY order_date) [2_visit],
	LEAD(order_date, 2) OVER(PARTITION BY cust_id ORDER BY order_date) [3_visit],
	LEAD(order_date,3) OVER(PARTITION BY cust_id ORDER BY order_date) [4_visit],
	LEAD(order_date, 4) OVER(PARTITION BY cust_id ORDER BY order_date) [5_visit],
	LEAD(order_date, 5) OVER(PARTITION BY cust_id ORDER BY order_date) [6_visit],
	LEAD(order_date, 6) OVER(PARTITION BY cust_id ORDER BY order_date) [7_visit],
	LEAD(order_date, 7) OVER(PARTITION BY cust_id ORDER BY order_date) [8_visit],
	LEAD(order_date, 8) OVER(PARTITION BY cust_id ORDER BY order_date) [9_visit],
	LEAD(order_date, 9) OVER(PARTITION BY cust_id ORDER BY order_date) [10_visit],
	LEAD(order_date, 10) OVER(PARTITION BY cust_id ORDER BY order_date) [11_visit],
	LEAD(order_date, 11) OVER(PARTITION BY cust_id ORDER BY order_date) [12_visit],
	LEAD(order_date, 12) OVER(PARTITION BY cust_id ORDER BY order_date) [13_visit],
	LEAD(order_date, 13) OVER(PARTITION BY cust_id ORDER BY order_date) [14_visit],
	LEAD(order_date, 14) OVER(PARTITION BY cust_id ORDER BY order_date) [15_visit],
	LEAD(order_date, 15) OVER(PARTITION BY cust_id ORDER BY order_date) [16_visit],
	LEAD(order_date, 16) OVER(PARTITION BY cust_id ORDER BY order_date) [17_visit]
FROM
        [order].order_table



/* 4. Calculate the monthly time gap between two consecutive visits by each customer. */

WITH CTE AS (
    SELECT
	DISTINCT cust_id,
	0 AS [1_visit],
	DATEDIFF(MONTH ,order_date, LEAD(order_date) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [1_gap],
	DATEDIFF(MONTH , LEAD(order_date) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 2) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [2_gap],
	DATEDIFF(MONTH , LEAD(order_date, 2) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 3) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [3_gap],
	DATEDIFF(MONTH , LEAD(order_date, 3) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 4) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [4_gap],
	DATEDIFF(MONTH , LEAD(order_date, 4) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 5) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [5_gap],
	DATEDIFF(MONTH , LEAD(order_date, 5) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 6) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [6_gap],
	DATEDIFF(MONTH , LEAD(order_date, 6) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 7) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [7_gap],
	DATEDIFF(MONTH , LEAD(order_date, 7) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 8) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [8_gap],
	DATEDIFF(MONTH , LEAD(order_date, 8) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 9) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [9_gap],
	DATEDIFF(MONTH , LEAD(order_date, 9) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 10) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [10_gap],
	DATEDIFF(MONTH , LEAD(order_date, 10) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 11) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [11_gap],
	DATEDIFF(MONTH , LEAD(order_date, 11) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 12) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [12_gap],
	DATEDIFF(MONTH , LEAD(order_date, 12) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 13) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [13_gap],
	DATEDIFF(MONTH , LEAD(order_date, 13) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 14) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [14_gap],
	DATEDIFF(MONTH , LEAD(order_date, 14) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 15) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [15_gap],
	DATEDIFF(MONTH , LEAD(order_date, 15) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 16) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [16_gap]
    FROM
        [order].order_table
)
SELECT TOP 1 WITH TIES *
FROM CTE
ORDER BY RANK() OVER (PARTITION BY cust_id ORDER BY CASE WHEN [1_gap] IS NULL THEN 1 ELSE 0 END + 
                                                    CASE WHEN [2_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [3_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [4_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [5_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [6_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [7_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [8_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [9_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [10_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [11_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [12_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [13_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [14_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [15_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [16_gap] IS NULL THEN 1 ELSE 0 END +
                                                      0)  ASC;

/* 5. Categorise customers using average time gaps. Choose the most fitted labeling model for you. */
--create a table with 'total_gaps_non_null' name
WITH CTE AS (
    SELECT
	DISTINCT cust_id,
	0 AS [1_visit],
	DATEDIFF(MONTH ,order_date, LEAD(order_date) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [1_gap],
	DATEDIFF(MONTH , LEAD(order_date) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 2) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [2_gap],
	DATEDIFF(MONTH , LEAD(order_date, 2) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 3) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [3_gap],
	DATEDIFF(MONTH , LEAD(order_date, 3) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 4) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [4_gap],
	DATEDIFF(MONTH , LEAD(order_date, 4) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 5) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [5_gap],
	DATEDIFF(MONTH , LEAD(order_date, 5) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 6) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [6_gap],
	DATEDIFF(MONTH , LEAD(order_date, 6) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 7) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [7_gap],
	DATEDIFF(MONTH , LEAD(order_date, 7) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 8) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [8_gap],
	DATEDIFF(MONTH , LEAD(order_date, 8) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 9) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [9_gap],
	DATEDIFF(MONTH , LEAD(order_date, 9) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 10) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [10_gap],
	DATEDIFF(MONTH , LEAD(order_date, 10) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 11) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [11_gap],
	DATEDIFF(MONTH , LEAD(order_date, 11) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 12) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [12_gap],
	DATEDIFF(MONTH , LEAD(order_date, 12) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 13) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [13_gap],
	DATEDIFF(MONTH , LEAD(order_date, 13) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 14) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [14_gap],
	DATEDIFF(MONTH , LEAD(order_date, 14) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 15) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [15_gap],
	DATEDIFF(MONTH , LEAD(order_date, 15) OVER(PARTITION BY cust_id ORDER BY order_date), LEAD(order_date, 16) OVER(PARTITION BY cust_id ORDER BY order_date)) AS [16_gap]
    FROM
        [order].order_table
)
SELECT TOP 1 WITH TIES *,
		COALESCE([1_gap], 0) + COALESCE([2_gap], 0) + COALESCE([3_gap], 0) + COALESCE([3_gap], 0) + COALESCE([4_gap], 0) + COALESCE([5_gap], 0) + COALESCE([6_gap], 0) + COALESCE([7_gap], 0) + COALESCE([8_gap], 0) + COALESCE([9_gap], 0) + COALESCE([10_gap], 0) + COALESCE([11_gap], 0) + COALESCE([12_gap], 0) + COALESCE([13_gap], 0) + COALESCE([14_gap], 0) + COALESCE([15_gap], 0)  + COALESCE([16_gap], 0) AS total_gap,
													CASE WHEN [1_gap] IS NOT NULL THEN 1 ELSE 0 END + 
                                                    CASE WHEN [2_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [3_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [4_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [5_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [6_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [7_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [8_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [9_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [10_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [11_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [12_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [13_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [14_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [15_gap] IS NOT NULL THEN 1 ELSE 0 END +
													CASE WHEN [16_gap] IS NOT NULL THEN 1 ELSE 0 END AS non_null_count
													INTO total_gaps_non_null


FROM CTE
ORDER BY RANK() OVER (PARTITION BY cust_id ORDER BY CASE WHEN [1_gap] IS NULL THEN 1 ELSE 0 END + 
                                                    CASE WHEN [2_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [3_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [4_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [5_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [6_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [7_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [8_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [9_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [10_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [11_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [12_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [13_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [14_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [15_gap] IS NULL THEN 1 ELSE 0 END +
													CASE WHEN [16_gap] IS NULL THEN 1 ELSE 0 END +
                                                      0)  ASC
select
	*
FROM
	total_gaps_non_null


SELECT
	cust_id,
	CASE WHEN avg_gap = 0 THEN 'Churn'
		WHEN avg_gap = 1 THEN 'Regular'
		WHEN avg_gap BETWEEN  2 AND 10 THEN 'Very Good' 
		WHEN avg_gap BETWEEN 11 AND 20 THEN 'Good'
		WHEN avg_gap BETWEEN 21 AND 30 THEN 'Medium'
		WHEN avg_gap BETWEEN 31 AND 40 THEN 'Bad'
		ELSE 'Very Bad' END AS category_visitors
FROM
(
SELECT
	*,
	total_gap / CASE WHEN non_null_count = 0 THEN 1 ELSE non_null_count END avg_gap
FROM
	total_gaps_non_null) AS subquery
ORDER BY
	cust_id

/* Month-Wise Retention Rate
Find month-by-month customer retention ratei since the start of the business.
There are many different variations in the calculation of Retention Rate. But we will try to calculate the month-wise retention rate in this project.
So, we will be interested in how many of the customers in the previous month could be retained in the next month.
Proceed step by step by creating “views”. You can use the view you got at the end of the Customer Segmentation section as a source.
1. Find the number of customers retained month-wise. (You can use time gaps)
2. Calculate the month-wise retention rate.
Month-Wise Retention Rate = 1.0 * Number of Customers Retained in The Current Month / Total Number of Customers in the Current Month */


CREATE VIEW vw_month_wise AS(
SELECT
	cust_id,
CASE WHEN [2009_January] = 1 AND [2009_February] = 1 THEN 1 ELSE 0 END AS [2009_Jan_Feb],
    CASE WHEN [2009_February] = 1 AND [2009_March] = 1 THEN 1 ELSE 0 END AS [2009_Feb_Mar],
    CASE WHEN [2009_March] = 1 AND [2009_April] = 1 THEN 1 ELSE 0 END AS [2009_Mar_Apr],
    CASE WHEN [2009_April] = 1 AND [2009_May] = 1 THEN 1 ELSE 0 END AS [2009_Apr_May],
    CASE WHEN [2009_May] = 1 AND [2009_June] = 1 THEN 1 ELSE 0 END AS [2009_May_Jun],
    CASE WHEN [2009_June] = 1 AND [2009_July] = 1 THEN 1 ELSE 0 END AS [2009_Jun_July],
    CASE WHEN [2009_July] = 1 AND [2009_August] = 1 THEN 1 ELSE 0 END AS [2009_July_Aug],
    CASE WHEN [2009_August] = 1 AND [2009_September] = 1 THEN 1 ELSE 0 END AS [2009_Aug_Sep],
    CASE WHEN [2009_September] = 1 AND [2009_October] = 1 THEN 1 ELSE 0 END AS [2009_Sep_Oct],
    CASE WHEN [2009_October] = 1 AND [2009_November] = 1 THEN 1 ELSE 0 END AS [2009_Oct_Nov],
    CASE WHEN [2009_November] = 1 AND [2009_December] = 1 THEN 1 ELSE 0 END AS [2009_Nov_Dec],
    CASE WHEN [2009_December] = 1 AND [2010_January] = 1 THEN 1 ELSE 0 END AS [2009_Dec_Jan],
    CASE WHEN [2010_January] = 1 AND [2010_February] = 1 THEN 1 ELSE 0 END AS [2010_Jan_Feb],
    CASE WHEN [2010_February] = 1 AND [2010_March] = 1 THEN 1 ELSE 0 END AS [2010_Feb_Mar],
    CASE WHEN [2010_March] = 1 AND [2010_April] = 1 THEN 1 ELSE 0 END AS [2010_Mar_Apr],
    CASE WHEN [2010_April] = 1 AND [2010_May] = 1 THEN 1 ELSE 0 END AS [2010_Apr_May],
    CASE WHEN [2010_May] = 1 AND [2010_June] = 1 THEN 1 ELSE 0 END AS [2010_May_Jun],
    CASE WHEN [2010_June] = 1 AND [2010_July] = 1 THEN 1 ELSE 0 END AS [2010_Jun_July],
    CASE WHEN [2010_July] = 1 AND [2010_August] = 1 THEN 1 ELSE 0 END AS [2010_July_Aug],
    CASE WHEN [2010_August] = 1 AND [2010_September] = 1 THEN 1 ELSE 0 END AS [2010_Aug_Sep],
    CASE WHEN [2010_September] = 1 AND [2010_October] = 1 THEN 1 ELSE 0 END AS [2010_Sep_Oct],
    CASE WHEN [2010_October] = 1 AND [2010_November] = 1 THEN 1 ELSE 0 END AS [2010_Oct_Nov],
    CASE WHEN [2010_November] = 1 AND [2010_December] = 1 THEN 1 ELSE 0 END AS [2010_Nov_Dec],
    CASE WHEN [2010_December] = 1 AND [2011_January] = 1 THEN 1 ELSE 0 END AS [2010_Dec_Jan],
    CASE WHEN [2011_January] = 1 AND [2011_February] = 1 THEN 1 ELSE 0 END AS [2011_Jan_Feb],
    CASE WHEN [2011_February] = 1 AND [2011_March] = 1 THEN 1 ELSE 0 END AS [2011_Feb_Mar],
    CASE WHEN [2011_March] = 1 AND [2011_April] = 1 THEN 1 ELSE 0 END AS [2011_Mar_Apr],
    CASE WHEN [2011_April] = 1 AND [2011_May] = 1 THEN 1 ELSE 0 END AS [2011_Apr_May],
    CASE WHEN [2011_May] = 1 AND [2011_June] = 1 THEN 1 ELSE 0 END AS [2011_May_Jun],
    CASE WHEN [2011_June] = 1 AND [2011_July] = 1 THEN 1 ELSE 0 END AS [2011_Jun_July],
    CASE WHEN [2011_July] = 1 AND [2011_August] = 1 THEN 1 ELSE 0 END AS [2011_July_Aug],
    CASE WHEN [2011_August] = 1 AND [2011_September] = 1 THEN 1 ELSE 0 END AS [2011_Aug_Sep],
    CASE WHEN [2011_September] = 1 AND [2011_October] = 1 THEN 1 ELSE 0 END AS [2011_Sep_Oct],
    CASE WHEN [2011_October] = 1 AND [2011_November] = 1 THEN 1 ELSE 0 END AS [2011_Oct_Nov],
    CASE WHEN [2011_November] = 1 AND [2011_December] = 1 THEN 1 ELSE 0 END AS [2011_Nov_Dec],
    CASE WHEN [2011_December] = 1 AND [2012_January] = 1 THEN 1 ELSE 0 END AS [2011_Dec_Jan],
	CASE WHEN [2012_January] = 1 AND [2012_February] = 1 THEN 1 ELSE 0 END AS [2012_Jan_Feb],
    CASE WHEN [2012_February] = 1 AND [2012_March] = 1 THEN 1 ELSE 0 END AS [2012_Feb_Mar],
    CASE WHEN [2012_March] = 1 AND [2012_April] = 1 THEN 1 ELSE 0 END AS [2012_Mar_Apr],
    CASE WHEN [2012_April] = 1 AND [2012_May] = 1 THEN 1 ELSE 0 END AS [2012_Apr_May],
    CASE WHEN [2012_May] = 1 AND [2012_June] = 1 THEN 1 ELSE 0 END AS [2012_May_Jun],
    CASE WHEN [2012_June] = 1 AND [2012_July] = 1 THEN 1 ELSE 0 END AS [2012_Jun_July],
    CASE WHEN [2012_July] = 1 AND [2012_August] = 1 THEN 1 ELSE 0 END AS [2012_July_Aug],
    CASE WHEN [2012_August] = 1 AND [2012_September] = 1 THEN 1 ELSE 0 END AS [2012_Aug_Sep],
    CASE WHEN [2012_September] = 1 AND [2012_October] = 1 THEN 1 ELSE 0 END AS [2012_Sep_Oct],
    CASE WHEN [2012_October] = 1 AND [2012_November] = 1 THEN 1 ELSE 0 END AS [2012_Oct_Nov],
    CASE WHEN [2012_November] = 1 AND [2012_December] = 1 THEN 1 ELSE 0 END AS [2012_Nov_Dec]
FROM
	vw_number_of_visits)

SELECT
	*
FROM
	vw_month_wise

CREATE VIEW vw_consecutive_months AS(
SELECT
	cust_id,
	CASE    WHEN [2009_Jan_Feb] = 1 THEN '2009_Jan_Feb'
			WHEN [2009_Feb_Mar] = 1 THEN '2009_Feb_Mar'
			WHEN [2009_Mar_Apr] = 1 THEN '2009_Mar_Apr'
			WHEN [2009_Apr_May] = 1 THEN '2009_Apr_May'
			WHEN [2009_May_Jun] = 1 THEN '2009_May_Jun'
			WHEN [2009_Jun_July] = 1 THEN '2009_Jun_July'
			WHEN [2009_July_Aug] = 1 THEN '2009_July_Aug'
			WHEN [2009_Aug_Sep] = 1 THEN '2009_Aug_Sep'
			WHEN [2009_Sep_Oct] = 1 THEN '2009_Sep_Oct'
			WHEN [2009_Oct_Nov] = 1 THEN '2009_Oct_Nov'
			WHEN [2009_Nov_Dec] = 1 THEN '2009_Nov_Dec'
			WHEN [2009_Dec_Jan] = 1 THEN '2009_Dec_Jan'
			WHEN [2010_Jan_Feb] = 1 THEN '2010_Jan_Feb'
			WHEN [2010_Feb_Mar] = 1 THEN '2010_Feb_Mar'
			WHEN [2010_Mar_Apr] = 1 THEN '2010_Mar_Apr'
			WHEN [2010_Apr_May] = 1 THEN '2010_Apr_May'
			WHEN [2010_May_Jun] = 1 THEN '2010_May_Jun'
			WHEN [2010_Jun_July] = 1 THEN '2010_Jun_July'
			WHEN [2010_July_Aug] = 1 THEN '2010_July_Aug'
			WHEN [2010_Aug_Sep] = 1 THEN '2010_Aug_Sep'
			WHEN [2010_Sep_Oct] = 1 THEN '2010_Sep_Oct'
			WHEN [2010_Oct_Nov] = 1 THEN '2010_Oct_Nov'
			WHEN [2010_Nov_Dec] = 1 THEN '2010_Nov_Dec'
			WHEN [2010_Dec_Jan] = 1 THEN '2010_Dec_Jan'
			WHEN [2011_Jan_Feb] = 1 THEN '2011_Jan_Feb'
			WHEN [2011_Feb_Mar] = 1 THEN '2011_Feb_Mar'
			WHEN [2011_Mar_Apr] = 1 THEN '2011_Mar_Apr'
			WHEN [2011_Apr_May] = 1 THEN '2011_Apr_May'
			WHEN [2011_May_Jun] = 1 THEN '2011_May_Jun'
			WHEN [2011_Jun_July] = 1 THEN '2011_Jun_July'
			WHEN [2011_July_Aug] = 1 THEN '2011_July_Aug'
			WHEN [2011_Aug_Sep] = 1 THEN '2011_Aug_Sep'
			WHEN [2011_Sep_Oct] = 1 THEN '2011_Sep_Oct'
			WHEN [2011_Oct_Nov] = 1 THEN '2011_Oct_Nov'
			WHEN [2011_Nov_Dec] = 1 THEN '2011_Nov_Dec'
			WHEN [2011_Dec_Jan] = 1 THEN '2011_Dec_Jan'
			WHEN [2012_Jan_Feb] = 1 THEN '2012_Jan_Feb'
			WHEN [2012_Feb_Mar] = 1 THEN '2012_Feb_Mar'
			WHEN [2012_Mar_Apr] = 1 THEN '2012_Mar_Apr'
			WHEN [2012_Apr_May] = 1 THEN '2012_Apr_May'
			WHEN [2012_May_Jun] = 1 THEN '2012_May_Jun'
			WHEN [2012_Jun_July] = 1 THEN '2012_Jun_July'
			WHEN [2012_July_Aug] = 1 THEN '2012_July_Aug'
			WHEN [2012_Aug_Sep] = 1 THEN '2012_Aug_Sep'
			WHEN [2012_Sep_Oct] = 1 THEN '2012_Sep_Oct'
			WHEN [2012_Oct_Nov] = 1 THEN '2012_Oct_Nov'
			WHEN [2012_Nov_Dec] = 1 THEN '2012_Nov_Dec'
			ELSE NULL 
		END AS consecutive_months
FROM
	 vw_month_wise

WHERE
[2009_Jan_Feb] = 1 OR [2009_Feb_Mar] = 1 OR  [2009_Mar_Apr] = 1  OR [2009_Apr_May] = 1  OR [2009_May_Jun] = 1  OR [2009_Jun_July] = 1  OR [2009_July_Aug] = 1 OR [2009_Aug_Sep] = 1 OR [2009_Sep_Oct] = 1 OR [2009_Oct_Nov] = 1 OR [2009_Nov_Dec] = 1 OR [2009_Dec_Jan] = 1 OR [2010_Jan_Feb] = 1 OR [2010_Feb_Mar] = 1 OR  [2010_Mar_Apr] = 1 OR [2010_Apr_May] = 1 OR [2010_May_Jun] = 1 OR [2010_Jun_July] = 1 OR [2010_July_Aug] = 1 OR [2010_Aug_Sep] = 1 OR [2010_Sep_Oct] = 1  OR [2010_Oct_Nov] = 1 OR [2010_Nov_Dec] = 1 OR [2010_Dec_Jan] = 1  OR [2011_Jan_Feb] = 1 OR [2011_Feb_Mar] = 1 OR [2011_Mar_Apr] = 1 OR [2011_Apr_May] = 1 OR [2011_May_Jun] = 1 OR [2011_Jun_July] = 1 OR [2011_July_Aug] = 1 OR [2011_Aug_Sep] = 1  OR [2011_Sep_Oct] = 1 OR [2011_Oct_Nov] = 1  OR [2011_Nov_Dec] = 1 OR [2011_Dec_Jan] = 1 OR [2012_Jan_Feb] = 1 OR [2012_Feb_Mar] = 1  OR [2012_Mar_Apr] = 1 OR  [2012_Apr_May] = 1 OR  [2012_May_Jun] = 1 OR [2012_Jun_July] = 1 OR [2012_July_Aug] = 1 OR [2012_Aug_Sep] = 1 OR [2012_Sep_Oct] = 1 OR [2012_Oct_Nov] = 1 OR [2012_Nov_Dec] = 1)

SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY consecutive_months ORDER BY consecutive_months)
FROM
	vw_consecutive_months
GROUP BY
	consecutive_months,
	cust_id
ORDER BY
	2


CREATE VIEW vw_year_month_consecutive AS(
SELECT
	*,
	CASE WHEN consecutive_months IN ('2009_Apr_May', '2009_Mar_Apr', '2009_Aug_Sep', '2009_Dec_Jan', '2009_Feb_Mar', '2009_Jan_Feb', '2009_July_Aug', '2009_Jun_July', '2009_Mar_Apr', '2009_May_Jun', '2009_Nov_Dec', '2009_Oct_Nov', '2009_Sep_Oct' ) THEN '2009' 
		 WHEN consecutive_months IN ('2010_Apr_May' , '2010_Aug_Sep', '2010_Dec_Jan', '2010_Feb_Mar', '2010_Jan_Feb', '2010_July_Aug', '2010_Jun_July', '2010_Mar_Apr', '2010_May_Jun', '2010_Nov_Dec', '2010_Oct_Nov', '2010_Sep_Oct')	THEN '2010' 
		 WHEN consecutive_months IN ('2011_Apr_May', '2011_Aug_Sep', '2011_Dec_Jan', '2011_Feb_Mar', '2011_Jan_Feb', '2011_July_Aug', '2011_Jun_July' ,'2011_Mar_Apr', '2011_May_Jun' , '2011_Nov_Dec', '2011_Oct_Nov', '2011_Sep_Oct') THEN'2011' ELSE '2012' END AS year_date,
	CASE WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'May' THEN 5 
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Sep' THEN 9
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Jan' THEN 1
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Mar' THEN 3
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Feb' THEN 2
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Aug' THEN 8
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'July' THEN 7
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Apr' THEN 4
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Jun' THEN 6
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Dec' THEN 12
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Nov' THEN 11
		 WHEN SUBSTRING(consecutive_months, CHARINDEX('_', consecutive_months, CHARINDEX('_', consecutive_months) + 1) + 1 ,LEN(consecutive_months)) = 'Oct' THEN 10
		  ELSE 0 END AS month_date

FROM
	vw_consecutive_months)

SELECT
	*
FROM
	vw_year_month_consecutive


SELECT
	DISTINCT
	A.year_date,
	A.month_date,
	COUNT(cust_id) OVER(PARTITION BY A.year_date,A.month_date ORDER BY A.year_date,A.month_date) cnt_consecutive,
	B.cnt_total,
	CAST(1.0 * COUNT(cust_id) OVER(PARTITION BY A.year_date,A.month_date ORDER BY A.year_date,A.month_date) / B.cnt_total AS DECIMAL(5,2)) AS month_wise_retention_rate
FROM
	vw_year_month_consecutive AS A
	INNER JOIN (
	SELECT
		DISTINCT YEAR(order_date) as year_date,
		MONTH(order_date) as month_date,
		COUNT(cust_id) OVER(PARTITION BY YEAR(order_date), MONTH(order_date) ORDER BY YEAR(order_date), MONTH(order_date)) cnt_total
	FROM
		[order].order_table
	) AS B ON A.year_date = B.year_date AND A.month_date = B.month_date
WHERE A.year_date + A.month_date ! = '2010'
ORDER BY
	1,2


--THE END

