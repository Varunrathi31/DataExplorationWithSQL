--VIEWING ALL DATA PRESENT IN COVID DEATH INFORMATION

SELECT * FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY [location] ASC,
		 [date] ASC



--VIEWING ALL DATA PRESENT IN COVID VACCINATION INFORMATION
SELECT * FROM PortfolioProject..CovidVaccinations
ORDER BY [location] ASC,
	 [date] ASC



--CREATING VIEW FOR COVID DEATH INFORMATION
CREATE VIEW vwCovidDeaths
AS
SELECT [iso_code], [continent], [location], [date], [population],  new_cases, total_cases,  new_deaths,  total_deaths
FROM PortfolioProject..CovidDeaths



--SHOWING ALL DATA PRESENT IN VIEW
SELECT * FROM vwCovidDeaths



--SELECTING DATA THAT WE ARE GOING TO USE

SELECT [location], [date], total_cases, new_cases, total_deaths, [population]
FROM PortfolioProject..vwCovidDeaths
WHERE continent IS NOT NULL
ORDER BY [location] ASC,
		 [date] ASC



--LOOKING AT TOTAL CASES, TOTAL DEATHS, DEATHPERCENTAGE ON EACH DAY FOR EACH COUNTRY

SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..vwCovidDeaths
WHERE continent IS NOT NULL
ORDER BY [location] ASC,
		 [date] ASC



--LOOKING AT TOTAL CASES, TOTAL DEATHS, DEATHPERCENTAGE ON EACH DAY FOR MY COUNTRY "INDIA"

SELECT [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..vwCovidDeaths
WHERE [location] = 'india' AND continent IS NOT NULL
ORDER BY [date] ASC



--TOP 10 DAYS WHICH HAS HIGH RATE OF CHANCE OF COVIDDEATH IN INDIA (Date Till 24th September 2021)

SELECT TOP 10 [location], [date], total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..vwCovidDeaths
WHERE [location] = 'india' AND continent IS NOT NULL
ORDER BY DeathPercentage DESC



--LOOKING AT POPULATION, COVIDINFECTED PERCENTAGE IN INDIA

SELECT [location], [date], [population], total_cases, (total_cases/[population])*100 AS CovidInfectedPercent
FROM PortfolioProject..vwCovidDeaths
WHERE [location] = 'india' AND continent IS NOT NULL
ORDER BY [date] ASC



--LOOKING AT HIGHEST COVID INFECTION RATE COMPARED TO THEIR POPULATION

SELECT [location], [population], MAX(total_cases) AS HighestCovidInfected, MAX((total_cases/[population])*100) AS HighestCovidInfectedPercent
FROM PortfolioProject..vwCovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location], [population]
ORDER BY HighestCovidInfectedPercent DESC



--COUNTRIES WITH HIGHEST NUMBER OF DEATHS PER POPULATION

SELECT [location], [population], MAX(CAST(total_deaths AS int)) AS HighestDeaths
FROM PortfolioProject..vwCovidDeaths
WHERE continent IS NOT NULL
GROUP BY [location], [population]
ORDER BY HighestDeaths DESC



--SHOWING CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION
--(i.e. HIGHEST NUMBER OF DEATHS BY CONTINENT)

SELECT [continent], MAX(CAST(total_deaths AS INT)) AS HIGHESTDEATHSCOUNT 
FROM PortfolioProject..vwCovidDeaths
WHERE [continent] IS NOT NULL
GROUP BY [continent]
ORDER BY HIGHESTDEATHSCOUNT DESC



--SHOWING DRILL DOWN EFFECT
--SHOWING CONTINENT WITH THEIR RESPECTIVE COUNTRIES FOR HIGHEST DEATH COUNT

SELECT [continent], [location], MAX(CAST(total_deaths AS INT)) AS [Highest_Number_Of_Deaths]
FROM PortfolioProject..vwCovidDeaths
WHERE [continent] IS NOT NULL
GROUP BY [continent], [location]
ORDER BY [continent] ASC,
		 [location] ASC



--GLOBAL NUMBERS
--SHOWING NUMBER OF COVID CASES AND NUMBER OF COVID DEATHS IN EACH DAY AS WORLDWIDE

SELECT [date], SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..vwCovidDeaths
WHERE [continent] IS NOT NULL
GROUP BY [date]
ORDER BY [date] ASC



