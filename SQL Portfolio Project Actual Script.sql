--OCTOBER 28

SELECT * FROM COVIDReports..CovidDeaths
SELECT * FROM COVIDReports..CovidVaccinations
WHERE continent is not null


SELECT continent, DATE, total_cases, new_cases, total_deaths, population
FROM COVIDReports..CovidDeaths
WHERE continent is not null
ORDER BY 1, 2

--TOTAL CASES VS TOTAL DEATHS
--Shows the likelihood of death if you contract COVID in your country

SELECT location, DATE, total_cases, new_cases, total_deaths, (total_deaths/total_cases)*100 AS Percentage_Of_Death
FROM COVIDReports..CovidDeaths
WHERE location LIKE '__DIA' 
ORDER BY 1, 2

--TOTAL CASES VS POPULATION
--SHOWS HOW MANY PEOPLE GOT COVID IN THE Poplulation

SELECT continent, DATE, total_cases, population, (total_cases/population)*100 AS Percentage_Of_Infected
FROM COVIDReports..CovidDeaths
WHERE continent LIKE 'india'
ORDER BY 1, 2

--OCTOBER 29

--Looking at hightest number of infected in the population

SELECT continent, population, Max(total_cases) as Hightest_Count, Max((total_cases/population)*100) AS Percentage_of_Infected_in_total_population
FROM COVIDReports..CovidDeaths
--WHERE location LIKE 'india'
WHERE continent is not null
group by continent, population
ORDER BY Percentage_of_Infected_in_total_population desc

--Showing countries with hightest death count per population (incorrect numbers)

SELECT continent, Max(CAST(total_deaths AS int)) as Hightest_Count
FROM COVIDReports..CovidDeaths
--WHERE location LIKE 'india'
where continent is not null
group by continent 
ORDER BY Hightest_Count desc

--Showing countries with hightest death count per population per continent

SELECT location, Max(CAST(total_deaths AS int)) as Hightest_Count
FROM COVIDReports..CovidDeaths
--WHERE location LIKE 'india'
where continent is null
group by location 
ORDER BY Hightest_Count desc

--Showing countries with hightest death count per population excluding world and international

SELECT location, Max(CAST(total_deaths AS int)) as Hightest_Count 
FROM COVIDReports..CovidDeaths
WHERE location NOT IN ('world', 'international') 
and continent is null
GROUP BY location 
ORDER BY Hightest_Count DESC;

--Total count of cases and death according to the date

Select date, SUM(cast (new_cases as int)) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, Sum (cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentages
From Covidreports..coviddeaths
Where continent is not null
Group by date

--Looking up the total death percentage 

Select SUM(cast (new_cases as int)) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, Sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentages
From Covidreports..coviddeaths
Where continent is not null
--Group by date

--Looking at Total population Vs Vaccinations (Should give day to day concurrent count of vacciantions without NULL values

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CONVERT(int, vac.new_vaccinations)) over(PARTITION by dea.location order by dea.location, dea.date) as Concurrent_Count
FROM COVIDReports..CovidDeaths dea
JOIN COVIDReports..CovidVaccinations vac
ON dea.date=vac.date
and dea.location=vac.location
WHERE dea.continent is not null AND dea.location= 'India' and vac.new_vaccinations is not null
Order by 2,3

--Concurrent count Vs Population

--With CTE

With PopVsVac (continent,location, date, population, new_vaccinations, Concurrent_count) as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CONVERT(int, vac.new_vaccinations)) over(PARTITION by dea.location order by dea.location, dea.date) as Concurrent_Count
FROM COVIDReports..CovidDeaths dea
JOIN COVIDReports..CovidVaccinations vac
ON dea.date=vac.date
and dea.location=vac.location
WHERE dea.continent is not null AND dea.location= 'India'
)
SELECT *, (Concurrent_count/population*100) as Affected_percentage From PopVsVac

--Concurrent count Vs Population

--With TempTable

Drop table if exists #PercentagePopulationVaccinated

Create table #PercentagePopulationVaccinated(
Continent nvarchar(50),
Location nvarchar(50),
Date datetime,
Population int,
New_Vaccinations int,
Concurrent_Count numeric,
)

INSERT INTO #PercentagePopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CONVERT(int, vac.new_vaccinations)) over(PARTITION by dea.location order by dea.location, dea.date) as Concurrent_Count
FROM COVIDReports..CovidDeaths dea
JOIN COVIDReports..CovidVaccinations vac
ON dea.date=vac.date
and dea.location=vac.location
WHERE dea.continent is not null AND dea.location= 'India' and vac.new_vaccinations is not null
--Order by 2,3

SELECT *, (Concurrent_count/population*100) as Affected_percentage From #PercentagePopulationVaccinated

--Creating View to store data for later visualization

Create view PercentagePopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
Sum(CONVERT(int, vac.new_vaccinations)) over(PARTITION by dea.location order by dea.location, dea.date) as Concurrent_Count
FROM COVIDReports..CovidDeaths dea
JOIN COVIDReports..CovidVaccinations vac
ON dea.date=vac.date
and dea.location=vac.location
WHERE dea.continent is not null AND dea.location= 'India' 
--Order by 2,3

SELECT * FROM PercentagePopulationVaccinated