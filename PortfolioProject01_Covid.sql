
--First PorfolioProject 


Select * 
From PorfolioProject..CovidDeaths
Where continent is not null
Order by 3, 4

--Selecting Data

Select location, date, total_cases, new_cases, total_deaths, population
From PorfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Total Cases vs. Total Deaths
--I used Alter Table to change the data type of total_deaths and total cases--

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where location like '%states%' and continent is not null
Order by 1,2

--Total Cases vs. Population

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
Order by 1,2

--Highest Infection Rate Compared to Population

Select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From PorfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

--Highest Death Count per Population

Select location, Max(total_deaths) as TotalDeathCount
From PorfolioProject..CovidDeaths
Where continent is not null
Group by location
Order by TotalDeathCount desc

--Global Numbers (totalcases: 2,501,980,959 totaldeaths: 22,825,241)

Select Sum(new_cases) as total_cases, Sum(new_deaths) as total_deaths, 
	   Sum(new_deaths)/Sum(new_cases)*100 as DeathPercentage
From PorfolioProject..CovidDeaths
Where continent is not null
Order by 1,2

--Using Second Table: CovidVaccinations

Select * From PorfolioProject..CovidVaccinations

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location, dea.date)
as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
	Join PorfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/population)*100
From PopvsVac

--Using Temp Table

Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--Where dea.continent is not null
--Order by 2,3

Select *, (RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

--Creating View to Store Data for later Visualizations

Create View PercentPopulationVaccinated as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
	Sum(vac.new_vaccinations) Over (Partition by dea.location Order by dea.location, dea.date)
	as RollingPeopleVaccinated
From PorfolioProject..CovidDeaths dea
Join PorfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3

Select * From PercentPopulationVaccinated