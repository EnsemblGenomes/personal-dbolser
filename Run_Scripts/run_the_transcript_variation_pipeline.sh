# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# The+transcript+variation+pipeline

# https://www.ebi.ac.uk/seqdb/confluence/display/EV/
# Transcript+variation+and+variation+class+pipeline

## Nurt: Make sure that the table meta_coord has entries for
##       variation_feature and transcript_variation

## Note, this variable simply matches what's in the _conf.pl so we can
## simply build (guess) the db name below
pipeline_name=variation_consequence


## CONFIG:

## ENSEMBL
libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-93

# This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR):
source ${libdir}/setup.sh

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'


## The variation database (and speceis) we want to use:

#vdb=arabidopsis_thaliana_variation_36_89_11
vdb=brachypodium_distachyon_variation_40_93_4
#vdb=hordeum_vulgare_variation_36_89_3

#vdb=oryza_glumaepatula_variation_37_90_15
#vdb=oryza_indica_variation_37_90_2
#vdb=oryza_sativa_variation_39_92_7

#vdb=solanum_lycopersicum_variation_36_89_250
#vdb=sorghum_bicolor_variation_37_90_30
vdb=triticum_aestivum_variation_39_92_4
#vdb=vitis_vinifera_variation_36_89_3
#vdb=zea_mays_variation_36_89_7

## Yuck, but hey.
species=${vdb%_variation*}
echo $species

scratch_dir=\
/nfs/nobackup/ensemblgenomes/$USER/$pipeline_name/$species
mkdir -p $scratch_dir

ls $scratch_dir



## Some more things to define...

## The default 'max distance to transcript' seems to be about 5k!
## (Within this distance the variation will be called 'updstream or
## downstream', which may be fine for human, but sucks balls for
## rice).

## A check of a 'default' run for rice shows that a max_distance of
## 200 gives approximately 3 times as many up/down TVs as genic TVs...
max_distance=200

#core_server=mysql-staging-1-ensrw
#core_server=mysql-staging-2-ensrw
core_server=mysql-prod-1-ensrw
#core_server=mysql-prod-2-ensrw
#core_server=mysql-prod-3-ensrw

#hive_server=mysql-prod-1-ensrw
#hive_server=mysql-prod-2-ensrw
#hive_server=mysql-prod-3-ensrw
#hive_server=mysql-devel-3-ensrw
hive_server=mysql-hive-ensrw



# ## REGISTRY (new style...)
# registry=${HOME}/Registries/p2pan.reg



# ## REGISTRY (old style...)

# eval $($core_server --details env_DB)

# registry=${HOME}/Registries/registry.${core_server}.pm
# md5sum ${registry}

# # ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
# # registry=${HOME}/Registries/registry.${core_server}.v${ensembl_version}.pm

# echo "{
#   package reg;
#   Bio::EnsEMBL::Registry->
#     load_registry_from_db(
#       qw($DBHOST $DBPORT $DBUSER $DBPASS 0 ${ensembl_version})
#     );
#   1;
# }" > ${registry}

# md5sum ${registry}



## Third time lucky?
registry=~/Registries/registry.mysql-prod-1+panx.pm
registry=~/Registries/registry.mysql-prod-2+panx.pm





## Get ready to run...

## Uh?
PERL5LIB=$ENSEMBL_ROOT_DIR/ensembl-variation/scripts/import:$PERL5LIB

## Can we not update the conf to change the queue names?

#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::Variation::Pipeline::VariationConsequence_conf \
    -species       ${species} \
    -reg_file      ${registry} \
    -pipeline_dir  ${scratch_dir} \
    -hive_root_dir $ENSEMBL_ROOT_DIR/ensembl-hive \
    $($hive_server --details script_hive_db_) \
    -hive_db_password $($hive_server pass) \
    -default_lsf_options '-q production-rh7 -M  2000 -R "rusage[mem= 2000]"' \
    -medmem_lsf_options  '-q production-rh7 -M  4000 -R "rusage[mem= 4000]"' \
    -urgent_lsf_options  '-q production-rh7 -M  2000 -R "rusage[mem= 2000]"' \
    -highmem_lsf_options '-q production-rh7 -M 15000 -R "rusage[mem=15000]"' \
    -long_lsf_options    '-q production-rh7 -M  2000 -R "rusage[mem= 2000]"' \
    -max_distance $max_distance \
    -hive_force_init 0

## Note, this setting simply matches what's in the _conf. We define it
## here for convenience. Note that in this pipeline the database isn't
## configurable on the cli!
hive_db=${USER}_${pipeline_name}_${species}

## These options seem unneeded
#    -hive_use_param_stack 1 \
#    -ensembl_release ${ensembl_version} \
#    -ensembl_cvs_root_dir ${ENSEMBL_ROOT_DIR} \



# And so...

url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

# Synchronize the Hive (should be done before [re]starting a pipeline) :
beekeeper.pl -url ${url} -sync

# Run the pipeline (can be interrupted and restarted) :
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive


## Reasons things fail
# * meta_coord?

