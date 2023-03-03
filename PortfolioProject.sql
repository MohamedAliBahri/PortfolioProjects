

SELECT *
FROM PortfolioProject..CovidDeaths
where continent is not null 
ORDER BY 3,4

-- Select Data that we are going to be using 

SELECT location, date, total_cases,new_cases , total_deaths, population 
FROM PortfolioProject..CovidDeaths
where continent is not null 
ORDER BY 1,2

-- Total Cases vs Total Deaths 

-- Shows the likelihood of dying if you contract covid in Tunisia
SELECT location, date, total_cases, total_deaths,((total_deaths/total_cases)*100) AS Death_Percentage
FROM PortfolioProject..CovidDeaths
Where location like 'Tunisia' 
ORDER BY 1,2

-- Shows the likelihood of being infected with covid in Tunisia ( Percentage of population that got Covid)
SELECT location, date, total_cases,((total_cases/population)*100) AS InfectionPercentage
FROM PortfolioProject..CovidDeaths
Where location like 'Tunisia'
ORDER BY 1,2

--Countries With the highest infection rate compared to Population
SELECT location, Population,MAX(total_cases) AS HighestInfection, MAX((total_cases/population)*100) AS HighestInfectionPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null 
Group by location, Population
ORDER BY HighestInfectionPercentage desc


--Countries with the highest DeathCount per population
SELECT location,population, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent is not null
Group by location,population
ORDER BY TotalDeathCount desc

--Aftican Countries with the highest DeathCount per population
SELECT location,population, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
where continent = 'africa'  
Group by location,population
ORDER BY TotalDeathCount desc

--Now looking at all the continents
--Showing the continent with the highest death 
SELECT continent, MAX(cast(Total_deaths as int)) AS TotalDeathCount 
FROM PortfolioProject..CovidDeaths
WHERE continent is not null
GROUP by continent
ORDER BY TotalDeathCount desc

--Global Numbers 

SELECT date, SUM(total_cases) as TotalCases, SUM(cast(total_deaths as int)) AS TotalDeaths,SUM(cast(total_deaths as int))/SUM(total_cases) * 100 AS DeathPercentageGlobal
FROM PortfolioProject..CovidDeaths
Where continent is not null
GRoup by date
Order by 1,2


-- Total Population Vs Vaccinations
Select cd.continent , cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location , cd.date) as total_vaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	ON cd.date = cv.date and cd.location = cv.location
WHERE cd.continent is not null 
order by 1,2,3


--Using a CTE so we can get the percentage of people vaccinated in each country 

WITH VaccinatedPop (Continent, Location, Date, Population,new_vaccinations, total_vaccinated)
AS 
(
Select cd.continent , cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location , cd.date) as total_vaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	ON cd.date = cv.date and cd.location = cv.location
WHERE cd.continent is not null 
)

select *,(total_vaccinated / Population) * 100 AS VaccinationPercentage
from VaccinatedPop

--Temp Table
drop table if exists #PopVaccPercentage
CREATE table #PopVaccPercentage
(continent nvarchar(255),
location nvarchar (255),
date datetime,
Population numeric,
new_vaccinations numeric,
total_vaccinated numeric
)

insert into #PopVaccPercentage
Select cd.continent , cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location , cd.date) as total_vaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	ON cd.date = cv.date and cd.location = cv.location
WHERE cd.continent is not null 

select *,(total_vaccinated / Population) * 100 AS VaccinationPercentage
from #PopVaccPercentage


--Creating View to Store data for visualizations

CREATE VIEW PercPopulationVac as  
SELECT cd.continent , cd.location, cd.date, cd.population, cv.new_vaccinations, SUM(cast(cv.new_vaccinations as int)) OVER (Partition by cd.location ORDER BY cd.location , cd.date) as total_vaccinated
from PortfolioProject..CovidDeaths cd
join PortfolioProject..CovidVaccinations cv
	ON cd.date = cv.date and cd.location = cv.location
WHERE cd.continent is not null 

select * from PercPopulationVac