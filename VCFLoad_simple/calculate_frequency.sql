
-- Try adding an index...
#ALTER TABLE tmp_individual_genotype_single_bp
#  ADD INDEX allele_1_idx (allele_1),
#  ADD INDEX allele_2_idx (allele_2);

# Query OK, 277545309 rows affected (43 min 29.78 sec)

-- The above index seems to have no impact on query execution time
-- below, as the individual_id_idx is picked instead of either of
-- these allele indexes!



-- Make a table with the allele_code IDs (and population_ids) instead
-- of allele strings (and individual_ids).  Bizarrely adding the JOIN
-- to individual_population actually speeds up the query by a factor
-- of approximately 2.

OPTIMIZE TABLE allele_code;
OPTIMIZE TABLE tmp_individual_genotype_single_bp;
OPTIMIZE TABLE     individual_genotype_multiple_bp;

DROP             TABLE IF EXISTS temp_individual_genotype;
CREATE TEMPORARY TABLE           temp_individual_genotype(
  INDEX (variation_id, population_id),
  INDEX (variation_id, population_id, allele_code_id_1),
  INDEX (variation_id, population_id, allele_code_id_2),
  INDEX (variation_id, population_id, allele_code_id_g)
)
#EXPLAIN
SELECT
  variation_id, population_id,
  one.allele_code_id    AS allele_code_id_1,
  two.allele_code_id    AS allele_code_id_2,
  CONCAT(
    one.allele_code_id, ':',
    two.allele_code_id) AS allele_code_id_g
FROM
  tmp_individual_genotype_single_bp
INNER JOIN
  individual_population p
USING
  (individual_id)
INNER JOIN
  allele_code one ON allele_1 = one.allele
INNER JOIN
  allele_code two ON allele_2 = two.allele
#
#LIMIT
#  0
;

# Query OK, 555,090,618 rows affected (3 hours 9 min 50.87 sec)
# Records:  555,090,618  Duplicates: 0  Warnings: 0

# Query OK, 832,635,927 rows affected (3 hours 34 min 39.96 sec)
# Records:  832,635,927  Duplicates: 0  Warnings: 0

# Query OK, 832,635,927 rows affected (5 hours 46 min 49.44 sec)
# Records:  832,635,927  Duplicates: 0  Warnings: 0

# Query OK, 832,635,927 rows affected (3 hours 14 min 51.44 sec)
# Records:  832,635,927  Duplicates: 0  Warnings: 0



OPTIMIZE TABLE temp_individual_genotype;
# 1 row in set (10 min 50.60 sec)
# 1 row in set ( 7 min 19.21 sec)
# 1 row in set ( 7 min 55.38 sec)
# 1 row in set ( 8 min 7.96 sec)



-- Add the multiple BP data to the same table

INSERT INTO
  temp_individual_genotype
SELECT
  variation_id, population_id,
  one.allele_code_id    AS allele_code_id_1,
  two.allele_code_id    AS allele_code_id_2,
  CONCAT(
    one.allele_code_id, ':',
    two.allele_code_id) AS allele_code_id_g
FROM
  individual_genotype_multiple_bp
INNER JOIN
  individual_population p
USING
  (individual_id)
INNER JOIN
  allele_code one ON allele_1 = one.allele
INNER JOIN
  allele_code two ON allele_2 = two.allele
#
#LIMIT
#  50000
;

# Loading into an empty table
#Query OK, 94,259,724 rows affected (29 min 33.71 sec)
#Records:  94,259,724  Duplicates: 0  Warnings: 0

OPTIMIZE TABLE temp_individual_genotype;
#1 row in set (1 min 5.82 sec)

# Loading into the existing data
#Query OK, 94259070 rows affected (3 hours 44 min 42.29 sec)
#Records: 94259070  Duplicates: 0  Warnings: 0

# 1 row in set (22 min 44.51 sec)





-- Now make tables for each allele, genotype, and the total...

-- ALLELE (in three steps)

-- Allele 1
DROP             TABLE IF EXISTS temp_individual_genotype_ax;
CREATE TEMPORARY TABLE           temp_individual_genotype_ax
  -- Adding N into the index here avoids a costly data look-up later.
  (INDEX pk_ish (variation_id, population_id, allele_code_id, N))
#EXPLAIN
SELECT   variation_id, population_id,
         allele_code_id_1 AS allele_code_id,
         COUNT(*) AS N
FROM     temp_individual_genotype
GROUP BY variation_id, population_id, allele_code_id_1;
#Query OK, 327889779 rows affected (29 min 32.86 sec)
#Query OK, 365,769,418 rows affected (14 min 10.04 sec)
#Records:  365,769,418  Duplicates: 0  Warnings: 0

OPTIMIZE TABLE temp_individual_genotype_ax;
#1 row in set (1 min 41.83 sec)

-- Allele 2
INSERT INTO  temp_individual_genotype_ax
#EXPLAIN
SELECT   variation_id, population_id,
         allele_code_id_2 AS allele_code_id,
         COUNT(*) AS N
