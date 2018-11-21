SELECT
  db_name             AS xref_type,
  ensembl_object_type AS ens_type,
  COUNT(*)            AS COUNT
FROM
  object_xref ox
INNER JOIN
  xref x      USING (xref_id)
LEFT JOIN
  external_db USING (external_db_id)
GROUP BY
  external_db_id,
  ensembl_object_type
;

