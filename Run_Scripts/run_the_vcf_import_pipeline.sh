
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh 
source /nfs/production/panda/ensemblgenomes/development/dbolser/lib/libensembl/setup.sh

#dbcmd=mysql-prod-2-ensrw
dbcmd=mysql-staging-2-ensrw

#database=solanum_lycopersicum_variation_24_77_240
database=triticum_aestivum_variation_32_85_3

#file=/nfs/nobackup2/ensemblgenomes/grabmuel/tomato/vcftools_merged_acc.vcf
#file=~/EG_Places/Data/Tomato/vcftools_merged_acc.vcf.gz
file=axiom.vcf

## TESTING!
#gunzip -c $file | head -n 100 > /tmp/puke.vcf
#file=/tmp/puke.vcf

## Trying to make things faster...
#time cp -i ${file}* /tmp/
#file=/tmp/$(basename ${file})



$dbcmd -e "DROP  DATABASE $database"
$dbcmd -e "CREATE DATABASE $database"
$dbcmd $database < $ENSEMBL_ROOT_DIR/ensembl-variation/sql/table.sql
$dbcmd $database < $ENSEMBL_ROOT_DIR/ensembl-variation/sql/attrib_entries.sql

time \
mysqldump \
    --host mysql-eg-staging-2.ebi.ac.uk --port 4275 \
    --user ensrw -pxxxxxxxx \
    ${database/_variation_/_core_} coord_system seq_region \
    | $dbcmd $database



## Only needed if forking

## Fix a problem with multiple processes, pre-populate allele_code

# gunzip -c $file | grep -v '^#' | perl -ane '
#   $x{$F[3]}++; $x{$_}++ for split(/,/, $F[4]); END{print "$_\n" for keys %x}
# ' > allele.list

# $dbcmd $database -e \
#     'LOAD DATA LOCAL INFILE "allele.list" INTO TABLE allele_code (allele)'



## GO

## Only needed if forking
#PATH=${PATH}:/nfs/panda/ensemblgenomes/external/tabix/bin

source=CerealsDB
population=Axiom

echo \
time \
perl -I \
    $ENSEMBL_ROOT_DIR/ensembl-variation/scripts/import \
    $ENSEMBL_ROOT_DIR/ensembl-variation/scripts/import/import_vcf.pl \
    --input_file $file \
    --species ${database%_variation_*} \
    --source $source \
    --population $population \
    --mart_genotypes \
    --tmpdir /tmp \
    $($dbcmd --details script)

#    --fork 12
#    --test 100 \