FROM     temp_individual_genotype
GROUP BY variation_id, population_id, allele_code_id_2;
#Query OK, 290,316,464 rows affected (25 min 17.58 sec)
#Query OK, 325,200,297 rows affected (50 min 37.48 sec)
#Records:  325,200,297  Duplicates: 0  Warnings: 0

OPTIMIZE TABLE temp_individual_genotype_ax;
#1 row in set (6 min 36.91 sec)


-- and finally...
DROP             TABLE IF EXISTS temp_individual_genotype_aa;
CREATE TEMPORARY TABLE           temp_individual_genotype_aa
  (PRIMARY KEY (variation_id, population_id, allele_code_id))
#EXPLAIN
SELECT 
  variation_id, population_id, allele_code_id,
  COUNT(*) AS X, SUM(N) AS N
FROM
  temp_individual_genotype_ax
GROUP BY
  variation_id, population_id, allele_code_id
;
#Query OK, 399187969 rows affected (32 min 38.95 sec)

OPTIMIZE TABLE temp_individual_genotype_aa;



-- GENOTYPE

DROP             TABLE IF EXISTS temp_individual_genotype_gg;
CREATE TEMPORARY TABLE           temp_individual_genotype_gg
  (PRIMARY KEY (variation_id, population_id, allele_code_id_g))
#EXPLAIN
SELECT
  variation_id, population_id, allele_code_id_g,
  COUNT(*) AS N
FROM
  temp_individual_genotype
GROUP BY
  variation_id, population_id, allele_code_id_g
;
#Query OK, 329562440 rows affected (1 hour 21 min 20.40 sec)

OPTIMIZE TABLE temp_individual_genotype_gg;



-- TOTAL

DROP             TABLE IF EXISTS temp_individual_genotype_tt;
CREATE TEMPORARY TABLE           temp_individual_genotype_tt
  (PRIMARY KEY (variation_id, population_id))
#EXPLAIN
SELECT
  variation_id, population_id,
  COUNT(*) AS N
FROM
  temp_individual_genotype
GROUP BY
  variation_id, population_id
;
#Query OK, 283148189 rows affected (22 min 14.18 sec)

OPTIMIZE TABLE temp_individual_genotype_tt;







-- MAKE COUNTS LIKE THIS

-- Allele

RENAME TABLE allele TO   allele_bk3;
CREATE TABLE allele LIKE allele_bk3;

INSERT INTO allele
  (variation_id, allele_code_id, population_id, count, frequency)
SELECT
  variation_id, allele_code_id, population_id,
  a.N           AS count,
  -- We picked up a factor of two somewhere above
  a.N / t.N / 2 AS frequency
FROM
  temp_individual_genotype_aa a
INNER JOIN
  temp_individual_genotype_tt t
USING
  (variation_id, population_id)
#LIMIT
#  03
;
#Query OK, 399187969 rows affected, 1 warning (1 hour 42 min 43.03 sec)

OPTIMIZE TABLE allele;



-- Genotype

-- For convenience we need to select population genotype in same
-- format as allele_code_id_g above
DROP             TABLE IF EXISTS temp_genotype_code;
CREATE TEMPORARY TABLE           temp_genotype_code
  (PRIMARY KEY (allele_code_id_g)) AS
SELECT
  genotype_code_id,
  CONCAT(
    one.allele_code_id, ':',
    two.allele_code_id) AS allele_code_id_g
FROM
  genotype_code one
INNER JOIN
  genotype_code two
USING
  (genotype_code_id)
WHERE
  one.haplotype_id = 1 AND
  two.haplotype_id = 2 
;
#Query OK, 1000424 rows affected (12.56 sec)
#Query OK, 1000424 rows affected (14.21 sec)

OPTIMIZE TABLE temp_genotype_code;
#1 row in set (0.27 sec)

RENAME TABLE population_genotype TO   population_genotype_bk3;
CREATE TABLE population_genotype LIKE population_genotype_bk3;

INSERT INTO population_genotype
  (variation_id, genotype_code_id, population_id, frequency)
SELECT
  variation_id, genotype_code_id, population_id,
  g.N / t.N AS frequency
FROM
  temp_individual_genotype_gg g
INNER JOIN
  temp_individual_genotype_tt t
USING
  (variation_id, population_id)
INNER JOIN
  temp_genotype_code
USING
  (allele_code_id_g)
#LIMIT
#  03
;
#Query OK, 367,890,086 rows affected, 1 warning (2 hours 31 min 41.78 sec)
#Records:  367,890,086 Duplicates: 0  Warnings: 1

OPTIMIZE TABLE population_genotype;
#1 row in set (2 min 50.12 sec)



-- PRAY!
DROP TABLE IF EXISTS
  temp_individual_genotype_tt,
  temp_individual_genotype_gg,
  temp_individual_genotype_aa,
  temp_individual_genotype_ax,
  temp_individual_genotype,
  temp_genotype_code
;


