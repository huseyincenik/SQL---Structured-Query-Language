--SQL Session-12, 26.07.2023, (DDL - DML)

--CREATE
--***********************************************

CREATE DATABASE LibraryDB
GO

USE LibraryDB
GO

--Create Schemas

CREATE SCHEMA Person
GO
CREATE SCHEMA Book
GO


--Create Tables

--create Book.Book table
CREATE TABLE [Book].[Book](
	[Book_ID] INT PRIMARY KEY NOT NULL,
	[Book_Name] [nvarchar](100) NOT NULL,
	[Author_ID] INT NOT NULL,
	[Publisher_ID] INT NOT NULL
	--,CONSTRAINT PK_Book PRIMARY KEY ([Book_ID])
);

--create Book.Author table
CREATE TABLE [Book].[Author](
	[Author_ID] INT,
	[Author_FirstName] NVARCHAR(50) NOT NULL,
	[Author_LastName] NVARCHAR(50) NOT NULL
);

--create Book.Publisher Table
CREATE TABLE [Book].[Publisher](
	[Publisher_ID] INT PRIMARY KEY IDENTITY(1,1) NOT NULL,
	[Publisher_Name] VARCHAR(MAX) NULL
);

--create Person.Person table
CREATE TABLE [Person].[Person](
	[SSN] BIGINT PRIMARY KEY CHECK(LEN(SSN)=11),
	[Person_FirstName] NVARCHAR(50) NULL,
	[Person_LastName] NVARCHAR(50) NULL
);

--create Person.Loan table
CREATE TABLE [Person].[Loan](
	[SSN] BIGINT NOT NULL,
	[Book_ID] INT NOT NULL,
	PRIMARY KEY ([SSN], [Book_ID])
);

--create Person.Person_Phone table
CREATE TABLE [Person].[Person_Phone](
	[Phone_Number] BIGINT PRIMARY KEY,
	[SSN] BIGINT NOT NULL REFERENCES [Person].[Person]
);

--create Person.Person_Mail table
CREATE TABLE [Person].[Person_Mail](
	[Mail_ID] INT PRIMARY KEY IDENTITY(1,1),
	[Mail] NVARCHAR(900) UNIQUE,
	[SSN] BIGINT NOT NULL,
	CONSTRAINT FK_SSNum FOREIGN KEY (SSN) REFERENCES Person.Person(SSN)
);


--INSERT
--***********************************************

SELECT * FROM Person.Person

INSERT INTO Person.Person ([SSN], [Person_FirstName], [Person_LastName])
VALUES (11122233333, N'Zehra', N'Tekin')

INSERT INTO Person.Person ([Person_FirstName], [Person_LastName], [SSN])
VALUES (N'Eylem', N'Yaðýz', 99988877777)

INSERT INTO Person.Person ([SSN], [Person_FirstName])
VALUES (44455566666, N'Mehmet')


--it is not mandatory to use column names & INTO is optional

INSERT Person.Person VALUES (22277788888, N'Ahmet', N'Güneri')

INSERT Person.Person VALUES (55500077788, N'Ezgi', NULL)

SELECT * FROM Person.Person


--primary key constraint

INSERT Person.Person VALUES (22277788888, N'Ahmet', N'Güneri')  --ERROR

--check constraint

INSERT Person.Person VALUES (222, N'Ahmet', N'Güneri')  --ERROR


--data types must be compatible


----------------------------------------------
--multiple entries

SELECT * FROM Person.Person_Mail
SELECT * FROM Person.Person

INSERT INTO Person.Person_Mail ([Mail], [SSN])
VALUES (N'zehratek@gmail.com', 11122233333),
	   (N'ahmetgün@hotmail.com', 22277788888),
	   (N'eylemyz@gmail.com', 99988877777)


--foreign key constraint

INSERT INTO Person.Person_Mail ([Mail], [SSN]) --ERROR
VALUES (N'ihsant@gmail.com', 66770001122)


--IDENTITY constraint

INSERT INTO Person.Person_Mail ([Mail_ID], [Mail], [SSN]) --ERROR
VALUES (4, N'mehmettt@gmail.com', 44455566666)

----------------------------------------------

--insert with SELECT statement

