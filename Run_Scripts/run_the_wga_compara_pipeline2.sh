
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## DNA+compara+pipeline

pipeline_name=lastz

## Ensembl
#source /nfs/panda/ensemblgenomes/apis/ensembl/89/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/90/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/91/setup.sh # or
#source ${HOME}/EG_Places/Devel/lib/libensembl-90/setup.sh
#source ${HOME}/EG_Places/Devel/lib/libensembl-91/setup.sh
#source ${HOME}/EG_Places/Devel/lib/libensembl-93/setup.sh
source ${HOME}/EG_Places/Devel/lib/libensembl-95/setup.sh
#source ${HOME}/EG_Places/Devel/lib/libensembl/setup.sh

## Ensembl Genomes (.../Bio/EnsEMBL/Analysis/Config/General.pm)
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=${PERL5LIB}:${libdir}/eg-pipelines/modules

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Path
PATH=${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline:$PATH

## Set this for convenience
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version



## Pair

## BLASTZ UPDATES
ref_species=arabidopsis_thaliana
oth_species=vitis_vinifera

ref_species=brachypodium_distachyon
oth_species=oryza_indica


## BARLEY

ref_species=oryza_sativa
oth_species=hordeum_vulgare

ref_species=brachypodium_distachyon
oth_species=hordeum_vulgare


## WHEAT

ref_species=brachypodium_distachyon
oth_species=triticum_aestivum

ref_species=hordeum_vulgare
oth_species=triticum_aestivum

ref_species=hordeum_vulgare
oth_species=triticum_aestivum.D


## WHEAT COMPONENTS?

ref_species=triticum_aestivum.A
ref_species=triticum_aestivum.B
oth_species=triticum_aestivum.B
oth_species=triticum_aestivum.D


## WHEAT McFUCK!

ref_species=triticum_dicoccoides
oth_species=hordeum_vulgare

ref_species=triticum_dicoccoides
oth_species=triticum_aestivum

ref_species=triticum_dicoccoides
oth_species=aegilops_tauschii

ref_species=aegilops_tauschii
oth_species=hordeum_vulgare

ref_species=aegilops_tauschii
oth_species=triticum_aestivum





# ## COLLECTION?

# ref_species=arabidopsis_thaliana
# oth_species=(physcomitrella_patens chlamydomonas_reinhardtii arabidopsis_lyrata brachypodium_distachyon glycine_max oryza_glaberrima oryza_indica selaginella_moellendorffii)

# ref_species=arabidopsis_thaliana
# ref_species=oryza_sativa
# ref_species=vitis_vinifera
# oth_species=(cucumis_sativus gossypium_raimondii helianthus_annuus lupinus_angustifolius manihot_esculenta nicotiana_attenuata phaseolus_vulgaris dioscorea_rotundata sorghum_bicolor glycine_max prunus_persica)

# ref_species=sorghum_bicolor
# oth_species=(zea_mays setaria_italica brachypodium_distachyon hordeum_vulgare musa_acuminata)





## Where are the cores for this pair or collection?
#core_server=mysql-staging-1
#core_server=mysql-staging-2
#core_server=mysql-prod-1
core_server=mysql-prod-2
#core_server=mysql-prod-3
#core_server=mysql-devel-3

## Where are previous WGA results, if you have them? (Needed for a
## simple healthcheck).
prev_server=mysql-eg-mirror
#prev_server=mysql-prod-1
#prev_server=mysql-prod-2
#prev_server=mysql-prod-3

prev_db=ensembl_compara_plants_41_94

#prev_db=dbolser_${pipeline_name}_${ensembl_version}_hvul_taes7
#prev_db=dbolser_${pipeline_name}_${ensembl_version}_hvul_taes14
#prev_db=dbolser_${pipeline_name}_90_hvul_taes14
#prev_db=dbolser_${pipeline_name}_90_poly_taes_ab
#prev_db=dbolser_${pipeline_name}_91_poly_taes_ad
#prev_db=dbolser_${pipeline_name}_91_poly_taes_bd

## Where is the Compara master database? NOTE, this needs to be set in
## the registry
#mast_server=mysql-pan-prod-ensrw
#mast_server=mysql-prod-3-ensrw
mast_server=mysql-ens-compara-prod-5

#mast_db=plants_compara_master_2
#mast_db=plants_compara_master_39_92
#mast_db=plants_compara_master_40_93
mast_db=ensembl_compara_master_plants

## Where do you want the hive database (production_db)?
#hive_server=mysql-prod-1-ensrw
hive_server=mysql-prod-2-ensrw
#hive_server=mysql-prod-3-ensrw
#hive_server=mysql-devel-1-ensrw
#hive_server=mysql-hive-ensrw



## NYANG NYANG NYANG

hive_db=${pipeline_name}_${ensembl_version}_tdic_hvul
hive_db=${pipeline_name}_${ensembl_version}_tdic_taes
hive_db=${pipeline_name}_${ensembl_version}_tdic_atau

hive_db=${pipeline_name}_${ensembl_version}_atau_hvul
hive_db=${pipeline_name}_${ensembl_version}_atau_taes


#hive_db=${pipeline_name}_${ensembl_version}_bdis_hvul
#hive_db=${pipeline_name}_${ensembl_version}_bdis_oind

#hive_db=${pipeline_name}_${ensembl_version}_atha_coll
#hive_db=${pipeline_name}_${ensembl_version}_osat_coll
#hive_db=${pipeline_name}_${ensembl_version}_vvin_coll
#hive_db=${pipeline_name}_${ensembl_version}_sbic_coll

# #hive_db=${pipeline_name}_${ensembl_version}_bdis_taes
# hive_db=${pipeline_name}_${ensembl_version}_hvul_taes
# hive_db=${pipeline_name}_${ensembl_version}_hvul_taes2
# hive_db=${pipeline_name}_${ensembl_version}_hvul_taes3
# hive_db=${pipeline_name}_${ensembl_version}_hvul_taes4

#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes5
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes6
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes7
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes8
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes9
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes10
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes11
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes12
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes13
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes14
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes15
#hive_db=${pipeline_name}_${ensembl_version}_hvul_taes16

#hive_db=${pipeline_name}_${ensembl_version}_poly_taes_ab_2
#hive_db=${pipeline_name}_${ensembl_version}_poly_taes_ad_2
#hive_db=${pipeline_name}_${ensembl_version}_poly_taes_bd_2

## Here we use $HIVE_PASS
eval $($hive_server --details env_HIVE_)



## Registry file (ensure it points to the correct master!)
registry=${HOME}/Registries/registry.${core_server}+panx.pm

## Double check...
grep $mast_db $registry



## Ahh
tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/wga/$hive_db
mkdir -p $tmpdir
ll $tmpdir


## Backup master
time \
$mast_server mysqldump $mast_db \
    | gzip -c \
    > $tmpdir/${mast_db}-$(date +%Y%m%d%H%M).sql.gz



## To add a species's dnafrags to master (not always necessary).

## Inserts into genome_db and dnafrag

## Also sets last_release in species_set_header and
## method_link_species_set for the old genome

#echo \
time \
update_genome.pl \
    --release \
    --compara multi \
    --reg_conf ${registry} \

    --species $ref_species
    --species $oth_species




# ## Alternatively, to build a collection...

# ## Touches species_set and species_set_header... Note that dry-run
# ## doesn't prevent this script from touching the database!

# collection=grape_vs
# collection=sorgu_vs

# echo $ref_species > $collection.txt

# for species in ${oth_species[@]}; do
#     echo $species >>  $collection.txt
# done

# wc -l $collection.txt



# echo \
# time \
#   edit_collection.pl \
#     --compara multi \
#     --reg_conf ${registry} \
#     --collection $collection \
#     --file $collection.txt \
#     --no-dry-run



## To get an MLSS for the pair (not always necessary)

## 1) Lookup genome_db_ids for each species

$mast_server $mast_db --table -e "
  SELECT #*
    genome_db_id, name, assembly, genome_component,
    first_release, last_release
  FROM
    genome_db
  WHERE
    last_release IS NULL
  AND (
    ( name = \"$ref_species\" OR
      name = \"$oth_species\" )
    OR
    ( CONCAT(name, \".\", genome_component) = \"$ref_species\" OR
      CONCAT(name, \".\", genome_component) = \"$oth_species\" )
  )
"

## 2) Use the above genome_db_ids here...

## Touches method_link_species_set, species_set and species_set_header

## TODO: Add release here!

#echo \
time \
create_mlss.pl \
    --release  \
    --compara multi \
    --reg_conf ${registry} \
    --source "ensembl" \
    --method_link_type LASTZ_NET \
    --url "" --species_set_name "" \
    --pw --ref_species $ref_species \
    --genome_db_id 

    --genome_db_id 2088,2120 # Barley vs. Ae. tauschii
    --genome_db_id 2102,2120 # IWGSC  vs. Ae. tauschii

    --genome_db_id 2088,2102 # Barley vs. IWGSC

    --genome_db_id 1505,1245
    --genome_db_id 1555,2091 # Brachy vs. IWGSC


    --genome_db_id 2088,2103 # Barley vs. IWGSC Component A
    --genome_db_id 2088,2105 # Barley vs. IWGSC Component D

    --genome_db_id 2103,2104 # IWGSC Component A vs. IWGSC Component B
    --genome_db_id 2103,2105 # IWGSC Component A vs. IWGSC Component D
    --genome_db_id 2104,2105 # IWGSC Component B vs. IWGSC Component D






# ## OR COLLECTION

# ## Touches method_link_species_set

# echo \
# time \
# create_mlss.pl \
#     --release \
#     --compara multi \
#     --reg_conf ${registry} \
#     --source "ensembl" \
#     --method_link_type LASTZ_NET \
#     --url "" --species_set_name "" \
#     \
#     --ref_species $ref_species \
#     --collection $collection \
#     --pw

## Note that *--pw* here IS SIGNIFICANT! Creates all pairs!!!  Run
## once with and once wihtout, the latter is to seed the pipeline.



## The output is...

#mlss_id=9556
#mlss_id=9557
#mlss_id=9558
#mlss_id=9559
#mlss_id=9560
#mlss_id=9569
#mlss_id=9570
# mlss_id=9569
# mlss_id=9581
# mlss_id=9604
# mlss_id=9616 # Barley vs. IWGSC
#mlss_id=9624 # Barley vs. IWGSC Component A
#mlss_id=9625 # Barley vs. IWGSC Component D

#mlss_id=9623 # Wheat Component A vs. IWGSC Component B

# mlss_id=9621 # Sorgu collection



#mlss_id=9627 # Barley vs. IWGSC
#mlss_id=9628 # IWGSC Component A vs. IWGSC Component B
#mlss_id=9629 # IWGSC Component A vs. IWGSC Component D
#mlss_id=9630 # IWGSC Component B vs. IWGSC Component D

mlss_id=9810 # T. dicoccoides vs. H. vulgare
mlss_id=9811 # T. dicoccoides vs. T. aestivum
mlss_id=9812 # T. dicoccoides vs. Ae. tauschii

mlss_id=9813 # Ae. tauschii vs. H. vulgare
mlss_id=9814 # Ae. tauschii vs. T. aestivum


## OK, HIVE TIME...

## Note Sensitivity parameters are configured within the PairAligner_conf...

## Generic config (we can ignore)
#$ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/Compara/PipeConfig/EBI/Ensembl/Lastz_conf.pm
#$ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/Compara/PipeConfig/EBI/Lastz_conf.pm
#$ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/Compara/PipeConfig/Lastz_conf.pm

## Specific config and pipeline config
#$ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/Compara/PipeConfig/PairAligner_conf.pm



#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::Compara::PipeConfig::EBI::Ensembl::Lastz_conf \
    $($hive_server --details script) --password $HIVE_PASS \
    --previous_db $($prev_server --details url)$prev_db \
    --master_db   $($mast_server --details url)$mast_db \
    --reg_conf ${registry} \
    --dump_dir $tmpdir \
    --ref_species $ref_species \
    --mlss_id $mlss_id \
    --bidirectional 1 \
    --pipeline_name $hive_db \
    --hive_force_init 0

## TODO: Why do we need a registry /and/ all the above config?



## OK then...

url=$($hive_server --details url)${USER}_$hive_db

echo $url
echo $url | xclip

## Fuck!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
#beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive

while true; do
    echo yo
    beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive
    echo po
    sleep 300
done













## IF NEEDED... GENERATE STATS

mlss_id=9634

comp_server=mysql-prod-3-ensrw
comp_db=plants_compara_wga_40_92

#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::Compara::PipeConfig::PairAlignerStats_conf \
    $($hive_server --details script) --password $HIVE_PASS \
    --reg_conf $registry \
    --dump_dir $tmpdir \
    --mlss_id ${mlss_id} \
    --pipeline_name pairalignstats_${mlss_id} \
    --compara_db $($comp_server --details url)$comp_db \
    --hive_force_init 1

url=$($hive_server --details url)${USER}_pairalignstats_${mlss_id}

echo $url
echo $url | xclip

url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive











### Now... the weird thing is the 'create_mlss' script above only
### creates one mlss for the collection, but not for the pairs... the
### production database does this for you 'at some point', so 'at some
### point' you can simply copy the MLSS back to the master (you
### mustn't use the master in the mean time or you'll get conflicts!

## Somethign like this...

$hive_server ${USER}_$hive_db -e "
    UPDATE method_link_species_set SET first_release = 91
    WHERE method_link_species_set_id BETWEEN 9570 AND 9580"

$hive_server mysqldump --no-create-info ${USER}_$hive_db \
    method_link_species_set \
    -w "method_link_species_set_id BETWEEN 9570 AND 9580" \
    | $mast_server $mast_db

$hive_server ${USER}_$hive_db -e "
    UPDATE species_set_header      SET first_release = 91
    WHERE species_set_id IN (
    SELECT species_set_id FROM method_link_species_set
    WHERE method_link_species_set_id BETWEEN 9570 AND 9580)"

$hive_server mysqldump --no-create-info --lock-all-tables ${USER}_$hive_db \
    species_set_header \
    -w "species_set_id IN (
    SELECT species_set_id FROM method_link_species_set
    WHERE method_link_species_set_id BETWEEN 9570 AND 9580)" \
    | $mast_server $mast_db




$hive_server ${USER}_$hive_db -e "
    UPDATE method_link_species_set SET first_release = 91
    WHERE method_link_species_set_id BETWEEN 9582 AND 9592"

$hive_server mysqldump --no-create-info ${USER}_$hive_db \
    method_link_species_set \
    -w "method_link_species_set_id BETWEEN 9582 AND 9592" \
    | $mast_server $mast_db

$hive_server ${USER}_$hive_db -e "
    UPDATE species_set_header      SET first_release = 91
    WHERE species_set_id IN (
    SELECT species_set_id FROM method_link_species_set
    WHERE method_link_species_set_id BETWEEN 9582 AND 9592)"

$hive_server mysqldump --no-create-info --lock-all-tables ${USER}_$hive_db \
    species_set_header \
    -w "species_set_id IN (
    SELECT species_set_id FROM method_link_species_set
    WHERE method_link_species_set_id BETWEEN 9582 AND 9592)" \
    | $mast_server $mast_db



## Now you can use your master again...



## Deal with an error that makes me deeply suspicous, but which Matthieu says, meh...
DELETE gab FROM genomic_align_block gab LEFT JOIN genomic_align ga
USING (genomic_align_block_id) WHERE ga.genomic_align_block_id IS NULL;










## Query some stats...

hive_server=mysql-eg-mirror
hive_db=ensembl_compara_plants_35_88
mlss_id=8650
mlss_id=8715
mlss_id=9171

hive_server=mysql-hive

hive_db=dbolser_lastz_90_atha_vvin
mlss_id=9556

hive_db=dbolser_lastz_90_bdis_oind
mlss_id=9559

hive_db=dbolser_lastz_90_osat_hvul
mlss_id=9557

hive_db=dbolser_lastz_90_bdis_hvul
mlss_id=9558

hive_db=dbolser_lastz_90_atha_coll


$hive_server $hive_db -e "
  SELECT * FROM method_link_species_set_tag
  WHERE method_link_species_set_id = \"$mlss_id\"
"

$hive_server $hive_db -e "
  SELECT
    @rna:=MAX(IF(tag = \"reference_species\",     value, -1)) AS rna,
    @ona:=MAX(IF(tag = \"non_reference_species\", value, -1)) AS ona,
    ##
    @rgc:=MAX(IF(tag = \"ref_genome_coverage\",     value, -1)) AS rgc,
    @rgl:=MAX(IF(tag = \"ref_genome_length\",       value, -1)) AS rgl,
    ##
    @ogc:=MAX(IF(tag = \"non_ref_genome_coverage\", value, -1)) AS ogc,
    @ogl:=MAX(IF(tag = \"non_ref_genome_length\",   value, -1)) AS ogl,
    ##
    @rec:=SUM(IF(tag IN (\"ref_insertions\",
                         \"ref_matches\",
                         \"ref_mis_matches\"),      value, -1)) AS  rec,
    @rel:=MAX(IF(tag = \"ref_coding_exon_length\",  value, -1)) AS  rel,
    ##
    @oec:=SUM(IF(tag IN (\"non_ref_insertions\",
                         \"non_ref_matches\",
                         \"non_ref_mis_matches\"),     value, -1)) AS oec,
    @oel:=MAX(IF(tag = \"non_ref_coding_exon_length\", value, -1)) AS oel
FROM
  method_link_species_set_tag
WHERE
  method_link_species_set_id = \"$mlss_id\";

SELECT
  @rna, @ona,
  ROUND(@rgc/@rgl*100) AS rgcp,
  ROUND(@ogc/@ogl*100) AS ogcp,
  ROUND(@rec/@rel*100) AS recp,
  ROUND(@oec/@oel*100) AS oecp
"


