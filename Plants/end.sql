
--
-- And now rename the stable ids...
--

-- -- I really hope nobody actually cares about exon stable IDs...
-- DROP TABLE IF EXISTS temp_die;
-- CREATE TEMPORARY TABLE temp_die (
--   PRIMARY KEY (exon_id)
-- ) AS
-- #
-- SELECT
--   exon_id,
--   e.stable_id AS e_id,
--   t.stable_id AS t_id,
--   rank,
--   CONCAT(
--     t.stable_id, '.exon', rank) AS Oh
-- FROM
--   exon_bk            e
-- INNER JOIN
--   exon_transcript_bk f USING (exon_id)
-- INNER JOIN
--   transcript         t USING (transcript_id)
-- GROUP BY
--   exon_id
-- ;

-- SELECT * FROM temp_die ORDER BY RAND() LIMIT 03;

-- SELECT COUNT(*) FROM temp_die WHERE e_id != Oh;

-- -- DO IT!
-- UPDATE
--   exon_bk
-- INNER JOIN
--   temp_die USING (exon_id)
-- SET
--   stable_id = Oh
-- ;

-- -- Sanity test, no results here please...
-- SELECT stable_id, COUNT(*)
-- FROM exon_bk GROUP BY stable_id
-- HAVING COUNT(*) > 2
-- LIMIT 03;

-- -- Please kill me
-- SELECT COUNT(*) FROM(
--   SELECT stable_id, COUNT(*)
--   FROM exon_bk GROUP BY stable_id
--   HAVING COUNT(*) > 1
-- ) AS x;



-- Final checks for the translation table...
SELECT COUNT(*), COUNT(DISTINCT translation_id) FROM translation;

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
ALTER  TABLE exon_bk DROP COLUMN exon_id2;

RENAME TABLE exon               TO exon_old;
RENAME TABLE exon_bk            TO exon;

RENAME TABLE exon_transcript    TO exon_transcript_old;
RENAME TABLE exon_transcript_bk TO exon_transcript;

RENAME TABLE translation        TO translation_old;
RENAME TABLE translation_bk     TO translation;
 

OPTIMIZE TABLES
  exon,
  exon_transcript,
  translation;

