


-- Summarize my XRefs:
SELECT
  logic_name,
  db_name,
  ensembl_object_type,
  COUNT(DISTINCT ensembl_id) AS objects,
  COUNT(DISTINCT xref_id) AS xrefs,
  COUNT(*) AS total
FROM
  object_xref INNER JOIN xref USING (xref_id)
INNER JOIN
  external_db USING (external_db_id)
INNER JOIN
  analysis USING (analysis_id)
GROUP BY
  ensembl_object_type, analysis_id, external_db_id
;



-- Summarize GENE display XRefs
SELECT
  logic_name,
  biotype,
  db_name,
  'Gene display XRef',
  COUNT(DISTINCT gene_id) AS genes,
  COUNT(DISTINCT xref_id) AS xrefs,
  COUNT(*) AS total
FROM
  gene INNER JOIN xref ON display_xref_id = xref_id
INNER JOIN
  external_db USING (external_db_id)
INNER JOIN
  analysis USING (analysis_id)
GROUP BY
  biotype, analysis_id, external_db_id
;

-- Summarize TRANSCRIPT display XRefs
SELECT
  logic_name,
  biotype,
  db_name,
  'Transcript display XRef',
  COUNT(DISTINCT gene_id) AS transcripts,
  COUNT(DISTINCT xref_id) AS xrefs,
  COUNT(*) AS total
FROM
  transcript INNER JOIN xref ON display_xref_id = xref_id
INNER JOIN
  external_db USING (external_db_id)
INNER JOIN
  analysis USING (analysis_id)
GROUP BY
  biotype, analysis_id, external_db_id
;



-- Summarisze dependent XRefs
SELECT COUNT(*), COUNT(DISTINCT object_xref_id)
FROM dependent_xref;

SELECT COUNT(*), COUNT(DISTINCT object_xref_id)
FROM dependent_xref
INNER JOIN object_xref USING (object_xref_id)
INNER JOIN xref master    ON    master_xref_id =    master.xref_id
INNER JOIN xref dependent ON dependent_xref_id = dependent.xref_id;

SELECT
  logic_name,
  ensembl_object_type,
  master_db.db_name,
  dependent_db.db_name,
  COUNT(DISTINCT ensembl_id) AS objects,
  COUNT(DISTINCT master.xref_id) AS master_xrefs,
  COUNT(DISTINCT dependent.xref_id) AS dependent_xrefs,
  COUNT(*)
FROM
  dependent_xref
INNER JOIN object_xref USING (object_xref_id)
INNER JOIN analysis    USING (analysis_id)
INNER JOIN xref master ON master_xref_id = master.xref_id
INNER JOIN external_db master_db ON master.external_db_id = master_db.external_db_id
INNER JOIN xref dependent ON dependent_xref_id = dependent.xref_id
INNER JOIN external_db dependent_db ON dependent.external_db_id = dependent_db.external_db_id
GROUP BY
  ensembl_object_type, analysis_id, master.external_db_id, dependent.external_db_id;



-- Summarisze XRef synonyms
SELECT
  db_name, COUNT(*)
FROM xref INNER JOIN external_db USING (external_db_id)
INNER JOIN external_synonym USING (xref_id);


-- Summarize Ontology XRefs
SELECT COUNT(*), COUNT(DISTINCT object_xref_id) FROM ontology_xref limit 03;

SELECT COUNT(*), COUNT(DISTINCT object_xref_id) FROM ontology_xref
INNER JOIN object_xref USING (object_xref_id) limit 03;

SELECT
  logic_name,
  db_name,
  ensembl_object_type,
  linkage_type,
  COUNT(DISTINCT ensembl_id) AS objects,
  COUNT(DISTINCT xref_id) AS xrefs,
  COUNT(*) AS total
FROM
  object_xref INNER JOIN xref USING (xref_id)
INNER JOIN
  ontology_xref USING (object_xref_id)
INNER JOIN
  external_db USING (external_db_id)
INNER JOIN
  analysis USING (analysis_id)
GROUP BY
  ensembl_object_type, analysis_id, external_db_id, linkage_type
;


SELECT 
  logic_name,   db_name,   ensembl_object_type,   linkage_type,   COUNT(DISTINCT ensembl_id) AS objects,   COUNT(DISTINCT xref.xref_id) AS xrefs,   COUNT(*) AS total
FROM 
  object_xref INNER JOIN xref USING (xref_id)
INNER JOIN 
  ontology_xref USING (object_xref_id)
INNER JOIN 
  external_db USING (external_db_id)
INNER JOIN 
  analysis USING (analysis_id)
GROUP BY 
  ensembl_object_type, analysis_id, xref.external_db_id, linkage_type;



SELECT db_name, COUNT(*) FROM    ontology_xref INNER JOIN xref source ON source_xref_id = source.xref_id INNER JOIN external_db USING (external_db_id) GROUP BY external_db_id;



SELECT TABLE_NAME, COLUMN_NAME FROM information_schema.COLUMNS WHERE COLUMNS.TABLE_SCHEMA = DATABASE() AND COLUMN_NAME RLIKE 'xref_id';
+------------------+--------------------+
| TABLE_NAME       | COLUMN_NAME        |
+------------------+--------------------+
| associated_xref  | associated_xref_id |x
| associated_xref  | object_xref_id     |x
| associated_xref  | xref_id            |x
| associated_xref  | source_xref_id     |x
| dependent_xref   | object_xref_id     |x
| dependent_xref   | master_xref_id     |x
| dependent_xref   | dependent_xref_id  |x
| external_synonym | xref_id            |x
| gene             | display_xref_id    |x
| identity_xref    | object_xref_id     |
| identity_xref    | xref_identity      |
| object_xref      | object_xref_id     |x
| object_xref      | xref_id            |x
| ontology_xref    | object_xref_id     |
| ontology_xref    | source_xref_id     |
| transcript       | display_xref_id    |x
| xref             | xref_id            |x
+------------------+--------------------+
17 rows in set (0.01 sec)

