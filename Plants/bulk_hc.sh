
source /homes/dbolser/EG_Places/Devel/lib/libensembl-95/setup.sh

release=42

# $ENSEMBL_ROOT_DIR/ensembl-production/scripts/process_division.sh \
#     EPl mysql-pan-prod ensembl_production $release \
#     > db_to_copy.txt
# 
# list=db_to_copy.txt

list=~/Plants/Lists/plant_list-42.txt
#list=~/Plants/funcgen.list

ENDPOINT=http://eg-prod-01.ebi.ac.uk:7000/hc/

SERVER=$(         mysql-prod-2             details url)
PRODUCTION=$(     mysql-pan-prod           details url)
#STAGING=$(        mysql-staging-1          details url)
STAGING=$(        mysql-staging-2          details url)
LIVE=$(           mysql-publicsql          details url)

#COMPARA_MASTER=$( mysql-pan-prod           details url)
COMPARA_MASTER=$( mysql-ens-compara-prod-5 details url)
COMPARA_MASTER=${COMPARA_MASTER}ensembl_compara_master_plants


unset GROUP
unset TEST

#GROUP=EGCoreHandover
#GROUP=EGCore
#GROUP=FuncgenPostProbemapping
#GROUP=FuncgenIntegrity
#GROUP=FuncgenRelease
#TEST=DensityFeatures
#TEST=BlanksInsteadOfNulls
#TEST=CoreForeignKeys
#TEST=InterproDescriptions
#TEST=AssemblyMapping
#TEST=GeneSource
TEST=SeqRegionsConsistentWithComparaMaster

LABEL=''
GREST=''

if [ ! -z ${GROUP} ]; then
    echo "USING GROUP $GROUP"
    GREST="$GREST --hc_groups $GROUP"
    LABEL="$LABEL-$GROUP"
fi


if [ ! -z ${TEST} ]; then
    echo "USING TEST $TEST"
    GREST="$GREST --hc_names $TEST"
    LABEL="$LABEL-$TEST"
fi




DATA_FILE_PATH=/nfs/panda/ensembl/production/ensemblftp/data_files/

#TAG=pre_handover_hc_bulk_run
TAG=one_off_test-"$(date +%Y%m%d%H%M%S)"

BASE_DIR=/homes/dbolser/EG_Places/Devel/lib/ensembl-prodinf-core

time \
while read -r db; do

    echo $SERVER$db

    #echo \
    python \
        $BASE_DIR/ensembl_prodinf/hc_client.py \
        --uri $ENDPOINT \
        --action submit \
        --tag "$TAG" \
        --db_uri "${SERVER}${db}" \
        --production_uri "${PRODUCTION}ensembl_production" \
        --staging_uri $STAGING \
        --live_uri $LIVE \
        --compara_uri "${COMPARA_MASTER}" \
        $GREST \
        --data_files_path $DATA_FILE_PATH \
        --email ${USER}@ebi.ac.uk
    echo

done \
    < <( grep _core_ $list )


#    < $list
#    < <( grep _funcgen_ $list )



echo $TAG; echo $TAG; echo $TAG; 
# one_off_test-2018-07-20T09:45:16+01:00
# one_off_test-20180828090317



## Get results...

outfile=results$LABEL-$release.json

echo " \
python \
    $BASE_DIR/ensembl_prodinf/hc_client.py \
    --uri $ENDPOINT \
    --action collate \
    --tag "$TAG" \
    --output_file $outfile \
    2>&1 | grep $TAG
"

echo " \
cat $outfile | json_pp > $outfile.pp
"


## Delete jobs...

# echo \
# python \
#     $BASE_DIR/ensembl_prodinf/hc_client.py \
#     --uri $ENDPOINT \
#     --action delete \
#     --tag "$TAG"
