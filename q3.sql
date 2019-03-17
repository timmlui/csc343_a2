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


--Find the number of vote that win that election for each election
CREATE VIEW winner_vote AS 
SELECT election_id as e_id, max(votes) AS votes
FROM election_result 
GROUP BY e_id;

 --Find the party that wins the election for each election
CREATE VIEW winner_party AS
SELECT p.country_id as c_id, er.election_id as e_id, p.id as p_id
FROM winner_vote wv INNER JOIN election_result er ON wv.e_id = er.election_id
    INNER JOIN party p ON p.id = er.party_id
WHERE wv.votes = er.votes;

--Find the number of win for each party
CREATE VIEW num_wins_party AS
SELECT c_id, p_id, count(e_id) as wins
FROM winner_party
GROUP BY c_id, p_id;

--Find the average number of winning elections of each country
CREATE VIEW avg_win AS
SELECT p.country_id as c_id, (sum(nwp.wins) / count(p.id)) as avg
FROM num_wins_party nwp RIGHT JOIN party p ON nwp.p_id = p.id
GROUP BY p.country_id;

--Find parties that have won 3x more than the avg number of winning elections 
CREATE VIEW answer_party AS
SELECT nwp.c_id, nwp.p_id, nwp.wins
FROM num_wins_party nwp INNER JOIN avg_win aw ON nwp.c_id = aw.c_id
WHERE nwp.wins > 3*aw.avg;

--Winning parties and their elections date
CREATE VIEW party_election_date AS
SELECT wp.p_id, max(e_date) as won_date
FROM winner_party wp INNER JOIN election e ON wp.e_id = e.id
GROUP BY wp.p_id;

--Find the most recently won election for each party
CREATE VIEW most_rec_won_election AS
SELECT ped.p_id, e.id as e_id, ped.won_date as won_date
FROM party_election_date ped INNER JOIN election e ON ped.won_date = e.e_date
    INNER JOIN winner_party wp ON ped.p_id = wp.p_id AND e.id = wp.e_id;


INSERT INTO q3
SELECT c.name as countryName, 
       p.name as partyName,
       pf.family as partyFamily,
       ap.wins as wonElections,
       mrwe.e_id as mostRecentlyWonElectionId,
       EXTRACT(YEAR FROM mrwe.won_date) as mostRecentlyWonElectionYear
FROM answer_party ap INNER JOIN most_rec_won_election mrwe ON ap.p_id = mrwe.p_id
    INNER JOIN num_wins_party nwp ON ap.p_id = nwp.p_id
    INNER JOIN country c ON ap.c_id = c.id
    INNER JOIN party p ON ap.p_id = p.id
    LEFT JOIN party_family pf ON p.id = pf.party_id;