SELECT
	byte = SUM(DATALENGTH(product_name) + 2) * 30
FROM
	product.product

SELECT
	*
FROM
	sys.objects

SELECT
	*
FROM
	sys.columns

SELECT
	o.name [Table Name],
	c.name[Column Name],
	TYPE_NAME(user_type_id) [Data Type]
FROM
	sys.objects AS o
	INNER JOIN sys.columns c ON o.object_id = c.object_id
WHERE
	type_desc = 'USER_TABLE'