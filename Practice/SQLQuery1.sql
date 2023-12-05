SELECT *
FROM sale.staff

SELECT model_year
FROM product.product

SELECT *
FROM sale.staff AS A
WHERE A.first_name = 'James'

-- ilk SQL calismam --

SELECT A.staff_id
FROM sale.staff AS A
WHERE A.first_name = 'James' 

/*
SELECT A.staff_id
FROM sale.staff AS A
WHERE A.first_name = 'James' 
*/
