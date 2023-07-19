/*List the product names in ascending order where the part from the beginning to the first space character is "Samsung" in the product_name column.

(Use SampleRetail Database and paste your result in the box below.)*/

SELECT
	a.product_name
FROM
	product.product AS a
WHERE
	a.product_name LIKE 'Samsung %'
ORDER BY
	a.product_name

SELECT
    a.product_name
FROM
    product.product AS a
WHERE
    a.product_name COLLATE SQL_Latin1_General_CP1_CS_AS LIKE 'Samsung%'
ORDER BY
    a.product_name;

SELECT
	a.street
FROM
	sale.customer AS a
WHERE
	a.street LIKE '%#[0-4]'
ORDER BY
	a.street