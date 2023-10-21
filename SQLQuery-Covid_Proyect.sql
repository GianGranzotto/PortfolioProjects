SELECT *
From PortfolioProyect..CovidDeaths
WHERE continent is not null
ORDER BY 3,4

SELECT *
From PortfolioProyect..CovidVaccinations
WHERE continent is not null
ORDER BY 3,4

--SELECT DATA THAT WE ARE GOING TO BE USING

SELECT location, date, total_cases, new_cases, total_deaths, population
From PortfolioProyect..CovidDeaths
WHERE continent is not null
order by 1,2

-- Looking at Total Cases vs Total Deaths

--Shows likehood of dying if you contract covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
From PortfolioProyect..CovidDeaths
WHERE location like 'Argentina'
and continent is not null
order by 1,2


--Looking at Total Cases vs Population
--Shows what percentage of population got covid
SELECT location, date, population, total_cases, (total_cases/population)*100 AS Percent_Population_Infected
From PortfolioProyect..CovidDeaths
--WHERE location like 'Argentina'
WHERE continent is not null
order by 1,2


--Looking at Countries with Highest Infection Rate compared to Population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Percent_Population_Infected
From PortfolioProyect..CovidDeaths
--WHERE location like 'Argentina'
WHERE continent is not null
GROUP BY location, population
order by Percent_Population_Infected DESC

--Showing Countries with Highest Dead Count per population

SELECT location, MAX(cast(total_deaths as int)) AS Total_Death_Count
From PortfolioProyect..CovidDeaths
--WHERE location like 'Argentina'
WHERE continent is not null
GROUP BY location
order by Total_Death_Count DESC

--Let's break things down by continent 

--Showing continents with highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS Total_Death_Count
From PortfolioProyect..CovidDeaths
--WHERE location like 'Argentina'
WHERE continent is not null
GROUP BY continent
order by Total_Death_Count DESC

--Global Numers

SELECT date, SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProyect..CovidDeaths
--WHERE location like 'Argentina'
WHERE continent is not null
GROUP BY date
order by 1,2

--Total Cases

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 AS Death_Percentage
From PortfolioProyect..CovidDeaths
--WHERE location like 'Argentina'
WHERE continent is not null
--GROUP BY date
order by 1,2


--Looking al Total Population vs Caccination

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
JOIN PortfolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3 
)
SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac


--TEMP TABLE

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_Vaccination numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
JOIN PortfolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3 

SELECT *, (RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccinated


--Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as 
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
	dea.date) as Rolling_People_Vaccinated
--, (RollingPeopleVaccinated/population)*100
FROM PortfolioProyect..CovidDeaths dea
JOIN PortfolioProyect..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent is not null
--order by 2, 3 

SELECT *
FROM PercentPopulationVaccinated