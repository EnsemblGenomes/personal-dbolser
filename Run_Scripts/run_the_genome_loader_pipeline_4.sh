#!/bin/bash

## NOTE: Execute this file, don't source it (there is an exit command
## that will exit your terminal if you just source it!).

## See:
## https://github.com/Ensembl/ensembl-genomeloader

## Screen
#screen -S GL

## BShell
#bshell-25



## Ensembl PERL dependencies
source ${HOME}/EG_Places/Devel/lib/libensembl-94/setup.sh

## Useful later...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
eg_version=$(echo $ensembl_version-53 | bc)

echo $eg_version $ensembl_version



## You need to be here (or clone it here)
#cd ${HOME}/EG_Places/Devel/lib/ensembl-genomeloader/



## Specific config

division=EnsemblPlants




## Set the species and gca on the cli before running the script! e.g.

# export species=triticum_dicoccoides
# export gca=GCA_002162155.1
# source run_the_genome_loader_pipeline_4.sh



## OK
echo $species $gca



## Bah, we have one checkout per genome to load!
bahdir=/hps/cstor01/nobackup/crop_genomics/dbolser/GenomeLoader
cd $bahdir



## Clone
if [ ! -d "$gca" ]; then
    git clone git@github.com:Ensembl/ensembl-genomeloader.git "$gca"
else
    cd "$gca"
    git status
    git branch -v
    cd ../
fi



## Build
cd "$gca"/genome_materializer/

time \
    ./gradlew fatJar

cd ../



## CONFIG

## See
## https://github.com/Ensembl/ensembl-genomeloader/blob/master/CONFIG.md

if [ ! -f "enagenome_config.xml" ]; then
    #cp genome_materializer/src/main/etc/enagenome_config.xml ./
    cp ~/EG_Places/Devel/lib/ensembl-genomeloader/enagenome_config.xml ./
fi

## You better hope this is correct (you can check it using info here:
## https://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/Oracle+Instances)

less enagenome_config.xml



## Run time...

db_suffix=${gca#*.}
db_name=${species}_core_${eg_version}_${ensembl_version}_${db_suffix}

#prod_db=mysql-prod-1-ensrw
#prod_db=mysql-prod-2-ensrw
prod_db=mysql-prod-3-ensrw
#prod_db=mysql-devel-1-ensrw
#prod_db=mysql-devel-2-ensrw
#prod_db=mysql-devel-3-ensrw

echo $prod_db
echo $prod_db
echo $prod_db



cmd="perl \
    -I ./modules \
    ./scripts/load_genome.pl \
    \
    -a ${gca%.*}     \
    --division $division \
    \
    $($prod_db --details script) \
    --dbname $db_name
    \
    $(mysql-pan-prod     --details script_tax_) \
    --tax_dbname ncbi_taxonomy \
    \
    $(mysql-pan-prod     --details script_prod_) \
    --prod_dbname ensembl_production"

echo $cmd
time $cmd

if [ $? -eq 0 ]; then
    echo OK
else
    echo FAIL
    hostname
    echo $species $gca
    exit
fi



hostname
echo $species $gca





### Now lets HC...

ENDPOINT=http://eg-prod-01.ebi.ac.uk:7000/hc/

SERVER=$(         $prod_db        details url)
PRODUCTION=$(     mysql-pan-prod  details url)
STAGING=$(        mysql-staging-1 details url)
LIVE=$(           mysql-publicsql details url)
COMPARA_MASTER=$( mysql-pan-prod  details url)

GROUP=EGCoreHandover

DATA_FILE_PATH=/nfs/panda/ensembl/production/ensemblftp/data_files/

TAG=my_gl_hc_run

BASE_DIR=/homes/dbolser/EG_Places/Devel/lib/ensembl-prodinf-core

python \
    $BASE_DIR/ensembl_prodinf/hc_client.py \
    --uri $ENDPOINT \
    --db_uri "${SERVER}${db_name}" \
    --production_uri "${PRODUCTION}ensembl_production" \
    --staging_uri $STAGING \
    --live_uri $LIVE \
    --compara_uri "${COMPARA_MASTER}ensembl_compara_master" \
    --hc_groups $GROUP \
    --data_files_path $DATA_FILE_PATH \
    --tag $TAG  \
    --action submit

