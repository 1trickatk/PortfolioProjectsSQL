SELECT *
FROM Project#1..CovidDeaths
ORDER BY 3,4

SELECT *
FROM Project#1..CovidVaccinations
ORDER BY 3,4

-- Select Data that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM Project#1..CovidDeaths
ORDER BY 1,2

-- Looking at Total Cases vs Total Deaths
-- Shows the likelihood of dying if you get infected by covid
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Project#1..CovidDeaths
--WHERE location like '%states' --To not include ''United States Virginia Islands
WHERE continent is not NULL
ORDER BY 1,2

-- Total Cases vs Population
-- Shows what percentage of population got Covid
SELECT Location, date, total_cases, Population, total_deaths,  (total_cases/population)*100 as PopulationCovidPercentage
FROM Project#1..CovidDeaths
WHERE continent is not NULL
--WHERE iso_code like 'USA'
ORDER BY 1,2

-- Highest Infection Rate compared to population

SELECT Location,Population, MAX(total_cases) as HighestCase, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM Project#1..CovidDeaths
--WHERE iso_code like 'USA'
WHERE continent is not NULL
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC


-- Showing the continents with the highest death count
--To show the rates based on the each continent
SELECT Location,Population, MAX(total_deaths) as Deaths, MAX((total_deaths/population))*100 AS PercentPopulationDied
FROM Project#1..CovidDeaths
WHERE continent is NULL and location NOT LIKE '%income%'
GROUP BY location,population
ORDER BY Deaths DESC

-- To show the rates for each continent 
--Detect which continent you want to analyze
SELECT Location
FROM Project#1..CovidDeaths
	WHERE continent is NULL
		AND location NOT LIKE '%income%'
		GROUP BY location
-- Change the continent name with the continent name that you've choosen
SELECT Location,Population, MAX(total_deaths) as Deaths, MAX((total_deaths/population))*100 AS PercentPopulationDied
FROM Project#1..CovidDeaths
WHERE 
	continent is not NULL 
	AND location NOT LIKE '%income%'
	AND continent LIKE '%Europe'
GROUP BY location,population
ORDER BY Deaths DESC


-- Showing Countires with the Highest Death Count compared to Population
SELECT Location,Population, MAX(total_deaths) as Deaths, MAX((total_deaths/population))*100 AS PercentPopulationDied
FROM Project#1..CovidDeaths
WHERE continent is not NULL and location NOT LIKE '%income%'
GROUP BY location,population
ORDER BY Deaths DESC


-- Global Numbers
SELECT SUM(new_cases)as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as DeathPercentage
FROM Project#1..CovidDeaths
WHERE continent is not NULL
	AND total_cases is not NULL
	AND total_deaths is not NULL
ORDER BY 1,2


-- Looking at Total Population against Vaccinations
---- CTE version
WITH PopvsVAC (Continent, Location, Date, Population, New_Vaccination,CumulativeVaccinated) 
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CumulativeVaccinated
FROM Project#1..CovidDeaths dea
JOIN Project#1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT *, (CumulativeVaccinated/population)*100 as VaccinatedPercentagePopulationCumulative
FROM PopvsVac

---- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
CumulativeVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CumulativeVaccinated
FROM Project#1..CovidDeaths dea
JOIN Project#1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
--WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *, (CumulativeVaccinated/population)*100 as VaccinatedPercentagePopulationCumulative
FROM #PercentPopulationVaccinated

-- In order to visualize in different BI applications

CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CAST(vac.new_vaccinations as float)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as CumulativeVaccinated
FROM Project#1..CovidDeaths dea
JOIN Project#1..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated