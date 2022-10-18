/*

Project: Data Exploration Using SQL Queries

*/


--------------------------------------------------------------------------------------------------------------------------

--Query To Explore The Data  
Select 
location as country,
date,
total_cases,
new_cases,
total_deaths,
population
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by
1, 2
-- "contintent is not null" filters out rows containing redundant data  

--------------------------------------------------------------------------------------------------------------------------


--Query To Look At Total Cases vs Total Deaths
--Shows A Rough Liklihood Of Dying From Contracting COVID 19 
Select 
location as country,
date,
total_cases,
total_deaths,
(total_deaths/total_cases)*100 as deathpercentage
From [Portfolio Project]..CovidDeaths
Where
continent is not null
Order by
1, 2

--------------------------------------------------------------------------------------------------------------------------


--Query To Look At Total Cases vs Population
--Shows What Percentage Of The Population Was Infected 
Select 
location as country,
date,
total_cases,
population,
(total_cases/population)*100 as infectionpercentage
From [Portfolio Project]..CovidDeaths
Where
continent is not null
Order by
1, 2

--------------------------------------------------------------------------------------------------------------------------


--Query To Look At Countries With The Highest Infection Rate Compared To Their Population 
Select 
location as country,
max(total_cases) as HighestInfectionCount,
population,
max((total_cases/population))*100 as PercentPopulationInfected
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location, population
Order by
4 desc

--------------------------------------------------------------------------------------------------------------------------


--Query To Look At Countries With The Highest Death Count Per Population 
Select 
location as country,
max(cast(total_deaths as int)) as HighestDeathCount,
population,
max((total_deaths/population))*100 as PercentPopulationDeceased
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by location, population
Order by
2 desc

--------------------------------------------------------------------------------------------------------------------------


--Query To Explore The Data Per Contintent
Select 
location,
max(cast(total_deaths as int)) as HighestDeathCount
From [Portfolio Project]..CovidDeaths
Where continent is null
Group by location
Order by
2 desc

--------------------------------------------------------------------------------------------------------------------------


--Query Outlining Global Numbers (Per Day)
Select 
date, 
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Group by date
Order by 3,4

--------------------------------------------------------------------------------------------------------------------------


--Query Outlining Global Totals 
Select 
sum(new_cases) as total_cases,
sum(cast(new_deaths as int)) as total_deaths,
sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
From [Portfolio Project]..CovidDeaths
Where continent is not null
Order by 1,2

--------------------------------------------------------------------------------------------------------------------------


--Query To Look At The Total Population vs Vaccinations
Select dea.continent, 
dea.location, 
dea.date,
dea.population,
vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as rolling_people_vaccinated
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vacc
on dea.location = vacc.location
and dea.date = vacc.date
Where dea.continent is not null
Order by 2,3

--------------------------------------------------------------------------------------------------------------------------


--Query To Use A CTE And Perform Further Calculations 
With PopulationvsVaccination (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as 
(
Select dea.continent, 
dea.location, 
dea.date,
dea.population,
vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as rolling_people_vaccinated
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vacc
on dea.location = vacc.location
and dea.date = vacc.date
Where dea.continent is not null
)


Select *, 
(rolling_people_vaccinated/population)*100 as rolling_percent_vaccinated
from PopulationvsVaccination

--------------------------------------------------------------------------------------------------------------------------


--Query To Demonstrate The Use Of A Temp Table 
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255), 
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, 
dea.location, 
dea.date,
dea.population,
vacc.new_vaccinations,
sum(cast(vacc.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date) as rolling_people_vaccinated
From [Portfolio Project]..CovidDeaths as dea
join [Portfolio Project]..CovidVaccinations as vacc
on dea.location = vacc.location
and dea.date = vacc.date
Where dea.continent is not null


Select *, 
(rolling_people_vaccinated/population)*100 as rolling_percent_vaccinated
From #PercentPopulationVaccinated

--------------------------------------------------------------------------------------------------------------------------


--Query To Demonstrate The Creation Of A View To Export Files
Create View GeneralCovidDeaths
as

Select 
location as country,
date,
total_cases,
new_cases,
total_deaths,
population
From [Portfolio Project]..CovidDeaths
Where continent is not null


--View To Look At Total Cases vs Population
Shows What Percentage Of The Population Was Infected 
Create View CasesvsPopulationCanada
as

Select 
location as country,
date,
total_cases,
population,
(total_cases/population)*100 as infectionpercentage
From [Portfolio Project]..CovidDeaths
Where
continent is not null


