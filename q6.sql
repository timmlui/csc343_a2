SET search_path TO parlgov;

DROP TABLE IF EXISTS q6 CASCADE;
CREATE TABLE q6
(
  countryName VARCHAR(50),
  r0_2        INT,
  r2_4        INT,
  r4_6        INT,
  r6_8        INT,
  r8_10       INT
);


-- The number of parties in each country within each of the intervals.

CREATE VIEW interval_count AS
SELECT party.country_id,
       floor(party_position.left_right / 2) * 2 AS floor_position,
       Count(*)                                 AS num_parties
FROM party,
     party_position
WHERE party.id = party_position.party_id
GROUP BY party.country_id, floor_position;


-- Inserting the data into the table.

INSERT INTO q6
SELECT inte_0.country_id  AS countryName,
       inte_0.num_parties AS r0_2,
       inte_1.num_parties AS r2_4,
       inte_2.num_parties AS r4_6,
       inte_3.num_parties AS r6_8,
       inte_4.num_parties AS r8_10
FROM interval_count AS inte_0,
     interval_count AS inte_1,
     interval_count AS inte_2,
     interval_count AS inte_3,
     interval_count AS inte_4
WHERE inte_0.country_id = inte_1.country_id
  AND inte_0.country_id = inte_2.country_id
  AND inte_0.country_id = inte_3.country_id
  AND inte_0.country_id = inte_4.country_id
  AND inte_0.floor_position = 0
  AND inte_1.floor_position = 2
  AND inte_2.floor_position = 4
  AND inte_3.floor_position = 6
  AND inte_4.floor_position = 8 OR inte_4.floor_position = 10;
