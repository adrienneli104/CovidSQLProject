--Covid Deaths & Vaccinations Data: https://ourworldindata.org/covid-deaths
USE [Covid Project]
Select *
From [dbo].[CovidDeaths$]
Where continent is not null
Order by 3,4

--Total Cases vs. Total Deaths
--Chance of dying if you get Covid
USE [Covid Project]
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From [dbo].[CovidDeaths$]
Order by 1,2

--Total Cases vs. Population
--Percentage of population that got Covid
USE [Covid Project]
Select Location, date, total_cases, Population, (total_cases/population)*100 as InfectedPercentage
From [dbo].[CovidDeaths$]
Order by 1,2

--Countries with Highest Infection Rate
USE [Covid Project]
Select Location, MAX(total_cases) as HighestInfectionCount, Population, MAX((total_cases/population))*100 as InfectedPercentage
From [dbo].[CovidDeaths$]
Group by Location, Population
Order by InfectedPercentage desc

--Continents with Highest Death Count
USE [Covid Project]
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths$]
Where continent is not null
Group by continent
Order by TotalDeathCount desc

--Countries with Highest Death Count
USE [Covid Project]
Select Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From [dbo].[CovidDeaths$]
Where continent is not null
Group by Location
Order by TotalDeathCount desc

--Global Death Percentage
USE [Covid Project]
Select SUM(new_cases) as TotalCases, SUM(cast(new_deaths as int)) as TotalDeaths, (SUM(cast(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From [dbo].[CovidDeaths$]
Where continent is not null
Order by 1,2

--Total Population vs. Vaccination
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255), 
Location nvarchar(255), 
Date datetime, 
Population numeric, 
New_Vaccinations numeric, 
CumulativeVaccinationCount numeric)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as CumulativeVaccinationCount
From [dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null
Select *, (CumulativeVaccinationCount/Population)*100 AS PercentPopulationVaccinated
From #PercentPopulationVaccinated

--View for Visualization
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location ORDER BY dea.location,
dea.Date) as CumulativeVaccinationCount
From [dbo].[CovidDeaths$] dea
Join [dbo].[CovidVaccinations$] vac
	On dea.location = vac.location 
	and dea.date = vac.date
Where dea.continent is not null

Select * 
From PercentPopulationVaccinated


