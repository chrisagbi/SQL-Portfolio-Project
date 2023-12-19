SELECT *
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

--SELECT *
--FROM Portfolioproject..CovidVaccinations
--ORDER BY 3,4


--Select data we are going to be using

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolioproject..CovidDeaths
WHERE continent is not null
ORDER BY 1,2

--Looking at total case vs total death
-- This is the likelihood of dying if you contract covid in the country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolioproject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2


--Looking at the Total Cases vs Population
--Shows what Percentage of Population got covid
SELECT location, date,population, total_cases, (total_cases/population)*100 as PercentofPopulation
FROM Portfolioproject..CovidDeaths
WHERE location like '%states%' and continent is not null
ORDER BY 1,2

--Looking at Countries with highest infection rate compared to population
SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM Portfolioproject..CovidDeaths
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent,	 population, location
ORDER BY PercentPopulationInfected DESC

--Countries with the Highest Death Count per Population
SELECT location,MAX(cast(total_deaths as int)) As TotalDeathCount
FROM Portfolioproject..CovidDeaths
--WHERE location like '%states% 
WHERE continent is not null
GROUP BY continent, population, location
ORDER BY TotalDeathCount DESC

--Showing continents with the highest death count per population
--LET'S BREAK THIS DOWN BY CONTINENT
SELECT continent,MAX(cast(total_deaths as int)) As TotalDeathCount
FROM Portfolioproject..CovidDeaths
--WHERE location like '%states% 
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC


--GLOBAL NUMBERS
--Across the world showing number of total cases, total death, death percentages and their respective dates.
SELECT date, SUM(total_cases) AS totalcases, SUM(cast(total_deaths as int)) AS totaldeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
FROM Portfolioproject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--Tostl Cases,Total Deaths , DeathPercentage of all time in the world.
SELECT SUM(total_cases) AS totalcases, SUM(cast(total_deaths as int)) AS totaldeath, SUM(cast(new_deaths as int))/SUM(new_cases)*100  as DeathPercentage
FROM Portfolioproject..CovidDeaths
--WHERE location like '%states%' 
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2


--Looking at Total Populations Vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(cast(dea.new_vaccinations as int)) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated 
--,(Rollingpeoplevaccinated/population)
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac. location
	and dea.date = vac.date
	where dea.continent is not null
order by 2, 3

--USE CTE
with PopvsVac (Continent, Location,Date, Population,New_vaccinations, Rollingpeoplevaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, dea.new_vaccinations
, SUM(convert(int,dea.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated 
--,(Rollingpeoplevaccinated/population)
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac. location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2, 3
) 
SELECT *, (Rollingpeoplevaccinated/population)*100 AS PercentofRollingPopulation
FROM PopvsVac

--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
) 
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,dea.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated 
--,(Rollingpeoplevaccinated/population)
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac. location
	and dea.date = vac.date
	--where dea.continent is not null
--order by 2, 3
SELECT *, (Rollingpeoplevaccinated/population)*100 AS PercentofRollingPopulation
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualization
drop view if exists PercentPopulationVaccinated
create view PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(convert(int,dea.new_vaccinations )) OVER (Partition by dea.location order by dea.location, dea.date)
as Rollingpeoplevaccinated 
--,(Rollingpeoplevaccinated/population)
FROM Portfolioproject..CovidDeaths dea
JOIN Portfolioproject..CovidVaccinations vac
	ON dea.location = vac. location
	and dea.date = vac.date
	where dea.continent is not null
--order by 2, 3

SELECT * 
FROM PercentPopulationVaccinated