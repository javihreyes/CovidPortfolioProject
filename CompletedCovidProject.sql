SELECT Location, date, total_cases, new_cases, total_deaths, population
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
order by 1,2

-- Looking at total cases vs toatl deaths
-- Shows likelihood of dying if you contract covid in the United States
SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Where location like '%United States%'
order by 1,2

-- Shows death percentage from covid in the United States
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS DeathPercentage
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Where location like '%United States%'
order by 1,2

-- Shows what percentage of population got covid
SELECT Location, date, total_cases, population, (total_cases/population)*100 AS PercentPopulationInfected
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
order by 1,2

-- Looking at Countries with Highest Infection Rate compared to population
SELECT Location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Group by  location, population
order by PercentPopulationInfected desc

-- Showing Countriest with highest Death Count per Population
SELECT Location, MAX(cast(total_deaths as int)) as TotalDeathCount
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Where continent is not null
Group by Location
order by TotalDeathCount desc

-- Break things Down BY Continent
SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Where continent is not null
Group by Continent
order by TotalDeathCount desc

-- Global Numbers
SELECT date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Where continent is not null
Group By date
order by 1,2

-- Global Numbers in total dataset
SELECT SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS DeathPercentage
From `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths`
Where continent is not null
order by 1,2

--total population vs vaccination
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations AS int)) Over (partition by dea.Location order by dea.location, dea.date) as RollingVaccinated
From `chromatic-timer-381216.PortfolioProjectCovid..CovidDeaths` as dea
JOIN `chromatic-timer-381216.PortfolioProjectCovid..CovidVaccinations` as vac
  On dea.location = vac.location
  and dea.date = vac.date
 where dea.continent is not null
order by 2,3

-- Use CTE
WITH PopvsVac AS (
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM 
    `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths` AS dea
    JOIN `chromatic-timer-381216.PortfolioProjectCovid.CovidVaccinations` AS vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL
)

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM 
  PopvsVac;

-- Create View to store data for later visualization
CREATE VIEW `chromatic-timer-381216.PortfolioProjectCovid.PercentagePopulationVaccination` AS
  SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS int)) OVER (PARTITION BY dea.Location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
  FROM 
    `chromatic-timer-381216.PortfolioProjectCovid.CovidDeaths` AS dea
    JOIN `chromatic-timer-381216.PortfolioProjectCovid.CovidVaccinations` AS vac ON dea.location = vac.location AND dea.date = vac.date
  WHERE 
    dea.continent IS NOT NULL;