## See:
## https://github.com/Ensembl/ensembl-genomeloader

## screen?
## bshell?


## Ensembl PERL dependencies
#source ${HOME}/EG_Places/Devel/lib/libensembl-91/setup.sh
source ${HOME}/EG_Places/Devel/lib/libensembl-93/setup.sh

## You need to be here (or clone it there)
cd $ENSEMBL_ROOT_DIR/../ensembl-genomeloader/



## Specific config

gca=GCA_002240015.2
species=dioscorea_rotundata_core_39_92_3

division=EnsemblPlants



## Generic config

## Note, for now, this is still necessary:
export ORACLE_HOME=/sw/arch/dbtools/oracle/product/11.1.0.6.2/client

export PERL5LIB=$PERL5LIB:$ENSEMBL_ROOT_DIR/ensembl-genomeloader/modules



## Go time!

#echo \
time \
perl \
  ./scripts/load_genome.pl -a ${gca%.*} \
    --division $division \
    $(mysql-prod-1-ensrw --details script) \
    --dbname $species \
    $(mysql-pan-prod     --details script_tax_) \
    --tax_dbname ncbi_taxonomy \
    $(mysql-pan-prod     --details script_prod_) \
    --prod_dbname ensembl_production \
    --interpro_driver oracle





## ERRORS...
Could not connect to database IPREAD as user proteomes_prod using [DBI:Oracle:] as a locator:
DBI connect('','proteomes_prod@IPREAD',...) failed: ORA-12154: TNS:could not resolve the connect identifier specified (DBD ERROR: OCIServerAttach) at /nfs/production/panda/ensemblgenomes/development/dbolser/lib/libensembl-91/ensembl/modules/Bio/EnsEMBL/DBSQL/DBConnection.pm line 260.

## Added the above ORACLE_HOME
