# http://www.ebi.ac.uk/seqdb/confluence/display/
# ensf/How+to+run

## Screen?

pipeline_name=probemapping_hive

## This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR)...
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh
#source /homes/dbolser/EG_Places/Devel/lib/libensembl-91/setup.sh
#source /homes/dbolser/EG_Places/Devel/lib/libensembl/setup.sh
#source /homes/dbolser/EG_Places/Devel/lib/libensembl-93/setup.sh
source /homes/dbolser/EG_Places/Devel/lib/libensembl-95/setup.sh

# A few extra things defined here (NOT NEEDED ANYMORE):
# https://www.ebi.ac.uk/seqdb/confluence/display/
# ensf/Set+up+a+work+directory+and+configure+environment
#PATH=$PATH:/nfs/production/panda/ensembl/funcgen/bedtools/bedtools2/bin
PATH=$PATH:/nfs/production/panda/ensembl/funcgen/binaries

#PATH=$PATH:$ENSEMBL_ROOT_DIR/ensembl-funcgen/scripts/rollback
PATH=$PATH:$ENSEMBL_ROOT_DIR/ensembl-funcgen/scripts/export
PATH=$PATH:$ENSEMBL_ROOT_DIR/ensembl-funcgen/scripts/array_mapping


#core_server=mysql-prod-1-ensrw
core_server=mysql-prod-2-ensrw

## Registry file... (funcgen specific?)
#registry=/homes/dbolser/Registries/p1pan.reg
registry=/homes/dbolser/Registries/p2pan.reg
#registry=/homes/dbolser/Registries/p3pan.reg

## eHive config
#hive_server=mysql-prod-3-ensrw
hive_server=mysql-hive-ensrw

hive_db=${USER}_${pipeline_name}
url=$($hive_server --details url)$hive_db

## Random config
tempdir=/nfs/nobackup/ensemblgenomes/${USER}/array_mapping/temp
mkdir -p $tempdir
ls $tempdir

#probe_directory=/nfs/nobackup/ensemblgenomes/${USER}/array_mapping
#probe_directory=/nfs/production/panda/ensembl/funcgen/array_mapping
probe_directory=/nfs/production/panda/ensemblgenomes/data/Plants/array_mapping

tree $probe_directory



## Make a database?

db_list=(
    #aegilops_tauschii_funcgen_42_95_1
    #arabidopsis_halleri_funcgen_42_95_1
    #arabidopsis_lyrata_funcgen_42_95_10
    #arabidopsis_thaliana_funcgen_42_95_11
    #brassica_napus_funcgen_42_95_1
    #brassica_oleracea_funcgen_42_95_1
    #brassica_rapa_funcgen_42_95_1
    glycine_max_funcgen_42_95_3
    #gossypium_raimondii_funcgen_42_95_1
    #hordeum_vulgare_funcgen_42_95_3
    #medicago_truncatula_funcgen_42_95_2
    #nicotiana_attenuata_funcgen_42_95_1
    #oryza_barthii_funcgen_42_95_3
    #oryza_brachyantha_funcgen_42_95_14
    #oryza_indica_funcgen_42_95_2
    #oryza_sativa_funcgen_42_95_7
    #oryza_glaberrima_funcgen_42_95_2
    #oryza_glumaepatula_funcgen_42_95_15
    #oryza_longistaminata_funcgen_42_95_2
    #oryza_meridionalis_funcgen_42_95_13
    #oryza_nivara_funcgen_42_95_10
    #oryza_punctata_funcgen_42_95_12
    #oryza_rufipogon_funcgen_42_95_11
    phaseolus_vulgaris_funcgen_42_95_1
    #populus_trichocarpa_funcgen_42_95_3
    #solanum_lycopersicum_funcgen_42_95_250
    #triticum_aestivum_funcgen_40_93_4
    #triticum_dicoccoides_funcgen_42_95_1
    #triticum_urartu_funcgen_42_95_1
    vigna_angularis_funcgen_42_95_1
    vigna_radiata_funcgen_42_95_2
    #vitis_vinifera_funcgen_42_95_3
    #zea_mays_funcgen_42_95_7
)


