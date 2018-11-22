## See:
## 

## Screen?

## BSHELL (non-hive pipeline)

## CONFIG
#species=brachypodium_distachyon
#species=hordeum_vulgare
#species=oryza_glaberrima
#species=oryza_indica
#species=oryza_sativa
species=solanum_lycopersicum
#species=sorghum_bicolor
#species=vitis_vinifera
#species=zea_mays
#species=triticum_aestivum

#export core_server=mysql-staging-1-ensrw
#export core_server=mysql-staging-2-ensrw
#core_server=mysql-prod-1-ensrw
core_server=mysql-prod-2-ensrw

eval $($core_server --details env_DB)



# Central checkout
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/79/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/80/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/84/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/85/setup.sh

## Or mine
#libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl
#libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-93
libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-95

# This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR):
source ${libdir}/setup.sh

## Check
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Script
script_dir=${ENSEMBL_ROOT_DIR}/ensembl-variation/scripts/import

## Registry
registry=${HOME}/Registries/registry.${core_server}.pm



## OK

## Should truncate the compressed tables first!

# e.g. 
# RENAME TABLE compressed_genotype_region TO   compressed_genotype_region_bk;
# RENAME TABLE compressed_genotype_var    TO   compressed_genotype_var_bk   ;
# CREATE TABLE compressed_genotype_region LIKE compressed_genotype_region_bk;
# CREATE TABLE compressed_genotype_var    LIKE compressed_genotype_var_bk   ;

## compressed_genotype_var

#echo \
time \
  perl -I $script_dir \
    $script_dir/compress_genotypes_by_var.pl \
    -tmpdir /tmp/ -tmpfile ffs \
    -registry ${registry} \
    -species  $species \
    -table tmp_sample_genotype_single_bp

time \
  perl -I $script_dir \
    $script_dir/compress_genotypes_by_var.pl \
    -tmpdir /tmp/ -tmpfile ffs \
    -registry ${registry} \
    -species  $species \
    -table     sample_genotype_multiple_bp



## compressed_genotype_region

#echo \
time \
  perl -I $script_dir \
    $script_dir/compress_genotypes_by_region.pl \
    -tmpdir /tmp/ -tmpfile ffs \
    -registry ${registry} \
    -species  $species \
    -table tmp_sample_genotype_single_bp

time \
  perl -I $script_dir \
    $script_dir/compress_genotypes_by_region.pl \
    -tmpdir /tmp/ -tmpfile ffs \
    -registry ${registry} \
    -species  $species \
    -table     sample_genotype_multiple_bp
