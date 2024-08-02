-- Information

---All column names in my view are underlined in red in SSMS
---Or, using the menu: Edit -> IntelliSense -> Refresh Local Cache

/*To change the Prevent saving changes that require the table re-creation option, follow these steps:

Open SQL Server Management Studio.

On the Tools menu, click Options.

In the navigation pane of the Options window, click Designers.

Select or clear the Prevent saving changes that require the table re-creation check box, and then click OK. */


USE pizza_runner;


--- Before working in SQL, must be clean column and must be prepare tables for analysis.

-- 1) Correcting the NULL and empty string ('') values in the columns to be NULL
Select * from pizza_runner.customer_orders;
select DISTINCT exclusions from pizza_runner.customer_orders;
select DISTINCT extras from pizza_runner.customer_orders;

select order_id,
		customer_id,
		pizza_id,
		case when exclusions = 'null' or exclusions = ''  then NULL else exclusions END as exclusions,
		case when extras = 'null' or extras = ''  then NULL else extras END as extras,
		order_time
FROM pizza_runner.customer_orders;

-- 2)Clean pickup_time, distance, duration, and cancellation columns

-- a) Update invalid pickup_time values to NULL
UPDATE pizza_runner.runner_orders
SET pickup_time = NULL
WHERE ISDATE(pickup_time) = 0;


-- b)Correction of km, min, mins, minute, minutes expressions found in columns
UPDATE pizza_runner.runner_orders
SET 
   pickup_time = CASE
        WHEN pickup_time = 'null' THEN NULL 
        ELSE pickup_time 
    END,
    distance = CASE
        WHEN distance = 'null' THEN NULL
        WHEN distance LIKE '%km' THEN REPLACE(distance, 'km', '') 
        ELSE distance
    END,
    duration = CASE
        WHEN duration = 'null' THEN NULL
        WHEN duration LIKE '%mins' THEN REPLACE(duration, 'mins', '')
        WHEN duration LIKE '%minute' THEN REPLACE(duration, 'minute', '')
        WHEN duration LIKE '%minutes' THEN REPLACE(duration, 'minutes', '')
        ELSE duration
    END,
    cancellation = CASE
        WHEN cancellation = 'null' OR cancellation = '' THEN NULL 
        ELSE cancellation 
    END;



-- c) Clean exclusions and extras columns
UPDATE pizza_runner.customer_orders
SET exclusions = CASE
    WHEN exclusions = 'null' OR exclusions = '' THEN NULL 
    ELSE exclusions
END; 

UPDATE pizza_runner.customer_orders
SET extras = CASE
    WHEN extras = 'null' OR extras = '' THEN NULL 
    ELSE extras
END;


-- d) Change `pickup_time` to `DATETIME`
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN pickup_time DATETIME;

-- e) Change `distance` to `FLOAT`
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN distance FLOAT;

-- f) Change `duration` to `INT`
ALTER TABLE pizza_runner.runner_orders
ALTER COLUMN duration INT;

--- START

-- Question 1) How many pizzas were ordered?

SELECT
	COUNT(order_id) AS count_of_pizzas
FROM
	pizza_runner.customer_orders;

-- Question 2) How many unique customer orders were made?

SELECT
	COUNT(DISTINCT A.customer_id) AS count_of_customer
FROM
	pizza_runner.customer_orders AS A;

-- Question 3) How many successful orders were delivered by each runner?

SELECT
	runner_id,
	COUNT(*) AS successful_orders
FROM
	pizza_runner.runner_orders
WHERE
	cancellation IS NULL
GROUP BY
	runner_id;

-- Question 4) How many of each type of pizza was delivered?

SELECT
	b.pizza_name,
	COUNT(a.order_id) AS delivered_count
FROM
	pizza_runner.customer_orders AS a
	JOIN pizza_runner.pizza_names AS b ON a.pizza_id = b.pizza_id
GROUP BY
	b.pizza_name;

-- Question 5) How many Vegetarian and Meatlovers were ordered by each customer?
