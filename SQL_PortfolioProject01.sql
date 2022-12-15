 select *
 from PortfolioProject..CovidDeaths
 where continent is not null 
 order by 3,4

 --select *
 --from PortfolioProject..CovidVaccinations
 --order by 3,4
 
 --SELECT DATA THAT WE ARE GOING TO BE USING

 select location,date,total_cases,new_cases,total_deaths,population
 from PortfolioProject..CovidDeaths
 where continent is not null
 order by 1,2

 -- LOOKING AT TOTAL CASES VS TOTAL DEATHS

 select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where location like '%India%'
 order by 1,2

 -- LOOKING AT TOTAL CASES VS POPULATION

 select location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
 from PortfolioProject..CovidDeaths
 --where location like '%india%'
 order by 1,2

 --  LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION 

  select location,population,max(total_cases) as HighestInfectionCount ,Max((total_cases/population))*100 as PercentPopulationInfected
 from PortfolioProject..CovidDeaths
-- where location like '%india%'
 group by location,population
 order by PercentPopulationInfected desc

 -- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION 

 select location,max(cast(total_deaths as int)) as TotalDeathCount 
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by location,population
 order by TotalDeathCount desc

 -- BY LOCATIONS

 select location,max(cast(total_deaths as int)) as TotalDeathCount 
 from PortfolioProject..CovidDeaths
 where continent is null
 group by location
 order by TotalDeathCount desc

 -- BY CONTINENTS

 select continent,max(cast(total_deaths as int)) as TotalDeathCount 
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 -- CONTINENTS WITH HIGHEST DEATH COUNTS PER POPULATION 

 select continent,max(cast(total_deaths as int)) as TotalDeathCount 
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by continent
 order by TotalDeathCount desc

 -- GLOBAL NUMBERS

 select date,SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 group by date
 order by 1,2

 select SUM(new_cases) as TotalCases, SUM(CAST(new_deaths as int)) as TotalDeaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
 from PortfolioProject..CovidDeaths
 where continent is not null
 --group by date
 --order by 1,2

 -- Join

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as TotalPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE 

with PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated) as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--USING DROP

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)

insert into #PercentPopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- CREATING VIEW TO STORE DATA FOR VISUALISATION

create view PercentPopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,
       sum(convert(int,vac.new_vaccinations)) over(partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
  on dea.location=vac.location
  and dea.date=vac.date
where dea.continent is not null
--order by 2,3


select *
from PercentPopulationVaccinated