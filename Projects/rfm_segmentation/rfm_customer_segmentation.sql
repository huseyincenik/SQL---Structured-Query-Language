USE PortfolioProject;
-- data--- https://github.com/AllThingsDataWithAngelina/DataSource/blob/main/sales_data_sample.csv
SELECT
	*
FROM
	sales_data_sample;

--Checking unique values
SELECT
	DISTINCT STATUS
FROM
	sales_data_sample; -- 6 class

SELECT
	DISTINCT YEAR_ID
FROM
	sales_data_sample; -- 3 class

SELECT
	DISTINCT PRODUCTLINE
FROM
	sales_data_sample; -- 7 class

SELECT
	DISTINCT COUNTRY
FROM
	sales_data_sample; -- 19 class

SELECT
	DISTINCT DEALSIZE
FROM
	sales_data_sample; -- 3 class

SELECT
	DISTINCT TERRITORY
FROM
	sales_data_sample; -- 4 class

SELECT
	DISTINCT MONTH_ID
FROM
	sales_data_sample
WHERE
	YEAR_ID = 2003; -- sadece 2004 ten 5 ay var. digerleri 12 ay.

-- ANALYSIS
--- Let's start by grouping sales by production

SELECT 
	PRODUCTLINE, SUM(SALES) AS Revenue
FROM	
	sales_data_sample
GROUP BY
	PRODUCTLINE
ORDER BY 
	2 DESC;

SELECT 
	YEAR_ID, SUM(SALES) AS Revenue
FROM	
	sales_data_sample
GROUP BY
	YEAR_ID
ORDER BY 
	2 DESC;

--pivot gelecek yil, productline ve sum(sales) seklinde

SELECT
	*
FROM
	(
	SELECT 
		YEAR_ID,
		PRODUCTLINE,
		SALES
	FROM
		sales_data_sample
	) AS A
PIVOT
	(
	SUM(SALES)
	FOR 
		YEAR_ID
	IN ([2003], [2004], [2005])
	)
AS pivot_table_1

ORDER BY
	2 DESC;

USE PortfolioProject
SELECT
	*
FROM
	sales_data_sample

---
SELECT
	*
FROM
	(
	SELECT
		COUNTRY,
		DATENAME(WEEKDAY, ORDERDATE) AS day_of_week,
		ORDERNUMBER
	FROM
		sales_data_sample
	) AS A
