SELECT * 
FROM Portfolio.dbo.Covidvaccinations
ORDER BY 3,4

SELECT * 
FROM Portfolio.dbo.Coviddeaths
ORDER BY 3,4

--SELECT & CHECK THE DATA THAT WILL BE USED 

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM Portfolio.dbo.Coviddeaths
ORDER BY 1,2

--LOOK AT TOTAL DEATHS V.S. TOTAL CASES IN TAIWAN

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM Portfolio.dbo.Coviddeaths
WHERE location LIKE '%Taiwan%'
ORDER BY 1,2

--LOOK AT TOTAL CASES V.S. POPULATION IN TAIWAN

SELECT location, date, total_cases, population, (total_cases/population)*100 as InfectionPercentage
FROM Portfolio.dbo.Coviddeaths
WHERE location LIKE '%Taiwan%'
ORDER BY 1,2

--LOOK AT COUNTRIES WITH THE HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT location, population, MAX(total_cases)as HighestInfectionCount, MAX((total_cases/population))*100 
as InfectionPercentage
FROM Portfolio.dbo.Coviddeaths
GROUP BY location, population
ORDER BY InfectionPercentage DESC

--SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION

SELECT location, MAX(cast(total_deaths AS INT)) AS Totaldeathcount
FROM Portfolio.dbo.Coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Totaldeathcount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS INT)) AS Totaldeathcount
FROM Portfolio.dbo.Coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Totaldeathcount DESC

--GLOBAL NUMBER

SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM Portfolio.dbo.Coviddeaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

--GLOBAL NUMBER TO DATE (TOTAL)

SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths,
SUM(cast (new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
FROM Portfolio.dbo.Coviddeaths
WHERE continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL POPULATIONS V.S. NEW VACCINATIONS
--1.USE CTE

WITH VacvsPop (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
AS 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.Coviddeaths dea
JOIN Portfolio.dbo.Covidvaccinations vac
	 ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is not null 
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM VacvsPop 
ORDER BY 1,2

--LOOKING AT TOTAL POPULATIONS V.S. NEW VACCINATIONS
--2.USE TEMP TABLE

DROP table IF EXISTS #PercentPopulationVaccinated
CREATE table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.Coviddeaths dea
JOIN Portfolio.dbo.Covidvaccinations vac
	 ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is not null 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated
ORDER BY 1,2


--CREATE A VIEW TO STORE DATA 

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
  SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location
  ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM Portfolio.dbo.Coviddeaths dea
JOIN Portfolio.dbo.Covidvaccinations vac
	 ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is not null 

SELECT * 
FROM PercentPopulationVaccinated

