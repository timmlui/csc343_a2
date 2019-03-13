SET SEARCH_PATH to parlgov;

--Step 1: Get country data
CREATE VIEW countryData AS
SELECT id AS "country_id", name AS "countryName"
FROM Country;


--Step 2: Calculate the participation rate per country per year
--If more than one election per country per year, average is reported
CREATE VIEW countryParticipationRate AS
SELECT countryName, EXTRACT (YEAR from e_date) AS "year", 
	   (AVG (CAST(votes_cast AS float) / CAST(electorate AS float))) AS participationRatio
FROM countryData NATURAL JOIN election
GROUP BY (country_id, year)
WHERE year >= 2001 AND year <= 2016;



