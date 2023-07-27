---query time - 1
----SQL Programming Basics

CREATE PROCEDURE
	sp_sampleproc_2 AS

BEGIN
	SELECT 'Hello World' AS [Message]
END;

EXECUTE sp_sampleproc_2

EXEC sp_sampleproc_2

------------------
ALTER PROCEDURE
	sp_sampleproc_2 AS

BEGIN
	PRINT 'Hello World' 
END;

EXEC sp_sampleproc_2



---------------------
CREATE TABLE ORDER_TBL
(
ORDER_ID TINYINT NOT NULL,
CUSTOMER_ID TINYINT NOT NULL,
CUSTOMER_NAME VARCHAR(50),
ORDER_DATE DATE,
EST_DELIVERY_DATE DATE--estimated delivery date
);
INSERT ORDER_TBL VALUES (1, 1, 'Adam', GETDATE()-10, GETDATE()-5 ),
						(2, 2, 'Smith',GETDATE()-8, GETDATE()-4 ),
						(3, 3, 'John',GETDATE()-5, GETDATE()-2 ),
						(4, 4, 'Jack',GETDATE()-3, GETDATE()+1 ),
						(5, 5, 'Owen',GETDATE()-2, GETDATE()+3 ),
						(6, 6, 'Mike',GETDATE(), GETDATE()+5 ),
						(7, 6, 'Rafael',GETDATE(), GETDATE()+5 ),
						(8, 7, 'Johnson',GETDATE(), GETDATE()+5 )

SELECT
	*
FROM
	ORDER_TBL


-----------
CREATE TABLE ORDER_DELIVERY
(
ORDER_ID TINYINT NOT NULL,
DELIVERY_DATE DATE -- tamamlanan delivery date
);
INSERT ORDER_DELIVERY VALUES (1, GETDATE()-6 ),
				(2, GETDATE()-2 ),
				(3, GETDATE()-2 ),
				(4, GETDATE() ),
				(5, GETDATE()+2 ),
				(6, GETDATE()+3 ),
				(7, GETDATE()+5 ),
				(8, GETDATE()+5 )
--------------------------------------
SELECT
	*
FROM
	ORDER_DELIVERY

-------------------
;CREATE PROC sp_ord_count_1 AS
BEGIN
	SELECT	COUNT(ORDER_ID)
	FROM ORDER_TBL
END;

EXEC sp_ord_count_1

-------------------

;CREATE PROC sp_ord_count_2 AS
BEGIN
	SELECT	MAX(ORDER_ID)
	FROM ORDER_TBL
END;

EXEC sp_ord_count_2

INSERT ORDER_TBL VALUES(9,9, NULL, NULL, NULL)

--WHEN WE UPDATE ORDER_TBL , SP_ORD_COUNT_2 IS UPDATE AUTOMATICALLY

SELECT
	*
FROM
	ORDER_TBL

EXEC sp_ord_count_2

----------------------

CREATE PROC sp_sample_proc3 (@ORD_DATE DATE)
AS
BEGIN
	SELECT
		COUNT(ORDER_ID)
	FROM
		ORDER_TBL
	WHERE
		ORDER_DATE = @ORD_DATE
END;

EXEC sp_sample_proc3 '2023-07-27'

--istenilen müþterinin istenilen tarihteki sipariþ bilgilerini döndüren bir proc . tanimlayin.

ALTER PROC sp_customer_orders_1(@CUSTOMER_NAME VARCHAR(50), @ORDER_DATE DATE = '2023-7-21')
AS
BEGIN
	SELECT	*
	FROM
		ORDER_TBL
	WHERE 
		CUSTOMER_NAME = @CUSTOMER_NAME
		AND ORDER_DATE = @ORDER_DATE

END;

EXEC sp_customer_orders_1 'Jack';
--while we write parameter for procedure , we can not use paranthess.
EXEC sp_customer_orders_1 'Jack' , '2023-07-24';

----------------------
-----Query Variable



----DEFINE VARIABLES
DECLARE @V1 INT
DECLARE	@V2 INT
DECLARE @RESULT INT

----------------------
DECLARE @V1 INT, @V2 INT, @RESULT INT

---ASSIGN VALUES TO VARIABLES

SET @V1 = 5

SELECT @V2 = 6

SELECT @RESULT = @V1 * @V2

