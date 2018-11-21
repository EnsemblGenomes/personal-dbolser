SQL='
SELECT
  MAX(IF(meta_key = "species.common_name",        meta_value, NULL)) AS common_name,
  MAX(IF(meta_key = "species.db_name",            meta_value, NULL)) AS db_name_obs,
  MAX(IF(meta_key = "species.display_name",       meta_value, NULL)) AS display_name,
  MAX(IF(meta_key = "species.ensembl_alias_name", meta_value, NULL)) AS ean_obs,
  MAX(IF(meta_key = "species.production_name",    meta_value, NULL)) AS production_name,
  MAX(IF(meta_key = "species.scientific_name",    meta_value, NULL)) AS scientific_name,
  MAX(IF(meta_key = "species.short_name",         meta_value, NULL)) AS short_name_obs,
  MAX(IF(meta_key = "species.strain",             meta_value, NULL)) AS strain,
  MAX(IF(meta_key = "species.sql_name",           meta_value, NULL)) AS sql_name_obs,
  MAX(IF(meta_key = "species.taxonomy_id",        meta_value, NULL)) AS taxonomy_id,
  MAX(IF(meta_key = "species.url",                meta_value, NULL)) AS url
FROM
  meta;
'
while read -r db; do 
    mysql-staging-1 $db -N -e "$SQL"
done \
    < <(grep _core_ plant_23_db.list)


__END__

DROP   VIEW IF EXISTS meta_species_scientific_name_plants;
CREATE VIEW           meta_species_scientific_name_plants
AS
SELECT * FROM aegilops_tauschii_core_23_76_1.meta          WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM amborella_trichopoda_core_23_76_1.meta       WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM arabidopsis_lyrata_core_23_76_10.meta        WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM arabidopsis_thaliana_core_23_76_10.meta      WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM brachypodium_distachyon_core_23_76_12.meta   WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM brassica_oleracea_core_23_76_1.meta          WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM brassica_rapa_core_23_76_1.meta              WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM chlamydomonas_reinhardtii_core_23_76_1.meta  WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM cyanidioschyzon_merolae_core_23_76_1.meta    WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM glycine_max_core_23_76_1.meta                WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM hordeum_vulgare_core_23_76_1.meta            WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM leersia_perrieri_core_23_76_14.meta          WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM medicago_truncatula_core_23_76_1.meta        WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM musa_acuminata_core_23_76_1.meta             WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_barthii_core_23_76_3.meta              WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_brachyantha_core_23_76_14.meta         WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_glaberrima_core_23_76_2.meta           WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_glumaepatula_core_23_76_15.meta        WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_indica_core_23_76_2.meta               WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_meridionalis_core_23_76_1.meta         WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_nivara_core_23_76_10.meta              WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_punctata_core_23_76_12.meta            WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_rufipogon_core_23_76_11.meta           WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM oryza_sativa_core_23_76_7.meta               WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM ostreococcus_lucimarinus_core_23_76_1.meta   WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM physcomitrella_patens_core_23_76_11.meta     WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM populus_trichocarpa_core_23_76_20.meta       WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM prunus_persica_core_23_76_1.meta             WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM selaginella_moellendorffii_core_23_76_1.meta WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM setaria_italica_core_23_76_21.meta           WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM solanum_lycopersicum_core_23_76_240.meta     WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM solanum_tuberosum_core_23_76_4.meta          WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM sorghum_bicolor_core_23_76_14.meta           WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM theobroma_cacao_core_23_76_1.meta            WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM triticum_aestivum_core_23_76_1.meta          WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM triticum_urartu_core_23_76_1.meta            WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM vitis_vinifera_core_23_76_3.meta             WHERE meta_key = 'species.scientific_name' UNION ALL
SELECT * FROM zea_mays_core_23_76_6.meta                   WHERE meta_key = 'species.scientific_name';






