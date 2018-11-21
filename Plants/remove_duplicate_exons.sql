
-- Lets use temp tables for safety...

-- exon
DROP TABLE IF EXISTS exon_bk;
CREATE TABLE exon_bk LIKE exon;
INSERT INTO exon_bk SELECT * FROM exon;
OPTIMIZE TABLE exon_bk;

-- exon_transcript
DROP TABLE IF EXISTS exon_transcript_bk;
CREATE TABLE exon_transcript_bk LIKE exon_transcript;
INSERT INTO exon_transcript_bk SELECT * FROM exon_transcript;
OPTIMIZE TABLE exon_transcript_bk;

-- translation
DROP TABLE IF EXISTS translation_bk;
CREATE TABLE translation_bk LIKE translation;
INSERT INTO translation_bk SELECT * FROM translation;
OPTIMIZE TABLE translation_bk;

-- Below, we also need an exon_id 'tracking column':
ALTER TABLE exon_bk
  ADD COLUMN exon_id2 INT UNSIGNED NULL DEFAULT NULL,
  ADD INDEX e2 (exon_id2);





--
-- Repeat from here as required...
--

-- I honestly can't work out why this is necessary each itteration...
UPDATE exon_bk SET exon_id2 = exon_id;

-- Get a list of dupes
DROP   TABLE IF EXISTS temp_duplicate_exons;
CREATE TEMPORARY TABLE temp_duplicate_exons (
  PRIMARY KEY (exon_id)
) AS
--
SELECT
  exon_id,
  -- Pick the transcript we'll link the new exon to below here for
  -- convenience...
  MAX(transcript_id) AS transcript_id
FROM
  exon_transcript_bk
GROUP BY
  exon_id
HAVING
  COUNT(*) > 1
;

-- Sanity test, both counts should be equal
SELECT COUNT(*) FROM temp_duplicate_exons;

SELECT COUNT(*) FROM temp_duplicate_exons
INNER JOIN exon_bk USING (exon_id)
INNER JOIN exon_transcript_bk
USING (exon_id, transcript_id);



-- Clone the dupes (all fields except exon_id, because we're
-- intentinoally handing out new IDs)
INSERT INTO exon_bk (
  seq_region_id, seq_region_start, seq_region_end, seq_region_strand,
  phase, end_phase, is_current, is_constitutive, stable_id, version,
  created_date, modified_date, exon_id2
)
SELECT
  seq_region_id, seq_region_start, seq_region_end, seq_region_strand,
  phase, end_phase, is_current, is_constitutive, stable_id, version,
  created_date, modified_date, exon_id2
FROM
  exon_bk
INNER JOIN
  temp_duplicate_exons
USING
  (exon_id)
;

-- Now re-link the dupes in the exon_transcript table...
UPDATE
  temp_duplicate_exons x
INNER JOIN
  exon_bk a USING (exon_id)
INNER JOIN
  exon_bk b
ON -- Link via the old ID, returning the new row...
  a.exon_id2 = b.exon_id2 AND a.exon_id != b.exon_id
INNER JOIN
  exon_transcript_bk et
ON
  a.exon_id = et.exon_id
AND
  x.transcript_id = et.transcript_id
SET
  et.exon_id = b.exon_id
;

-- You didn't forget this table now did you?
UPDATE
  translation_bk t
INNER JOIN
  exon_bk
ON -- Link to the old ID, for the updated row...
  start_exon_id = exon_id2 AND exon_id2 != exon_id
INNER JOIN
  exon_transcript_bk et
USING
  (exon_id, transcript_id)
SET
  start_exon_id = exon_id
;

UPDATE
  translation_bk t
INNER JOIN
  exon_bk
ON -- Link to the old ID, for the updated row...
  end_exon_id = exon_id2 AND exon_id2 != exon_id
INNER JOIN
  exon_transcript_bk et
USING
  (exon_id, transcript_id)
SET
  end_exon_id = exon_id
;

-- Now repeat from above as required, as some exons are shared between
-- more than just two transcripts...





--
-- And now rename the stable ids...
--

-- I really hope nobody actually cares about exon stable IDs...

DROP TABLE IF EXISTS temp_die;
CREATE TEMPORARY TABLE temp_die (
  PRIMARY KEY (exon_id)
) AS
#
SELECT
  exon_id,
  e.stable_id AS e_id,
  t.stable_id AS t_id,
  rank,
  CONCAT(
    t.stable_id, '.exon', rank) AS Oh
FROM
  exon_bk            e
INNER JOIN
  exon_transcript_bk f USING (exon_id)
INNER JOIN
  transcript         t USING (transcript_id)
GROUP BY
  exon_id
;

SELECT * FROM temp_die ORDER BY RAND() LIMIT 03;

SELECT COUNT(*) FROM temp_die WHERE e_id != Oh;

-- DO IT!
UPDATE
  exon_bk
INNER JOIN
  temp_die USING (exon_id)
SET
  stable_id = Oh
;



-- Sanity test, no results here please...
SELECT stable_id, COUNT(*)
FROM exon_bk GROUP BY stable_id
HAVING COUNT(*) > 2
LIMIT 03;

-- Please kill me
SELECT COUNT(*) FROM(
  SELECT stable_id, COUNT(*)
  FROM exon_bk GROUP BY stable_id
  HAVING COUNT(*) > 1
) AS x;



-- Final checks for the translation table...
SELECT COUNT(*) FROM translation;

SELECT
  COUNT(*), COUNT(DISTINCT translation_id)
FROM
  translation
INNER JOIN
  exon ON end_exon_id = exon_id
INNER JOIN
  exon_transcript
USING
  (exon_id, transcript_id)
;

SELECT
  COUNT(*), COUNT(DISTINCT translation_id)
FROM
  translation_bk
INNER JOIN
  exon_bk ON start_exon_id = exon_id
INNER JOIN
  exon_transcript_bk
USING
  (exon_id, transcript_id)
;



-- TIDY UP
ALTER TABLE exon_bk DROP COLUMN exon_id2;

RENAME TABLE exon TO exon_old;
RENAME TABLE exon_transcript TO exon_transcript_old;
RENAME TABLE translation TO translation_old;

RENAME TABLE exon_bk TO exon;
RENAME TABLE exon_transcript_bk TO exon_transcript;
RENAME TABLE translation_bk TO translation;






* medicago_truncatula_core_22_75_1
* oryza_brachyantha_core_22_75_14
* oryza_glaberrima_core_22_75_2
* populus_trichocarpa_core_22_75_20
* prunus_persica_core_22_75_1
* selaginella_moellendorffii_core_22_75_1
* setaria_italica_core_22_75_21
* solanum_lycopersicum_core_22_75_240
* triticum_urartu_core_22_75_1
* vitis_vinifera_core_22_75_3

* amborella_trichopoda_core_22_75_1
* arabidopsis_thaliana_core_22_75_10
* arabidopsis_lyrata_core_22_75_10
* brachypodium_distachyon_core_22_75_12
* brassica_rapa_core_22_75_1
* chlamydomonas_reinhardtii_core_22_75_1
* cyanidioschyzon_merolae_core_22_75_1
* glycine_max_core_22_75_1
* oryza_barthii_core_22_75_1
* oryza_glumaepatula_core_22_75_15
* oryza_meridionalis_core_22_75_1
* oryza_nivara_core_22_75_10
* oryza_punctata_core_22_75_12
* oryza_sativa_core_22_75_7
* physcomitrella_patens_core_22_75_11
* sorghum_bicolor_core_22_75_14
* zea_mays_core_22_75_6
