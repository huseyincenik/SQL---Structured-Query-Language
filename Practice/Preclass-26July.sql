/* Create Database
The SQL statement CREATE is used to create the database and table structures.


The major SQL DDL statements are CREATE DATABASE.*/

CREATE DATABASE deneme;
CREATE TABLE departments
(
	id BIGINT NOT NULL,
	name VARCHAR(20) NULL,
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,
	graduation VARCHAR(20) NULL,
	salary BIGINT NULL,
	hire_date DATE NULL,
		CONSTRAINT pk_1 PRIMARY KEY(id)
);
SELECT
	*
FROM
	departments

ALTER TABLE departments
ADD CONSTRAINT unique_id_constraint UNIQUE(id)
/* Drop Table
The DROP TABLE will remove a table from the database. Make sure you have the correct database selected. */

DROP TABLE departments;

/* Data Manipulation Language (DML)

Introduction
The SQL data manipulation language (DML) is used to query and modify database data. In this chapter, we will describe how to use the SELECT, INSERT, UPDATE, and DELETE SQL DML command statements, defined below.

SELECT – to query data in the database
INSERT – to insert data into a table
UPDATE – to update data in a table
DELETE – to delete data from a table
*/
CREATE TABLE departments
(
	id BIGINT NOT NULL,
	name VARCHAR(20) NULL,
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,
	graduation VARCHAR(20) NULL,
	salary BIGINT NULL,
	hire_date DATE NULL,
		CONSTRAINT pk_1 PRIMARY KEY(id)
);

INSERT departments (id, name, dept_name, seniority, graduation, salary, hire_date)
VALUES
(10238,	'Eric'	   ,'Economics'	       ,'Experienced'	,'MSc' ,72000	,'2019-12-01'),
(13378,	'Karl'	   ,'Music'	       ,'Candidate'	,'BSc' ,42000	,'2022-01-01'),
(23493,	'Jason'	   ,'Philosophy'       ,'Candidate'	,'MSc' ,45000	,'2022-01-01'),
(30766,	'Jack'     ,'Economics'	       ,'Experienced'	,'BSc' ,68000	,'2020-06-04'),
(36299,	'Jane'	   ,'Computer Science' ,'Senior'	,'PhD' ,91000	,'2018-05-15'),
(40284,	'Mary'	   ,'Psychology'       ,'Experienced'	,'MSc' ,78000	,'2019-10-22'),
(43087,	'Brian'	   ,'Physics'	       ,'Senior'	,'PhD' ,93000	,'2017-08-18'),
(53695,	'Richard'  ,'Philosophy'       ,'Candidate'	,'PhD' ,54000	,'2021-12-17'),
(58248,	'Joseph'   ,'Political Science','Experienced'	,'BSc' ,58000	,'2021-09-25'),
(63172,	'David'	   ,'Art History'      ,'Experienced'	,'BSc' ,65000	,'2021-03-11'),
(64378,	'Elvis'	   ,'Physics'	       ,'Senior'	,'MSc' ,87000	,'2018-11-23'),
(96945,	'John'	   ,'Computer Science' ,'Experienced'	,'MSc' ,80000	,'2019-04-20'),
(99231,	'Santosh'  ,'Computer Science' ,'Experienced'	,'BSc' ,74000	,'2020-05-07');

SELECT
	*
FROM
	departments

DROP TABLE departments;
go
/* The SELECT statement, or command, allows the user to extract data from tables, based on specific criteria. It is processed according to the following sequence: */

SELECT TOP 2 id, name, dept_name
FROM departments
ORDER BY id
/* Insert into an IDENTITY column
By default, data cannot be inserted directly into an IDENTITY column; however, if a row is accidentally deleted, or there are gaps in the IDENTITY column values, you can insert a row and specify the IDENTITY column value.

To allow an insert with a specific identity value, the IDENTITY_INSERT option should be used.

If the id column in the departments table was an IDENTITY column and it was desired to add an id to this column, it could be done as follows: */