DELETE FROM aegilops_tauschii_core_23_76_1.meta          WHERE meta_key = 'species.db_name';
DELETE FROM amborella_trichopoda_core_23_76_1.meta       WHERE meta_key = 'species.db_name';
DELETE FROM arabidopsis_lyrata_core_23_76_10.meta        WHERE meta_key = 'species.db_name';
DELETE FROM arabidopsis_thaliana_core_23_76_10.meta      WHERE meta_key = 'species.db_name';
DELETE FROM brachypodium_distachyon_core_23_76_12.meta   WHERE meta_key = 'species.db_name';
DELETE FROM brassica_oleracea_core_23_76_1.meta          WHERE meta_key = 'species.db_name';
DELETE FROM brassica_rapa_core_23_76_1.meta              WHERE meta_key = 'species.db_name';
DELETE FROM chlamydomonas_reinhardtii_core_23_76_1.meta  WHERE meta_key = 'species.db_name';
DELETE FROM cyanidioschyzon_merolae_core_23_76_1.meta    WHERE meta_key = 'species.db_name';
DELETE FROM glycine_max_core_23_76_1.meta                WHERE meta_key = 'species.db_name';
DELETE FROM hordeum_vulgare_core_23_76_1.meta            WHERE meta_key = 'species.db_name';
DELETE FROM leersia_perrieri_core_23_76_14.meta          WHERE meta_key = 'species.db_name';
DELETE FROM medicago_truncatula_core_23_76_1.meta        WHERE meta_key = 'species.db_name';
DELETE FROM musa_acuminata_core_23_76_1.meta             WHERE meta_key = 'species.db_name';
DELETE FROM oryza_barthii_core_23_76_3.meta              WHERE meta_key = 'species.db_name';
DELETE FROM oryza_brachyantha_core_23_76_14.meta         WHERE meta_key = 'species.db_name';
DELETE FROM oryza_glaberrima_core_23_76_2.meta           WHERE meta_key = 'species.db_name';
DELETE FROM oryza_glumaepatula_core_23_76_15.meta        WHERE meta_key = 'species.db_name';
DELETE FROM oryza_indica_core_23_76_2.meta               WHERE meta_key = 'species.db_name';
DELETE FROM oryza_meridionalis_core_23_76_1.meta         WHERE meta_key = 'species.db_name';
DELETE FROM oryza_nivara_core_23_76_10.meta              WHERE meta_key = 'species.db_name';
DELETE FROM oryza_punctata_core_23_76_12.meta            WHERE meta_key = 'species.db_name';
DELETE FROM oryza_rufipogon_core_23_76_11.meta           WHERE meta_key = 'species.db_name';
DELETE FROM oryza_sativa_core_23_76_7.meta               WHERE meta_key = 'species.db_name';
DELETE FROM ostreococcus_lucimarinus_core_23_76_1.meta   WHERE meta_key = 'species.db_name';
DELETE FROM physcomitrella_patens_core_23_76_11.meta     WHERE meta_key = 'species.db_name';
DELETE FROM populus_trichocarpa_core_23_76_20.meta       WHERE meta_key = 'species.db_name';
DELETE FROM prunus_persica_core_23_76_1.meta             WHERE meta_key = 'species.db_name';
DELETE FROM selaginella_moellendorffii_core_23_76_1.meta WHERE meta_key = 'species.db_name';
DELETE FROM setaria_italica_core_23_76_21.meta           WHERE meta_key = 'species.db_name';
DELETE FROM solanum_lycopersicum_core_23_76_240.meta     WHERE meta_key = 'species.db_name';
DELETE FROM solanum_tuberosum_core_23_76_4.meta          WHERE meta_key = 'species.db_name';
DELETE FROM sorghum_bicolor_core_23_76_14.meta           WHERE meta_key = 'species.db_name';
DELETE FROM theobroma_cacao_core_23_76_1.meta            WHERE meta_key = 'species.db_name';
DELETE FROM triticum_aestivum_core_23_76_1.meta          WHERE meta_key = 'species.db_name';
DELETE FROM triticum_urartu_core_23_76_1.meta            WHERE meta_key = 'species.db_name';
DELETE FROM vitis_vinifera_core_23_76_3.meta             WHERE meta_key = 'species.db_name';
DELETE FROM zea_mays_core_23_76_6.meta                   WHERE meta_key = 'species.db_name';


