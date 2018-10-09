
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## DNA+compara+pipeline

## Ensembl
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/87/setup.sh # or
source /nfs/panda/ensemblgenomes/apis/ensembl/89/setup.sh # or
#source ${PWD}/lib/libensembl/setup.sh

## Ensembl Genomes
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=${PERL5LIB}:${libdir}/eg-pipelines/modules

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Path
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline

## FECK...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")



## Pair
#ref_species=brassica_rapa
#oth_species=brassica_oleracea

ref_species=triticum_aestivum.A
oth_species=triticum_aestivum.B

ref_species=triticum_aestivum.A
oth_species=triticum_aestivum.D

ref_species=triticum_aestivum.B
oth_species=triticum_aestivum.D

ref_species=brachypodium_distachyon
oth_species=triticum_aestivum.A

ref_species=brachypodium_distachyon
oth_species=triticum_aestivum.B

ref_species=arabidopsis_thaliana
oth_species=vitis_vinifera


## Sorg...
ref_species=arabidopsis_thaliana
oth_species=sorghum_bicolor

ref_species=sorghum_bicolor
oth_species=oryza_sativa

ref_species=sorghum_bicolor
oth_species=zea_mays

ref_species=sorghum_bicolor
oth_species=setaria_italica

ref_species=sorghum_bicolor
oth_species=setaria_italica







## Zea pair...
#ref_species=oryza_sativa              # --genome_db_id 1985,2073
#ref_species=setaria_italica           # --genome_db_id 1581,2073
#ref_species=vitis_vinifera            # --genome_db_id 1245,2073
#ref_species=sorghum_bicolor           # --genome_db_id 1561,2073
#ref_species=arabidopsis_thaliana      # --genome_db_id 1505,2073
#ref_species=brachypodium_distachyon   # --genome_db_id 1555,2073
#ref_species=musa_acuminata            # --genome_db_id 1837,2073
#ref_species=physcomitrella_patens     # --genome_db_id 1506,2073

#oth_species=zea_mays



## To build a collection, see below

## Tomato pairs...
#ref_species=solanum_lycopersicum
#collection=tomato-wga



## Where are the cores for this pair?
#core_server=mysql-staging-1
core_server=mysql-staging-2
#core_server=mysql-prod-1
#core_server=mysql-prod-2
#core_server=mysql-devel-3

## Where is the Compara master database?
mast_server=mysql-pan-prod-ensrw
mast_db=plants_compara_master

## Where do you want the hive database (called the production_db in
## the docs)?
#hive_server=mysql-prod-1-ensrw
#hive_server=mysql-prod-2-ensrw
#hive_server=mysql-prod-3-ensrw
#hive_server=mysql-devel-1-ensrw
hive_server=mysql-hive-ensrw

## Put the connection details for all three servers in the shell
## environment for later... TODO: THIS DOESN'T WORK, NEED TO MAKE THE
## CONFIG MORE CANONICAL AND/OR PASS OPTIONS ON THE COMMAND LINE!
## However, these are used to build the registry file below.
eval $($core_server --details env_DB)
eval $($mast_server --details env_MA)
eval $($hive_server --details env_HIVE_)

## Registry file
#registry=${HOME}/Registries/registry.${core_server}+pan.v${ensembl_version}.pm
registry=${HOME}/Registries/registry.${core_server}+pan.pm

echo "{
  package reg;
  Bio::EnsEMBL::Registry->
    load_registry_from_db(
      ('$DBHOST', '$DBPORT', '$DBUSER', '$DBPASS', 0, ${ensembl_version})
    );
  1;
}" > ${registry}

# You need to update the registry to include the location to the
# master database... Add this section to your registry file
echo "
use
Bio::EnsEMBL::Compara::DBSQL::DBAdaptor;
Bio::EnsEMBL::Compara::DBSQL::DBAdaptor->new(
    -host    => '$MAHOST',
    -port    => '$MAPORT',
    -user    => '$MAUSER',
    -pass    => '$MAPASS',
    -dbname  => '$mast_db',
    -species => 'multi',
    -group   => 'compara'
);" >> ${registry}


## Used for backing up the master (at least)...
tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/wga
mkdir -p $tmpdir

## Backup master
time \
$mast_server mysqldump $mast_db \
    | gzip -c \
    > $tmpdir/${mast_db}-$(date +%Y%m%d%H%M).sql.gz



## To add a species's dnafrags to master (not always necessary).
## Note, ${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline is in
## the path!

## Touches dnafrag and genome_db

time \
update_genome.pl \
    --compara multi \
    --reg_conf ${registry} \
    --species $oth_species
    #--species $ref_species

## Feh!?
SELECT genome_db_id, name, assembly, first_release, last_release
FROM genome_db WHERE name RLIKE 'sorghum';

UPDATE genome_db SET last_release = '89' WHERE genome_db_id = 2087;
UPDATE genome_db SET first_release = '90' WHERE genome_db_id = 2089;



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
## Note, ${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline is in
## the path!

## Touches method_link_species_set, species_set and species_set_header

create_mlss.pl \
    --compara multi \
    --reg_conf ${registry} \
    --source "ensembl" \
    --method_link_type LASTZ_NET \
    --url "" --species_set_name "" \
    \
    --genome_db_id ...

    --genome_db_id 1505,1245

    --genome_db_id 1505,2089
    --genome_db_id 1985,2089
    --genome_db_id 2073,2089
    --genome_db_id 1581,2089

    --genome_db_id 1505,2087

