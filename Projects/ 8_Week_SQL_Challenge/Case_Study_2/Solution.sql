-- Information

---All column names in my view are underlined in red in SSMS
---Or, using the menu: Edit -> IntelliSense -> Refresh Local Cache

/*To change the Prevent saving changes that require the table re-creation option, follow these steps:

Open SQL Server Management Studio.

On the Tools menu, click Options.

In the navigation pane of the Options window, click Designers.

Select or clear the Prevent saving changes that require the table re-creation check box, and then click OK. */


USE pizza_runner;

SELECT
	*
FROM
	pizza_runner.pizza_recipes;

-- Question 1) How many pizzas were ordered?

SELECT
	COUNT(order_id) AS count_of_pizzas
FROM
	pizza_runner.customer_orders;
--Answer = 14

-- Question 2) How many unique customer orders were made?

SELECT
	COUNT(DISTINCT A.customer_id) AS count_of_customer
FROM
	pizza_runner.customer_orders AS A;
--Answer = 5


-- Question 3) How many successful orders were delivered by each runner?

SELECT
	runner_id,
	COUNT(*) AS succesful_orders
FROM
	pizza_runner.runner_orders
