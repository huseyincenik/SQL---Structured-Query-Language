--CREATE DATABASE "PortfolioProject";

USE PortfolioProject


-- When coming from data, it comes with error. It was used to make periods instead of commas.
DECLARE @tableName NVARCHAR(255)
DECLARE @sql NVARCHAR(MAX)
DECLARE @columnName NVARCHAR(255)

SET @tableName = 'CovidVaccinations' -- Type the table name here

DECLARE column_cursor CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName
  AND DATA_TYPE IN ('nvarchar', 'varchar') 

OPEN column_cursor
FETCH NEXT FROM column_cursor INTO @columnName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'UPDATE ' + @tableName + ' SET ' + @columnName + ' = REPLACE(' + @columnName + ', '','' , ''.'' );'
    EXEC sp_executesql @sql

    FETCH NEXT FROM column_cursor INTO @columnName
END

CLOSE column_cursor
DEALLOCATE column_cursor;


SELECT
	*
FROM
	dbo.CovidVaccinations
WHERE
	location = 'Turkey'

SELECT
	SUM(total_vaccinations)
FROM
	dbo.CovidVaccinations
WHERE
	location = 'Turkey';
GO
-- When coming from data, it comes with error. It was used to make periods instead of commas.
DECLARE @tableName NVARCHAR(255)
DECLARE @sql NVARCHAR(MAX)
DECLARE @columnName NVARCHAR(255)

SET @tableName = 'CovidDeath' -- Type the table name here

DECLARE column_cursor CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName
  AND DATA_TYPE IN ('nvarchar', 'varchar')

OPEN column_cursor
FETCH NEXT FROM column_cursor INTO @columnName

WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = 'UPDATE ' + @tableName + ' SET ' + @columnName + ' = REPLACE(' + @columnName + ', '','' , ''.'' );'
    EXEC sp_executesql @sql

    FETCH NEXT FROM column_cursor INTO @columnName
END

CLOSE column_cursor
DEALLOCATE column_cursor;

GO

SELECT
	*
FROM
	dbo.CovidDeath
WHERE
	location = 'Turkey';

-- Select Data that we are going to be using
GO

SELECT
	location, date, total_cases,new_cases, total_deaths, population
FROM
	dbo.CovidDeath
ORDER BY
	1, 2
;

-- Looking at Total Cases vs Total Deaths

SELECT
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage
FROM
	dbo.CovidDeath
ORDER BY
	1, 2;
GO
SELECT
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage,
	MAX((total_deaths/total_cases) * 100) OVER()
FROM
	dbo.CovidDeath
WHERE
	location = 'Turkey'
ORDER BY
	1, 2
;
GO
--according to countries ; The situation where the death rate of total cases is maximum.. 

WITH MaxCte AS(SELECT
	location, date, total_cases,total_deaths, (total_deaths/total_cases) * 100 as DeathPercentage,
	MAX((total_deaths/total_cases) * 100) OVER() AS Max_Ratio
FROM
	dbo.CovidDeath
WHERE
	location = 'United States'
)

SELECT
	*
FROM
	MaxCte
WHERE
	DeathPercentage = Max_Ratio

-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT
	location, date, population,total_cases, (total_cases/population) * 100 as PercentPopulationInfect,
	MAX((total_cases/population) * 100) OVER()
FROM
	dbo.CovidDeath
WHERE
	location = 'Turkey' AND continent IS NOT NULL
ORDER BY
	1, 2

--Looking at Countries with Highest Infection Rate Compared to Population
SELECT
	location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 as PercentPopulationInfected
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
GROUP BY
	location, population
ORDER BY
	4 DESC;

-- Showing Countries with Highest Death Count per Population
SELECT
	location, MAX(Total_deaths) as Total_Death_Count
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
GROUP BY
	location
ORDER BY
	2 DESC;
--Let's Break Things Down By Continent
SELECT
	location, MAX(Total_deaths) as Total_Death_Count
FROM
	dbo.CovidDeath
WHERE
	continent IS NULL
--	location = 'Turkey'
GROUP BY
	location
ORDER BY
	2 DESC;

SELECT
	continent, MAX(Total_deaths) as Total_Death_Count
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
GROUP BY
	continent
ORDER BY
	2 DESC;

/*The short information entered in Location represents the continents. Therefore, both continent knowledge and knowledge of those with NaN locations are needed here. The following query combines two results*/