for db in ${db_list[*]}; do
    echo $db

    ## Note thtat this BK naming scheme fails, the pipeline actually
    ## picks up the bk from the registry! Not sure what to do.

    # mysqlnaga-rename $($core_server --details script) \
    #     --drop --create \
    #     --database $db \
    #     --target ${db}_bk

    ## Note that the pipeline will automatically truncate the tables
    ## that it plans to populate... i.e. the drop isn't strictly
    ## necessary.

    #$core_server mysqladmin DROP   $db -f
    $core_server mysqladmin CREATE $db
    $core_server                   $db \
        < $ENSEMBL_ROOT_DIR/ensembl-funcgen/sql/table.sql

    ## While we're here, lets check that the core also exists...

    $core_server mysqlcheck ${db/_funcgen_/_core_} -o | grep -C 3 OK
    mysql-prod-2 ${db/_funcgen_/_core_} -e 'SELECT DATABASE()'

    echo
done


## For each species you need to check the fasta header add them into
## the array config!!!


# OLD: modules/Bio/EnsEMBL/Funcgen/Config/ImportArrays.pm

# NEW:
emacs \
    $ENSEMBL_ROOT_DIR/\
ensembl-funcgen/modules/Bio/EnsEMBL/Funcgen/RunnableDB/ProbeMapping/Config/ImportArrays.pm



## Oh dear...
pipeline_parameters="\
  --pipeline_url ${url} \
  --reg_conf ${registry} \
  --tempdir $tempdir \
  --probe_directory $probe_directory \
"

conf="Bio::EnsEMBL::Funcgen::PipeConfig::ProbeMapping"

init_pipeline.pl ${conf}::Backbone_conf                         $pipeline_parameters -hive_force_init 0
init_pipeline.pl ${conf}::ImportArrays_conf                     $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::RunImportHealthchecks_conf            $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::ExportSequences_conf                  $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::AlignProbes_conf                      $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::StoreProbeFeatures_conf               $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::RunAlignHealthchecks_conf             $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::Probe2Transcript_conf                 $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::RunProbeToTranscriptHealthchecks_conf $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::SwitchToMyIsam_conf                   $pipeline_parameters -hive_no_init 1
init_pipeline.pl ${conf}::RunSwitchTableEngineHealthchecks_conf $pipeline_parameters -hive_no_init 1

for db in ${db_list[*]}; do
    echo $db
    species=${db%%_funcgen_*}
    echo $species

    seed_pipeline.pl -url ${url} -logic_name start -input_id "{\"species\" => \"$species\" }"
    echo
done

## OR 
seed_pipeline.pl -url ${url} -logic_name start -input_id '{"species" => "arabidopsis_lyrata"}'
seed_pipeline.pl -url ${url} -logic_name start -input_id '{"species" => "arabidopsis_lyrata"}'
seed_pipeline.pl -url ${url} -logic_name start -input_id '{"species" => "arabidopsis_lyrata"}'





## AND

echo $url; echo $url; echo $url; 

echo $url | xclip

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive

## Or perhaps...
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -run
runWorker.pl -url ${url} -reg_conf ${registry} -debug 1





## NOW DON@T FORGET:

#for db in triticum_aestivum_funcgen_39_92_3
for db in ${db_list[*]}
do
    echo $db
    echo ${db%%_funcgen_*}

    perl $ENSEMBL_ROOT_DIR/ensembl-funcgen/scripts/release/populate_meta_coord.pl \
        --registry ${registry} \
        --species ${db%%_funcgen_*}

    echo
done





## NOW DON@T FORGET:
## NOW DON@T FORGET:

## INSERT species.production_name into FG DBs!


SQL='SELECT * FROM meta
     WHERE meta_key = "species.production_name"'

for db in \
    aegilops_tauschii_funcgen_42_95_3    \
    arabidopsis_halleri_funcgen_42_95_1  \
    glycine_max_funcgen_42_95_4          \
    nicotiana_attenuata_funcgen_42_95_1  \
    solanum_lycopersicum_funcgen_42_95_3 \
    triticum_dicoccoides_funcgen_42_95_1 \
    zea_mays_funcgen_42_95_7
