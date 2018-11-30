
-- Run correct phase now!

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

-- Get a list of dupes
DROP   TABLE IF EXISTS temp_duplicate_exons;
CREATE TEMPORARY TABLE temp_duplicate_exons (
  PRIMARY KEY (exon_id),
  UNIQUE INDEX (
    seq_region_id,
    seq_region_start,
    seq_region_end,
    seq_region_strand,
    phase,
    end_phase,
    gene_id
  )
) AS
--
SELECT
  -- The exon we'll keep...
  MIN(exon_id) AS exon_id,
  -- The part we want to make unique
  e.seq_region_id,
  e.seq_region_start, e.seq_region_end, e.seq_region_strand,
  e.phase, e.end_phase,
  t.gene_id,
  -- Just FYI...
  COUNT(*) AS N
  --
FROM
  exon e
INNER JOIN
  exon_transcript
USING
  (exon_id)
INNER JOIN
  transcript t
USING
  (transcript_id)
GROUP BY
  -- The part we want to make unique (these are the columns used by
  -- the DuplicateExons HC).
  e.seq_region_id,
  e.seq_region_start, e.seq_region_end, e.seq_region_strand,
  e.phase, e.end_phase,
  t.gene_id
HAVING
  COUNT(*) > 1
;

--
SELECT COUNT(*) FROM temp_duplicate_exons;
SELECT SUM(N)   FROM temp_duplicate_exons;

-- Make a mapping
DROP   TABLE IF EXISTS temp_exon_map;
CREATE TEMPORARY TABLE temp_exon_map (
  PRIMARY KEY (old_exon_id, new_exon_id)
) AS
SELECT DISTINCT
  #COUNT(*)
  e.exon_id AS old_exon_id,
  x.exon_id AS new_exon_id
FROM
  exon_bk e
INNER JOIN
  exon_transcript_bk
USING
  (exon_id)
INNER JOIN
  transcript t
USING
  (transcript_id)
INNER JOIN
  temp_duplicate_exons x
ON
  x.seq_region_id     =
  e.seq_region_id     AND
  x.seq_region_start  =
  e.seq_region_start  AND
  x.seq_region_end    =
  e.seq_region_end    AND
  x.seq_region_strand =
  e.seq_region_strand AND
  x.phase             =
  e.phase             AND
  x.end_phase         =
  e.end_phase         AND
  t.gene_id           =
  x.gene_id
;

--
SELECT COUNT(*) FROM temp_exon_map;

-- Now re-link the dupes in the exon_transcript table...
UPDATE
  temp_exon_map
INNER JOIN
  exon_transcript_bk
ON
  exon_id = old_exon_id
SET
  exon_id = new_exon_id
;

-- You didn't forget this table now did you?
UPDATE
  temp_exon_map
INNER JOIN
  translation_bk
ON
  start_exon_id = old_exon_id
SET
  start_exon_id = new_exon_id
;

UPDATE
  temp_exon_map
INNER JOIN
  translation_bk
ON
  end_exon_id = old_exon_id
SET
  end_exon_id = new_exon_id
;

-- NOW KILL THEM!!!!
DELETE
  exon_bk
FROM
  exon_bk
INNER JOIN
  temp_exon_map
ON
  exon_id = old_exon_id
WHERE
  old_exon_id !=
  new_exon_id
;

-- Final checks
SELECT COUNT(*)
FROM exon_bk;

SELECT COUNT(*), COUNT(DISTINCT exon_id), COUNT(DISTINCT transcript_id)
FROM exon_transcript_bk
-- Hack...
IGNORE INDEX (PRIMARY);

SELECT COUNT(*), COUNT(DISTINCT exon_id), COUNT(DISTINCT transcript_id)
FROM exon_bk INNER JOIN exon_transcript_bk USING (exon_id);

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

RENAME TABLE exon    TO exon_old_2;
RENAME TABLE exon_bk TO exon;

RENAME TABLE exon_transcript    TO exon_transcript_old_2;
RENAME TABLE exon_transcript_bk TO exon_transcript;

RENAME TABLE translation    TO translation_old_2;
RENAME TABLE translation_bk TO translation;

OPTIMIZE TABLE exon, exon_transcript, translation;
