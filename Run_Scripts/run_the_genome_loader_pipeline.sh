
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## ENA+GenomeLoader+QuickStart

## Screen?
## BSHELL? May need more than the default amount of memory!

## Adding a component?
species=hordeum_vulgare_core_36_89_3
pt=KC912687.1
mt=AP017301.1


## Species config
species=solanum_lycopersicum
gca=GCA_000188115.2

species=oryza_indica
gca=GCA_000004655.2

species=beta_vulgaris
gca=GCA_000511025.1

species=oryza_longistaminata
gca=GCA_000789195.1

species=prunus_persica
gca=GCA_000346465.1

species=zea_mays_nrgene
gca=GCA_001644905

species=sorghum_bicolor
gca=GCA_000003195.2
gca=GCA_000003195.3
mt=DQ984518.1

species=corchorus_capsularis
gca=GCA_001974805.1

species=manihot_esculenta
gca=GCA_001659605.1

species=spinacia_oleracea
gca=GCA_000510995.2

species=triticum_dicoccoides
gca=GCA_002162155.1

species=helianthus_annuus
gca=GCA_002127325.1

species=gossypium_raimondii
gca=GCA_000327365.1

species=phaseolus_vulgaris
gca=GCA_000499845.1

species=phoenix_dactylifera
gca=GCA_000413155.1



## and
division=EnsemblPlants
eg_version=39



## Generic config
bse=/nfs/panda/ensemblgenomes/production
dir=$bse/eg-genomeloader/genomeloader_exec/dist
tar=$dir/genomeloader-dist.tar.gz

ll $tar

cd ~/EG_Places/Devel/GenomeLoader/

mkdir $gca
tar xvzf $tar -C $gca #--strip 1

cd $gca/genomeloader

## DO IT!
echo \
time \
./bin/load_genome.sh \
    -s ${gca%.*} \
    -n ${species} \
    -D ${division} \
    -v ${eg_version} \

## NOTE: The database used to create or update the core is configured
## in etc/eg_genomeloader_config.xml, but defaults to prod-1. The
## value in the config file can be overridden with "-e <Java
## connection URL>" on the command line

## e.g. -e "jdbc:mysql://mysql-eg-prod-2.ebi.ac.uk:4238/mydb?user=ensrw&password=xxxxxxxx"
## e.g. -e "jdbc:mysql://mysql-eg-prod-2.ebi.ac.uk:4239/sorghum_bicolor_core_32_85_15?user=ensrw&password=xxxxxxxx"

Note, see this page for Ensembl API configuration:
https://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
ENA+GenomeLoader+Pipeline#ENAGenomeLoaderPipeline-Perlsetup









## DO IT AGAIN!

## Note $species here is actually the database you want to load into!
species=sorghum_bicolor_v2_mt
species=hordeum_vulgare_v2_mt



## Skip if you already have a core...

## CREATE DATBASE
mysql-prod-1-ensrw mysqladmin CREATE $species

## LOAD CORE TABLES
mysql-prod-1-ensrw $species < $ENSEMBL_ROOT_DIR/ensembl/sql/table.sql

## LOAD CVs
perl $ENSEMBL_ROOT_DIR/ensembl-production/\
scripts/production_database/populate_production_db_tables.pl \
    $(mysql-prod-1-ensrw --details script) \
    $(mysql-pan-prod     --details prefix_m) \
    --database $species \
    --dumppath /tmp/prod_db_tables/ \
    --dropbaks

echo \
time \
./bin/add_component.sh \
    -a ${mt%.*} \
    -d ${species} \
    -c ./etc/eg_genomeloader_config.xml




# echo \
# time \
# ./bin/add_component.sh \
#     -a ${mt%.*} \
#     -d ${species} \
#     -D ${division} \
#     -v ${eg_version} \
#     -c ./etc/eg_genomeloader_config.xml






diff -u bin/setup_perl.sh~ bin/setup_perl.sh
--- bin/setup_perl.sh~  2015-12-16 12:33:45.000000000 +0000
+++ bin/setup_perl.sh   2017-06-13 18:41:04.349568366 +0100
@@ -13,5 +13,6 @@
 EMBOSS_HOME=/sw/arch/pkg/EMBOSS-5.0.0/
 unset PERL5LIB
 . $dir/setup_env.sh
+source /nfs/software/ensembl/RHEL7/envs/basic.sh
 PERLBIN=$(which perl)
 export LD_LIBRARY_PATH ORACLE_HOME PERL5LIB PERLBIN PERLINC EMBOSS_HOME ENSEMBL_MISC_SCRIPTS ENSEMBL_BASE
