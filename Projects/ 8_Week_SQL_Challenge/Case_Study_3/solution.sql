USE foodie_fi;

SELECT
	*
FROM
	plans;

SELECT 
	*
FROM	
	subscriptions;


SELECT
	*
FROM
	plans AS a
JOIN 
	subscriptions as b
ON
	a.plan_id = b.plan_id