---SELECT @V1 = 5, @V2 = 6 , @RESULT = @V1 * @V2

---CALL
PRINT @RESULT
SELECT
	 @RESULT

	 ------
DECLARE @V1 INT = 5, @V2 INT = 6, @RESULT INT = @V1* @V2 --ERROR
SELECT @RESULT


DECLARE @V1 INT = 5, @V2 INT = 6
DECLARE @RESULT INT = @V1* @V2
SELECT @RESULT

-----
DECLARE @CUST_ID INT

SET @CUST_ID = 1 ---

SELECT *
FROM
	ORDER_TBL
WHERE CUSTOMER_ID = @CUST_ID

DECLARE @CUST_ID INTSELECT *FROM ORDER_TBLWHERE CUSTOMER_ID = @CUST_ID

--------------

---IF , ELSE IF, ELSE

IF CONDITION_1	
	SELECT...

ELSE IF CONDITION_2	
	SELECT ...

ELSE
	SELECT ...

;SELECT
	*
FROM
	ORDER_TBL

SELECT
	*
FROM
	ORDER_DELIVERY
------
DECLARE @ORDER INT
DECLARE @EST_DEL_DATE DATE
DECLARE @DEL_DATE DATE

SET @ORDER = 5

SELECT--firstly , variable name is written left of equal . 
	 @EST_DEL_DATE = EST_DELIVERY_DATE 
FROM
	ORDER_TBL
WHERE
	ORDER_ID = @ORDER


SELECT
	@DEL_DATE = DELIVERY_DATE
FROM
	ORDER_DELIVERY
WHERE
	ORDER_ID = @ORDER
--SELECT @EST_DEL_DATE, @DEL_DATE

IF @EST_DEL_DATE = @DEL_DATE
	PRINT 'ON TIME'
ELSE IF @EST_DEL_DATE > @DEL_DATE
	PRINT 'EARLY'
ELSE PRINT 'LATE'
--
--with join

DECLARE @ORDER INT
DECLARE @EST_DEL_DATE DATE
DECLARE @DEL_DATE DATE

SET @ORDER = 5

SELECT--firstly , variable name is written left of equal . 
	 @EST_DEL_DATE = EST_DELIVERY_DATE,
	 @DEL_DATE = DELIVERY_DATE

FROM
	ORDER_TBL AS A
	INNER JOIN ORDER_DELIVERY AS B ON B.ORDER_ID = A.ORDER_ID
WHERE
	A.ORDER_ID = @ORDER

IF @EST_DEL_DATE = @DEL_DATE
	PRINT 'ON TIME'
ELSE IF @EST_DEL_DATE > @DEL_DATE
	PRINT 'EARLY'
ELSE PRINT 'LATE'
--
SELECT
	*
FROM
	ORDER_TBL A , ORDER_DELIVERY B
WHERE	
	A.ORDER_ID = B.ORDER_ID

SELECT
	*
FROM
	ORDER_TBL


---- I must hands on in this subject . 
---
--EXISTS , NOT EXISTS

IF EXISTS (SELECT 1)
	PRINT 'YES'
ELSE
	PRINT 'NO'

IF NOT EXISTS (SELECT 1)
	PRINT 'YES'
ELSE
	PRINT 'NO'

---Ýstenilen tarihte verilen sipariþ sayýsý 2 ten küçükse 'lower than 2',
-- 2 ile 5 arasýndaysa sipariþ sayýsý, 5' den büyükse 'upper than 5' yazdýran bir sorgu yazýnýz.
DECLARE @ORD_DATE DATE
DECLARE @ORDER_CNT INT

SET @ORD_DATE = '2023-07-27'

		SELECT
			 @ORDER_CNT  = COUNT(ORDER_ID) 
		FROM
			ORDER_TBL
		WHERE
			@ORD_DATE = ORDER_DATE 

IF @ORDER_CNT < 2
	PRINT 'Lower Than 2'
ELSE IF @ORDER_CNT BETWEEN 2 AND 5
	SELECT @ORDER_CNT
ELSE 
	PRINT 'Upper Than 5'

--teacher solution

DECLARE @DATE DATE
DECLARE @ORDER_CNT INT

SET @DATE = '2023-07-27'

SELECT
	@ORDER_CNT = COUNT(ORDER_ID)
FROM
	ORDER_TBL
WHERE
	ORDER_DATE = @DATE

