
-- -- Query for the analysis ID's of the 11 InterPro domain families 
-- SELECT
--   analysis_id, logic_name, db, description
-- FROM
--   analysis INNER JOIN analysis_description USING (analysis_id)
-- WHERE logic_name IN (
--   'blastprodom', 'gene3d', 'hamap', 'hmmpanther', 'pfam', 'pfscan',
--   'pirsf', 'prints', 'scanprosite', 'smart', 'superfamily', 'tigrfam'
-- );

-- Query counts...
SELECT
  COUNT(*), @X:=COUNT(DISTINCT translation_id)
FROM protein_feature WHERE analysis_id IN (
  SELECT analysis_id FROM analysis WHERE logic_name IN (
    'blastprodom', 'gene3d', 'hamap', 'hmmpanther', 'pfam', 'pfscan',
    'pirsf', 'prints', 'scanprosite', 'smart', 'superfamily', 'tigrfam'
  )
);


-- of...
SELECT @Y:=COUNT(*) FROM translation;

SELECT @X, @Y, ROUND(@X/@Y*100);
