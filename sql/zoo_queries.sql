CREATE DATABASE IF NOT EXISTS GULBIE_ZOO_DB;
USE DATABASE GULBIE_ZOO_DB;

CREATE OR REPLACE TABLE ZOO_DATA (
  raw_data VARIANT
);

SELECT * FROM ZOO_DATA;

--Профил на зоопарка--
SELECT
  raw_data:zooName::STRING AS zoo_name,
  raw_data:location::STRING AS location
FROM ZOO_DATA;

--Достъп до данни – директор на зоопарка--
SELECT
  raw_data:director.name::STRING AS director_name,
  raw_data:director.species::STRING AS director_species
FROM ZOO_DATA;

--Всички същества--
SELECT
  creature.value:name::STRING AS name,
  creature.value:species::STRING AS species
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:creatures) AS creature;

--Същества от планетата 'Xylar'--
SELECT
  creature.value:name::STRING AS name
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:creatures) AS creature
WHERE creature.value:originPlanet::STRING = 'Xylar';

--Хабитати по-големи от 2000 кв.м.--
SELECT
  habitat.value:name::STRING AS habitat_name,
  habitat.value:environmentType::STRING AS environment_type
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:habitats) AS habitat
WHERE habitat.value:sizeSqMeters::NUMBER > 2000;

--Същества със способност ‘Camouflage’--
SELECT
  creature.value:name::STRING AS name
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:creatures) AS creature,
LATERAL FLATTEN(input => creature.value:specialAbilities) AS ability
WHERE ability.value::STRING = 'Camouflage';

--Същества със здравен статус ≠ 'Excellent'--
SELECT
  creature.value:name::STRING AS name,
  creature.value:healthStatus.status::STRING AS status
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:creatures) AS creature
WHERE creature.value:healthStatus.status::STRING != 'Excellent';

--Персонал, назначен към 'H001'--
SELECT
  staff.value:name::STRING AS name,
  staff.value:role::STRING AS role
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:staff) AS staff,
LATERAL FLATTEN(input => staff.value:assignedHabitatIds) AS habitat
WHERE habitat.value::STRING = 'H001';

--Брой същества по habitatId--
SELECT
  creature.value:habitatId::STRING AS habitat_id,
  COUNT(*) AS creature_count
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:creatures) AS creature
GROUP BY habitat_id;

--Уникални характеристики на хабитатите--
SELECT DISTINCT
  feature.value::STRING AS feature
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:habitats) AS habitat,
LATERAL FLATTEN(input => habitat.value:features) AS feature;

--Предстоящи събития--
SELECT
  event.value:name::STRING AS name,
  event.value:type::STRING AS type,
  event.value:scheduledTime::TIMESTAMP AS scheduled_time
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:upcomingEvents) AS event;

--Същества + тип среда на хабитата им--
SELECT
  creature.value:name::STRING AS creature_name,
  habitat.value:environmentType::STRING AS environment_type
FROM ZOO_DATA,
LATERAL FLATTEN(input => raw_data:creatures) AS creature,
LATERAL FLATTEN(input => raw_data:habitats) AS habitat
WHERE creature.value:habitatId = habitat.value:id;

Add SQL queries