IF @ORDER_CNT < 2
	PRINT 'LOWER THAN TWO'
ELSE IF @ORDER_CNT BETWEEN 2 AND 5
	SELECT @ORDER_CNT
ELSE
	PRINT 'UPPER THAN FIVE'
	

---
--with stored_procedure

CREATE PROC sp_date_count (@DATE DATE)
AS
BEGIN
--DECLARE @DATE DATE
DECLARE @ORDER_CNT INT

SELECT
	@ORDER_CNT = COUNT(ORDER_ID)
FROM
	ORDER_TBL
WHERE
	ORDER_DATE = @DATE

IF @ORDER_CNT < 2
	PRINT 'LOWER THAN TWO'
ELSE IF @ORDER_CNT BETWEEN 2 AND 5
	SELECT @ORDER_CNT
ELSE
	PRINT 'UPPER THAN FIVE'

END;

EXEC sp_date_count '2023-07-28'


---WHILE LOOPS

---start value

---ending value

---iteration command

DECLARE @START INT ,@END INT

SET @START = 1

SET @END = 50

WHILE @START <= @END 
BEGIN
	PRINT @START 
	SET @START += 1
END;
---CONTINUE
---BREAK

DECLARE @START INT ,@END INT

SET @START = 1

SET @END = 50

WHILE @START <= @END 
BEGIN
	PRINT @START 
	SET @START += 1
	IF	@START = 10
		BREAK
END;
------------------
---User Defined Functions

--Scalar - Valued Functions

