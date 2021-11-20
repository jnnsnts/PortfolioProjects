Select *
From PortfolioProject..CovidDeaths
order by 3,4

Select *
From PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
Where location like '%states%'
order by 1, 2

--Looking at Total Cases vs Population
--Shows what percentage of population got Covid
Select Location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%Philippines%'
order by 1, 2


Select Location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population*100)) as PercentPopulationInfected
From PortfolioProject..CovidDeaths
Where location like '%states%'
Group by Location,Population
order by PercentPopulationInfected

--Showing the countries with highest death count per population

  Select Location, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location
order by TotalDeathCount desc

--BREAK THINGS OUT BY CONTINENT

 Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


--Showing the Continents with the highest Death count Population

 Select continent, MAX(cast (Total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc



-- GLOBAL NUMBERS

Select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths,sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
-- Where location like '%states%'
where continent is not null
--Group by date
order by 1, 2


--Looking at Total Population vs Vaccinations 
Select*
From PortfolioProject..CovidDeaths

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location order by dea.location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3

--Use CTE

with PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location order by dea.Location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac



--TEMP TABLE
DROP TABLE if exists #PercentPopulationVaccinated;	 

Create Table #PercentPopulationVaccinated
 (
 Continent nvarchar(255),
 Location nvarchar(255),
 Date datetime,
 Population numeric,
 New_Vaccinations numeric,
 RollingPeopleVaccinated numeric
 )


Insert into #PercentPopulationVaccinated

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

Select *,( RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated



--Creating View to store data

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
Sum(Cast(vac.new_vaccinations as numeric)) OVER (Partition by dea.Location order by dea.Location,
dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
  On dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3

Select *
From PercentPopulationVaccinated

