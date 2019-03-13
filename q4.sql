SET SEARCH_PATH to parlgov;

--Step 1: Get parties for each country
CREATE VIEW CountryParties AS
SELECT country_id, name_short, id AS party_id
FROM party;



--Step 2: Get election data from each country
CREATE VIEW CountryElectionData AS
SELECT country_id, EXTRACT(YEAR from e_date) AS election_year, votes_valid, id AS election_id
FROM election
WHERE EXTRACT(YEAR from e_date) >= 1996 AND EXTRACT(YEAR from e_date) <= 2016;



--Step 3: Join the previous views into one view
CREATE VIEW ElectionData AS
SELECT *
FROM CountryParties NATURAL JOIN CountryElectionData;



--Step 4: Get election results for each party
CREATE VIEW ElectionResults AS
SELECT election_id, party_id, votes
FROM election_result
WHERE votes > 0;


--Step 5: Natural join the previous views into one view
CREATE VIEW PartyElectionData AS
SELECT *
FROM ElectionResults NATURAL JOIN ElectionData;



--Step 6: Calculate the percentage of valid votes each party received
CREATE VIEW PartyVotePercentage AS
SELECT country_id, party_id, election_id, name_short, election_year, 
		(CAST (votes AS float) / CAST (votes_valid AS float) * 100) AS vote_percentage
FROM PartyElectionData
WHERE votes_valid >0; --Extra check to ensure no division by zero



--Step 7: Find the average votes percentage if there was more than one election in one year
CREATE VIEW VotePercentageAverage AS
SELECT election_year, country_id, AVG(vote_percentage) AS vote_percentage, name_short AS partyName
FROM PartyVotePercentage
GROUP BY (country_id, party_id, election_year, partyName);



--Step 8: Get country name and country ID
CREATE VIEW CountryNameID AS
SELECT id AS country_id, name AS countryName
FROM Country;



--Step 9: Replace country ID with country name in VotePercentageAverage
CREATE VIEW VotePercentageAverageCountry AS
SELECT election_year AS year, countryName, vote_percentage, partyName
FROM VotePercentageAverage NATURAL JOIN CountryNameID;

--Step 10: Place the vote percentage into one of the vote ranges

	
DROP TABLE IF EXISTS q4 CASCADE;
CREATE TABLE q4
(
  year        INT,
  countryName VARCHAR(50),
  voteRange   VARCHAR(50),
  partyName   VARCHAR(50)
);


INSERT INTO q4
SELECT vpac.year,
       vpac.countryName,
       CASE when 0 < vpac.vote_percentage and vpac.vote_percentage <= 5 THEN '(0-5]'
            when 5 < vpac.vote_percentage and vpac.vote_percentage <= 10 THEN '(5-10]'
            when 10 < vpac.vote_percentage and vpac.vote_percentage <= 20 THEN '(10-20]'
            when 20 < vpac.vote_percentage and vpac.vote_percentage <= 30 THEN '(20-30]'
            when 30 < vpac.vote_percentage and vpac.vote_percentage <= 40 THEN '(30-40]'
            when 40 < vpac.vote_percentage and vpac.vote_percentage <= 100 THEN '(40-100]'
       END AS voteRange,
       vpac.partyName
FROM VotePercentageAverageCountry as vpac;
 

