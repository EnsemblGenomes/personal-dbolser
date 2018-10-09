
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Gene+Mart+Production

## Ensembl
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/79/setup.sh # or
source /nfs/panda/ensemblgenomes/apis/ensembl/80/setup.sh # or


## Check
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'


## eg-biomart
libdir=${HOME}/EG_Places/Devel/lib/lib-eg

## Get ready...
cd $libdir/eg-biomart



## Should probably put this in my .profile

# JAVA_HOME
if [ -z "$JAVA_HOME" ]; then
    JAVA_HOME="/nfs/panda/ensemblgenomes/external/java"
    PATH="$JAVA_HOME/bin:$PATH"
fi
export JAVA_HOME
export PATH

# Ant
if [ -z "$ANT_HOME" ]; then
        export ANT_HOME=/nfs/panda/ensemblgenomes/external/apache-ant
        PATH=$ANT_HOME/bin:$PATH
fi
export ANT_HOME
export PATH





### SEQUENCE MART

cd sequence_mart

# Run without parameters for usage
# Usage: 
# sequence_mart.sh PROD_CMD DIVISION ENS_VERSION EG_VERSION [STAG_CMD]

sh sequence_mart.sh \
    mysql-prod-1-ensrw \
    plants 80 27 \
    mysql-staging-1-ensrw















### GENE MART

## We're going to need this...
list=~/Plants/plant_list-27.txt

## Add MTMP_probestuff_helper to funcgen
while read -r db; do
    echo $db
    mysql-prod-1-ensrw $db < gene_mart/probestuff_helper.sql
    echo
done \
  < <( grep _funcgen_ $list );


## Add MTMP_transcript_variation to variation
vlib=${ENSEMBL_ROOT_DIR}/ensembl-variation/scripts
 
while read -r db; do
    echo $db
    perl -I $vlib/import \
        $vlib/misc/mart_variation_effect.pl \
        $(mysql-prod-1-ensrw details naga) \
        -tmpdir /tmp \
        -tmpfile mtmp.txt \
        -table transcript_variation \
        -db $db    
    echo
done \
  < <( grep _funcgen_ $list )



## PICK UP eg-biomart/ensembl/ensembl_76_egready.xml

cd eg-biomart/scripts

perl \
    ./create_martbuilder_file.pl \
    --mart plants_mart_27 \
    --template ../ensembl/ensembl_80_egready.xml \
    --division EnsemblPlants





## Build (run SQL)
./martj/bin/martbuilder.sh





## POST PROCESSING SQL

cd eg-biomart/gene_mart

# Parameters are: division ens_release eg_release [prod_cmd], where
# prod_cmd defaults to 'mysql-prod-1-ensrw'

sh mart_processing.sh plants 80 27





## Generate template...

ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
#core_server=mysql-prod-1-ensrw
core_server=mysql-staging-1-ensrw
mart_db=plants_mart_27
 
cd eg-biomart/scripts

perl generate_template.pl \
  $($core_server --details script) \
  -mart $mart_db \
  -release $ensembl_version \
  -template templates/eg_template_template.xml



## Template

./martj/bin/marteditor.sh




## TESTING
perl -I modules \
    ./misc_scripts/test_mart.pl \
    --uri http://ebi4-129:8083/biomart/martservice \
    --mart plants_mart_27


    --verbose










## SNP/VARIATION MART

## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Variation+Mart

## EG
PERL5LIB=$PERL5LIB:${libdir}/eg-biomart/modules
PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules

## Check
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'



#registry=~/Registries/s1.pm
registry=~/Registries/p1.pm


ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")

hive_server=mysql-prod-3-ensrw
hive_db=${USER}_variation_mart_${ensembl_version}

init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::VariationMart_conf \
    $($hive_server --details script) \
    -registry ${registry} \
    -eg_biomart_root_dir ${libdir}/eg-biomart \
    -species solanum_lycopersicum \
    -species triticum_aestivum \
    -division_name plants \
    -eg_release 27


url=$($hive_server --details url)$hive_db

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
runWorker.pl -url ${url} -reg_conf ${registry}




./martj/bin/marteditor.sh


