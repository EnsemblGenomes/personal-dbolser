;; This buffer is for notes you don't want to save, and for Lisp evaluation.
;; If you want to create a file, visit that file with C-x C-f,
;; then enter the text in that file's own buffer.

SELECT
  dbprimary_acc      AS accession,
  xref.description   AS core_name,
  t.name             AS onto_name,
  COALESCE(xref.description=t.name,0) AS mismatch
FROM
  object_xref
INNER JOIN
  xref        USING (xref_id)
INNER JOIN
  external_db USING (external_db_id)
INNER JOIN
  ensemblgenomes_ontology_33_86.term t ON (t.accession=xref.dbprimary_acc)
INNER JOIN
  ensemblgenomes_ontology_33_86.ontology o USING (ontology_id)
WHERE
  external_db.db_name IN ('GO', 'FYPO', 'MOD', 'SO')
#AND
#  COALESCE(xref.description=t.name,0) = 0
LIMIT
  10
;




UPDATE
  object_xref
INNER JOIN
  xref        USING (xref_id)
INNER JOIN
  external_db USING (external_db_id)
INNER JOIN
  ensemblgenomes_ontology_33_86.term t ON (t.accession=xref.dbprimary_acc)
INNER JOIN
  ensemblgenomes_ontology_33_86.ontology USING (ontology_id)
SET
  xref.description=t.name
WHERE
  external_db.db_name IN ('GO')
;
