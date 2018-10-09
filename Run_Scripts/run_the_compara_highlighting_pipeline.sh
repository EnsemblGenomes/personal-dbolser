
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Running+Gene+Tree+Highlighting


# ## Note from sync to fix?
# WARNING: Table 'accu' exists on TARGET but not on SOURCE!
# WARNING: Table 'hive_meta' exists on TARGET but not on SOURCE!
# WARNING: Table 'pipeline_wide_parameters' exists on TARGET but not on SOURCE!
# WARNING: Table 'worker_resource_usage' exists on TARGET but not on SOURCE!




## Ensembl
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/79/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/80/setup.sh # or
source /nfs/panda/ensemblgenomes/apis/ensembl/83/setup.sh # or

## Check your checkout
#source ${PWD}/lib/libensembl/setup.sh

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Scripts path
scripts=$ENSEMBL_ROOT_DIR/ensembl-compara/scripts/xref_association

## Note that the script needs to find all cores, so prolly easyest to
## sync to staging and run this final step there.




## Registry (nurt, we need pan-1 species for plants)...
registry=~/Registries/staging_2.reg
#registry=/homes/dbolser/Registries/hh+pan.reg

#comp_host=mysql-hive-ensrw

comp_host=mysql-staging-2-ensrw
comp_db=ensembl_compara_plants_30_83

# ## Populate the external_db table...
# mysql-pan-1 ensembl_production -Ne \
#     'SELECT * FROM external_db' > puke.tsv

# replace 'NULL' '\N' -- puke.tsv

# $comp_host $comp_db -e \
#     'LOAD DATA LOCAL INFILE "puke.tsv" INTO TABLE external_db'



# ## The GO terms failed like this, ended up running both as below...

# ## Do GO terms
# time \
# perl \
#   -I $ENSEMBL_ROOT_DIR/ensembl-compara/modules \
#   -I $ENSEMBL_ROOT_DIR/ensembl/modules \
#     $scripts/load_go_associations.pl \
#     -reg_conf ${registry} \
#     -compara $comp_db

# ## Do InterPro accessions
# time \
# perl \
#   -I $ENSEMBL_ROOT_DIR/ensembl-compara/modules \
#   -I $ENSEMBL_ROOT_DIR/ensembl/modules \
#     $scripts/load_interpro_associations.pl \
#     -reg_conf ${registry} \
#     -compara $comp_db



## Do GO terms again
while read -r db;
do
    species=${db%_core_*}
    time perl \
        -I $ENSEMBL_ROOT_DIR/ensembl-compara/modules \
        -I $ENSEMBL_ROOT_DIR/ensembl/modules \
        $scripts/load_go_associations.pl \
        -reg_conf ${registry} \
        -compara $comp_db \
        -species $species
done \
    < <( grep _core_ ~/Plants/plant_list-30.txt )

## Do InterPro accessions again
while read -r db;
do
    species=${db%_core_*}
    time perl \
        -I $ENSEMBL_ROOT_DIR/ensembl-compara/modules \
        -I $ENSEMBL_ROOT_DIR/ensembl/modules \
        $scripts/load_interpro_associations.pl \
        -reg_conf ${registry} \
        -compara $comp_db \
        -species $species
done \
    < <( grep _core_ ~/Plants/plant_list-30.txt )
