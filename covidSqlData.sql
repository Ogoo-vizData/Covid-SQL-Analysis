select *
from PortfolioProject..coviddeath
where continent is not null
order by 3,4

select *
from PortfolioProject..covidvacination
where continent is not null
order by 3,4

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..coviddeath
where continent is not null
order by 1,2

--looking at total cases vs total deaths

SELECT 
    location, 
    date, 
    CONVERT(float, total_cases) AS total_cases, 
    CONVERT(float, total_deaths) AS total_deaths, 
    (CONVERT(float, total_deaths) / CONVERT(float, total_cases)) * 100 AS Deathpercentage
FROM PortfolioProject..coviddeath
WHERE location LIKE '%states%'
ORDER BY Deathpercentage DESC;

--total cases vs population

select Location, date, total_cases, total_cases, population, (total_cases/population)*100 as infectionraate
from PortfolioProject..coviddeath
where location like '%states%'
order by 1,2

--looking at countries with highest infection rate comparaed to population
select location, population, max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentagePopulationinfected
from PortfolioProject..coviddeath
group by location, population
order by 1,percentagePopulationinfected desc

--showing countries ewith highest death count per poulation
select location,  max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..coviddeath
where continent is not null
group by location
order by Totaldeathcount desc

--lets break it down by continent/--showing the continent with the highest death count
select continent,  max(cast(total_deaths as int)) as Totaldeathcount
from PortfolioProject..coviddeath
where continent is not null
group by continent
order by Totaldeathcount desc

--global numbers
SELECT sum(new_cases) as total_cases, SUM(new_deaths) as Totaldeaths, sum (new_deaths)/sum(new_cases)*100 as Deathpercentage
from PortfolioProject..coviddeath
where continent is not null
order by 1,2

--looking at total population vs vaccinations

SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..coviddeath dea 
JOIN 
    PortfolioProject..covidvacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
ORDER BY 
    dea.location, 
    dea.date;


--use CTE
with popsvsvac (continent, location, date , population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..coviddeath dea 
JOIN 
    PortfolioProject..covidvacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL
)
select *
from popsvsvac


IF OBJECT_ID('tempdb..#PercentPopulationVaccinated') IS NOT NULL
    DROP TABLE #PercentPopulationVaccinated;

--using temp table
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(255),
    Location nvarchar(255),
    Date datetime,
    New_vaccinations numeric,
    RollingPeopleVaccinated numeric
);

INSERT INTO #PercentPopulationVaccinated (Continent, Location, Date, New_vaccinations, RollingPeopleVaccinated)
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..coviddeath dea 
JOIN 
    PortfolioProject..covidvacination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;


Select  *, RollingPeopleVaccinated
from #PercentPopulationVaccinated



--creating view to store data for later visualization
Create View PercentPopulationVaccinatedd as
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..coviddeath dea 
JOIN 
    PortfolioProject..covidvacination vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL

	--creating view to store data for later visualization
CREATE VIEW PercentPopulationVaccinated AS
SELECT 
    dea.continent, 
    dea.location, 
    dea.date, 
    dea.population, 
    vac.new_vaccinations, 
    SUM(CONVERT(BIGINT, ISNULL(vac.new_vaccinations, 0))) 
        OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM 
    PortfolioProject..coviddeath dea 
JOIN 
    PortfolioProject..covidvacination vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE 
    dea.continent IS NOT NULL;

select *
from PercentPopulationVaccinated



