
-- DELETE object_xref dupes

-- Dupes as reported by HC
SELECT
  COUNT(*)
FROM (
  SELECT
    COUNT(*)
  FROM
    xref x
  INNER JOIN
    object_xref ox
  USING
    (xref_id)
  GROUP BY
    ox.ensembl_id,
    ox.ensembl_object_type,
    x.dbprimary_acc,
    #x.display_label,
    x.external_db_id,
    x.info_type,
    x.info_text
  HAVING
    COUNT(*)>1
) AS
  cc
;

-- Pure XRef dupes? (Expect 0)
SELECT
  COUNT(*)
FROM (
  SELECT
    COUNT(*)
  FROM
    xref x
  GROUP BY
    x.dbprimary_acc,
    x.external_db_id,
    x.info_type,
    x.info_text
  HAVING
    COUNT(*)>1
) AS
  cc
;

-- Object XRef dupes (the cause of the above dupes)
SELECT
  COUNT(*)
FROM (
  SELECT
    COUNT(*)
  FROM
    object_xref ox
  GROUP BY
    ox.xref_id,
    ox.ensembl_id,
    ox.ensembl_object_type
  HAVING
    COUNT(*)>1
) AS
  cc
;

-- Clean them up...
DROP             TABLE IF EXISTS temp_foo;
CREATE TEMPORARY TABLE           temp_foo(
  PRIMARY KEY (object_xref_id)
) AS
SELECT
  MAX(object_xref_id) AS object_xref_id
FROM
  object_xref
GROUP BY
  xref_id,
  ensembl_id,
  ensembl_object_type
HAVING
  COUNT(*)>1
;

DELETE
  object_xref
FROM
  temp_foo
INNER JOIN
  object_xref
USING
  (object_xref_id)
;





-- FIX DUPLICATE XREF ONLY

CREATE TEMPORARY TABLE temp_foo_foo(
  PRIMARY KEY (MAX)
) AS
SELECT
  MIN(xref_id) AS MIN,
  MAX(xref_id) AS MAX,
  COUNT(*) AS M
FROM
  xref x
GROUP BY
  x.dbprimary_acc,
  x.external_db_id,
  x.info_type,
  x.info_text
HAVING
  COUNT(*)>1
;

UPDATE
  object_xref
INNER JOIN
  temp_foo_foo
ON
  xref_id = MAX
SET
  xref_id = MIN
;

DELETE
  xref
FROM
  xref
INNER JOIN
  temp_foo_foo
ON
  xref_id = MAX
;


-- Don't we need to update a variety of other xrefs here? At least
-- gene and transcript display xrefs?


