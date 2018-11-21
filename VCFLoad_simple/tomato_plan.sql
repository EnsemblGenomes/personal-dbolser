
-- Cleanup for dump tomato alleles


-- New plan

-- 1) Collect the list of variations from
--    individual_genotype_multiple_bp where allele length > 1000.

-- 2) Delete them from variation and variation feature, and we're
--    done.







-- 1) DELETE FROM allele_code WHERE the allele is > 1000bp;

SELECT COUNT(*)
FROM allele_code
WHERE LENGTH(allele) > 1000;

DELETE
FROM allele_code
WHERE LENGTH(allele) > 1000;


-- 2) DELETE FROM individual_genotype_multiple_bp WHERE the allele
--    (either 1 or 2) is > 1000bp

SELECT
  COUNT(*) AS A,
  COUNT(DISTINCT variation_id, individual_id) AS B,
  COUNT(DISTINCT variation_id) AS C
FROM individual_genotype_multiple_bp
WHERE LENGTH(allele_1) > 1000;

SELECT
  COUNT(*) AS A,
  COUNT(DISTINCT variation_id, individual_id) AS B,
  COUNT(DISTINCT variation_id) AS C
FROM individual_genotype_multiple_bp
WHERE LENGTH(allele_2) > 1000;

-- SHOULD HAVE STORED DISTINCT variation_ids HERE TO USE BELOW WHEN
-- DELETING FROM variation AND variation_feature!!!

DELETE
FROM individual_genotype_multiple_bp
WHERE LENGTH(allele_1) > 1000;

DELETE
FROM individual_genotype_multiple_bp
WHERE LENGTH(allele_2) > 1000;



-- 3) DELETE FROM genotype_code WHERE there is no corresponding
--    allele_code;

SELECT COUNT(*) FROM genotype_code;

SELECT COUNT(*) FROM genotype_code
LEFT JOIN allele_code USING (allele_code_id)
WHERE allele_code.allele_code_id IS NULL;

CREATE TEMPORARY TABLE temp_gc (PRIMARY KEY (genotype_code_id)) AS
  SELECT DISTINCT genotype_code_id FROM genotype_code
  LEFT JOIN allele_code USING (allele_code_id)
  WHERE allele_code.allele_code_id IS NULL;

DELETE genotype_code FROM genotype_code 
  INNER JOIN temp_gc USING (genotype_code_id);



-- 4) DELETE FROM allele WHERE there is no corresponding allele_code;

OPTIMIZE TABLE allele_code;
OPTIMIZE TABLE allele;

SELECT COUNT(*) FROM allele;
SELECT COUNT(*) FROM allele INNER JOIN allele_code USING (allele_code_id);

SELECT COUNT(*) FROM allele LEFT  JOIN allele_code USING (allele_code_id)
WHERE allele_code.allele_code_id IS NULL;

CREATE TEMPORARY TABLE temp_a (
  PRIMARY KEY (allele_id),
  INDEX (variation_id)
) AS
SELECT allele_id, variation_id
FROM allele LEFT JOIN allele_code USING (allele_code_id)
WHERE allele_code.allele_code_id IS NULL;

DELETE allele FROM allele INNER JOIN temp_a USING (allele_id);

-- Slower version of the above (when temp_a isn't available)
DELETE allele FROM allele LEFT JOIN allele_code USING (allele_id)
WHERE allele_code.allele_code_id IS NULL;



-- 5) DELETE FROM variation AND variation_feature WHERE there is no
--    variation in allele;

DELETE variation
FROM variation
INNER JOIN temp_xxx USING (variation_id);

DELETE variation_feature
FROM variation_feature
INNER JOIN temp_xxx USING (variation_id);

-- Slower version of the above (when temp_xxx isn't available)
DELETE variation
FROM variation
LEFT JOIN allele USING (variation_id)
WHERE allele.variation_id IS NULL;

DELETE variation_feature
FROM variation_feature
LEFT JOIN allele USING (variation_id)
WHERE allele.variation_id IS NULL;







--FK HC?




-- Random queries

SELECT
  vf.seq_region_id,
  vf.seq_region_start,
  vf.seq_region_end,
  vf.seq_region_strand,
  gt.allele_1,
  gt.allele_2,
  gt.individual_id,
  vf.variation_id
FROM
  variation_feature_29595 vf,
  individual_genotype_multiple_bp as gt
WHERE
  gt.variation_id = vf.variation_id
AND
  gt.individual_id IN 
    ( 1, 2, 3, 4, 5, 6, 7, 8, 9,10,11,12,13,14,15,16,17,18,19,20,
     21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,
     41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,
     61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,
     81,82,83,84)
ORDER BY
  vf.seq_region_start
LIMIT
  03
;

SELECT
  COUNT(*),
  COUNT(DISTINCT
    individual_id, seq_region_id, seq_region_start, seq_region_end)
FROM
  compressed_genotype_region
;
