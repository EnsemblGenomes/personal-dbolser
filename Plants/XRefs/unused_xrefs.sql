
-- SELECT
--   TABLE_NAME, COLUMN_NAME, COLUMN_TYPE
-- FROM
--   information_schema.COLUMNS
-- WHERE
--   TABLE_SCHEMA = DATABASE()
-- AND
--   COLUMN_NAME RLIKE 'xref_id'
-- ;


DROP             TABLE IF EXISTS tmp_all_xrefs;
CREATE TEMPORARY TABLE           tmp_all_xrefs(
  PRIMARY KEY (xref_id, table_name)
)
AS
  SELECT              'gene' AS table_name, x.xref_id FROM xref x INNER JOIN             gene y ON x.xref_id =   y.display_xref_id
UNION                    
  SELECT        'transcript' AS table_name, x.xref_id FROM xref x INNER JOIN       transcript y ON x.xref_id =   y.display_xref_id
UNION                    
  SELECT   'associated_xref' AS table_name, x.xref_id FROM xref x INNER JOIN  associated_xref y ON x.xref_id =           y.xref_id
UNION                    
  SELECT   'associated_xref' AS table_name, x.xref_id FROM xref x INNER JOIN  associated_xref y ON x.xref_id =    y.source_xref_id
UNION                    
  SELECT    'dependent_xref' AS table_name, x.xref_id FROM xref x INNER JOIN   dependent_xref y ON x.xref_id =    y.master_xref_id
UNION                    
  SELECT    'dependent_xref' AS table_name, x.xref_id FROM xref x INNER JOIN   dependent_xref y ON x.xref_id = y.dependent_xref_id
UNION                    
  SELECT  'external_synonym' AS table_name, x.xref_id FROM xref x INNER JOIN external_synonym y ON x.xref_id =           y.xref_id
UNION                    
  SELECT       'object_xref' AS table_name, x.xref_id FROM xref x INNER JOIN      object_xref y ON x.xref_id =           y.xref_id
UNION                    
  SELECT     'ontology_xref' AS table_name, x.xref_id FROM xref x INNER JOIN    ontology_xref y ON x.xref_id =    y.source_xref_id
UNION
  SELECT          'interpro' AS table_name, x.xref_id FROM xref x INNER JOIN         interpro y ON dbprimary_acc = interpro_ac
                                                                  INNER JOIN  protein_feature z ON id = hit_name
;

SELECT
  db_name, external_db_id, COUNT(*)
FROM
  external_db
INNER JOIN
   xref x USING (external_db_id)
LEFT JOIN
  tmp_all_xrefs y
USING
  (xref_id)
WHERE
  y.xref_id IS NULL
GROUP BY
  external_db_id
WITH ROLLUP
;

#DELETE x FROM   xref x LEFT JOIN   tmp_all_xrefs y USING   (xref_id) WHERE   y.xref_id IS NULL;
