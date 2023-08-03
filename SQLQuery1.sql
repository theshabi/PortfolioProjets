
--Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Death
select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location = 'Azerbaijan'
order by 1,2


--Looking at Total Cases vs Population
select location, date, population,total_cases,(total_cases/population)*100 as TotalCasePercentage
from PortfolioProject..CovidDeaths
where location = 'Azerbaijan'
order by 1,2

--Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as highestCase, max((total_cases/population))*100 as TotalCasePercentage
from PortfolioProject..CovidDeaths
group by location, population
order by 4 desc

-- Showing Countries with Highest Death count per Population

select location, max(cast(total_deaths as int)) as highestDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by 2 desc

-- BY CONTINENT

select continent, max(cast(total_deaths as int)) as highestDeath
from PortfolioProject..CovidDeaths
where continent is not null
group by continent
order by 2 desc

-- Showing global numbers group by date

select date, sum(new_cases) as new_total_cases ,sum(cast(new_deaths as int)) as new_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1,2

-- Showing global numbers 

select  sum(new_cases) as new_total_cases ,sum(cast(new_deaths as int)) as new_deaths,
sum(cast(new_deaths as int))/sum(new_cases) * 100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
order by 1,2

--Total Population vs Vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with popvsvac (continent,location, date, population, new_vaccinations,RollingPeopleVaccinated )
as (
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null

)

select *, (RollingPeopleVaccinated/population)*100 from popvsvac

--USE TEMP TABLES

drop table if exists  #PercentPeopleVaccinated

create table #PercentPeopleVaccinated (
continent nvarchar(225),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)


insert into #PercentPeopleVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null


select *, (RollingPeopleVaccinated/population)*100 from #PercentPeopleVaccinated

--VIEW

create view PercentPeopleVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
on dea.location = vac.location and
dea.date = vac.date
where dea.continent is not null