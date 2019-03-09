SET search_path TO parlgov;

DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3
(
  countryName                 VARCHAR(100),
  partyName                   VARCHAR(100),
  partyFamily                 VARCHAR(100),
  wonElections                INT,
  mostRecentlyWonElectionId   INT,
  mostRecentlyWonElectionYear INT
);

-- Elections and their winning parties

CREATE VIEW most_recently_won AS
SELECT country_id,
       election_id,
       party_id,
       Max(votes)                         AS votes_max,
       extract(YEAR FROM election.e_date) AS year
FROM election_result
       JOIN election ON election.id = election_result.election_id
GROUP BY country_id, election_id;


-- Parties and how many elections they won in a country.

CREATE VIEW parties_won_elections AS
SELECT country_id, party_id, Count(votes_max) AS num_won
FROM most_recently_won
GROUP BY country_id, party_id;


-- Average number of winning elections per country

CREATE VIEW aver_win_elections AS
SELECT country_id, Avg(num_won) AS avg_num_won
FROM parties_won_elections
GROUP BY country_id;


-- Parties that won more than 3 times the average number of winning elections of parties of the same country.

CREATE VIEW won_more_than_3t AS
SELECT country_id, party_id, num_won
FROM parties_won_elections
       NATURAL JOIN aver_win_elections
WHERE num_won > 3 * avg_num_won
GROUP BY country_id, party_id;


-- Most recently won.

CREATE VIEW most_rec_w AS
SELECT country_id, election_id, party_id, votes_max, Max(year) AS year
FROM most_recently_won
GROUP BY party_id;


-- Inserting the data into the table.

INSERT INTO q3
SELECT country.name             AS countryName,
       party.name               AS partyName,
       party_family             AS partyFamily,
       won_more_than_3t.num_won AS wonElections,
       most_rec_w.election_id   AS mostRecentlyWonElectionId,
       most_rec_w.year          AS mostRecentlyWonElectionYear
FROM country,
     won_more_than_3t,
     party,
     party_family,
     most_rec_w
WHERE country.id = won_more_than_3t.country_id
  AND party.id = won_more_than_3t.party_id
  AND party_family.party_id = party.id
  AND most_rec_w.party_id = party_family.party_id;
