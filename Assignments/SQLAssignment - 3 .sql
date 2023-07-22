/* Discount Effects

Generate a report including product IDs and discount effects on whether the increase in the discount rate positively impacts the number of orders for the products.

In this assignment, you are expected to generate a solution using SQL with a logical approach. */

--prepration
SELECT
	a.product_id,
	a.discount,
	COUNT(a.order_id)
FROM
	sale.order_item AS a
	LEFT JOIN product.product AS b ON b.product_id = a.product_id
GROUP BY
	a.product_id,
	a.discount

ORDER BY
	a.product_id
-------------
SELECT
	discount,
	COUNT(order_id)
FROM
	sale.order_item AS a
WHERE
	a.product_id = 3
GROUP BY
	discount
ORDER BY 
	discount
--------------------
--------------------
--SOLUTION--
--- according to correlation between discount and quantity, we can say whether discount is relation with quantity
--- you can visit https://medium.com/machine-learning-t%C3%BCrkiye/korelasyon-katsay%C4%B1s%C4%B1-python-uygulamas%C4%B1-de83ea37ff23 for correlation coefficient formula . 
SELECT
	product_id,
	--correlation,
	CASE
		WHEN correlation < 0 THEN 'Negative' 
		WHEN correlation = 0 THEN 'Neutral'
		WHEN correlation > 0 THEN 'Positive'
	END AS [Discount Effect]
FROM(
SELECT
  product_id,
  (
    SUM((discount - avg_discount) * (quantity - avg_quantity))
    / (COUNT(*) - 1) 
  ) / (CASE WHEN STDEV(discount) = 0 THEN 1 ELSE STDEV(discount) END * CASE WHEN STDEV(quantity) = 0 THEN 1 ELSE STDEV(quantity) END) as correlation
FROM (
  SELECT
    product_id,
    discount,
    quantity,
    AVG(discount) OVER(PARTITION BY product_id) as avg_discount,
    AVG(quantity * 1.0) OVER(PARTITION BY product_id) as avg_quantity
  FROM sale.order_item
) as subquery
GROUP BY product_id
HAVING COUNT(*) > 1
) AS corelation





