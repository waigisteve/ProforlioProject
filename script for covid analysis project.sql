select * from [dbo].[Covid-deaths]
order by 3,4

--select * from [dbo].[Covid-vaccinations]
--order by 3,4

-- select Data that we are going to be using


select location, date, total_cases, new_cases, total_deaths, population 
from [dbo].[Covid-deaths]
order by 1,2

ALTER TABLE [dbo].[Covid-deaths]
ALTER COLUMN total_cases bigint;

ALTER TABLE [dbo].[Covid-deaths]
ALTER COLUMN total_deaths bigint;

ALTER TABLE [dbo].[Covid-deaths]
ALTER COLUMN population bigint;

--- looking at total cases vs total deaths
---- shows the liklihood of dying if you contact covid in your country

select location, date, total_cases, total_deaths,(TRY_CAST(total_deaths AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0)) * 100.0 AS DeathPercentage
from [dbo].[Covid-deaths]
where location = 'United States'
order by 1,2

--- looking at total cases vs population
---- shows the likelihood of dying if you contact covid in your country

select location, date,total_cases, population,(TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0)) * 100.0 AS CasesperPopulationPercentage
from [dbo].[Covid-deaths]
order by 1,2

select location, date,total_cases, population,MAX (Total_cases) as HighestInfectionCount, MAX( (TRY_CAST(total_cases AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0))) * 100.0 AS PercentagePopulationInfected 
from [dbo].[Covid-deaths]
group by Location, Population
order by PercentagePopulationInfected DESC

select location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [dbo].[Covid-deaths]
where continent is not null
group by Location
Order by TotalDeathCount Desc


--- BREAK THINGS DOWN BY CONTINENT

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [dbo].[Covid-deaths]
where continent  like 'Asia' 
group by continent
Order by TotalDeathCount Desc

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [dbo].[Covid-deaths]
where continent like 'Asia' or continent like 'Europe' or continent like 'Africa' or continent like 'North America'
group by continent
Order by TotalDeathCount Desc

-- showing the continent wiht the highest deathcount

select continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM [dbo].[Covid-deaths]
where continent like 'Asia' or continent like 'Europe' or continent like 'Africa' or continent like 'North America'
group by continent
Order by TotalDeathCount Desc

--global numbers 

Select date, SUM(new_cases), SUM(CAST(new_deaths as int)), SUM(cast(new_deaths as int))/SUM (new_cases) *100  as DeathPercentage 
from [dbo].[Covid-deaths]
where continent is not null
Group by date
order by 1,2

----joins
---looking at Total Population vs Vaccinations
---use CTE 
with PopvsVac (continent, location,Date,Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location ,  dea.date ,dea.population, vac.new_vaccinations,
SUM (CONVERT( bigint, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
from [dbo].[Covid-deaths] dea
join [dbo].[Covid-vaccinations] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null

)
select *,(TRY_CAST(RollingPeopleVaccinated AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(Population AS NUMERIC(10, 2)), 0)) * 100.0
from PopvsVac

---temp table

Drop Table if exists #PercentPopulationvaccinated
create table
#PercentPopulationvaccinated
(
Continents nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

  
Insert into #PercentPopulationvaccinated

Select dea.continent, dea.location ,  dea.date ,dea.population, vac.new_vaccinations,
SUM (CONVERT( bigint, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
from [dbo].[Covid-deaths] dea
join [dbo].[Covid-vaccinations] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null

select *,(TRY_CAST(RollingPeopleVaccinated AS NUMERIC(10, 2)) / NULLIF(TRY_CAST(Population AS NUMERIC(10, 2)), 0)) * 100.0
FROM #PercentPopulationvaccinated

--CREATING VIEW TO STORE DATA FOR LATER
Create view vWPercentPopulation as 
Select dea.continent, dea.location ,  dea.date ,dea.population, vac.new_vaccinations,
SUM (CONVERT( bigint, vac.new_vaccinations)) over (Partition by dea.Location Order by dea.location,dea.date) AS RollingPeopleVaccinated
from [dbo].[Covid-deaths] dea
join [dbo].[Covid-vaccinations] vac
on dea.location =vac.location
and dea.date = vac.date
where dea.continent is not null

select * from [dbo].[vWPercentPopulation]