CREATE FUNCTION sp_lower_string (@STRING VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	RETURN(SELECT LOWER(@STRING))

END;

CREATE FUNCTION sp_lower_string (@STRING VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	RETURN LOWER(@STRING)

END;

---CLARUSWAY

SELECT dbo.sp_lower_string('CLARUSWAY') --we can call user_defined_functions with schema name (namely dbo)


SELECT
	dbo.sp_lower_string(CUSTOMER_NAME) --OVER()
FROM	
	ORDER_TBL

-----Aldigi stringin bas harfini buyuk, digerlerini kucuk harfe donusturen bir fonksiyon uretin.
GO

;CREATE FUNCTION sp_string (@STRING VARCHAR(100))
RETURNS VARCHAR(100)
AS
BEGIN

	RETURN
		UPPER (LEFT (@STRING, 1)) + LOWER(SUBSTRING(@STRING, 2, LEN(@STRING)))

END;

SELECT dbo.sp_string ('CLaruswaY')

---SELECT UPPER (LEFT ('clarusway', 1)) + LOWER(SUBSTRING('clarusway', 2, LEN('clarusway')))
--ANOTHER EXAMPLE

SELECT--firstly , variable name is written left of equal . 
	 @EST_DEL_DATE = EST_DELIVERY_DATE 
FROM
	ORDER_TBL
WHERE
	ORDER_ID = @ORDER


SELECT
	@DEL_DATE = DELIVERY_DATE
FROM
	ORDER_DELIVERY
WHERE
	ORDER_ID = @ORDER



--SELECT @EST_DEL_DATE, @DEL_DATE

IF @EST_DEL_DATE = @DEL_DATE
	PRINT 'ON TIME'
ELSE IF @EST_DEL_DATE > @DEL_DATE
	PRINT 'EARLY'
ELSE PRINT 'LATE'

--MY FUNC -?
CREATE FUNCTION dbo.fn_order_status (@ORDER_INT)
RETURNS VARCHAR(10)
AS
BEGIN
	DECLARE @EST_DEL_DATE DATE
	DECLARE @DEL_DATE DATE
	DECLARE @STATUS VARCHAR(10)

	SELECT @EST_DEL DATE = EST_DELIVERY_DATE
	FROM	ORDER_TBL
	WHERE	ORDER_ID = @ORDER

	SELECT	@DEL_DATE = DELIVERY_DATE
	FROM	ORDER_DELIVERY
	WHERE	ORDER_ID = @ORDER

	IF @EST_DEL_DATE = @DEL_DATE
		SET @STATUS = 'ON TIME'

	ELSE IF @EST_DEL_DATE > @DEL_DATE
		SET @STATUS = 'EARLY'

	ELSE
		SET @STATUS = 'LATE'

RETURN @STATUS

END;
--TEACHER FUNC
ALTER FUNCTION dbo.fn_order_status (@ORDER INT)
RETURNS VARCHAR(10)
AS
BEGIN
		DECLARE @EST_DEL_DATE DATE
		DECLARE @DEL_DATE DATE
		DECLARE @STATUS VARCHAR(10)
		SELECT	@EST_DEL_DATE = EST_DELIVERY_DATE
		FROM	ORDER_TBL
		WHERE	ORDER_ID = @ORDER
		SELECT	@DEL_DATE = DELIVERY_DATE
		FROM	ORDER_DELIVERY
		WHERE	ORDER_ID = @ORDER
		IF @EST_DEL_DATE = @DEL_DATE
			SET @STATUS = 'ON TIME'
		
		ELSE IF @EST_DEL_DATE > @DEL_DATE
			SET @STATUS = 'EARLY'

		ELSE SET @STATUS = 'LATE'
RETURN @STATUS
END;

SELECT
	dbo.fn_order_status(ORDER_ID)
FROM
	ORDER_DELIVERY

---Table Valued Functions 

;CREATE FUNCTION fn_table_valued_1 ()
RETURNS TABLE
AS

RETURN	SELECT * FROM ORDER_TBL WHERE ORDER_DATE < '2023-07-25'

SELECT
	*
FROM
	dbo.fn_table_valued_1()


--WITH PARAMETER

;CREATE FUNCTION fn_table_valued_2 (@date DATE)
RETURNS TABLE
AS

RETURN	SELECT * FROM ORDER_TBL WHERE ORDER_DATE < @date;

SELECT
	*
FROM
	dbo.fn_table_valued_2('2023-07-22')

---------------
---variable as table formatter
---table is temporary . 

DECLARE @TABLE1 TABLE(ID INT, NAME VARCHAR(25))


INSERT @TABLE1 VALUES(1, 'Ahmet')

SELECT
	*
FROM
	@TABLE1


------
ALTER FUNCTION fn_table_valued_3 (@ORDER INT)
RETURNS @TABLE TABLE(ID INT, NAME VARCHAR(25))
AS
BEGIN
	INSERT @TABLE
	SELECT	CUSTOMER_ID, CUSTOMER_NAME
	FROM	ORDER_TBL
	WHERE	dbo.fn_order_status(@ORDER) = 'ON TIME'
	AND ORDER_ID = @ORDER

RETURN --because of convert a table , return is empty . 
END;

SELECT
	dbo.fn_order_status(3)

SELECT *, dbo.fn_order_status(ORDER_ID) order_stateFROM ORDER_TBL


SELECT
	*
FROM
	dbo.fn_table_valued_3(1)

---assignment : table of above , I must add LATE TIME if it is not on time . 

--
ALTER FUNCTION fn_table_valued_4 ()
RETURNS @TABLE TABLE(ID INT, NAME VARCHAR(25), order_state VARCHAR(15)  )
AS
BEGIN
	DECLARE @START INT, @END INT
	SET @START = (SELECT MIN(ORDER_ID) FROM ORDER_TBL)
	SET @END = (SELECT MAX(ORDER_ID) FROM ORDER_TBL)
	WHILE @START <= @END 
	BEGIN
		DECLARE @ORDER_STATUS VARCHAR(15)
		SET @ORDER_STATUS =dbo.fn_order_status(@START)
		IF @ORDER_STATUS <> 'ON TIME'
		BEGIN
			INSERT @TABLE
			SELECT	CUSTOMER_ID, CUSTOMER_NAME, @ORDER_STATUS
			FROM	ORDER_TBL
			WHERE	ORDER_ID = @START
		END
	SET @START += 1
	END
RETURN --because of convert a table , return is empty . 
END;

SELECT
	*
FROM
	fn_table_valued_4()



----NOT WHILE

ALTER FUNCTION fn_table_valued_5 ()
RETURNS @TABLE TABLE(ID INT, NAME VARCHAR(25), order_state VARCHAR(15))
AS
BEGIN
	DECLARE @ORDER INT
	INSERT @TABLE
	SELECT	CUSTOMER_ID, CUSTOMER_NAME, dbo.fn_order_status(ORDER_ID) order_state
	FROM	ORDER_TBL
	WHERE	dbo.fn_order_status(ORDER_ID) != 'ON TIME'

RETURN --because of convert a table , return is empty . 
END;


SELECT
	*
FROM
	fn_table_valued_5()