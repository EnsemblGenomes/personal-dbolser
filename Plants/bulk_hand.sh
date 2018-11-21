
source /homes/dbolser/EG_Places/Devel/lib/libensembl-95/setup.sh

release=42

# $ENSEMBL_ROOT_DIR/ensembl-production/scripts/process_division.sh \
#     EPl mysql-pan-prod ensembl_production $release \
#     > db_to_copy.txt
# 
# list=db_to_copy.txt

list=~/Plants/Lists/plant_list-42.txt
#list=~/Plants/funcgen.list

ENDPOINT=http://eg-prod-01.ebi.ac.uk:7000/handover

SERVER=$(         mysql-prod-2             details url)

EMAIL=${USER}@ebi.ac.uk
UPDATE_TYPE=other
#UPDATE_TYPE=new_genome
#UPDATE_TYPE=new_genebuild
#UPDATE_TYPE=new_assembly
DESCRIPTION="And not forgetting... (seriously, I nearly forgot!)"

BASE_DIR=/homes/dbolser/EG_Places/Devel/lib/ensembl-prodinf-core

time \
while read -r db; do

    echo $SERVER$db

    python $BASE_DIR/ensembl_prodinf/handover_client.py \
        --action submit \
        --uri ${ENDPOINT} \
        --src_uri "${SERVER}${db}" \
        --email "${EMAIL}" \
        --type "${UPDATE_TYPE}" \
        --description "${DESCRIPTION}";

    echo

done \
    < <( grep _variation_ $list | grep "solanum_lycopersicum_variation_42_95_3" )


#    < <( grep _core_ $list | grep -vP "arabidopsis_halleri_core_42_95_1|aegilops_tauschii_core_42_95_3|glycine_max_core_42_95_4|solanum_lycopersicum_core_42_95_3|lupinus_angustifolius_core_42_95_1|physcomitrella_patens_core_42_95_2|vigna_radiata_core_42_95_2" )


