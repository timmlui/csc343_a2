SET search_path TO parlgov;

DROP TABLE IF EXISTS q2 CASCADE;
CREATE TABLE q2
(
  countryName VARCHAR(50),
  partyName   VARCHAR(100),
  partyFamily VARCHAR(50),
  stateMarket REAL
);


-- The number of all cabinets in each country from 1996 to 2016 inclusive.

CREATE VIEW all_cabinets_count AS
SELECT country_id, Count(*) AS num_cabinets
FROM cabinet
WHERE extract(YEAR FROM start_date) >= 1996
  AND extract(YEAR FROM start_date) <= 2016
GROUP BY country_id;


-- The number of times a party was in a cabinet in a country from 1996 to 2016 inclusive.

CREATE VIEW party_cabinets_count AS
SELECT cabinet.country_id,
       cabinet_party.party_id,
       Count(*) AS times_in_cabinet
FROM cabinet,
     cabinet_party
WHERE cabinet_party.cabinet_id = cabinet.id
  AND extract(YEAR FROM start_date) >= 1996
  AND extract(YEAR FROM start_date) <= 2016
GROUP BY cabinet.country_id, cabinet_party.party_id;


-- Inserting committed parties into the table.

INSERT INTO q2
SELECT country.name                AS countryName,
       party.name                  AS partyName,
       party_family.family         AS partyFamily,
       party_position.state_market AS stateMarket
FROM party_cabinets_count,
     all_cabinets_count,
     country,
     party,
     party_family,
     party_position
WHERE all_cabinets_count.country_id = party_cabinets_count.country_id
  AND all_cabinets_count.num_cabinets = party_cabinets_count.times_in_cabinet
  AND all_cabinets_count.country_id = country.id
  AND party_cabinets_count.party_id = party.id
  AND party_cabinets_count.party_id = party_family.party_id
  AND party_cabinets_count.party_id = party_position.party_id;