CREATE TABLE example
(
	id BIGINT IDENTITY(1, 1) NOT NULL,
	name VARCHAR(20) NULL,
	dept_name VARCHAR(20) NULL,
	seniority VARCHAR(20) NULL,
	graduation VARCHAR(20) NULL,
	salary BIGINT NULL,
	hire_date DATE NULL,
		CONSTRAINT pkm_1 PRIMARY KEY(id)
);
INSERT INTO example (name, dept_name, seniority, graduation, salary, hire_date)
VALUES
('Eric', 'Economics', 'Experienced', 'MSc', 72000, '2019-12-01'),
('Karl', 'Music', 'Candidate', 'BSc', 42000, '2022-01-01'),
('Jason', 'Philosophy', 'Candidate', 'MSc', 45000, '2022-01-01'),
('Jack', 'Economics', 'Experienced', 'BSc', 68000, '2020-06-04'),
('Jane', 'Computer Science', 'Senior', 'PhD', 91000, '2018-05-15'),
('Mary', 'Psychology', 'Experienced', 'MSc', 78000, '2019-10-22'),
('Brian', 'Physics', 'Senior', 'PhD', 93000, '2017-08-18'),
('Richard', 'Philosophy', 'Candidate', 'PhD', 54000, '2021-12-17'),
('Joseph', 'Political Science', 'Experienced', 'BSc', 58000, '2021-09-25'),
('David', 'Art History', 'Experienced', 'BSc', 65000, '2021-03-11'),
('Elvis', 'Physics', 'Senior', 'MSc', 87000, '2018-11-23'),
('John', 'Computer Science', 'Experienced', 'MSc', 80000, '2019-04-20'),
('Santosh', 'Computer Science', 'Experienced', 'BSc', 74000, '2020-05-07');

SELECT
	*
FROM
	example

SET IDENTITY_INSERT departments ON;

INSERT departments (id, name, dept_name, seniority, graduation, salary, hire_date)
VALUES (44552,	'Edmond' ,'Economics'	,'Candidate','BSc' ,60000	,'2021-12-04')

SET IDENTITY_INSERT departments OFF;


SET IDENTITY_INSERT example ON;
INSERT example( id, name, dept_name, seniority, graduation, salary, hire_date)
VALUES (44552,'Edmond', 'Economics', 'Candidate', 'BSc', 60000, '2021-12-04')
SET IDENTITY_INSERT example OFF;

SELECT
	*
FROM
	example

/*Insert with SELECT
We can sometimes create a small temporary table from a large table. For this, we can insert rows with a SELECT statement. When using this command, there is no validation for uniqueness. Consequently, there may be many rows with the same id in the example below.

This example creates a smaller temporary salary table using the CREATE TABLE statement. Then the INSERT with a SELECT statement is used to add records to this temporary salary table from the departments table. You should use # for creating a temporary table.*/
CREATE TABLE #salary (
id BIGINT NOT NULL,
name VARCHAR (40) NULL,
salary BIGINT NULL
);
INSERT #salary
SELECT id, name, salary FROM departments;

----
--Or you can use the SELECT ... INTO ... FROM statement as follow:
SELECT id, name, salary 
INTO #salary
FROM departments;

SELECT *
FROM #salary
/* UPDATE
The UPDATE statement changes data in existing rows either by adding new data or modifying existing data.


This example uses the UPDATE statement to change the employee name in the name field to be Edward for the employee has 44552 id number in the departments table. */

UPDATE departments
SET name = 'Edward'
WHERE id = 44552;
---
/* DELETE
The DELETE statement removes rows from a record set. DELETE names the table or view that holds the rows that will be deleted and only one table or row may be listed at a time. WHERE is a standard WHERE clause that limits the deletion to select records.*/

--DELETE FROM departments;

DELETE FROM departments WHERE id = 44552;
