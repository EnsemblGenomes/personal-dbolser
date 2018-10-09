#!/bin/env bash

## Generic config (mostly) common to all hive pipelines...
## You'll probably want to set things up by editing below.



## We use the pipeline name to setup various paths
pipeline_name=${1:?plz pass a pipeline_name}

#pipeline_name=synteny



## Would put this in .bashrc, but it's slow!
#source /nfs/software/ensembl/RHEL7/envs/basic.sh



## Ensembl APIs and scripts
source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/synteny
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")



## Ensembl Genomes APIs
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=${PERL5LIB}:${libdir}/eg-pipelines/modules
eg_version=$(echo $ensembl_version-53 | bc)



## Err...
noback=/nfs/nobackup/ensemblgenomes
tmpdir=${noback}/${USER}/${pipeline_name}
mkdir -p $tmpdir



## Cores
core_server=mysql-prod-1



## For compara pipelines
mast_server=mysql-pan-prod-ensrw
mast_db=plants_compara_master

prod_server=mysql-prod-1
prod_db=ensembl_compara_plants_35_88



## Hive database (sometimes called production database)
hive_server=mysql-prod-2-ensrw


## The all important registry
registry=${HOME}/Registries/p1-generic.reg

