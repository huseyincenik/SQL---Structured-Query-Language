/* HAVING Clause 

Introduction
HAVING clause is used to filter on the new column that will create as a result of the aggregate operation.

Its intended use is very similar to WHERE. Both are used for filtering results. However, HAVING and WHERE differ from each other in terms of usage and reasons for use. */

CREATE	TABLE departments
(
id BIGINT,
name VARCHAR(20),
dept_name VARCHAR(20),
seniority VARCHAR(20),
graduation CHAR(3),
salary BIGINT,
hire_date DATE
);



INSERT INTO departments (id, name, dept_name,seniority, graduation,salary, hire_date)
VALUES
( 10238, 'Eric', 'Economics', 'Experienced', 'MSc', 72000, '2019-12-01'),
( 13378, 'Karl', 'Music', 'Candidate', 'BSc', 42000, '2022-01-01'),
( 23493, 'Jason', 'Philosophy', 'Candidate', 'MSc', 45000, '2022-01-01'),
( 36299, 'Jane', 'Computer Science', 'Senior', 'PhD', 91000, '2018-05-15'),
( 30766, 'Jack', 'Economics', 'Experienced', 'BSc', 68000, '2020-04-06'),
( 40284, 'Mary', 'Psychology', 'Experienced', 'MSc', 78000, '2019-10-22'),
( 43087, 'Brain', 'Physics', 'Senior', 'PhD', 93000, '2017-08-18'),
( 53695, 'Richard', 'Philosophy', 'Candidate', 'PhD', 54000, '2021-12-17'),
( 58248, 'Joseph', 'Political Science', 'Experienced', 'BSc', 58000, '2021-09-25'),
( 63172, 'David', 'Art History', 'Experienced', 'BSc', 65000, '2021-03-11'),
( 64378, 'Elvis', 'Physics', 'Senior', 'MSc', 87000, '2018-11-23'),
( 96945, 'John', 'Computer Science', 'Experienced', 'MSc', 80000, '2019-04-20'),
( 99231, 'Santosh', 'Computer Science', 'Experienced', 'BSc', 74000, '2020-05-07')
;

SELECT
	*
FROM
	departments

----

SELECT
	dept_name,
	AVG(SALARY * 1.0) AS avg_salary
FROM
	departments
GROUP BY
	dept_name

--------------------------
SELECT
	dept_name,
	AVG(a.salary * 1.0) AS avg_salary
FROM
	departments AS a
GROUP BY
	a.dept_name
HAVING
	AVG(a.salary) > 50000 ;
/* GROUPING SETS & PIVOT & ROLLUP & CUBE 

Introduction
These methods are mostly used in periodical reporting. They ensure that different breakdowns of the data are obtained as a result of a single query. Different grouping options are returned in a single query, saving time and resources.

In addition, it enables decision-makers to evaluate the reported analysis from different directions at a single glance.

Only a piece of brief information has been given here. Details and examples will be covered in in-class lessons.
*/


SELECT
	seniority,
	graduation,
	AVG(salary)
FROM
	departments
GROUP BY
	GROUPING SETS(
	(seniority, graduation),
	(graduation))
ORDER BY
	seniority DESC

SELECT
	seniority,
	graduation,
	AVG(salary)
FROM
	departments
GROUP BY
	GROUPING SETS(
	(seniority, graduation))


SELECT    seniority,    graduation,	dept_name,    AVG(Salary) salaryFROM    departmentsGROUP BY    GROUPING SETS (        (seniority, graduation, dept_name),        (graduation))
ORDER BY
	seniority DESC;
------------Pivot Example
SELECT
	*
FROM
(
SELECT
	seniority,
	graduation,
	salary
FROM
	departments
) AS SourceTable
PIVOT
(
AVG(salary)
FOR graduation IN([BSc], [MSc], [PhD])
) AS pivot_table;

--Rollup Example

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    departments
GROUP BY
    ROLLUP (seniority, graduation);

--Cube Example

SELECT
    seniority,
    graduation,
    AVG(Salary)
FROM
    departments
GROUP BY
    CUBE (seniority, graduation);
--------------------------
SELECT    seniority,    graduation,    AVG(Salary)FROM    departmentsGROUP BY    CUBE (seniority, graduation);SELECT    seniority,    graduation,    AVG(Salary) salaryFROM    departmentsGROUP BY    GROUPING SETS (        (seniority, graduation),        (seniority),		(graduation),		());

---Aggregate Window Functions

SELECT graduation, COUNT (id) OVER() as cnt_employee
FROM departments 

SELECT
	*
FROM
	departments

----
SELECT DISTINCT graduation, COUNT (id) OVER() as cnt_employee
FROM departments 

---
SELECT DISTINCT graduation, COUNT (id) OVER(PARTITION BY graduation) as cnt_employee
FROM departments 
-----------
SELECT hire_date, COUNT (id) OVER(ORDER BY hire_date) cnt_employee
FROM departments

/* Ranking Window Functions
In this part, we'll learn ranking window functions. Ranking window functions return a ranking value for each row in a partition. Here are the window functions and their description used for ranking purposes.
*/
