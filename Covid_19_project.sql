select location_,date_,total_cases,new_cases,total_Deaths,population
from coviddeaths
order by 1,2

---- Looking at total cases vs total deaths
---- Show the likelihood of dying if you contract covid in your country

select location_,date_,total_cases,total_deaths,cast(total_deaths as float)/total_cases *100 as deathpercentage
from coviddeaths
where location_ like '%India%'
order by 1,2

---- Looking at the total cases vs population
---- Shows what percentage of population got covid
select location_,date_,total_cases,population,cast(total_cases as float)/population *100 as percent_population_infected
from coviddeaths
where location_ like '%India%'
order by 1,2

---- Looking at countries highest infection rate compared to population
select location_,max(total_cases) as max_cases,population,max(cast(total_cases as float)/population *100) as highest_infection_percentage
from coviddeaths
group by location_,population
order by highest_infection_percentage desc

---- Showing the countries with the highest death count per population
select location_,max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is not null
group by location_
order by TotalDeathCount desc

---- LETS BREAK THIS DOWN BY CONTINENT

---- Total death count in each continent

select location_,max(total_deaths) as TotalDeathCount
from coviddeaths
where continent is null
and location_ not in ('High income','Upper middle income','Lower middle income','Low income')
group by location_
order by TotalDeathCount desc


---- GLOBAL NUMBERS

SELECT sum(new_cases) as total_cases,sum(cast(new_deaths as float)) as total_deaths,sum(cast(new_deaths as float))/nullif(sum(cast(new_cases as float)),0)*100 as death_percentage
from coviddeaths
where continent is not NULL
and location_ not in ('High income','Upper middle income','Lower middle income','Low income')
order by 1,2

---looking at total population vs total vaccinations
select dea.continent,dea.location_,dea.date_,dea.population,vac.new_vacciantions , sum(vac.new_vacciantions) OVER (PARTITION BY dea.location_ order by dea.location_,dea.date_) as RollingPeopleVaccinated
from coviddeaths dea 
join covidvaccinations vac
on dea.location_ = vac.location
and dea.date_ = vac.date
where dea.continent is not null
order by 2,3

--- USE CTE

With PopvsVac(Continent,Location_,Date_,population)
as
(
select dea.continent,dea.location_,dea.date_,dea.population,vac.new_vacciantions , sum(vac.new_vacciantions) OVER (PARTITION BY dea.location_ order by dea.location_,dea.date_) as RollingPeopleVaccinated
from coviddeaths dea 
join covidvaccinations vac
on dea.location_ = vac.location
and dea.date_ = vac.date
where dea.continent is not null
)
select *, (RollingPeopleVaccinated/CAST(population as float))*100 from PopvsVac



--- TEMP TABLE


Create TABLE PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)




---- creating view to store data for later visualisations
CREATE VIEW PercentPopulationVaccianted AS
Select dea.continent,dea.location_,dea.date_,dea.population,vac.new_vaccinations
,SUM(C)
