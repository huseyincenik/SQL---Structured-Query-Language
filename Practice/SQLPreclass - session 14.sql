/*Stored Procedure Basics
A stored procedure in SQL Server is a group of one or more Transact-SQL statements or a reference to a Microsoft .NET Framework common runtime language (CLR) method. Procedures resemble constructs in other programming languages because they can:

Accept input parameters and return multiple values in the form of output parameters to the calling program.
Contain programming statements that perform operations in the database. These include calling other procedures.
Return a status value to a calling program to indicate success or failure (and the reason for failure).
Benefits of Using Stored Procedures
Reduced server/client network traffic
Stronger security
Reuse of code
Easier maintenance
Improved performance*/

CREATE PROCEDURE sp_FirstProc AS
BEGIN
	SELECT 'Welcome to precedural world.' AS message
END

EXECUTE sp_FirstProc
/* Otherwise, using the ALTER PROCEDURE as below, you can change the query you wrote in the procedure.*/
GO
ALTER PROCEDURE sp_FirstProc AS
BEGIN
	PRINT 'Welcome to procedural world.'
END

EXECUTE sp_FirstProc

/*When you want to remove the stored procedure, you can use:*/

DROP PROCEDURE sp_FirstProc

/* Stored Procedure Parameters
In this section, we demonstrate how to use input and output parameters to pass values to and from a stored procedure.

Parameters are used to exchange data between stored procedures and functions and the application or tool that called the stored procedure or function:

Input parameters allow the caller to pass a data value to the stored procedure or function.
Output parameters allow the stored procedure to pass a data value or a cursor variable back to the caller.
Every stored procedure returns an integer return code to the caller. If the stored procedure does not explicitly set a value for the return code, the return code is 0. */

-- Create a procedure that takes one input parameter and returns one output parameter and a return code.

CREATE PROCEDURE sp_SecondProc @name varchar(20), @salary INT OUTPUT
AS
BEGIN

-- Set a value in the output parameter by using input parameter.
SELECT @salary = salary
FROM departments
WHERE name = @name

-- Returns salary of @name
RETURN @salary
END
GO
-------------------call/execute the procedure:
-- Declare the variables for the output salary.
DECLARE @salary_output INT

-- Execute the stored procedure and specify which variable are to receive the output parameter.
EXEC sp_SecondProc @name = 'Eric', @salary = @salary_output OUTPUT

-- Show the values returned.
PRINT CAST(@salary_output AS VARCHAR(10)) + '$'
GO

--run all of these together

SELECT
	*
FROM
	departments

	/* You can assign a default value for the parameters. If any value that is used as a parameter value is NULL, then the procedure continues with the default parameter.

Let's modify the procedure "sp_SecondProc": */

ALTER PROCEDURE sp_SecondProc @name varchar(20) = 'Jack', @salary INT OUTPUT
AS
BEGIN

-- Set a value in the output parameter by using input parameter.
SELECT @salary = salary
FROM departments
WHERE name = @name

-- Returns salary of @name
RETURN @salary
END
GO

/*Declaring a Variable
The DECLARE statement initializes a variable by:

Assigning a name. The name must have a single @ as the first character.
Assigning a system-supplied or user-defined data type and a length. For numeric variables, precision and scale are also assigned.
Setting the value to NULL.*/

DECLARE @myfirstvar INT

DECLARE @LastName NVARCHAR(20), @FirstName NVARCHAR(20), @State NCHAR(2);

/*Setting a value in a variable
When a variable is first declared, its value is set to NULL. To assign a value to a variable, use the SET statement.

This is the preferred method of assigning a value to a variable. A variable can also have a value assigned by being referenced in the select list of a SELECT statement.

To assign a variable a value by using the SET statement, include the variable name and the value to assign to the variable. This is the preferred method of assigning a value to a variable.*/

--Declare a variable
DECLARE @Var1 VARCHAR(5)
DECLARE @Var2 VARCHAR(20)

--Set a value to the variable with 'SET'
SET @Var1 = 'MSc'

--Set a value to the variable with 'SELECT'

SELECT @Var2 = 'Computer Science'

--Get a result by using variable value

SELECT	*
FROM	departments
WHERE	graduation = @Var1
AND dept_name = @Var2

-- Declare a variable
DECLARE @Var1 VARCHAR(5)

-- Set a value to the variable with 'SET'
SET @Var1 = 'MSc'

-- Use the variable in a query
SELECT * FROM departments WHERE graduation = @Var1;

