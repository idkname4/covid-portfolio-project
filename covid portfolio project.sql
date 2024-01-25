select *
from portfolioProject..CovidDeaths$

--looking at total cases vs total deaths

select Location , date , total_cases,total_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioProject..coviddeaths$
where Location like 'india'
order by 1,2

--looking at total cases vs population
select Location , date , total_cases,population,(total_cases/population)*100 as populationinfected
from portfolioProject..coviddeaths$
--where Location like 'india'
order by 1,2

--looking for countries having highest infection rate comapared to population 
select Location ,max(total_cases)as highestinfectionrate,max((total_cases/population))*100 as percentagepopulationinfected,population
from portfolioProject..coviddeaths$
group by location , population
order by  percentagepopulationinfected desc 



--looking for countries having highest death count per population 
select Location ,max(cast(total_deaths as bigint)) totaldeathcount
from portfolioProject..coviddeaths$
where continent is not null--this is rid of the unwanted locaton entries like world ,africa asia
group by location 
order by totaldeathcount desc 


--Let's break thing up by continent


select Location ,max(cast(total_deaths as bigint)) totaldeathcount
from portfolioProject..coviddeaths$
where continent is null
group by location 
order by totaldeathcount desc 



--breaking Global numberS
--(i)
select date ,Sum(new_cases) sumofcasesoneachday--al_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioProject..coviddeaths$
where continent is not null
group by date --eveneyer we're trying to group he must put everthing in select column to aggreate column 
order by 2 desc --this willl eventually tell us that on which date acc to my data has higest sum of cases around world i.e 2021-04-28

--(ii)
select date ,Sum(cast(new_deaths as float)) sumofdaethsoneachday--al_deaths,(total_deaths/total_cases)*100 as deathpercentage
from portfolioProject..coviddeaths$
where continent is not null
group by date --evenever we're trying to group he must put everthing in select column to aggregate column 
order by 2 desc --this willl eventually tell us that on which date acc to my data has higest sum of deaths around world i.e 2021-01-20

--(final)
select Sum(new_cases) totalcases ,Sum(cast(new_deaths as float)) totaldeaths , (Sum(cast(new_deaths as float))/sum(new_cases)*100) deathpercentage
from portfolioProject..coviddeaths$
where continent is not null
--group by date 
order by 1,2

--now lets join  and have fun
--lokking at TOTal population vs population

select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations))over(partition by cd.location order by cd.location,
cd.date)as rollingpeoplevaccinated --this will add new vaccin.. nos and tell up total nos vaccinat... without using actual data
--,(rollingpeoplevaccinated/population )*100 --not applicable because we can't you aggregate column below
from portfolioProject..CovidDeaths$ cd
inner join portfolioProject..CovidVaccinations$ cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null
order by 2 ,3

--(i)use cte for comment one 

with pop_vs_vac (continent, location , date , population ,new_vaccinations,rollingpeoplevaccinated)
as (
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations))over(partition by cd.location order by cd.location,
cd.date)as rollingpeoplevaccinated --this will add new vaccin.. nos and tell up total nos vaccinat... without using actual data
from portfolioProject..CovidDeaths$ cd
inner join portfolioProject..CovidVaccinations$ cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null
)
select *
,(rollingpeoplevaccinated/population)*100 --this tell us that at any date who people get vaccinated 
from pop_vs_vac

--(ii)use temp table for comment one 

Drop table if exists #percentpopulationvaccinated --you know you know what this is

create table #percentpopulationvaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime ,
population bigint,
new_vaccination numeric,
rollingpeoplevaccinated numeric)

insert into #percentpopulationvaccinated
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations))over(partition by cd.location order by cd.location,
cd.date)as rollingpeoplevaccinated --this will add new vaccin.. nos and tell up total nos vaccinat... without using actual data
--,(rollingpeoplevaccinated/population )*100 --not applicable because we can't you aggregate column below
from portfolioProject..CovidDeaths$ cd
inner join portfolioProject..CovidVaccinations$ cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null

select *
,(rollingpeoplevaccinated/population)*100 --this tell us that at any date who people get vaccinated 
from #percentpopulationvaccinated


--creating view to store for later visualizations
--(i)

create  view percentpopulationvaccinated as
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations
,sum(convert(bigint,cv.new_vaccinations))over(partition by cd.location order by cd.location,
cd.date)as rollingpeoplevaccinated --this will add new vaccin.. nos and tell up total nos vaccinat... without using actual data
--,(rollingpeoplevaccinated/population )*100 --not applicable because we can't you aggregate column below
from portfolioProject..CovidDeaths$ cd
inner join portfolioProject..CovidVaccinations$ cv
	on cd.location=cv.location
	and cd.date=cv.date
where cd.continent is not null

select *
from percentpopulationvaccinated

--(ii)
create view sumofcases_and_deaths_on_each_day as 
select date ,Sum(new_cases) sumofcasesoneachday ,Sum(cast(new_deaths as float)) sumofdaethsoneachday
from portfolioProject..coviddeaths$
where continent is not null
group by date --eveneyer we're trying to group he must put everthing in select column to aggreate column 
 --this willl eventually tell us that on which date acc to my data has higest sum of cases around world i.e 2021-04-28

select *
from sumofcases_and_deaths_on_each_day