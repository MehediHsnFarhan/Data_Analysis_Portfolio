SELECT location,
	date,
    total_cases,
    new_cases,
    total_deaths,
    population
FROM covid_report.covid_death
ORDER BY 1, 2;


-- Looking at Total Cases VS Total Death By Country
SELECT location
	, date
    , max(total_cases) as max_cases
    , max(total_deaths) as max_deaths
    , max((total_deaths/ total_cases))*100 as death_percentage
FROM covid_death
-- WHERE location LIKE '%States%'
GROUP BY location
-- 	, year(`date`)
ORDER BY 1;


-- Looking for What Percentage of Population got Covid Effected
SELECT location
	, date
    , max(total_cases)
    , population
    , max((total_cases/population))*100 as percentage 
FROM covid_death
-- where location like '%states'
GROUP BY location, population
ORDER BY percentage DESC;

-- Looking for Total Cases Vs Populations
-- Show What Parcentage of Population got Covid

SELECT location
	, date
    , total_cases
    , population
    , (total_cases/population)*100 AS AffactPercentage
FROM covid_death
ORDER BY 5 DESC;

-- Loking for Countries with heighest Infaction Rate compare to populations
SELECT location
    , max(total_cases)
    , population
    , max((total_cases/population))*100 AS INFACTION_Rate
FROM covid_death
group by location , population
order by INFACTION_Rate DESC;


-- Showing Countries with highest death count per population
SELECT location
	, MAX(total_deaths) AS TotalDeadth
    
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeadth DESC;

-- BREAK BY CONTINENTS
SELECT continent
	, MAX(total_deaths) AS TotalDeadth
    
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeadth DESC;


-- GLOBAL NUMBERS
SELECT date 
	, SUM(new_cases)
    , SUM(new_deaths)
    , (SUM(new_deaths)/SUM(new_cases))*100 AS DayDeathPersentage
FROM covid_death
where continent IS NOT NULL
GROUP BY date
ORDER BY 3 DESC;

-- TOTAL GLOBAL NUMBERS
SELECT SUM(new_cases)
    , SUM(new_deaths)
    , (SUM(new_deaths)/SUM(new_cases))*100 AS DayDeathPersentage
FROM covid_death
where continent IS NOT NULL;



-- Looking for Total Population vs Vaccinations

WITH PopVac (continent, location, date, population, new_vaccination, DaySumVaccinated)
as
(
SELECT dt.continent
	, dt.location
    , dt.date
    , dt.population
    , vac.new_vaccinations
    , SUM(vac.new_vaccinations) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS DaySumVaccinated
FROM covid_death AS dt
JOIN covid_vacination AS vac
	ON dt.location = vac.location
    AND dt.date = vac.date
WHERE dt.continent IS NOT NULL
-- ORDER BY 2, 3
)
SELECT *
	, (DaySumVaccinated/population)*100
From PopVac;



-- TEMP TABLE
DROP TABLE IF EXISTS PresentPopulationVaccinated;
CREATE TABLE PresentPopulationVaccinated (	
	`Continent` varchar(255)
    , Location Varchar(255)
    , Date datetime
    , Population float
    , new_vaccinations float
    , DaySumVaccinated float
);
INSERT INTO PresentPopulationVaccinated (
SELECT dt.continent
	, dt.location
    , dt.date
    , dt.population
    , vac.new_vaccinations
    , SUM(vac.new_vaccinations) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS DaySumVaccinated
FROM covid_death AS dt
JOIN covid_vacination AS vac
	ON dt.location = vac.location
    AND dt.date = vac.date
WHERE dt.continent IS NOT NULL
-- ORDER BY 2, 3
);

-- Creating View to store date for later Visualization
CREATE VIEW ParcentageVaccinatedByPopulation AS
SELECT dt.continent
	, dt.location
    , dt.date
    , dt.population
    , vac.new_vaccinations
    , SUM(vac.new_vaccinations) OVER (PARTITION BY dt.location ORDER BY dt.location, dt.date) AS DaySumVaccinated
FROM covid_death AS dt
JOIN covid_vacination AS vac
	ON dt.location = vac.location
    AND dt.date = vac.date
WHERE dt.continent IS NOT NULL;
-- ORDER BY 2, 3


-- Creating View to show Continent Death Percentage
CREATE VIEW Total_Death_By_Continent AS
SELECT continent
	, MAX(total_deaths) AS TotalDeadth
    
FROM covid_death
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeadth DESC;
