--Covid Deaths & Vaccinations Data: https://ourworldindata.org/covid-deaths
USE [Covid Project]
SELECT *
FROM [dbo].[CovidDeaths$]
WHERE continent is not null
ORDER BY 3,4

--Total Cases vs. Total Deaths
--Chance of dying if you get Covid
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM [dbo].[CovidDeaths$]
ORDER BY 1,2

--Total Cases vs. Population
--Percentage of population that got Covid
SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectedPercentage
FROM [dbo].[CovidDeaths$]
ORDER BY 1,2

--Countries with Highest Infection Rate
SELECT location, MAX(total_cases) AS HighestInfectionCount, population, MAX((total_cases/population))*100 AS InfectedPercentage
FROM [dbo].[CovidDeaths$]
GROUP BY location, Population
ORDER BY InfectedPercentage desc

--Continents with Highest Death Count
SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM [dbo].[CovidDeaths$]
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Countries with Highest Death Count
SELECT location, MAX(cast(total_deaths AS int)) AS TotalDeathCount
FROM [dbo].[CovidDeaths$]
WHERE continent is not null
Group by location
ORDER BY TotalDeathCount desc

--Global Death Percentage
SELECT SUM(new_cases) AS TotalCases, SUM(cast(new_deaths as int)) AS TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 AS DeathPercentage
FROM [dbo].[CovidDeaths$]
WHERE continent is not null
ORDER BY 1,2

--Total Population vs. Vaccination
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
CumulativeVaccinationCount numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) AS CumulativeVaccinationCount
FROM [dbo].[CovidDeaths$] dea
JOIN [dbo].[CovidVaccinations$] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
SELECT *, (CumulativeVaccinationCount/Population)*100 AS PercentPopulationVaccinated
FROM #PercentPopulationVaccinated

--View for Visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location,
dea.Date) AS CumulativeVaccinationCount
FROM [dbo].[CovidDeaths$] dea
JOIN [dbo].[CovidVaccinations$] vac
	ON dea.location = vac.location 
	AND dea.date = vac.date
WHERE dea.continent is not null
