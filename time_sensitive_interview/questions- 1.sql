--You should report count of orders, Website sales rate, Inbound call sales rate, outbound call sales rate and number of different agents for each hour.

--There are three type of orders. One order is may be online, outbound or inbound. 
--For outbound call there must be an agent. For inbound call there mustn't be an agent.

----PRACTICE

SELECT
	COUNT(*) AS count_of_orders,
	CAST(100.0 * SUM(website) / COUNT(*) AS DECIMAL(10,2)) AS website_sales_rate,
	CAST(100.0 * SUM(inbound) / COUNT(*) AS DECIMAL(10,2)) AS inbound_sales_rate,
	CAST(100.0 * SUM(outbound) / COUNT(*) AS DECIMAL(10,2)) AS website_sales_rate
FROM(
SELECT
	*,
	CASE WHEN transaction_type != 'Online' AND sales_agent IS NOT NULL THEN 1 ELSE 0 END AS outbound,
	CASE WHEN transaction_type != 'Online' AND sales_agent IS NULL THEN 1 ELSE 0 END AS inbound,
	CASE WHEN transaction_type = 'Online' THEN 1 ELSE 0 END AS website,
	COUNT(DISTINCT sales_agent) OVER(PARTITION BY [hour]) AS hour_count
FROM( VALUES
	('8:00', 'ABC123', 'Online', NULL),
	('8:00', 'ABC123', 'Online', NULL),
	('8:00', 'XYZ789', 'Online', NULL),
	('8:00', 'XYZ789', 'Phone', NULL),
	('9:30', 'DEF456', 'Phone', 'John'),
	('9:30', 'GHI789', 'Online', 'John'),
	('10:15', 'XYZ789', 'Phone', 'John'),
	('10:15', 'GHI789', 'Online', NULL),
	('10:15', 'GHI789', 'Phone', NULL),
	('10:15', 'DEF456', 'Phone', 'Jane'),
	('10:15', 'GHI789', 'Phone', NULL)) AS table1 ([hour], [product_code], [transaction_type],
													[sales_agent])) AS report_table
/*
hour	product_code	transaction_type	sales_agent
8:00	ABC123				Online				NULL
8:00	ABC123				Online				NULL
8:00	XYZ789				Online				NULL
8:00	XYZ789				Phone				NULL
9:30	DEF456				Phone				John
9:30	GHI789				Online				John
10:15	XYZ789				Phone				John
10:15	GHI789				Online				NULL
10:15	GHI789				Phone				NULL
10:15	DEF456				Phone				Jane
10:15	GHI789				Phone				NULL
*/

--SOLUTION
WITH CTE AS (
    SELECT
        [hour],
        COUNT(*) AS count_of_orders,
        SUM(CASE WHEN transaction_type = 'Online' THEN 1 ELSE 0 END) AS website_orders,
        SUM(CASE WHEN transaction_type = 'Phone' AND sales_agent IS NULL THEN 1 ELSE 0 END) AS inbound_orders,
        SUM(CASE WHEN transaction_type = 'Phone' AND sales_agent IS NOT NULL THEN 1 ELSE 0 END) AS outbound_orders,
        COUNT(DISTINCT sales_agent) AS num_agents
    FROM (
        VALUES
            ('8:00', 'ABC123', 'Online', NULL),
            ('8:00', 'ABC123', 'Online', NULL),
            ('8:00', 'XYZ789', 'Online', NULL),
            ('8:00', 'XYZ789', 'Phone', NULL),
            ('9:30', 'DEF456', 'Phone', 'John'),
            ('9:30', 'GHI789', 'Online', 'John'),
            ('10:15', 'XYZ789', 'Phone', 'John'),
            ('10:15', 'GHI789', 'Online', NULL),
            ('10:15', 'GHI789', 'Phone', NULL),
            ('10:15', 'DEF456', 'Phone', 'Jane'),
            ('10:15', 'GHI789', 'Phone', NULL)
    ) AS table1 ([hour], [product_code], [transaction_type], [sales_agent])
    GROUP BY [hour]
)
SELECT
    [hour],
    count_of_orders,
    CAST(100.0 * website_orders / count_of_orders AS DECIMAL(10, 2)) AS website_sales_rate,
    CAST(100.0 * inbound_orders / count_of_orders AS DECIMAL(10, 2)) AS inbound_sales_rate,
    CAST(100.0 * outbound_orders / count_of_orders AS DECIMAL(10, 2)) AS outbound_sales_rate,
    num_agents
FROM CTE;








--------------/////////////////////
---------------////////////////////////





-------Write a query that returns the source of users. Users must have only one client. 
--For multiple sources, print ‘multiple’.


/*
user_id	client_id	source
A23bc	101			API
A23bc	101			API
A23bc	101			API
X9PqW	202			Mobile App
X9PqW	202			Website
X9PqW	202			Social Media
G7RtZ	808			Mobile App
G7RtZ	303			Mobile App
G7RtZ	303			Mobile App
T5Yhn	404			Website
T5Yhn	405			Social Media
T5Yhn	406			Social Media
K8Mju	505			Website
K8Mju	505			Website
K8Mju	505			Website
E4Sdf	606			Mobile App
E4Sdf	606			API
E4Sdf	606			API
*/

SELECT
	*,
	COUNT(client_id) OVER(PARTITION BY user_id) num_of_client,
	CASE WHEN COUNT(client_id) OVER(PARTITION BY user_id) > 1 THEN 'Multiple' ELSE CASE WHEN source = 'API' THEN 'API' ELSE 'Website'END END AS source_of_users

FROM(
SELECT	
	DISTINCT *	
FROM( VALUES    ('A23bc', 101, 'API'),
    ('A23bc', 101, 'API'),
    ('A23bc', 101, 'API'),
    ('X9PqW', 202, 'Mobile App'),
    ('X9PqW', 202, 'Website'),
    ('X9PqW', 202, 'Social Media'),
    ('G7RtZ', 808, 'Mobile App'),
    ('G7RtZ', 303, 'Mobile App'),
    ('G7RtZ', 303, 'Mobile App'),
    ('T5Yhn', 404, 'Website'),
    ('T5Yhn', 405, 'Social Media'),
    ('T5Yhn', 406, 'Social Media'),
    ('K8Mju', 505, 'Website'),
    ('K8Mju', 505, 'Website'),
    ('K8Mju', 505, 'Website'),
    ('E4Sdf', 606, 'Mobile App'),
    ('E4Sdf', 606, 'API'),
    ('E4Sdf', 606, 'API')) as table1 ([user_id], [client_id], [source])) AS subq















