
-- ONE OFF, patch

-- DROP   TABLE              IF EXISTS exon_duff;
-- RENAME TABLE exon                TO exon_duff;
-- RENAME TABLE exon_old            TO exon;

-- DROP   TABLE              IF EXISTS exon_transcript_duff;
-- RENAME TABLE exon_transcript     TO exon_transcript_duff;
-- RENAME TABLE exon_transcript_old TO exon_transcript;

-- DROP   TABLE              IF EXISTS translation_duff;
-- RENAME TABLE translation         TO translation_duff;
-- RENAME TABLE translation_old     TO translation;



-- ONE OFF SET UP...

-- CREATE TEMPORARY TABLE temp_problem_genes(
--   PRIMARY KEY (gene_id)
-- )
-- SELECT
--   DISTINCT gene_id
-- FROM
--   transcript
-- INNER JOIN
--   translation USING (transcript_id)
-- INNER JOIN
--   exon ON end_exon_id = exon_id
-- WHERE
--   start_exon_id != end_exon_id
-- AND
--   phase = -1
-- ;

-- OPTIMIZE TABLE temp_problem_genes;

-- DROP   TABLE IF EXISTS temp_problem_exons;
-- CREATE TABLE           temp_problem_exons(
--   PRIMARY KEY (exon_id)
-- )
-- SELECT
--   DISTINCT exon_id
-- FROM
--   exon_transcript
-- INNER JOIN
--   transcript USING (transcript_id)
-- INNER JOIN
--   temp_problem_genes USING (gene_id)
-- ;

-- OPTIMIZE TABLE temp_problem_exons;



-- Lets use temp tables for safety...

-- exon
DROP TABLE IF EXISTS exon_bk;
CREATE TABLE exon_bk LIKE exon;
INSERT INTO exon_bk SELECT * FROM exon;
OPTIMIZE TABLE exon, exon_bk;

-- exon_transcript
DROP TABLE IF EXISTS exon_transcript_bk;
CREATE TABLE exon_transcript_bk LIKE exon_transcript;
INSERT INTO exon_transcript_bk SELECT * FROM exon_transcript;
OPTIMIZE TABLE exon_transcript, exon_transcript_bk;

-- translation
DROP TABLE IF EXISTS translation_bk;
CREATE TABLE translation_bk LIKE translation;
INSERT INTO translation_bk SELECT * FROM translation;
OPTIMIZE TABLE translation, translation_bk;

-- Below, we also need an exon_id 'tracking column':
ALTER TABLE exon_bk
  ADD COLUMN exon_id2 INT UNSIGNED NULL DEFAULT NULL,
  ADD INDEX e2 (exon_id2);
