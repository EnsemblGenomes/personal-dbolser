
/*

USE information_schema;

*/

DESC TABLES;

SELECT * FROM TABLES 
WHERE TABLE_SCHEMA RLIKE 'cyanidioschyzon_merolae_core_13_66_1'
LIMIT 03;

SELECT TABLE_NAME, TABLE_TYPE, ENGINE FROM TABLES 
WHERE TABLE_SCHEMA RLIKE 'cyanidioschyzon_merolae_core_13_66_1'
LIMIT 03;

SELECT
  TABLE_SCHEMA,
  COUNT(*),
  SUM(IF(ENGINE='InnoDB',1,0)) AS INNODBS,
  SUM(IF(ENGINE='MyISAM',1,0)) AS MYISAMS,
  SUM(IF(ENGINE!='MyISAM',1,0)) AS OTHERS
FROM
  INFORMATION_SCHEMA.TABLES 
GROUP BY
  TABLE_SCHEMA
HAVING
  OTHERS > 0
;

SELECT
  TABLE_NAME
FROM
  INFORMATION_SCHEMA.TABLES 
WHERE
  #TABLE_SCHEMA = 'cyanidioschyzon_merolae_core_13_66_1'
  TABLE_SCHEMA = 'cyanidioschyzon_merolae_core_12_65_1'
AND
  ENGINE != 'MyISAM'
;



USE cyanidioschyzon_merolae_core_13_66_1;
USE cyanidioschyzon_merolae_core_12_65_1;

ALTER TABLE alt_allele                            ENGINE = 'MyISAM';
ALTER TABLE analysis                              ENGINE = 'MyISAM';
ALTER TABLE analysis_description                  ENGINE = 'MyISAM';
ALTER TABLE assembly                              ENGINE = 'MyISAM';
ALTER TABLE assembly_exception                    ENGINE = 'MyISAM';
ALTER TABLE coord_system                          ENGINE = 'MyISAM';
ALTER TABLE density_feature                       ENGINE = 'MyISAM';
ALTER TABLE density_type                          ENGINE = 'MyISAM';
ALTER TABLE dependent_xref                        ENGINE = 'MyISAM';
ALTER TABLE ditag                                 ENGINE = 'MyISAM';
ALTER TABLE ditag_feature                         ENGINE = 'MyISAM';
ALTER TABLE dna                                   ENGINE = 'MyISAM';
ALTER TABLE dna_align_feature                     ENGINE = 'MyISAM';
ALTER TABLE dnac                                  ENGINE = 'MyISAM';
ALTER TABLE external_synonym                      ENGINE = 'MyISAM';
ALTER TABLE gene_archive                          ENGINE = 'MyISAM';
ALTER TABLE gene_attrib                           ENGINE = 'MyISAM';
ALTER TABLE identity_xref                         ENGINE = 'MyISAM';
ALTER TABLE interpro                              ENGINE = 'MyISAM';
ALTER TABLE karyotype                             ENGINE = 'MyISAM';
ALTER TABLE map                                   ENGINE = 'MyISAM';
ALTER TABLE mapping_session                       ENGINE = 'MyISAM';
ALTER TABLE mapping_set                           ENGINE = 'MyISAM';
ALTER TABLE marker                                ENGINE = 'MyISAM';
ALTER TABLE marker_feature                        ENGINE = 'MyISAM';
ALTER TABLE marker_map_location                   ENGINE = 'MyISAM';
ALTER TABLE marker_synonym                        ENGINE = 'MyISAM';
ALTER TABLE meta                                  ENGINE = 'MyISAM';
ALTER TABLE meta_coord                            ENGINE = 'MyISAM';
ALTER TABLE misc_attrib                           ENGINE = 'MyISAM';
ALTER TABLE misc_feature                          ENGINE = 'MyISAM';
ALTER TABLE misc_feature_misc_set                 ENGINE = 'MyISAM';
ALTER TABLE misc_set                              ENGINE = 'MyISAM';
ALTER TABLE object_xref                           ENGINE = 'MyISAM';
ALTER TABLE ontology_xref                         ENGINE = 'MyISAM';
ALTER TABLE operon                                ENGINE = 'MyISAM';
ALTER TABLE operon_stable_id                      ENGINE = 'MyISAM';
ALTER TABLE operon_transcript                     ENGINE = 'MyISAM';
ALTER TABLE operon_transcript_gene                ENGINE = 'MyISAM';
ALTER TABLE operon_transcript_stable_id           ENGINE = 'MyISAM';
ALTER TABLE peptide_archive                       ENGINE = 'MyISAM';
ALTER TABLE prediction_exon                       ENGINE = 'MyISAM';
ALTER TABLE prediction_transcript                 ENGINE = 'MyISAM';
ALTER TABLE protein_align_feature                 ENGINE = 'MyISAM';
ALTER TABLE protein_feature                       ENGINE = 'MyISAM';
ALTER TABLE qtl                                   ENGINE = 'MyISAM';
ALTER TABLE qtl_feature                           ENGINE = 'MyISAM';
ALTER TABLE qtl_synonym                           ENGINE = 'MyISAM';
ALTER TABLE repeat_consensus                      ENGINE = 'MyISAM';
ALTER TABLE repeat_feature                        ENGINE = 'MyISAM';
ALTER TABLE seq_region                            ENGINE = 'MyISAM';
ALTER TABLE seq_region_attrib                     ENGINE = 'MyISAM';
ALTER TABLE seq_region_mapping                    ENGINE = 'MyISAM';
ALTER TABLE seq_region_synonym                    ENGINE = 'MyISAM';
ALTER TABLE simple_feature                        ENGINE = 'MyISAM';
ALTER TABLE splicing_event                        ENGINE = 'MyISAM';
ALTER TABLE splicing_event_feature                ENGINE = 'MyISAM';
ALTER TABLE splicing_transcript_pair              ENGINE = 'MyISAM';
ALTER TABLE stable_id_event                       ENGINE = 'MyISAM';
ALTER TABLE supporting_feature                    ENGINE = 'MyISAM';
ALTER TABLE transcript_attrib                     ENGINE = 'MyISAM';
ALTER TABLE transcript_supporting_feature         ENGINE = 'MyISAM';
ALTER TABLE translation_attrib                    ENGINE = 'MyISAM';
ALTER TABLE unconventional_transcript_association ENGINE = 'MyISAM';
ALTER TABLE unmapped_object                       ENGINE = 'MyISAM';
ALTER TABLE unmapped_reason                       ENGINE = 'MyISAM';
ALTER TABLE xref                                  ENGINE = 'MyISAM';