--Declare a variable
DECLARE @Var1 bigint

--Set a value to the variable with "SELECT"
SELECT @Var1 = id
FROM departments

--Call the variable
SELECT @var1 AS last_id;
/*IF Statements
IF statements in SQL allow you to check if a condition has been met and, if so, to perform a sequence of actions.  This secture teaches you everything from the basic syntax of IF statements, including how to use the ELSE clause and perform multiple actions using a BEGIN and END block.

The SQL statement that follows an IF keyword and its condition is executed if the condition is satisfied: the Boolean expression returns TRUE. The optional ELSE keyword introduces another SQL statement that is executed when the IF condition is not satisfied: the Boolean expression returns FALSE.*/

IF DATENAME(weekday, GETDATE()) IN (N'Saturday', N'Sunday')
	SELECT 'Weekend' AS day_of_week;
ELSE
	SELECT 'Weekday' AS day_of_week;

/* In the query above, If statement checks if today is saturday or sunday. If today is saturday or sunday, Query returns "Weekend", If not returns "Weekday". */

IF 1 = 1 PRINT 'Boolean_expression is true.'  
ELSE PRINT 'Boolean_expression is false.' ;

/* In the query above, If statement checks "1 = 1" equality. If the equality is confirmed, Query returns the first message, If not returns the second message. */

/* WHILE Loops
In SQL Server there is only one type of loop: a WHILE loop.  This secture teaches you how to use them, from the basic syntax of the WHILE statement, through how to use a SELECT statement within a loop. 

The statements are executed repeatedly as long as the specified condition is true. The execution of statements in the WHILE loop can be controlled from inside the loop with the BREAK and CONTINUE keywords.*/

SELECT CAST(4599.999999 AS numeric(5,1)) AS col

/*In the following query, we'll generate a while loop. We'll give a limit for the while loop, and we want to break the loop when the variable divisible by 3. In this example we use WHILE, IF, BREAK and CONTINUE statements together.*/

-- Declaring a @count variable to delimited the while loop.
DECLARE @count as int

--Setting a starting value to the @count variable
SET @count=1

--Generating the while loop

WHILE  @count < 30 -- while loop condition
BEGIN  	 	
	SELECT @count, @count + (@count * 0.20) -- Result that is returned end of the statement.
	SET @count +=1 -- the variable value raised one by one to continue the loop.
	IF @count % 3 = 0 -- this is the condition to break the loop.
		BREAK -- If the condition is met, the loop will stop.
	ELSE
		CONTINUE -- If the condition isn't met, the loop will continue.
END;

/* User Defined Functions
Like functions in programming languages, SQL Server user-defined functions are routines that accept parameters, perform an action, such as a complex calculation, and return the result of that action as a value. The return value can either be a single scalar value or a result set.

*/

/* In the following batch, created an user-defined scalar-valued function dbo.ufnGetAvgSalary(). The function gets an input parameter: @seniority. Then, calculated the average salary according to the value/object assigned to @seniority parameter. The variable @avg_salary, declared in the function, catches the result average salary. Finally, the function returns @avg_salary variable as a result. */

CREATE FUNCTION dbo.ufnGetAvgSalary(@seniority VARCHAR(15))  
RETURNS BIGINT   
AS   
-- Returns the stock level for the product.  
BEGIN  
    DECLARE @avg_salary BIGINT
	
    SELECT @avg_salary = AVG(salary)
    FROM departments   
    WHERE seniority = @seniority   
 
    RETURN @avg_salary  
END; 

SELECT dbo.ufnGetAvgSalary('Senior') as avg_salary
SELECT dbo.ufnGetAvgSalary('Candidate') as avg_salary

SELECT
	*
FROM
	departments

/* Table-Valued Function Example:

In the following batch, created an user-defined table-valued function dbo.dept_of_employee(). The function gets an input parameter: @dept_name. In the RETURNS statement we specify the return type of the function. Finally, in the RETURN statement we specify what will return the function among the parentheses.

 */

 CREATE FUNCTION dbo.dept_of_employee (@dept_name VARCHAR(15))  
RETURNS TABLE  
AS  
RETURN   
(  
	SELECT id, name, salary
	FROM departments
	WHERE	dept_name=@dept_name
);  

SELECT * FROM dbo.dept_of_employee('Music')

