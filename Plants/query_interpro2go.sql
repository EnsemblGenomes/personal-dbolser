
-- -- Query counts...
-- SELECT COUNT(*) FROM ontology_xref;
-- SELECT COUNT(*) FROM ontology_xref INNER JOIN object_xref USING (object_xref_id);

SELECT
  analysis_id                AS AID,
  logic_name, 
  ensembl_object_type        AS OBJ,
  linkage_type               AS TYPE,
  COUNT(*)                   AS ANNOTs,
  COUNT(DISTINCT ensembl_id) AS OBJs,
  COUNT(DISTINCT xref_id)    AS XREFs
FROM
  object_xref
INNER JOIN
  ontology_xref
USING
  (object_xref_id)
LEFT JOIN
  analysis
USING
  (analysis_id)
#WHERE
#  -- Not InterPro2GO
#  linkage_type != 'IEA'
GROUP BY
  analysis_id, ensembl_object_type, linkage_type
;

-- SELECT COUNT(*) FROM translation;