CREATE TABLE [Names] (
	[Name] VARCHAR(100)
);

SELECT * FROM Names

INSERT INTO Names
SELECT first_name FROM [SampleRetail].sale.customer WHERE first_name LIKE 'M%';

SELECT * FROM Names

-- SELECT INTO
--***********************************************

SELECT *
INTO person_person_2
FROM Person.Person

SELECT * FROM person_person_2


--different database







-- DEFAULT (insert default values)
--***********************************************

SELECT * FROM Book.Publisher

INSERT INTO Book.Publisher
DEFAULT VALUES



-- UPDATE
--***********************************************

--Update iþleminde koþul tanýmlamaya dikkat ediniz. Eðer herhangi bir koþul tanýmlamazsanýz sütundaki tüm deðerlere deðiþiklik uygulanacaktýr.

SELECT * FROM person_person_2

UPDATE person_person_2
SET Person_FirstName='adsum'

UPDATE person_person_2
SET Person_FirstName='Emel'
WHERE SSN=44455566666


--update with JOIN

SELECT * FROM person_person_2
SELECT * FROM Person.Person

UPDATE person_person_2 SET Person_FirstName=b.Person_FirstName
FROM person_person_2 a INNER JOIN Person.Person b ON a.SSN=b.SSN

SELECT * FROM person_person_2


--update with functions

SELECT * FROM person_person_2

UPDATE person_person_2
SET SSN=LEFT(SSN, 5)

SELECT * FROM person_person_2

-- DELETE
--***********************************************

--IDENTITY constraint

SELECT * FROM Book.Publisher

INSERT Book.Publisher VALUES ('X Yayýncýlýk'), ('Y Yayýncýlýk')

DELETE FROM Book.Publisher

INSERT Book.Publisher VALUES ('Z Yayýncýlýk')

SELECT * FROM Book.Publisher

--------------------

SELECT * FROM Person.Person

DELETE FROM Person.Person
WHERE Person_LastName IS NULL;


--FOREIGN KEY-REFERENCE CONSTRAINT

SELECT * FROM Person.Person_Mail

DELETE FROM Person.Person  --ERROR
WHERE SSN=11122233333;


-- DROP
--***********************************************

DROP TABLE [dbo].[Names]

DROP TABLE [dbo].[person_person_2]


--foreign key constraint

DROP TABLE [Person].[Person]  --ERROR


-- TRUNCATE
--***********************************************


SELECT * FROM Book.Publisher

TRUNCATE TABLE Book.Publisher 

SELECT * FROM Person.Person_Mail

TRUNCATE TABLE Person.Person_Mail


-- ALTER
--***********************************************

--ADD KEY CONSTRAINTS

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Book.Author (Author_ID)  --ERROR

ALTER TABLE Book.Author 
ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)  --ERROR

ALTER TABLE Book.Author 
ALTER COLUMN Author_ID INT NOT NULL

ALTER TABLE Book.Author 
ADD CONSTRAINT pk_author PRIMARY KEY (Author_ID)

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Author FOREIGN KEY (Author_ID) REFERENCES Book.Author (Author_ID)

-----------------------------

ALTER TABLE Book.Book 
ADD CONSTRAINT FK_Publisher FOREIGN KEY (Publisher_ID) REFERENCES Book.Publisher (Publisher_ID)


--Person.Loan Table

ALTER TABLE Person.Loan 
ADD CONSTRAINT FK_PERSON FOREIGN KEY (SSN) REFERENCES Person.Person (SSN)

ALTER TABLE Person.Loan 
ADD CONSTRAINT FK_book FOREIGN KEY (Book_ID) REFERENCES Book.Book (Book_ID)
--ON DELETE CASCADE / SET NULL / SET DEFAULT / NO ACTION --default
--ON UPDATE CASCADE / SET NULL / SET DEFAULT / NO ACTION --default


--ADD CHECK CONSTRAINTS

SELECT * FROM Person.Person_Phone

ALTER TABLE Person.Person_Phone 
ADD CONSTRAINT FK_Phone_check CHECK (Phone_Number BETWEEN 700000000 AND 9999999999)


--drop constraints

ALTER TABLE Person.Person_Phone
DROP CONSTRAINT FK_Phone_check


