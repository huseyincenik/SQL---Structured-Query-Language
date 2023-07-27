

--You should report count of orders, Website sales rate, Inbound call sales rate, outbound call sales rate and number of different agents for each hour.

--There are three type of orders. One order is may be online, outbound or inbound. For outbound call there must be an agent. For inbound call there mustn't be an agent.


/*
hour	product_code	transaction_type	sales_agent
8:00	ABC123	Online	NULL
8:00	ABC123	Online	NULL
8:00	XYZ789	Online	NULL
8:00	XYZ789	Phone	NULL
9:30	DEF456	Phone	John
9:30	GHI789	Online	John
10:15	XYZ789	Phone	John
10:15	GHI789	Online	NULL
10:15	GHI789	Phone	NULL
10:15	DEF456	Phone	Jane
10:15	GHI789	Phone	NULL
*/




CREATE TABLE table1 (
    hour time,
    product_code VARCHAR(10),
    transaction_type VARCHAR(20),
    sales_agent VARCHAR(10)
);


INSERT INTO table1 
VALUES ('8:00', 'ABC123', 'Online', NULL),
		('8:00', 'ABC123', 'Online', NULL),
		('8:00', 'XYZ789', 'Online', NULL),
		('8:00', 'XYZ789', 'Phone', NULL),
		('9:30', 'DEF456', 'Phone', 'John'),
		('9:30', 'GHI789', 'Online', 'John'),
		('10:15', 'XYZ789', 'Phone', 'John'),
		('10:15', 'GHI789', 'Online', NULL),
		('10:15', 'GHI789', 'Phone', NULL),
		('10:15', 'DEF456', 'Phone', 'Jane'),
		('10:15', 'GHI789', 'Phone', NULL);


-----

SELECT		hour,
			count(*) total_orders,
			FORMAT (1.0*SUM(CASE WHEN transaction_type = 'Online' Then 1 else 0 end) / COUNT(*) , 'P2')  website,
			FORMAT (1.0*SUM(CASE WHEN transaction_type = 'Phone' AND sales_agent IS NULL Then 1 else 0 end) / COUNT(*), 'P2') inbound_call,
			FORMAT (1.0*SUM(CASE WHEN transaction_type = 'Phone' AND sales_agent IS NOT NULL Then 1 else 0 end) / COUNT(*), 'P2') outbound_call,
			COUNT(DISTINCT sales_agent) distinct_agents
FROM		table1
GROUP BY	hour






----Write a query that returns the source of users. Users must have only one client. 
--For multiple sources, print ‘multiple’.




/*
user_id	client_id	source
A23bc	101	API
A23bc	101	API
A23bc	101	API
X9PqW	202	Mobile App
X9PqW	202	Website
X9PqW	202	Social Media
G7RtZ	808	Mobile App
G7RtZ	303	Mobile App
G7RtZ	303	Mobile App
T5Yhn	404	Website
T5Yhn	405	Social Media
T5Yhn	406	Social Media
K8Mju	505	Website
K8Mju	505	Website
K8Mju	505	Website
E4Sdf	606	Mobile App
E4Sdf	606	API
E4Sdf	606	API
*/

CREATE TABLE table2 (
    user_id VARCHAR(10),
    client_id VARCHAR(10),
    source VARCHAR(20)
);


INSERT INTO table2 
VALUES ('A23bc', '101', 'API'),
		('A23bc', '101', 'API'),
		('A23bc', '101', 'API'),
		('X9PqW', '202', 'Mobile App'),
		('X9PqW', '202', 'Website'),
		('X9PqW', '202', 'Social Media'),
		('G7RtZ', '808', 'Mobile App'),
		('G7RtZ', '303', 'Mobile App'),
		('G7RtZ', '303', 'Mobile App'),
		('T5Yhn', '404', 'Website'),
		('T5Yhn', '405', 'Social Media'),
		('T5Yhn', '406', 'Social Media'),
		('K8Mju', '505', 'Website'),
		('K8Mju', '505', 'Website'),
		('K8Mju', '505', 'Website'),
		('E4Sdf', '606', 'Mobile App'),
		('E4Sdf', '606', 'API'),
		('E4Sdf', '606', 'API');




WITH T1 AS 
(
SELECT		user_id,
			COUNT(DISTINCT source) disticnt_source
FROM		table2
GROUP BY	user_id
HAVING		COUNT(DISTINCT client_id) = 1

) 
SELECT	DISTINCT A.user_id, A.client_id, 
		CASE WHEN disticnt_source > 1 THEN 'multiple' else source END source
FROM	table2 A INNER JOIN T1 ON A.user_id = T1.user_id


