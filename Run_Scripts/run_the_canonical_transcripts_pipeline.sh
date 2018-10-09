# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# Core+Statistics+Pipeline

## My lib
libdir=/nfs/panda/ensemblgenomes/apis/ensembl/current
libdir=/nfs/panda/ensemblgenomes/apis/ensembl/79
libdir=/nfs/panda/ensemblgenomes/apis/ensembl/80
libdir=/nfs/panda/ensemblgenomes/apis/ensembl/81

## This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR)...
source ${libdir}/setup.sh

## Sets Ensembl Genomes environment
PERL5LIB=$PERL5LIB:${ENSEMBL_ROOT_DIR}/../../eg-pipelines/modules

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'


core_server=mysql-staging-2-ensrw
core_server=mysql-prod-2-ensrw

dbname=triticum_aestivum_otherfeatures_28_81_2
dnadbname=triticum_aestivum_core_28_81_2

time \
perl \
    $ENSEMBL_CVS_ROOT_DIR/ensembl/misc-scripts/canonical_transcripts/\
select_canonical_transcripts.pl \
    $($core_server --details script_db) \
    --dbname $dbname \
    $($core_server --details script_dnadb) \
    --dnadbname $dnadbname \
    -coord_system toplevel -write
