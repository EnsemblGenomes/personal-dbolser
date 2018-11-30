Failures detected for hordeum_vulgare_core_36_89_3:


org.ensembl.healthcheck.testcase.generic.AnalysisDescription
PROBLEM: Analysis ibsc is used in gene but has no entry in analysis_description
PROBLEM: Analysis ibsc is used in transcript but has no entry in analysis_description




SELECT stable_id, COUNT(*) FROM exon GROUP BY stable_id HAVING COUNT(*) > 1 ORDER BY COUNT(*) DESC LIMIT 03;


DROP             TABLE IF EXISTS temp_exon_stable_id;
CREATE TEMPORARY TABLE           temp_exon_stable_id (
  PRIMARY KEY (exon_id)
) AS
SELECT
  exon_id,
  stable_id, 1 AS i,
  stable_id AS new_stable_id,
  stable_id AS ignore_me
FROM exon
LIMIT 0;

SET @name: = '';

INSERT INTO temp_exon_stable_id
SELECT
  exon_id, stable_id,
  IF(stable_id != @name, @i := 1, @i := @i+1) AS i,
  CONCAT(stable_id, "-", @i) AS new_stable_id,
  @name := stable_id
FROM exon INNER JOIN (
  SELECT stable_id, COUNT(*) AS N FROM exon
  GROUP BY stable_id HAVING N > 1
#  LIMIT 5
) AS x
USING
  (stable_id)
#LIMIT
#  100
;


SELECT COUNT(*), COUNT(DISTINCT stable_id) FROM exon;
SELECT COUNT(*), COUNT(DISTINCT new_stable_id) FROM temp_exon_stable_id;

SELECT COUNT(*), COUNT(DISTINCT new_stable_id)
FROM exon INNER JOIN temp_exon_stable_id USING (exon_id);

UPDATE exon INNER JOIN temp_exon_stable_id USING (exon_id)
SET exon.stable_id = new_stable_id;





