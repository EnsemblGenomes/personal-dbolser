## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Data+dumping+for+FTP

## For the time being, the pipeline uses a very specific layout of the
## 'working directory'. This requirement can be removed, but only once
## We work out how to build a decent production 'PATH'...

pipeline_name=ftpDataDump



## We assume you know your perl version and why

cd ~/EG_Places/Devel/FTP_Dumps/
source lib/setup.sh

## DONT FORGET RELEVANT PATCHES!



# OR 
libdir=/nfs/panda/ensemblgenomes/apis/ensembl/current
source ${libdir}/setup.sh



## Some EG things... (BRANCH STILL NEEDED?)
git clone -b feature/ftp_dump \
    https://scm.ebi.ac.uk/git/eg-pipelines.git
git clone -b feature/ftp_dump \
    https://scm.ebi.ac.uk/git/eg-release.git
git clone -b master           \
    https://scm.ebi.ac.uk/git/eg-utils.git

## AND SO
export PERL5LIB=$PERL5LIB:$(readlink -f eg-pipelines/modules)
export PERL5LIB=$PERL5LIB:$(readlink -f eg-release/lib)
export PERL5LIB=$PERL5LIB:$(readlink -f eg-utils/lib)


# OR
PERL5LIB=$PERL5LIB:${ENSEMBL_ROOT_DIR}/../../eg-pipelines/modules
PERL5LIB=$PERL5LIB:${ENSEMBL_ROOT_DIR}/../../eg-release/lib
PERL5LIB=$PERL5LIB:${ENSEMBL_ROOT_DIR}/../../eg-utils/lib



## CHECK
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'



## SERVERS

# We use RW here because...
#core_server=mysql-staging-1-ensrw
#core_server=mysql-staging-1-ro-ensrw
#core_server=mysql-staging-2-ensrw
#core_server=mysql-staging-2-ro-ensrw
core_server=mysql-prod-2-ensrw
#core_server=mysql-prod-3-ensrw

hive_server=mysql-prod-1-ensrw
#hive_server=mysql-hive-ensrw

eval $($core_server --details env_DB)
eval $($hive_server --details env_HIVE_)

hive_db=${USER}_${pipeline_name}





## REGISTRY
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")

registry=${PWD}/registry.${core_server}.v${ensembl_version}.pm

echo "{
  package reg;
  Bio::EnsEMBL::Registry->
    load_registry_from_db(
      qw($DBHOST $DBPORT $DBUSER $DBPASS 0 ${ensembl_version})
    );
  1;
}" > ${registry}



## HIVE

hive_db_params=" \
  -pipeline_db -dbname=${hive_db} \
  -pipeline_db -driver=mysql \
  -pipeline_db -host=$HIVE_HOST \
  -pipeline_db -port=$HIVE_PORT \
  -pipeline_db -user=$HIVE_USER \
  -pipeline_db -pass=$HIVE_PASS"




## FINAL SETUP

eg_version=$(echo $ensembl_version-53 | bc)

noback=/nfs/nobackup/ensemblgenomes
ftp_dir=${noback}/${USER}/${pipeline_name}/ftp_site
tmpdir=${noback}/${USER}/${pipeline_name}/temp_dir



## This is a mess however you carve it up

init_pipeline_args="\
  -registry ${registry} \
  -ftp_dir ${ftp_dir} \
  -tempdir ${tmpdir} \
  ${hive_db_params} \
  -ensembl_cvs_root_dir ${ENSEMBL_ROOT_DIR} \
  -eg_git_root_dir ${PWD} \
  -eg_version ${eg_version} \
  -pipeline_name ${pipeline_name} \
  -hive_root_dir ${ENSEMBL_ROOT_DIR}/ensembl-hive/"

## EMPTEH
init_pipeline.pl EGExt::FTP::PipeConfig::Empty \
    ${init_pipeline_args}



## FINAL FINAL SETUP

division=plants

core_db_params=" \
  -data_db -host=$DBHOST \
  -data_db -port=$DBPORT \
  -data_db -user=$DBUSER \
  -data_db -pass=$DBPASS"





## CORE /and/ VEP (go figure)

s1=${ENSEMBL_ROOT_DIR}/\
ensembl-variation/scripts/export/dump_vep.pl

s2=${ENSEMBL_ROOT_DIR}/\
ensembl-tools/scripts/variant_effect_predictor/\
variant_effect_predictor.pl

init_pipeline.pl EGExt::FTP::PipeConfig::DumpsCoreVEP_conf \
    ${init_pipeline_args} -hive_no_init 1 \
    ${core_db_params} \
    -compara  ${division} \
    -division ${division} \
    -dump_vep_script                 $s1 \
    -variant_effect_predictor_script $s2

## Variation
init_pipeline.pl EGVar::PipeConfig::Dump::DumpGVF_conf \
    ${init_pipeline_args} -hive_no_init 1 -compara ${division}

## Compara
init_pipeline.pl \
    EGExt::FTP::PipeConfig::Compara::DumpComparaTsv_conf \
    ${init_pipeline_args} -hive_no_init 1 -compara ${division}

init_pipeline.pl \
    EGExt::FTP::PipeConfig::Compara::DumpComparaDb_conf \
    ${init_pipeline_args} -hive_no_init 1 -compara ${division}

init_pipeline.pl \
    EGExt::FTP::PipeConfig::Compara::DumpComparaStableId2StableId_conf \
    ${init_pipeline_args} -hive_no_init 1 -compara ${division}



# sync and loop
url=$($hive_server --details url)$hive_db

# Synchronize the Hive (should be done before [re]starting a pipeline) :
beekeeper.pl -url $url -sync

# Run the pipeline (can be interrupted and restarted) :
beekeeper.pl -url ${url} -reg_conf ${registry} -loop # or
runWorker.pl -url ${url} -reg_conf ${registry}













# ## VEP
# init_pipeline.pl \
#     EGVar::PipeConfig::Dump::DumpVEPSingleAndCollection_conf \
#     ${init_pipeline_args} -analysis_topup -compara  ${division} ${core_db_params} \
#     -dump_vep_script \
#       ${ENSEMBL_ROOT_DIR}/ensembl-variation/scripts/export/dump_vep.pl \
#     -variant_effect_predictor_script \
#       ${ENSEMBL_ROOT_DIR}/ensembl-tools/scripts/variant_effect_predictor/variant_effect_predictor.pl

