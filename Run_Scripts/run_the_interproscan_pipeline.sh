## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## InterProScan+pipeline

## Screen?

pipeline_name=InterProScanSeg

#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh
source /nfs/panda/ensemblgenomes/apis/ensembl/83/setup.sh

## Sets Ensembl Genomes environment
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules
PERL5LIB=$PERL5LIB:${libdir}/eg-proteinfeature/lib
PERL5LIB=$PERL5LIB:${libdir}/eg-release/lib
PERL5LIB=$PERL5LIB:${libdir}/eg-utils/lib

## Used to update analysis and analysis_description by the hive
## itself...
script_dir=${libdir}/eg-proteinfeature/scripts

## Please kill me
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'



## Moving on...

## Set the speceis...
species_cmd=" \
  --division  EnsemblPlants \
  --antispecies brassica_oleracea \
"

species_cmd=" \
  --species leersia_perrieri \
"

species_cmd=" \
  --species solanum_lycopersicum \
  --species zea_mays \
"

species_cmd=" \
  --species hordeum_vulgare_v2 \
"

## Where are the cores for those species?
#core_server=mysql-prod-1-ensrw
core_server=mysql-prod-2-ensrw
#core_server=mysql-staging-1-ensrw
#core_server=mysql-staging-2-ensrw

## and so...
registry=$HOME/Registries/registry.${core_server}.pm

## if needed...
eval $( ${core_server} --details env_DB )
echo "{ package reg; Bio::EnsEMBL::Registry->load_registry_from_db(qw($DBHOST $DBPORT $DBUSER $DBPASS)); 1; }" > ${registry}

# You need to update the registry to include the location to the
# production_db.. Add this section to your registry file

# Bio::EnsEMBL::DBSQL::DBAdaptor->new(
#     -host    => 'mysql-eg-pan-prod.ebi.ac.uk',
#     -port    => 4276,
#     -user    => 'ensro',
#     -dbname  => 'ensembl_production',
#     -species => 'multi',
#     -group   => 'production'
#   );



## OK, HIVE TIME...

hive_server=mysql-prod-1-ensrw
hive_server=mysql-prod-2-ensrw
hive_server=mysql-prod-3-ensrw
hive_server=mysql-hive-ensrw

hive_db=${USER}_${pipeline_name}

pipeline_dir=/nfs/nobackup/ensemblgenomes/${USER}/${pipeline_name}

init_pipeline.pl Bio::EnsEMBL::Hive::PipeConfig::InterProScanSeg_conf \
    -registry      ${registry} $species_cmd \
    $($hive_server --details script_hive_) \
    -hive_dbname   ${hive_db} \
    -pipeline_dir  ${pipeline_dir} \
    -script_dir    ${script_dir} \
    -hive_force_init 1



## OK then...

url=$($hive_server --details url)$hive_db

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop

# OR
runWorker.pl -url ${url} -reg_conf ${registry}