WITH combined_results AS(
SELECT
	continent, MAX(Total_deaths) as Total_Death_Count
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
GROUP BY
	continent

UNION

SELECT
	location, MAX(Total_deaths) as Total_Death_Count
FROM
	dbo.CovidDeath
WHERE
	continent IS NULL
GROUP BY
	location
)
SELECT continent ,SUM(Total_Death_Count) AS total_death_for_continent
FROM combined_results
GROUP BY
	continent
ORDER BY
	total_death_for_continent DESC;

---2.method
GO

WITH combined_results AS (
  SELECT
    location AS continent, MAX(Total_deaths) as Total_Death_Count
  FROM
    dbo.CovidDeath
  WHERE
    continent IS NULL
  GROUP BY
    location
)

SELECT c.continent, SUM(COALESCE(r.Total_Death_Count, 0)) AS total_death_for_continent
FROM combined_results c
LEFT JOIN combined_results r ON c.continent = r.continent
GROUP BY c.continent
ORDER BY total_death_for_continent DESC;

---- 3.method

WITH combined_results AS (
  SELECT
    location, MAX(Total_deaths) as Total_Death_Count
  FROM
    dbo.CovidDeath
  WHERE
    continent IS NULL
  GROUP BY
    location
)

SELECT c.location, SUM(COALESCE(r.Total_Death_Count, 0)) AS total_death_for_continent
FROM combined_results c
LEFT JOIN combined_results r ON c.location = r.location
GROUP BY c.location
ORDER BY total_death_for_continent DESC;

-- Showing continents with the highest death count per population

SELECT
	continent, MAX(Total_deaths) as Total_Death_Count
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
GROUP BY
	continent
ORDER BY
	2 DESC;

-- Global Numbers

-- Daily cases, death numbers and death percentages around the world

SELECT
	date, SUM(new_cases) AS total_cases, SUM(total_deaths) AS total_deaths, SUM(new_deaths) / SUM(new_cases)*100 AS DeathPercentage
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
GROUP BY
	date
ORDER BY
	1, 2
;
-- total number around the world
SELECT
	SUM(new_cases) AS total_cases, SUM(total_deaths) AS total_deaths, SUM(new_deaths) / SUM(new_cases)*100 AS DeathPercentage
FROM
	dbo.CovidDeath
WHERE
	continent IS NOT NULL
--	location = 'Turkey'
ORDER BY
	1, 2
;

-- it is joined both table . 
SELECT
	*
FROM
	CovidVaccinations AS vac
	JOIN CovidDeath AS dea
	ON dea.location = vac.location
	AND dea.date = vac.date

-- Looking at Total Population vs Vaccinations

SELECT
	dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations
FROM
	CovidVaccinations AS vac
	JOIN CovidDeath AS dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	1, 2, 3

-- -- Looking at Total Population vs Vaccinations and total vaccinations according to location
SELECT
	dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS vaccination_according_to_location
FROM
	CovidVaccinations AS vac
	JOIN CovidDeath AS dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
ORDER BY
	1, 2, 3;
GO

-- Use Cte

WITH temp_cte ( continent, location, date,population, new_vaccinations, vaccination_according_to_location)
AS
(
SELECT
	dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS vaccination_according_to_location
FROM
	CovidVaccinations AS vac
	JOIN CovidDeath AS dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL
)
SELECT
	*, ( vaccination_according_to_location /population) * 100
FROM
	temp_cte

-- with temp table

CREATE TABLE #percent_population_vaccinated
(
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
vaccination_according_to_location numeric
)

INSERT INTO #percent_population_vaccinated
SELECT
	dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS vaccination_according_to_location
FROM
	CovidVaccinations AS vac
	JOIN CovidDeath AS dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

SELECT
	*, ( vaccination_according_to_location /population) * 100
FROM
	#percent_population_vaccinated

-- Creating View to Store Data For Later Visualizations
;GO

CREATE VIEW percent_population_vaccinated AS

SELECT
	dea.continent , dea.location, dea.date, dea.population , vac.new_vaccinations,
	SUM(vac.new_vaccinations) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date ) AS vaccination_according_to_location
FROM
	CovidVaccinations AS vac
	JOIN CovidDeath AS dea
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE
	dea.continent IS NOT NULL

;GO

SELECT
	*
FROM
	percent_population_vaccinated