INSERT INTO aegilops_tauschii_core_23_76_1.meta          (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Aegilops_tauschii'                             );
INSERT INTO amborella_trichopoda_core_23_76_1.meta       (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Amborella_trichopoda'                          );
INSERT INTO arabidopsis_lyrata_core_23_76_10.meta        (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Arabidopsis_lyrata_subsp._lyrata'              );
INSERT INTO arabidopsis_thaliana_core_23_76_10.meta      (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Arabidopsis_thaliana'                          );
INSERT INTO brachypodium_distachyon_core_23_76_12.meta   (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Brachypodium_distachyon'                       );
INSERT INTO brassica_oleracea_core_23_76_1.meta          (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Brassica_oleracea_var._oleracea'               );
INSERT INTO brassica_rapa_core_23_76_1.meta              (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Brassica_rapa_subsp._pekinensis'               );
INSERT INTO chlamydomonas_reinhardtii_core_23_76_1.meta  (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Chlamydomonas_reinhardtii'                     );
INSERT INTO cyanidioschyzon_merolae_core_23_76_1.meta    (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Cyanidioschyzon_merolae_strain_10D'            );
INSERT INTO glycine_max_core_23_76_1.meta                (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Glycine_max'                                   );
INSERT INTO hordeum_vulgare_core_23_76_1.meta            (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Hordeum_vulgare_subsp._vulgare'                );
INSERT INTO leersia_perrieri_core_23_76_14.meta          (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Leersia_perrieri'                              );
INSERT INTO medicago_truncatula_core_23_76_1.meta        (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Medicago_truncatula'                           );
INSERT INTO musa_acuminata_core_23_76_1.meta             (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Musa_acuminata_subsp._malaccensis'             );
INSERT INTO oryza_barthii_core_23_76_3.meta              (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_barthii'                                 );
INSERT INTO oryza_brachyantha_core_23_76_14.meta         (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_brachyantha'                             );
INSERT INTO oryza_glaberrima_core_23_76_2.meta           (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_glaberrima'                              );
INSERT INTO oryza_glumaepatula_core_23_76_15.meta        (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_glumaepatula'                            );
INSERT INTO oryza_indica_core_23_76_2.meta               (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_sativa_Indica_Group'                     );
INSERT INTO oryza_meridionalis_core_23_76_1.meta         (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_meridionalis'                            );
INSERT INTO oryza_nivara_core_23_76_10.meta              (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_nivara'                                  );
INSERT INTO oryza_punctata_core_23_76_12.meta            (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_punctata'                                );
INSERT INTO oryza_rufipogon_core_23_76_11.meta           (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_rufipogon'                               );
INSERT INTO oryza_sativa_core_23_76_7.meta               (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Oryza_sativa_Japonica_Group'                   );
INSERT INTO ostreococcus_lucimarinus_core_23_76_1.meta   (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Ostreococcus_lucimarinus_CCE9901'              );
INSERT INTO physcomitrella_patens_core_23_76_11.meta     (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Physcomitrella_patens'                         );
INSERT INTO populus_trichocarpa_core_23_76_20.meta       (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Populus_trichocarpa'                           );
INSERT INTO prunus_persica_core_23_76_1.meta             (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Prunus_persica'                                );
INSERT INTO selaginella_moellendorffii_core_23_76_1.meta (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Selaginella_moellendorffii'                    );
INSERT INTO setaria_italica_core_23_76_21.meta           (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Setaria_italica'                               );
INSERT INTO solanum_lycopersicum_core_23_76_240.meta     (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Solanum_lycopersicum'                          );
INSERT INTO solanum_tuberosum_core_23_76_4.meta          (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Solanum_tuberosum'                             );
INSERT INTO sorghum_bicolor_core_23_76_14.meta           (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Sorghum_bicolor'                               );
INSERT INTO theobroma_cacao_core_23_76_1.meta            (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Theobroma_cacao'                               );
INSERT INTO triticum_aestivum_core_23_76_1.meta          (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Triticum_aestivum'                             );
INSERT INTO triticum_urartu_core_23_76_1.meta            (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Triticum_urartu'                               );
INSERT INTO vitis_vinifera_core_23_76_3.meta             (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Vitis_vinifera'                                );
INSERT INTO zea_mays_core_23_76_6.meta                   (species_id, meta_key, meta_value) VALUES (1, 'species.wikipedia_url', 'http://wikipedia.org/wiki/Zea_mays'                                      );