## Feh!?
SELECT * FROM method_link_species_set WHERE name = 'A.tha-S.bic lastz-net';

UPDATE method_link_species_set SET first_release = '87',
                                    last_release = '89'
WHERE method_link_species_set_id = 9548;

UPDATE method_link_species_set SET first_release = '90'
WHERE method_link_species_set_id = 9552;



## and then one of ...

#  --genome_db_id 1505,2037 # or
#  --collection "$collection" --pw

mlss_id=9465 # AB
mlss_id=9452 # AD
mlss_id=9466 # BD

mlss_id=9467 # B.dis-A
mlss_id=9468 # B.dis-B
mlss_id=9469 # B.dis-D

mlss_id=9470

mlss_id=9556


## Final steps...

#hive_db=${USER}_brap_bole_lastz_$ensembl_version
#hive_db=${USER}_bdis_taea_lastz_$ensembl_version
#hive_db=${USER}_bdis_taeb_lastz_$ensembl_version
hive_db=${USER}_atha_vvin_lastz_$ensembl_version

#hive_db=${USER}_athl_brap_lastz_$ensembl_version
#hive_db=${USER}_slyc_stub_lastz_default_$ensembl_version
#hive_db=${USER}_slyc_coll_lastz_$ensembl_version

#hive_db=${USER}_taea_taeb_lastz_default_$ensembl_version
#hive_db=${USER}_taea_taeb_lastz_low_sens_big_chunk_$ensembl_version

hive_db=${USER}_taea_taed_lastz_low_sens_ortho_$ensembl_version

hive_db=${USER}_taea_taeb_lastz_xlow_sens_homoeo_$ensembl_version
hive_db=${USER}_taea_taed_lastz_xlow_sens_homoeo_$ensembl_version
hive_db=${USER}_taeb_taed_lastz_xlow_sens_homoeo_$ensembl_version

export PERL5LIB=$PWD/ensembl-compara-new-pairs/modules:$PERL5LIB
export PATH=${PWD}/ensembl-compara-new-pairs/scripts/pipeline:$PATH
export ENSEMBL_CVS_ROOT_DIR=$PWD

#hive_db=${USER}_athal_cmer_lastz_default_$ensembl_version
#hive_db=${USER}_aclum_olong_lastz_default_$ensembl_version
#hive_db=${USER}_lperr_olong_lastz_default_$ensembl_version
#hive_db=${USER}_olong_opunc_lastz_default_$ensembl_version
#hive_db=${USER}_olong_orufi_lastz_default_$ensembl_version


region_file="\
  --region_file /homes/dbolser/EG_Places/Data/Wheat/TGACv1/uniq_homs.txt"

region_file="\
  --region_file /homes/dbolser/EG_Places/Data/Wheat/TGACv1/Ortho_WGA/homoeologous_scaffolds_ab.dat"
region_file="\
  --region_file /homes/dbolser/EG_Places/Data/Wheat/TGACv1/Ortho_WGA/homoeologous_scaffolds_ad.dat"
region_file="\
  --region_file /homes/dbolser/EG_Places/Data/Wheat/TGACv1/Ortho_WGA/homoeologous_scaffolds_bd.dat"

# ## OK, HIVE TIME...
# init_pipeline.pl Bio::EnsEMBL::Compara::PipeConfig::Example::EGLastz_conf \
#     --dbname $hive_db \
#     --password $HIVE_PASS \
#     --ref_species $ref_species \
#     --mlss_id $mlss_id \
#     --reg_conf ${registry} \
#     $region_file \
#     --hive_force_init 0

# # OR
# #    --collection "$collection" \





## !!!! BELOW, WE USE A LOCAL COPY OF THE CONFIG!

cp $ENSEMBL_ROOT_DIR/ensembl-compara/modules/\
Bio/EnsEMBL/Compara/PipeConfig/Example/\
EGLastz_conf.pm EGLastz/\
EGLastz_conf-${ensembl_version}.pm

cp $ENSEMBL_ROOT_DIR/ensembl-compara/modules/\
Bio/EnsEMBL/Compara/PipeConfig/Example/\
EGPairAligner_conf.pm EGLastz/\
EGPairAligner_conf-${ensembl_version}.pm



## I've tweeked EGLastz_conf to simply point at the appropriate copy
## of EGPairAligner_conf. Use that one in the init below mkay?

diff $ENSEMBL_ROOT_DIR/ensembl-compara/modules/\
Bio/EnsEMBL/Compara/PipeConfig/Example/\
EGLastz_conf.pm EGLastz/\
EGLastz_conf_tweek.pm

## Edit the above to point to the appropriate EGPairAligner_conf

## Edit EGPairAligner_conf_xxx to connect to the appropriate db...

diff $ENSEMBL_ROOT_DIR/ensembl-compara/modules/\
Bio/EnsEMBL/Compara/PipeConfig/Example/\
EGPairAligner_conf.pm EGLastz/\
EGPairAligner_conf_p2.pm




export PERL5LIB=EGLastz:$PERL5LIB

init_pipeline.pl EGLastz::EGLastz_conf_89 \
    $($hive_server details script) \
    --dbname $hive_db \
    --password $HIVE_PASS \
    --ref_species $ref_species \
    --mlss_id $mlss_id \
    --reg_conf ${registry} \
    --hive_force_init 0

    --reg_conf ${registry} \

# OR
#    --collection "$collection" \





## OK then...

url=$($hive_server --details url)$hive_db

echo $url; echo $url; echo $url

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
runWorker.pl -url ${url} -reg_conf ${registry}
