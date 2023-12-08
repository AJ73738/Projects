

--select * 
--from CovidVaccinations
--order by 3,4


Select Location,date,total_deaths,new_cases,total_cases,population
from CovidDeaths
order by 1,2

select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths
order by 1,2



select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
from CovidDeaths
where location like '%Nigeria%'
order by 1,2


select location,date,total_cases,Population,(population/total_cases)*100 as Populationpercentage
from CovidDeaths
where location like '%nigeria%'
order by 1,2



select location,population,MAX(total_cases)as Highestinfectoncount,max(total_cases/Population)*100 as populationinfected
from Coviddeaths
Group by location,population
order by populationinfected desc

select location,MAX(cast(total_deaths as int ))as totaldeaths
from CovidDeaths
where continent is null
Group by location,population
order by totaldeaths desc


select continent,MAX(cast(total_deaths as int ))as totaldeathsincontinents
from CovidDeaths
where continent is null
Group by continent
order by totaldeathsincontinents desc

select location,MAX(cast(total_deaths as int ))as totaldeathsincontinents
from CovidDeaths
where continent is null
Group by location
order by totaldeathsincontinents desc



select date,sum(new_cases),sum(cast(new_deaths as int))
from CovidDeaths
where continent is not null
group by date
order by 1,2


select date,sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int ))/sum(new_cases) * 100 as Deathpercentage
from CovidDeaths
where continent is not null
group by date
order by 1,2

select sum(new_cases) as totalcases,sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int ))/sum(new_cases) * 100 as Deathpercentage
from CovidDeaths
where continent is not null
--group by date
order by 1,2


select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from CovidDeaths dea
join covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
join covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
order by 1,2

 --USING CTE

with PopulationVsVaccinations (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
join covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 1,2
)
select *,RollingPeopleVaccinated/population*100      
from PopulationVsVaccinations

--TEMP TABLE

DROP TABLE IF EXISTS Percentpopulationvaccinated
CREATE TABLE Percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric

)


INSERT INTO Percentpopulationvaccinated
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
join covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 1,2

select *,RollingPeopleVaccinated/population*100      
from Percentpopulationvaccinated


CREATE VIEW  Percentpopulationvaccinated2 AS
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from CovidDeaths dea
join covidvaccinations vac
on dea.location=vac.location and dea.date=vac.date
where dea.continent is not null
--order by 1,2





 