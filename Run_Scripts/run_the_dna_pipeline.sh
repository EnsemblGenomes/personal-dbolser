## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## DNA+Features+Pipeline (Hive)

## Screen?

pipeline=dna_features

## Ensembl
#source /homes/dbolser/EG_Places/Devel/lib/libensembl-93/setup.sh
source /homes/dbolser/EG_Places/Devel/lib/libensembl-94/setup.sh

## Sets Ensembl Genomes environment
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
#PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules
PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines-repeat/modules

ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Adding REdat (Note, REdat does not include RepBase)
lib=/nfs/panda/ensemblgenomes/external/data/repeats_libraries
file=$lib/redat/mipsREdat_9.3p_ALL.fasta

grep -c "^>" $file ## 61730



## Set the speceis (TODO: clean up)...
species_cmd=" \
  --division             EnsemblPlants \
"

# legacy!!!
#   --repeatmasker_library all=$file \
#   --logic_name           all=repeatmask_redat \
#   --always_use_repbase   1 \
# "

species_cmd=" \
  --species ostreococcus_lucimarinus \
  --species chlamydomonas_reinhardtii \
  --species chondrus_crispus \
  --species musa_acuminata \
  --species brachypodium_distachyon
"

species_cmd=" \
  --species nicotiana_attenuata \
"

# species_cmd=" \
#   --species hordeum_vulgare \
#   --repeatmasker_library hordeum_vulgare=$file \
#   --logic_name           hordeum_vulgare=repeatmask_redat_high \
#   --repeatmasker_sensitivity high
#   --always_use_repbase   1 \
#   --delete_existing 0
# "



## Run a 'default' RepBase pipeline after the above seems to have
## stalled, and didn't create any pure RepBase jobs!
# species_cmd=" \
#   --species $species \
#   --no_dust 1 \
#   --no_trf 1 \
#   --delete_existing 0 \
# "

## Where are the cores for the above species?
#registry=${HOME}/Registries/s1pan.reg
#registry=${HOME}/Registries/s2pan.reg
#registry=${HOME}/Registries/p1pan.reg
registry=${HOME}/Registries/p2pan.reg
#registry=${HOME}/Registries/p3pan.reg



tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines
tmpdir=$tmpdir/${USER}/$pipeline

ls $tmpdir



## OK, HIVE TIME...

#hive_server=mysql-devel-1-ensrw
#hive_server=mysql-devel-2-ensrw
#hive_server=mysql-devel-3-ensrw
#hive_server=mysql-prod-1-ensrw
#hive_server=mysql-prod-2-ensrw
hive_server=mysql-prod-3-ensrw
#hive_server=mysql-hive-ensrw

#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::EGPipeline::PipeConfig::DNAFeatures_conf \
    $($hive_server --details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    $species_cmd \
    --hive_force_init 0

## Currently matches what the pipeline sets (but could change)
hive_db=${USER}_${pipeline}_${ensembl_version}

url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

##
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive
