
source /homes/dbolser/EG_Places/Devel/lib/libensembl-94/setup.sh

release=42

$ENSEMBL_ROOT_DIR/ensembl-production/scripts/process_division.sh \
    EPl mysql-pan-prod ensembl_production $release \
    > db_to_copy.txt

# ## If needed ... sigh
# replace _40_93_ _41_94_ -- db_to_copy.txt
# replace _40_93  _41_94  -- db_to_copy.txt
# replace _40     _41     -- db_to_copy.txt

list=db_to_copy.txt
list=~/Plants/Lists/plant_list-41.txt

#staging_db=$(mysql-staging-1 details url)
staging_db=$(mysql-staging-2 details url)

#prod_db=$(mysql-prod-1-ensrw details url)
prod_db=$(mysql-prod-2-ensrw details url)

ENDPOINT=http://eg-prod-01.ebi.ac.uk:7000/dbcopy/

while read -r db; do
    #echo \
    time \
    $ENSEMBL_ROOT_DIR/../ensembl-prodinf-core/ensembl_prodinf/db_copy_client.py \
        --action submit \
        --uri ${ENDPOINT} \
        --source_db_uri "${staging_db}${db}" \
        --target_db_uri "${prod_db}${db}"
    echo
done \
    < <( grep _core_ $list )



    < <( grep _otherfeatures_ $list )
