
## My db
export dbname=solanum_lycopersicum_core_25_78_250

## My fasta
export fasta=/nfs/production/panda/ensemblgenomes/data/Plants/Tomato/\
S_lycopersicum_scaffolds.2.50.fa

## My AGP
export myagp=/nfs/production/panda/ensemblgenomes/data/Plants/Tomato/\
SL2.50ch_from_sc.agp

## My lib
export libdir=/nfs/panda/ensemblgenomes/apis/ensembl/78

## This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR)...
source ${libdir}/setup.sh

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

export core_server=mysql-prod-1-ensrw

$core_server mysqladmin CREATE $dbname

$core_server $dbname < $ENSEMBL_ROOT_DIR/ensembl/sql/table.sql

## Why was I born to suffer?
perl \
    $ENSEMBL_ROOT_DIR/ensembl-production/scripts/production_database/populate_production_db_tables.pl \
    $($core_server --details script) \
    $( mysql-pan-1 --details script_m ) \
    -d $dbname -dp /tmp

perl \
    $ENSEMBL_ROOT_DIR/ensembl-pipeline/scripts/load_seq_region.pl \
    $($core_server --details script_db) \
    --dbname $dbname \
    --rank 2 \
    --coord_system_name scaffold \
    --coord_system_version SL2.50 \
    --default_version \
    --sequence_level \
    --fasta_file $fasta

perl \
    $ENSEMBL_ROOT_DIR/ensembl-pipeline/scripts/load_seq_region.pl \
    $($core_server --details script_db) \
    --dbname $dbname \
    --rank 1 \
    --coord_system_name chromosome \
    --coord_system_version SL2.50 \
    --default_version \
    --agp_file $myagp

## FALAFFLE
INSERT INTO seq_region_synonym (seq_region_id, synonym)
SELECT seq_region_id, name FROM seq_region
WHERE coord_system_id = 2;

UPDATE seq_region SET name = RIGHT(name, 2) + 0
WHERE coord_system_id = 2;

perl \
    $ENSEMBL_ROOT_DIR/ensembl-pipeline/scripts/load_agp.pl \
    $($core_server --details script_db) \
    --dbname $dbname \
    --assembled_name chromosome \
    --assembled_version SL2.50 \
    --component_name scaffold \
    --agp_file $myagp


perl \
    $ENSEMBL_ROOT_DIR/ensembl-pipeline/scripts/set_toplevel.pl \
    $($core_server --details script_db) \
    --dbname $dbname

