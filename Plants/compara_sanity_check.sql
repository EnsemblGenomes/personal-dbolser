
SELECT
  COUNT(*),
  COUNT(DISTINCT species_set_id)
FROM
  method_link_species_set mlss
INNER JOIN
  species_set_header ssh USING (species_set_id)
WHERE
  COALESCE(mlss.first_release, 0) =
  COALESCE( ssh.first_release, 0)
AND
  COALESCE(mlss.last_release, 0) =
  COALESCE( ssh.last_release, 0)
;

SELECT
  COUNT(*),
  COUNT(DISTINCT species_set_id)
FROM
  method_link_species_set mlss
INNER JOIN
  species_set_header ssh USING (species_set_id)
;

-- And so...

SELECT
  method_link_species_set_id,
  species_set_id,
  mlss.first_release, ssh.first_release,
  mlss.last_release,  ssh.last_release
FROM
  method_link_species_set mlss
INNER JOIN
  species_set_header ssh USING (species_set_id)
WHERE
  COALESCE(mlss.first_release, 0) !=
  COALESCE( ssh.first_release, 0)
OR
  COALESCE(mlss.last_release, 0) !=
  COALESCE( ssh.last_release, 0)
LIMIT
  10
;


-- Fix 1
UPDATE
  method_link_species_set mlss
INNER JOIN
  species_set_header ssh USING (species_set_id)
SET
  ssh.first_release = mlss.first_release
WHERE
  mlss.first_release IS NOT NULL
AND
   ssh.first_release IS NULL
;




SELECT * FROM method_link_species_set WHERE first_release IS NULL;


-- Identify duplicate species sets
SELECT x, GROUP_CONCAT(species_set_id), COUNT(*)
FROM (
  SELECT species_set_id, GROUP_CONCAT(genome_db_id ORDER BY genome_db_id) AS x
  FROM species_set
  GROUP BY species_set_id
) AS xxx GROUP BY x HAVING COUNT(*) > 1
LIMIT 03;



