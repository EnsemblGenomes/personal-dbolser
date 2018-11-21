#!/bin/bash

## EXAMPLE USAGE (CONFIGURE SERVER, SQL, and DB VERSION BELOW):

# ./patch_plants.sh <(grep core               plant_17_db.list)
# ./patch_plants.sh <(grep otherfeatures      plant_17_db.list)
# ./patch_plants.sh <(grep variation          plant_17_db.list)
# ./patch_plants.sh <(grep zea_mays_variation plant_17_db.list)

# ./patch_plants.sh <(echo oryza_sativa_core_17_70_6_tmp)


### CONFIGURATION

## DEFINE THE SERVER!

 SERVER=mysql-staging-1-ensrw
#SERVER=mysql-staging-2-ensrw


## LOCATE THE PATCHING SCRIPTS

SQL_DIR=$HOME/cvs_cos/ensembl/sql
#SQL_DIR=$HOME/cvs_cos/ensembl-variation/sql
#SQL_DIR=$HOME/cvs_cos/ensembl-functgenomics/sql

## VERSION
#PATCH='66_67'
#PATCH='67_68'
#PATCH='68_69'
 PATCH='69_70'






### GO TIME

## Read DB list file
DBLIST=${1:?Pass a list of databases to patch!}

## SQL TO ECHO THE CURRENT SCHEMA VERSION:
VER_SQL='
 (SELECT * FROM meta
  WHERE META_KEY = "schema_version")
 UNION
 (SELECT * FROM meta
  WHERE META_KEY = "patch"
  ORDER BY meta_id DESC
  LIMIT 1)'



## Apply the patches...

while read -r DB; do
    echo "Doing $DB"
    
    ## Echo current version
    $SERVER $DB -Ne "$VER_SQL" -t
    
    ## Apply all patches
    echo 'Patching'
    for P in $SQL_DIR/patch_${PATCH}_x.sql; do
    #for P in $SQL_DIR/patch_${PATCH}_*.sql; do
	echo "        ${P}"
        $SERVER $DB < ${P}
    done
    
    ## Echo current version
    $SERVER $DB -Ne "$VER_SQL" -t
    
    echo
    echo
    #break
done \
    < $DBLIST

echo OK