/* Relational DB & SQL_C15_EU_US
Dashboard
My courses
RDB&SQL_C15
SQL Programming Basics
SQL Programming with T-SQL
 
SQL Programming with T-SQL
To do: Go through the activity to the end
User Defined Functions
Like functions in programming languages, SQL Server user-defined functions are routines that accept parameters, perform an action, such as a complex calculation, and return the result of that action as a value. The return value can either be a single scalar value or a result set.



💡Why use user-defined functions (UDFs)?

They allow modular programming.
You can create the function once, store it in the database, and call it any number of times in your program. User-defined functions can be modified independently of the program source code.
They allow faster execution.
Similar to stored procedures, user-defined functions reduce the compilation cost of the code by caching the plans and reusing them for repeated executions.
They can reduce network traffic.
An operation that filters data based on some complex constraint that cannot be expressed in a single scalar expression can be expressed as a function. The function can then be invoked in the WHERE clause to reduce the number of rows sent to the client.

Types of Functions
Scalar-valued Functions
Scalar-valued functions return a single data value of the type defined in the RETURNS clause. For an inline scalar function, the returned scalar value is the result of a single statement. For a multistatement scalar function, the function body can contain a series of Transact-SQL statements that return the single value.

Table-Valued Functions
User-defined table-valued functions return a table data type. For an inline table-valued function, there is no function body; the table is the result set of a single SELECT statement.
Scalar-Valued Function Example:

"departments" table:

In the following batch, created an user-defined scalar-valued function dbo.ufnGetAvgSalary(). The function gets an input parameter: @seniority. Then, calculated the average salary according to the value/object assigned to @seniority parameter. The variable @avg_salary, declared in the function, catches the result average salary. Finally, the function returns @avg_salary variable as a result.

CREATE FUNCTION dbo.ufnGetAvgSalary(@seniority VARCHAR(15))  
RETURNS BIGINT   


call the function:

SELECT dbo.ufnGetAvgSalary('Senior') as avg_salary


result:


Table-Valued Function Example:

In the following batch, created an user-defined table-valued function dbo.dept_of_employee(). The function gets an input parameter: @dept_name. In the RETURNS statement we specify the return type of the function. Finally, in the RETURN statement we specify what will return the function among the parentheses.

CREATE FUNCTION dbo.dept_of_employee (@dept_name VARCHAR(15))  
RETURNS TABLE  


call the function:

SELECT * FROM dbo.dept_of_employee('Music')


result:

Here is another example of table-valued function:

Table-valued function dbo.raised_salary() gets an input parameter @name. In the RETURNS statement we generate a table variable @raised_salary. Then, as the main process, insert the values we want to get as a result. A RETURN statement with a return value cannot be used in this context. Finally, writing the RETURN statement we mention that what will return the function among the parentheses.*/

CREATE FUNCTION dbo.raised_salary (@name varchar(20))  
RETURNS @raised_salary TABLE   
(  
    id BIGINT,  
    name NVARCHAR(20),  
    raised_salary BIGINT 
)  
AS  
BEGIN  
	INSERT @raised_salary
	SELECT id, name, salary + (salary * 0.20)
	FROM departments
	WHERE name = @name
RETURN
END

SELECT * FROM dbo.raised_salary('Eric')

SELECT
	*
FROM
	departments

GOCREATE FUNCTION dbo.dept_avg_salary(@graduation char(3))RETURNS TABLEASRETURN (		SELECT dept_name, AVG(salary) avg_salary	FROM departments	WHERE graduation = @graduation	GROUP BY dept_name);GOSELECT * FROM dept_avg_salary('PhD')GOCREATE FUNCTION dbo.dept_avg_salary2(@dept_name VARCHAR(20), @graduation char(3))RETURNS TABLEASRETURN (		SELECT dept_name = @dept_name, AVG(salary) avg_salary	FROM departments	WHERE graduation = @graduation AND dept_name =  @dept_name	--GROUP BY dept_name);GOSELECT * FROM dept_avg_salary2('Computer Science', 'MSc')SELECT dept_name, AVG(salary) OVER(PARTITION BY dept_name)FROM [dbo].departmentsWHERE graduation = 'MSc' AND dept_name ='Computer Science'--GROUP BY dept_nameGOCREATE FUNCTION dbo.raised_salary4 (@name varchar(20))  RETURNS TABLE AS  RETURN (      	SELECT id, name, salary + (salary * 0.20) raised_salary 	FROM departments	WHERE name = @name) ;GOSELECT * FROM raised_salary4('Eric')