do
    echo $db
    mysql-prod-2 $db -e "$SQL"
    
    core=${db/_funcgen_/_core_}
    echo $core

    mysql-prod-2 $core -e "$SQL"

    echo
done





## And... update array names from here:

https://docs.google.com/spreadsheets/d/1cfXs8y5rdXTfe5kf8MvsWVcgZKcql8WxOIUbYDW37Fk/edit#gid=320001600


perl -ne 'chomp; @F=split/\t/; print "UPDATE array INNER JOIN array_chip USING (array_id) SET array.name = \"$F[2]\", array.description = \"$F[10]\", array_chip.name = \"$F[7]\" WHERE array_chip.design_id = \"$F[1]\";\n\n"' flabby 









## [OPTIONAL] Comparing previous mappings to new mappings...

for db in \
    arabidopsis_thaliana_funcgen_42_95_11 \
    hordeum_vulgare_funcgen_42_95_3 \
    oryza_indica_funcgen_42_95_2 \
    oryza_sativa_funcgen_42_95_7 \
    populus_trichocarpa_funcgen_42_95_20 \
    vitis_vinifera_funcgen_42_95_3 \
    zea_mays_funcgen_42_95_7
do
    echo $db;

    SQL='
      SELECT
        array_chip.name, probe.name, probe_transcript.stable_id
      FROM
        array_chip INNER JOIN probe USING (array_chip_id)
        INNER JOIN probe_transcript USING (probe_id)
      ORDER BY 1, 2, 3
    '

    mysql-staging-2 $db -e "$SQL" > $db.old
    mysql-prod-2    $db -e "$SQL" > $db.new

done












-- Looking at mappings...
SELECT
  COUNT(DISTINCT probe_id)         AS Ps,
  COUNT(*)
FROM
  probe
;
+--------+----------+
| Ps     | COUNT(*) |
+--------+----------+
| 265682 |   265682 |
+--------+----------+
1 row in set (0.26 sec)


SELECT
  COUNT(DISTINCT probe_feature_id) AS PFs,
  COUNT(DISTINCT seq_region_id)    AS SRs,
  COUNT(DISTINCT probe_id)         AS Ps,
  COUNT(*)
FROM
  probe_feature
;
+---------+-----+--------+----------+
| PFs     | SRs | Ps     | COUNT(*) |
+---------+-----+--------+----------+
| 1071801 | 136 | 229396 |  1071801 |
+---------+-----+--------+----------+
1 row in set (2.42 sec)


SELECT
  COUNT(DISTINCT probe_feature_id) AS PFs,
  COUNT(DISTINCT seq_region_id)    AS SRs,
  COUNT(DISTINCT probe_id)         AS Ps,
  COUNT(DISTINCT probe_feature_transcript_id) AS PFTs,
  COUNT(DISTINCT stable_id)        AS Ss,
  COUNT(*)
FROM
  probe_feature
INNER JOIN
  probe_feature_transcript USING (probe_feature_id)
;

## p2t version
+--------+-----+--------+---------+-------+----------+
| PFs    | SRs | Ps     | PFTs    | Ss    | COUNT(*) |
+--------+-----+--------+---------+-------+----------+
| 583821 |  71 | 195252 | 3678194 | 22968 |  3678194 |
+--------+-----+--------+---------+-------+----------+
1 row in set (25.68 sec)

## BK version
+--------+-----+--------+---------+-------+----------+
| PFs    | SRs | Ps     | PFTs    | Ss    | COUNT(*) |
+--------+-----+--------+---------+-------+----------+
| 733487 |  71 | 191685 |  733487 | 55152 |   733487 |
+--------+-----+--------+---------+-------+----------+
1 row in set (5.36 sec)


SELECT
  COUNT(DISTINCT probe_feature_id) AS PFs,
  COUNT(DISTINCT pf.seq_region_id) AS SRs,
  COUNT(DISTINCT probe_id)         AS Ps,
  COUNT(DISTINCT probe_feature_transcript_id) AS PFTs,
  COUNT(DISTINCT stable_id)        AS Ss,
  COUNT(*)