--SHOWING TOTAL CASES, TOTAL DEATHS AND DEATHPERCENATGE GLOBALLY TILL 24th Sept 2021

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS INT)) AS total_deaths,
SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..vwCovidDeaths
WHERE [continent] IS NOT NULL



--JOINING TWO TABLES AND SHOWING ALL DATA PRESENT IN BOTH TABLES
--Two Tables Are CovidDeaths and CovidVaccinations

SELECT * 
FROM PortfolioProject..CovidDeaths AS dea
INNER JOIN PortfolioProject..CovidVaccinations AS vac
		ON dea.[location] = vac.[location]
		AND dea.[date] = vac.[date]



--LOOKING AT EACH COUNTRY, ITS POPULATION, ITS VACCINATIONS AND THEIR ROLLING COUNT OF VACCININTIONS ON THAT DAY

SELECT dea.[continent], dea.[location], dea.[date], dea.[population], vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.[location] ORDER BY dea.[location] ASC, dea.[date] ASC) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
		ON dea.[location] = vac.[location]
		AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL AND vac.new_vaccinations IS NOT NULL
ORDER BY dea.[location] ASC,
		 dea.[date] ASC



--USE CTE
--LOOKING AT POPULATION AND ROLLING PEOPLE VACCINATIONS

WITH popvsvac(continent, [location], [date], [population], new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.[continent], dea.[location], dea.[date], dea.[population], vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.[location]
ORDER BY dea.[location] ASC, dea.[date] ASC) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
		ON dea.[location] = vac.[location]
		AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL AND vac.new_vaccinations IS NOT NULL
)
--VIEWING THE VACCINATED PEOPLE PERCENTAGE ON THAT DAY COUNTRYWISE
SELECT *, RollingPeopleVaccinated/[population]*100 AS VaccinatedPeoplePercent FROM popvsvac



--CREATING LOCAL TEMPORARY TABLE NAMED "#PercentPopulationVaccinated"

CREATE TABLE #PercentPopulationVaccinated
(
	Continent NVARCHAR (255),
	[Location] NVARCHAR (255),
	[Date] DATETIME,
	[Population] NUMERIC,
	New_vaccinations NUMERIC,
	RollingPeopleVaccinated NUMERIC
)



--INSERTION TO EMPTY LOCAL TEMPORARY TABLE NAMED "#PercentPopulationVaccinated"
--ADDING WHOLE RECORDS TO LOCAL TEMPORARY TABLE FROM RESULTSET OF JOINING TWO TABLES
--Two Tables Are CovidDeaths and CovidVaccinations

INSERT INTO #PercentPopulationVaccinated
SELECT dea.[continent], dea.[location], dea.[date], dea.[population], vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.[location]
ORDER BY dea.[location] ASC, dea.[date] ASC) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
		ON dea.[location] = vac.[location]
		AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL



--VIEWING ALL THE DATA PRESENT IN LOCAL TEMPORARY TABLE
SELECT *, RollingPeopleVaccinated/[population]*100 AS VaccinatedPeoplePercent FROM #PercentPopulationVaccinated



--TO SEE HOW MANY TEMP TABLES ARE CREATED IN ANY CONNECTION WINDOW
SELECT name FROM tempdb..sysobjects
WHERE name LIKE '#Percent%'



--DROP LOCAL TEMPORARY TABLE NAMED "#PercentPopulationVaccinated"
DROP TABLE #PercentPopulationVaccinated



--CREATING VIEW

CREATE VIEW vwPercentPopulationVaccinated
AS
SELECT dea.[continent], dea.[location], dea.[date], dea.[population], vac.new_vaccinations,
SUM(CONVERT(INT, vac.new_vaccinations)) OVER(PARTITION BY dea.[location]
ORDER BY dea.[location] ASC, dea.[date] ASC) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
INNER JOIN PortfolioProject..CovidVaccinations vac
		ON dea.[location] = vac.[location]
		AND dea.[date] = vac.[date]
WHERE dea.[continent] IS NOT NULL



--SHOWING DATA STORED IN THE VIEW NAMED "PercentPopulationVaccinated"
SELECT * FROM vwPercentPopulationVaccinated



--DELETING VIEW NAMED "PercentPopulationVaccinated"
DROP VIEW PercentPopulationVaccinated
	 
