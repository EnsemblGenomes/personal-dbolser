#!/bin/bash

SQL='
  SELECT
    full_db_name#, db.*
  FROM
    db_list
  INNER JOIN
    db
  USING
    (db_id)
  INNER JOIN
    division_species
  USING
    (species_id)
  INNER JOIN
    division
  USING
    (division_id)
  WHERE
#    division.name = "EnsemblBacteria"
#    division.name = "EnsemblFungi"
#    division.name = "EnsemblMetazoa"
    division.name = "EnsemblPlants"
#    division.name = "EnsemblProtists"
#  AND
#    db.db_type = "core"
  AND
    db.is_current = 1
  ORDER BY
    full_db_name
'

mysql-pan-prod ensembl_production -Ne "$SQL"
