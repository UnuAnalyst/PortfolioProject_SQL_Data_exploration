SELECT * 
FROM Portfolio_Project.dbo.CovidDeath
ORDER BY 3,4;



SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio_Project.dbo.CovidDeath
ORDER BY 1, 2

--Total cases vs total deaths
-- Likelihood of dying because of Covid. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1, 2

--Looking at Total Cases VS Population
--Shows what % of Population got Covid-19
SELECT location, date, total_cases, population, (total_cases/population)*100 as Cases_percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1, 2

--Looking at the highest infection rate compared to Population
SELECT location, population, MAX(total_cases) AS Highest_infected_case, MAX((total_cases/population))*100 as Percentage_of_population_infected 
FROM Portfolio_Project.dbo.CovidDeath
GROUP BY location, population
ORDER BY Percentage_of_population_infected DESC

--Showing countries with the highest death count per population

SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


--Checking out the DeathCount in each continent

SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC


--Global numbers date by date

SELECT date, SUM(new_cases) AS Total_Global_Cases, SUM(CAST(new_deaths AS int)) AS Total_Global_Deaths, 
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY Total_Global_Cases DESC


--Overall Global numbers such as: Total Cases, New deaths, & Total Global death percentage

SELECT SUM(new_cases) AS Total_Global_Cases, SUM(CAST(new_deaths AS int)) AS Total_Global_Deaths, 
SUM(CAST(new_deaths AS int))/SUM(New_cases)*100 AS Death_Percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE continent IS NOT NULL
ORDER BY Total_Global_Cases DESC;

--Looking at total population VS vaccination
SELECT Death.continent, death.location, death.date, death.population, 
Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
death.date) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeath AS Death
INNER JOIN Portfolio_Project..CovidVaccination AS Vac
ON Death.date = Vac.date AND
Death.location = Vac.location
WHERE Death.continent IS NOT NULL
ORDER BY 2,3


--CTE

WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(SELECT Death.continent, death.location, death.date, death.population, 
Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
death.date) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeath AS Death
INNER JOIN Portfolio_Project..CovidVaccination AS Vac
ON Death.date = Vac.date AND
Death.location = Vac.location
WHERE Death.continent IS NOT NULL
)

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopVsVac


-- Global each country update with Vaccination number and percentage 
WITH PopVsVac (continent, location, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(SELECT death.continent, death.location, death.population, 
Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (
PARTITION BY death.location ORDER BY death.location) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeath AS Death
INNER JOIN Portfolio_Project..CovidVaccination AS Vac
ON death.location = Vac.location
WHERE Death.continent IS NOT NULL
GROUP BY death.continent, death.location, death.population, Vac.new_vaccinations
ORDER BY death.continent, death.location, death.population, Vac.new_vaccinations
)

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopVsVac



--TEMP TABLE 
DROP TABLE if exists PercentagePopulationVaccinated
CREATE TABLE PercentagePopulationVaccinated (
Continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO PercentagePopulationVaccinated
SELECT death.continent, death.location, death.population, 
Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (
PARTITION BY death.location ORDER BY death.location) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeath AS Death
INNER JOIN Portfolio_Project..CovidVaccination AS Vac
ON death.location = Vac.location
WHERE Death.continent IS NOT NULL
GROUP BY death.continent, death.location, death.population, Vac.new_vaccinations
ORDER BY death.continent, death.location, death.population, Vac.new_vaccinations


SELECT *
FROM PercentagePopulationVaccinated


USE Portfolio_Project
GO
--Creating view for later visualization
CREATE VIEW Total_cases_vs_total_deaths_rate AS 
-- Likelihood of dying because of Covid. 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE location LIKE '%states%'
--ORDER BY 1, 2

USE Portfolio_Project
GO
CREATE VIEW Total_Cases_VS_Population AS 
--Looking at Total Cases VS Population
--Shows what % of Population got Covid-19
SELECT location, date, total_cases, population, (total_cases/population)*100 as Cases_percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE location LIKE '%states%'
--ORDER BY 1, 2


USE Portfolio_Project
GO
CREATE VIEW Highest_Infection_Rate_VS_Population AS 
--Looking at the highest infection rate compared to Population
SELECT location, population, MAX(total_cases) AS Highest_infected_case, MAX((total_cases/population))*100 as Percentage_of_population_infected 
FROM Portfolio_Project.dbo.CovidDeath
GROUP BY location, population
--ORDER BY Percentage_of_population_infected DESC

--Showing countries with the highest death count per population
USE Portfolio_Project
GO
CREATE VIEW Highest_death_Rate_PerPop AS 
SELECT location, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY location
--ORDER BY TotalDeathCount DESC


--Checking out the DeathCount in each continent
USE Portfolio_Project
GO
CREATE VIEW Total_DeathCount_Continent AS 
SELECT continent, MAX(CAST(total_deaths AS INT)) as TotalDeathCount
FROM Portfolio_Project.dbo.CovidDeath
WHERE continent IS NOT NULL
GROUP BY continent
--ORDER BY TotalDeathCount DESC


USE Portfolio_Project
GO

CREATE VIEW Total_Pop_VS_Vaccination AS 
--Looking at total population VS vaccination
SELECT Death.continent, death.location, death.date, death.population, 
Vac.new_vaccinations
, SUM(CONVERT(bigint, Vac.new_vaccinations)) OVER (PARTITION BY death.location ORDER BY death.location,
death.date) AS Rolling_People_Vaccinated
FROM Portfolio_Project..CovidDeath AS Death
INNER JOIN Portfolio_Project..CovidVaccination AS Vac
ON Death.date = Vac.date AND
Death.location = Vac.location
WHERE Death.continent IS NOT NULL
--ORDER BY 2,3




















--Showing the total cases in each country. 
SELECT location, SUM(total_cases) as total_cases
FROM Portfolio_Project..CovidDeath
WHERE date >= '2018-01-01' AND date <= '2023-12-31'
AND continent IS NOT NULL
GROUP BY location
ORDER BY total_cases DESC


--Showing the total cases in Continent 
SELECT continent, SUM(total_cases) as total_cases
FROM Portfolio_Project..CovidDeath
WHERE date >= '2018-01-01' AND date <= '2023-12-31'
AND continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC

--Showing the total cases in Continent 
SELECT continent, SUM(total_cases) AS total_cases
FROM Portfolio_Project..CovidDeath
WHERE date >= '2018-01-01' AND date <= '2023-12-31'
AND continent IS NOT NULL
GROUP BY continent
ORDER BY total_cases DESC


--Showing the total population of each country and death rate
SELECT continent, (CAST(total_deaths AS int)/population)*100 AS Death_percentage
FROM Portfolio_Project..CovidDeath
WHERE date >= '2018-01-01' AND date <= '2023-12-31'
AND continent IS NOT NULL
GROUP BY continent, Death_percentage
ORDER BY total_cases DESC


SELECT location, date, total_cases, population, (total_cases/population)*100 as Cases_percentage
FROM Portfolio_Project.dbo.CovidDeath
WHERE location LIKE '%states%'
ORDER BY 1, 2