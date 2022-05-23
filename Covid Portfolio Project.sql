CREATE DATABASE PortfolioProject;
SELECT * 
FROM portfolioproject.coviddeaths
WHERE continent is not null
ORDER BY 3,4

/* SELECT * 
FROM portfolioproject.covidvaccinations
ORDER BY 3,4 */

--Select Data To Be Used


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM portfolioproject.coviddeaths
WHERE continent is not null
ORDER BY 1,2

--Solving total_cases VS total_deaths 
--The odds of dying if you contact Covid In Africa


SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage 
FROM portfolioproject.coviddeaths
WHERE location like '%Africa%'
AND continent is not null
ORDER BY 1,2

--solving total_cases VS population
--tells us what percentage of population got covid in Africa


SELECT location, date, population, total_cases, (total_cases/population)*100 as percentage_population_infected 
FROM portfolioproject.coviddeaths
WHERE location like '%Africa%'
AND continent is not null
ORDER BY 1,2


--countries with highest infection rates VS population


SELECT location, population, MAX(total_cases) as highest_Infection_Count, MAX((total_deaths/total_cases))*100 as percentage_population_infected 
FROM portfolioproject.coviddeaths
WHERE location like '%africa%'
GROUP BY location, population
ORDER BY percentage_population_infected 


--countries with the highest death count per population


SELECT location, MAX(CAST(total_deaths as unsigned)) as total_death_count
FROM portfolioproject.coviddeaths
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count desc

--Total Deaths by Continent

--showing the continent with the highest death count per population


SELECT continent, MAX(cast(total_deaths as signed)) as total_death_count
FROM portfolioproject.coviddeaths
WHERE continent is not null
GROUP BY continent 
ORDER BY total_death_count desc


--Global Numbers


SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as SIGNED)) AS total_death, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM portfolioproject.coviddeaths
WHERE continent is not null 
ORDER BY 1,2 


--Global Number by dates


SELECT date, SUM(new_cases) AS total_cases, SUM(CAST(new_deaths as SIGNED)) AS total_death, SUM(new_deaths)/SUM(new_cases)*100 as death_percentage
FROM portfolioproject.coviddeaths
WHERE continent is not null 
GROUP BY date
ORDER BY 1,2 desc


---joining the tables


SELECT * 
FROM portfolioproject.coviddeaths dea
INNER JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date


--- doing for Total population VS vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS currentPeopleVaccinated
FROM portfolioproject.coviddeaths dea
INNER JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
order by 2,3  


--- Using CTE


With PopvsVac (continent, location, date, population, new_vaccinations, currentPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS currentPeopleVaccinated
FROM portfolioproject.coviddeaths dea
INNER JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null
)
SELECT*, (currentPeopleVaccinated/population)*100
FROM PopvsVac


---TEMP TABLE
DROP TEMPORARY TABLE PercentPopulationVaccinated
CREATE TEMPORARY TABLE PercentPopulationVaccinated
(
continent VARCHAR (200) not null default 0,
location VARCHAR (200) not null default 0,
date datetime,
population INT UNSIGNED not null default 0,
new_vaccinations text UNSIGNED not null default 0,
currentPeopleVaccinated decimal(43,0) UNSIGNED not null default 0,
)
INSERT INTO PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS currentPeopleVaccinated
FROM portfolioproject.coviddeaths dea
INNER JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
    
SELECT*, (currentPeopleVaccinated/population)*100
FROM PercentPopulationVaccinated

/*Creating view to store later for visualization */


CREATE VIEW PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CAST(vac.new_vaccinations as unsigned)) OVER (Partition By dea.location ORDER BY dea.location, dea.date) AS currentPeopleVaccinated
FROM portfolioproject.coviddeaths dea
INNER JOIN portfolioproject.covidvaccinations vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent is not null 



percentpopulationvaccinated