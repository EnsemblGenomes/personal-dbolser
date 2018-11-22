# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# Core+Statistics+Pipeline

pipeline_name=core_statistics

## Define our species (note, use -division EnsemblPlants if that's
## what you want)

species_cmd="\
  --species lupinus_angustifolius \
  --species glycine_max \
  --species vigna_radiata \
  --species physcomitrella_patens \
  --species arabidopsis_halleri \
  --species triticum_dicoccoides \
"

species_cmd="\
  --species physcomitrella_patens \
"

# species_cmd="\
#   --division EnsemblPlants \
# "

# species_cmd="\
#   --division EnsemblPlants \
#   --antispecies triticum_aestivum \
# "



## My lib
#libdir=/nfs/panda/ensemblgenomes/apis/ensembl/current
#libdir=/nfs/panda/ensemblgenomes/apis/ensembl/79
#libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl
#libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-93
#libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-94
libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-95

## This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR)...
source ${libdir}/setup.sh

## Sets Ensembl Genomes environment
PERL5LIB=$PERL5LIB:${libdir}/../lib-eg/eg-pipelines/modules

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Just for convenience...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version

## Moving on
#registry=/homes/dbolser/Registries/s1pan.reg
#registry=/homes/dbolser/Registries/s2pan.reg
#registry=/homes/dbolser/Registries/p1pan.reg
registry=/homes/dbolser/Registries/p2pan.reg
#registry=/homes/dbolser/Registries/p3pan.reg

#hive_server=mysql-devel-1-ensrw
#hive_server=mysql-devel-2-ensrw
#hive_server=mysql-devel-3-ensrw
#hive_server=mysql-prod-1-ensrw
#hive_server=mysql-prod-2-ensrw
#hive_server=mysql-prod-3-ensrw
hive_server=mysql-hive-ensrw

#echo \
time \
init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::CoreStatistics_conf \
    $($hive_server details script) \
    -registry ${registry} \
    ${species_cmd} \
    -hive_force_init 0

hive_db=${USER}_${pipeline_name}_${ensembl_version}
url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive

## Or perhaps...
#beekeeper.pl -url ${url} -reg_conf ${registry} -run
