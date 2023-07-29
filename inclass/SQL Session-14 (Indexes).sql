--SQL Session-14, 29.07.2023, (Indexes)

--Bir sorgunun en performanslý hali idealde sorgu costunun %100 Index Seek yöntemi ile 
--getiriliyor olmasýdýr!


--creating a new table
---------------------------------------------------
CREATE DATABASE new_database


--inserting random values into the table
---------------------------------------------------
CREATE TABLE website_visitor(
		visitor_id int IDENTITY(1,1),
		first_name varchar(50),
		last_name varchar(50),
		phone_number bigint,
		city varchar(50)
);

DECLARE @i int = 1
DECLARE @RAND AS INT
WHILE @i<200000
BEGIN
SET @RAND = RAND()*81
INSERT website_visitor
SELECT
'visitor_name' + cast (@i as varchar(20))
,'visitor_surname' + cast (@i as varchar(20))
,5326559632 + @i 
,'city' + cast(@RAND as varchar(2))
SET @i +=1
END;

SELECT
	*
FROM
	website_visitor

--STATISTICS
---------------------------------------------------

SET STATISTICS IO ON
--SET STATISTICS TIME ON



--without primary key/clustered index
---------------------------------------------------

SELECT
	TOP 1 *
FROM
	website_visitor
WHERE
	visitor_id = 100 -- table scan

SELECT 1879 * 8 --~15 mb

EXEC sp_spaceused website_visitor --stored procedure --first 15032 KB second 15304 KB


SELECT
	*
FROM
	website_visitor
WHERE
	last_name = 'visitor_surname77' 



--with primary key/clustered index
---------------------------------------------------

--CREATE CLUSTERED INDEX cls_idx ON  website_visitor(visitor_id)
--or
--ALTER TABLE website_visitor
--ADD CONSTRAINT pk_idx PRIMARY KEY(visitor_id)




--without nonclustered index
---------------------------------------------------

SELECT
	*
FROM
	website_visitor
WHERE
	first_name = 'visitor_name200' 







--with nonclustered index
---------------------------------------------------



CREATE NONCLUSTERED INDEX ncls_idx ON website_visitor(first_name)

SELECT
	*
FROM
	website_visitor
WHERE
	first_name = 'visitor_name200' 

--key lookup
EXEC sp_spaceused website_visitor 
/* name	rows	reserved	data	index_size	unused
website_visitor	199999    22416 KB	14488 KB	6528 KB	1400 KB */

--with nonclustered index and multiple columns
---------------------------------------------------

CREATE INDEX ncls_idx
ON website_visitor(first_name)
INCLUDE ([last_name], [phone_number], [city])
WITH(DROP_EXISTING= ON) --it is run on previous ncls_idx

SELECT
	*
FROM
	website_visitor
WHERE
	first_name = 'visitor_name200' 

EXEC sp_spaceused website_visitor 

/*
name	rows	reserved	data	index_size	unused
website_visitor	199999              	30096 KB	14488 KB	14232 KB	1376 KB*/






--filtering another column of nonclustered index
---------------------------------------------------


SELECT
	*
FROM
	website_visitor
WHERE
	city = 'city44' 
ORDER BY
	last_name

--it is useful seperately to create nonclustered index .

---sql sometimes advice for index . for example ;

CREATE NONCLUSTERED INDEX [xxx]
ON [dbo].[website_visitor] ([city])
INCLUDE ([first_name],[last_name],[phone_number])
---Primary key usually must be numeric and identity . 