FROM
  probe_feature pf
INNER JOIN
  probe_feature_transcript USING (probe_feature_id)
INNER JOIN
  zea_mays_core_35_88_7.transcript t USING (stable_id)
;

## p2t version with short stable_id columns
+--------+-----+--------+---------+-------+----------+
| PFs    | SRs | Ps     | PFTs    | Ss    | COUNT(*) |
+--------+-----+--------+---------+-------+----------+
|   5671 |   7 |   3087 |    6999 |   182 |     6999 | ## WRONG!!
+--------+-----+--------+---------+-------+----------+
1 row in set (40.35 sec)

## BK version with corrected stable_id columns
+--------+-----+--------+--------+-------+----------+
| PFs    | SRs | Ps     | PFTs   | Ss    | COUNT(*) |
+--------+-----+--------+--------+-------+----------+
| 733487 |  71 | 191685 | 733487 | 55152 |   733487 |
+--------+-----+--------+--------+-------+----------+
1 row in set (11.91 sec)






-- Clarity insanity (funcgen DB uses different CS ids and SR ids than
-- the corresponding core... naturally).
SELECT COUNT(DISTINCT name), COUNT(*) FROM seq_region;
+----------+
| COUNT(*) |
+----------+
|      136 |
+----------+

SELECT
  COUNT(DISTINCT name), COUNT(*)
FROM seq_region
INNER JOIN zea_mays_core_35_88_7.seq_region USING (name)
WHERE zea_mays_core_35_88_7.seq_region.coord_system_id IN (1,2);
+----------+
| COUNT(*) |
+----------+
|      136 |
+----------+





-- Look at drop off from probe -> probe_feature ->
-- probe_feature_transcript -> transcript

-- Probe drop off in probe_feature
SELECT 265682-229396 AS dropped, (265682-229396)/265682*100 AS perc;
+---------+---------+
| dropped | perc    |
+---------+---------+
|   36286 | 13.6577 |
+---------+---------+
1 row in set (0.00 sec)

-- Probe drop off in probe_feature -> probe_feature_transcript
SELECT 265682-195252 AS dropped, (265682-195252)/265682*100 AS perc;
+---------+---------+
| dropped | perc    |
+---------+---------+
|   70430 | 26.5091 |
+---------+---------+
1 row in set (0.00 sec)

-- Probe feature drop off in probe_feature_transcript
SELECT 1074525-583821 AS dropped, (1074525-583821)/1074525*100 AS perc;
+---------+---------+
| dropped | perc    |
+---------+---------+
|  490704 | 45.6671 |
+---------+---------+
1 row in set (0.00 sec)



ensro@mysql-eg-staging-1.ebi.ac.uk:4160/ vitis_vinifera_funcgen_39_92_3

> SELECT TABLE_NAME, TABLE_ROWS FROM information_schema.TABLES WHERE TABLE_SCHEMA = DATABASE() AND TABLE_ROWS > 0 ORDER BY UPDATE_TIME DESC, TABLE_NAME;
+--------------------------+------------++--------------------------+------------+
| TABLE_NAME               | TABLE_ROWS || TABLE_NAME               | TABLE_ROWS |
+--------------------------+------------++--------------------------+------------+
| analysis                 |          9 || analysis                 |          3 |
| analysis_description     |          3 || analysis_description     |          3 |
| array                    |          1 || array                    |          1 |
| array_chip               |          1 || array_chip               |          1 |
| meta                     |        209 || meta                     |         37 |
| probe                    |     264387 || probe                    |     264387 |
| probe_feature            |     299634 || probe_feature            |     452293 |
| probe_feature_transcript |     164816 || probe_feature_transcript |     304390 |
                                         | probe_seq                |     261592 |
| probe_set                |      16602 || probe_set                |      16602 |
| probe_set_transcript     |      10702 || probe_set_transcript     |      10546 |
                                         | probe_transcript         |     156606 |
| unmapped_object          |      45271 || unmapped_object          |      77365 |
| unmapped_reason          |        269 || unmapped_reason          |      77365 |
+--------------------------+------------++--------------------------+------------+





