PIVOT
	(
	COUNT(ORDERNUMBER)
	FOR day_of_week
	IN([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
	) AS pivot_table_2
ORDER BY
	2;
---
-- en cok hangi gun kargo iptal ediliyor ?
SELECT
	*
FROM
	(
	SELECT
		STATUS,
		DATENAME(WEEKDAY, ORDERDATE) AS day_of_week,
		ORDERNUMBER
	FROM
		sales_data_sample
	) AS A
PIVOT
	(
	COUNT(ORDERNUMBER)
	FOR day_of_week
	IN([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
	) AS pivot_table_2
ORDER BY
	2;

---
SELECT
	*
FROM
	sales_data_sample
WHERE
	ORDERNUMBER = 10195
---

SELECT 
	DEALSIZE, SUM(SALES) AS Revenue
FROM	
	sales_data_sample
GROUP BY
	DEALSIZE
ORDER BY 
	2 DESC; --sonuc farkli cikti.

---What was the best month for sales in a spesific year? How much was earned that month?
--- my solution
WITH CTE AS (
SELECT
	*,
	ROW_NUMBER() OVER(PARTITION BY YEAR_ID ORDER BY YEAR_ID, REVENUE DESC) AS number_of_earned
FROM(
SELECT
	DISTINCT YEAR_ID, MONTH_ID, SUM(SALES) OVER(PARTITION BY YEAR_ID, MONTH_ID) AS Revenue
FROM
	sales_data_sample
) AS a)
SELECT
	*
FROM	
	CTE
WHERE
	number_of_earned = 1;

-- video solution
SELECT
	MONTH_ID, 
	SUM(SALES) AS Revenue, COUNT(ORDERNUMBER) AS Frequency
FROM
	sales_data_sample
WHERE
	YEAR_ID = 2004
GROUP BY
	MONTH_ID
ORDER BY 
	2 DESC;-- result is different from video.

-- November seems to be the month, what product do they sell in November, Classic I believe.
SELECT
	MONTH_ID, 
	PRODUCTLINE,
	SUM(SALES) AS Revenue, COUNT(ORDERNUMBER)
FROM	
	sales_data_sample
WHERE 
	YEAR_ID = 2004 AND MONTH_ID = 11
GROUP BY
	MONTH_ID, PRODUCTLINE
ORDER BY
	3 DESC --most seller cars - classic cars.

--- Who is our best customer(this could be best answered with RFM)

-- ikinci 15 dk. Data Points Used In RFM Analysis
-- Recency - Last Order Date
-- Frequency - Count of Total Orders
-- Monetary Value - Total Spend


SELECT
	TOP 1 CUSTOMERNAME,
	SUM(SALES) AS max_sales
FROM
	sales_data_sample
GROUP BY
	CUSTOMERNAME;

--
/*
NTILE fonksiyonu, bir sorgudaki sonuç kümesini belirli sayýda eþit büyüklükte alt kümelere bölmek için kullanýlan bir analitik pencere fonksiyonudur. Bu, özellikle sýralý bir veri kümesini belirli sayýda parçaya ayýrmak istediðiniz durumlarda faydalýdýr.

NTILE fonksiyonu genellikle sýralý veri kümesindeki her bir öðeyi belirli bir sayýda eþit büyüklükteki gruplara ayýrmak için kullanýlýr. Bu gruplar, belirli bir sýralama kriterine göre belirlenir.*/

DROP TABLE IF EXISTS #rfm
;WITH cte AS
	(
	SELECT
		CUSTOMERNAME,
		SUM(SALES) AS monetary_value,
		AVG(SALES) AS avg_monetary_value,
		COUNT(ORDERNUMBER) AS frequency,
		MAX(ORDERDATE) AS last_order_date,
		(SELECT MAX(ORDERDATE) FROM sales_data_sample ) AS max_order_date,
		DATEDIFF(DD, MAX(ORDERDATE) , (SELECT MAX(ORDERDATE) FROM sales_data_sample)) AS recency
	FROM
		sales_data_sample
	GROUP BY
		CUSTOMERNAME
	),
rfm_calc AS
	(
	SELECT
		r.*,
		NTILE(4) OVER(ORDER BY recency desc) AS rfm_recency,
		NTILE(4) OVER(ORDER BY frequency) AS rfm_frequency,
		NTILE(4) OVER(ORDER BY monetary_value) AS rfm_monetary
	FROM
		cte AS r
	)
SELECT
	c.*, rfm_recency + rfm_frequency +  rfm_monetary AS rfm_cell,
	CAST(rfm_recency AS varchar) + CAST(rfm_frequency AS varchar) + CAST(rfm_monetary AS varchar) AS rfm_cell_string
INTO #rfm
FROM
	rfm_calc AS c;


SELECT
	CUSTOMERNAME, 
	rfm_recency, 
	rfm_frequency, 
	rfm_monetary,
	CASE
		WHEN rfm_cell_string IN(111,112, 121, 122, 123, 132, 211, 212, 114, 141) THEN 'lost_customers'--lost customers
		WHEN rfm_cell_string IN(133, 134, 143, 244, 334, 343, 144) THEN 'slipping_away, cannot_lose'-- big spenders who haven't purchased lately) slipping away
		WHEN rfm_cell_string IN(311, 411, 331) THEN 'new_customers'
		WHEN rfm_cell_string IN(222, 223, 233, 322) THEN 'potential_churners'
		WHEN rfm_cell_string IN(323, 333, 321, 422, 332, 432) THEN 'active'--(customers who buy often & recently, but at low price points)
		WHEN rfm_cell_string IN(344, 433, 434, 443, 444) THEN 'loyal'
	END rfm_segment
FROM
	#rfm;
	---https://youtu.be/O2hlHzehZb0?t=1810 - 30:10

-- baska bir rfm ornegi bu olabilirdi.
SELECT
	CUSTOMERNAME, 
	rfm_recency, 
	rfm_frequency, 
	rfm_monetary,
	CASE
		WHEN rfm_recency IN (2, 3, 4) AND rfm_frequency = 4 AND rfm_monetary = 4 THEN 'Champion' 
		WHEN rfm_recency = 3 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent Regular Customer'
		WHEN rfm_recency = 3 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'Regular Customer'
		WHEN rfm_recency = 4 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent New Customer'
		WHEN rfm_recency = 4 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'New Customer'
		WHEN rfm_recency IN (2, 3) AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent Customer Needed Attention'
		WHEN rfm_recency IN(2, 3) AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'Customer Needed Attention'
		WHEN rfm_recency = 1 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent Lost Customer'
		WHEN rfm_recency = 1 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'Lost Customer'
		END rfm_segment
FROM
	#rfm;

SELECT
	*
FROM
	sales_data_sample;

--- changing options


EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;






SELECT
    sds.*,
    rfm.rfm_recency,
    rfm.rfm_frequency,
    rfm.rfm_monetary,
    CASE
        WHEN rfm.rfm_recency IN (2, 3, 4) AND rfm.rfm_frequency = 4 AND rfm.rfm_monetary = 4 THEN 'Champion' 
        WHEN rfm.rfm_recency = 3 AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (3, 4) THEN 'Top Spent Regular Customer'
        WHEN rfm.rfm_recency = 3 AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (1, 2) THEN 'Regular Customer'
        WHEN rfm.rfm_recency = 4 AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (3, 4) THEN 'Top Spent New Customer'
        WHEN rfm.rfm_recency = 4 AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (1, 2) THEN 'New Customer'
        WHEN rfm.rfm_recency IN (2, 3) AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (3, 4) THEN 'Top Spent Customer Needed Attention'
        WHEN rfm.rfm_recency IN(2, 3) AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (1, 2) THEN 'Customer Needed Attention'
        WHEN rfm.rfm_recency = 1 AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (3, 4) THEN 'Top Spent Lost Customer'
        WHEN rfm.rfm_recency = 1 AND rfm.rfm_frequency IN (1, 2, 3, 4) AND rfm.rfm_monetary IN (1, 2) THEN 'Lost Customer'
    END AS rfm_segment
INTO final_data_table
FROM
    sales_data_sample sds
JOIN
    #rfm rfm ON sds.CUSTOMERNAME = rfm.CUSTOMERNAME

SELECT
	*
FROM
	final_data_table



--- INSIGHTS
--- For new customers, it can make discount campaign. Thanks to this, they come more before.
--- For top spent customer needed attention segment, it can make special campaign according to customers' demands.
--- For lost customer, it can research one by one. According to this, it can decide what to do.

-- well, how many people are segments?

WITH cte_rfm AS(
SELECT
	CUSTOMERNAME, 
	rfm_recency, 
	rfm_frequency, 
	rfm_monetary,
	CASE
		WHEN rfm_recency IN (2, 3, 4) AND rfm_frequency = 4 AND rfm_monetary = 4 THEN 'Champion' 
		WHEN rfm_recency = 3 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent Regular Customer'
		WHEN rfm_recency = 3 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'Regular Customer'
		WHEN rfm_recency = 4 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent New Customer'
		WHEN rfm_recency = 4 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'New Customer'
		WHEN rfm_recency IN (2, 3) AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent Customer Needed Attention'
		WHEN rfm_recency IN(2, 3) AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'Customer Needed Attention'
		WHEN rfm_recency = 1 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (3, 4) THEN 'Top Spent Lost Customer'
		WHEN rfm_recency = 1 AND rfm_frequency IN (1, 2, 3, 4) AND rfm_monetary IN (1, 2) THEN 'Lost Customer'
		END rfm_segment
FROM
	#rfm
	)
SELECT
	*
FROM
	(
	SELECT
		rfm_segment,
		B.CUSTOMERNAME
	FROM
		cte_rfm AS C
		INNER JOIN sales_data_sample AS B 
		ON C.CUSTOMERNAME = B.CUSTOMERNAME
	) AS A
PIVOT
	(
	COUNT(rfm_segment)
	FOR
		rfm_segment
	IN ([Champion], [Top Spent Regular Customer], [Regular Customer], [Top Spent New Customer],
	    [New Customer], [Top Spent Customer Needed Attention], [Customer Needed Attention],
		[Top Spent Lost Customer], [Lost Customer])
	) AS pivot_table_rfm;


SELECT
	*
FROM
	sales_data_sample
WHERE
	CUSTOMERNAME = 'Rovelli Gifts';
	666
-- What products are most often sold together?

SELECT
	*
FROM
	sales_data_sample;
--------
-- INSIGHTS
-- Company that bought more than one train didn't buy motorcycles.
-- Company that bought more than one motorcycles didn't bought not only train but also trucks and buses.
WITH cte AS(
SELECT
	*
FROM
	(
	SELECT	
		ORDERNUMBER,
		PRODUCTLINE
	FROM
		sales_data_sample
	) AS A
PIVOT
	(
	COUNT(PRODUCTLINE)
	FOR
		PRODUCTLINE
		IN ([Trains], [Motorcycles], [Ships], [Trucks and Buses], [Vintage Cars], [Classic Cars], [Planes])
	) AS pivot_table_line)
SELECT
	*
FROM
	cte
WHERE
	Planes > 0
ORDER BY 
	8 DESC;

---
WITH cte AS (
    SELECT
        ORDERNUMBER,
        [Trains],
        [Motorcycles],
        [Ships],
        [Trucks and Buses],
        [Vintage Cars],
        [Classic Cars],
        [Planes]
    FROM
        sales_data_sample
    PIVOT
        (
        COUNT(PRODUCTLINE)
        FOR
            PRODUCTLINE IN ([Trains], [Motorcycles], [Ships], [Trucks and Buses], [Vintage Cars], [Classic Cars], [Planes])
        ) AS pivot_table_line
)
SELECT
    ORDERNUMBER,
    STRING_AGG(PRODUCTLINE, ', ') AS ProductsSoldTogether
FROM
    (
    SELECT
        ORDERNUMBER,
        CASE
            WHEN [Trains] > 0 THEN 'Trains'
            WHEN [Motorcycles] > 0 THEN 'Motorcycles'
            WHEN [Ships] > 0 THEN 'Ships'
            WHEN [Trucks and Buses] > 0 THEN 'Trucks and Buses'
            WHEN [Vintage Cars] > 0 THEN 'Vintage Cars'
            WHEN [Classic Cars] > 0 THEN 'Classic Cars'
            WHEN [Planes] > 0 THEN 'Planes'
        END AS PRODUCTLINE
    FROM
        cte
    ) AS Products
GROUP BY
    ORDERNUMBER
HAVING
    COUNT(*) > 1; -- En az iki farklý ürün birlikte satýlmýþ olmalý

-- another solution for this problem. 

SELECT
	*
FROM
	sales_data_sample
WHERE ORDERNUMBER IN
	(
	SELECT
		ORDERNUMBER
	FROM
	(
	SELECT
		ORDERNUMBER,
		COUNT(*) AS rn
	FROM
		sales_data_sample
	WHERE
		STATUS = 'Shipped'
	GROUP BY
		ORDERNUMBER
	) AS n
	WHERE rn = 2 -- 19 rows
	); -- 38 rows

SELECT
	',' + PRODUCTCODE
FROM
	sales_data_sample
WHERE ORDERNUMBER IN
	(
	SELECT
		ORDERNUMBER
	FROM
	(
	SELECT
		ORDERNUMBER,
		COUNT(*) AS rn
	FROM
		sales_data_sample
	WHERE
		STATUS = 'Shipped'
	GROUP BY
		ORDERNUMBER
	) AS n
	WHERE rn = 2 -- 19 rows
	) -- 38 rows
	for xml path('');


SELECT DISTINCT ORDERNUMBER, STUFF(

	(
	SELECT
		',' + PRODUCTCODE
	FROM
		sales_data_sample AS c
	WHERE ORDERNUMBER IN
		(
		SELECT
			ORDERNUMBER
		FROM
		(
		SELECT
			ORDERNUMBER,
			COUNT(*) AS rn
		FROM
			sales_data_sample
		WHERE
			STATUS = 'Shipped'
		GROUP BY
			ORDERNUMBER
		) AS n
		WHERE rn = 3
		) 
		AND c.ORDERNUMBER = b.ORDERNUMBER
		for xml path('')),
		1, 1, '')
FROM 
	sales_data_sample AS b
ORDER BY 
	2 DESC

---https://youtu.be/O2hlHzehZb0?t=2638 --43:58



