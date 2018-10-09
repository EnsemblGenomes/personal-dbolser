
## See EG_Places/Devel/run_the_attached_vcf_import_pipeline.sh

## Screen and bshell?

## Set up the Ensembl Perl environment
libdir=/nfs/panda/ensemblgenomes/apis/ensembl/83
source ${libdir}/setup.sh

## CONFIG
dbcmd=mysql-prod-2-ensrw

core_db=oryza_sativa_core_31_84_7
variation_db=oryza_sativa_variation_30_83_7
species=oryza_sativa



## SETUP
$dbcmd -e "CREATE DATABASE $variation_db"

$dbcmd $variation_db < $ENSEMBL_ROOT_DIR/ensembl-variation/sql/table.sql
$dbcmd $variation_db < $ENSEMBL_ROOT_DIR/ensembl-variation/sql/attrib_entries.sql

## Oh for the love of Jesus
$dbcmd $variation_db < \
    <( mysqldump $(${dbcmd/-ensrw/} --details script) \
    $core_db coord_system seq_region )

$dbcmd $variation_db -e '
  INSERT INTO meta (species_id,meta_key,meta_value) VALUES
  (1, "species.production_name", "$species")'



registry=/homes/dbolser/Registries/p2pan.reg
vcf=/homes/dbolser/EG_Places/Devel/Species/Rice/VCF/merged2.vcf
vcf=/homes/dbolser/EG_Places/Devel/Species/Rice/VCF/merged3.vcf

## DEBUGGING
head -n 102 $vcf > puke.vcf
vcf=puke.vcf

perl \
    -I $ENSEMBL_ROOT_DIR/ensembl-variation/scripts/import \
    $ENSEMBL_ROOT_DIR/ensembl-variation/scripts/import/import_vcf.pl \
    --input_file $vcf \
    --species $species \
    --source test_load \
    --population test_popu \
    --tmpdir /tmp \
    --registry  ${registry}

#    --test 100 \

## Since we don't have any genotypes in our file anyway...

#    --skip_tables population_genotype
#    --skip_tables population_genotype,sample_genotype,compressed_genotype_var

TRUNCATE TABLE allele; TRUNCATE TABLE allele_code; TRUNCATE TABLE meta_coord; TRUNCATE TABLE population; TRUNCATE TABLE source; TRUNCATE TABLE variation; TRUNCATE TABLE variation_feature;
