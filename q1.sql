SET search_path TO parlgov;

DROP TABLE IF EXISTS q1 CASCADE;
CREATE TABLE q1
(
  countryId      INT,
  alliedPartyId1 INT,
  alliedPartyId2 INT
);

-- The pairs of parties that have been allies with each other in any of the elections
-- (pairs repetition allowed).

CREATE VIEW allies_pairs AS
SELECT elec_res_1.party_id AS party_id_1,
       elec_res_2.party_id AS party_id_2,
       election.country_id,
       Count(*)            AS elections_together
FROM election_result elec_res_1,
     election_result elec_res_2,
     election
WHERE elec_res_1.election_id = elec_res_2.election_id
  AND elec_res_1.election_id = election.id
  AND (elec_res_1.alliance_id = elec_res_2.id OR elec_res_1.alliance_id = elec_res_2.alliance_id OR
       elec_res_1.id = elec_res_2.alliance_id)
  AND elec_res_1.party_id < elec_res_2.party_id
GROUP BY (elec_res_1.party_id, elec_res_2.party_id, election.country_id);


-- The number of all elections held in one country.

CREATE VIEW all_elections_count AS
SELECT country_id, Count(*) AS num_elections
FROM election
GROUP BY country_id;


-- Inserting the data into the table.

INSERT INTO q1
SELECT allies_pairs.country_id AS countryId,
       allies_pairs.party_id_1 AS alliedPartyId1,
       allies_pairs.party_id_2 AS alliedPartyId2
FROM allies_pairs,
     all_elections_count
WHERE allies_pairs.country_id = all_elections_count.country_id
  AND allies_pairs.elections_together >= all_elections_count.num_elections
GROUP BY allies_pairs.country_id, allies_pairs.party_id_1, allies_pairs.party_id_2;
