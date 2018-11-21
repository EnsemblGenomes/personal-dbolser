
## Just check we're starting from the same place
#SERVER=mysql-staging-1; LIST=plant_21_db.list
SERVER=mysql-staging-2; LIST=plant_20_db.list

table=gene
#table=transcript

SQL="
  SELECT
    external_db_id,
    IF(display_xref_id IS NULL, 1, 0) AS IS_NULL,
    COUNT(*)
  FROM
    ${table}
  LEFT JOIN
    xref display
  ON display_xref_id =
     display.xref_id
  GROUP BY
    IS_NULL,
    external_db_id
  ;
"

while read -r db; do
    echo $db
    $SERVER $db --table -e "${SQL}"
    echo; echo;
done \
    < <( grep _core_ ${LIST} ) \
    > display_xref-${table}-${SERVER}.thing





##
## Fix (what we can) by simply dumping back from S2
##

SERVER1=mysql-staging-1-ensrw
SERVER2=mysql-staging-2

table=gene
table=transcript

SQL2="
  SELECT DISTINCT
    display.*
  FROM
    ${table}
  INNER JOIN
    xref display
  ON display_xref_id =
     display.xref_id
  ;
"

SQL1="
  ## Rows with missing display xrefs 
  DROP TABLE IF EXISTS   temp_scrunch;
  CREATE TEMPORARY TABLE temp_scrunch (
    PRIMARY KEY (${table}_id))
  AS
  SELECT
    ${table}_id
  FROM
    ${table}
  LEFT JOIN
    xref display
  ON display_xref_id =
     display.xref_id
  WHERE
    display_xref_id IS NOT NULL
  AND
    display.xref_id IS     NULL
  ;

  SELECT COUNT(*) FROM temp_scrunch;

  ## Load xrefs from staging 2
  DROP             TABLE IF EXISTS temp_puke;
  CREATE TEMPORARY TABLE           temp_puke (
    PRIMARY KEY (xref_id),
    UNIQUE INDEX (dbprimary_acc, external_db_id, info_type, info_text, version)
  )
  AS SELECT * FROM xref LIMIT 0;
  
  LOAD DATA LOCAL INFILE \"${PWD}/puke\" INTO TABLE temp_puke;

  SELECT COUNT(*) FROM temp_puke;
"

SQL1b="
  ## Map what we can from the old to the new XRef
  SELECT COUNT(*) FROM temp_puke
  INNER JOIN xref
  USING (dbprimary_acc, external_db_id, info_type, info_text, version);

  SELECT COUNT(*) FROM ${table} WHERE display_xref_id IS NOT NULL;

  SELECT COUNT(*) FROM ${table} INNER JOIN temp_puke display
  ON display_xref_id = display.xref_id;

  ## Oh boy...
  SELECT COUNT(*) FROM
  ${table} INNER JOIN temp_puke display
  ON display_xref_id = display.xref_id
  INNER JOIN xref USING
  (dbprimary_acc, external_db_id, info_type, info_text)
  WHERE display.version = xref.version;

  UPDATE
  ${table} INNER JOIN temp_puke display
  ON display_xref_id = display.xref_id
  INNER JOIN xref USING
  (dbprimary_acc, external_db_id, info_type, info_text)
  SET display_xref_id = xref.xref_id
  WHERE display.version = xref.version;
"







SQL1c="
  ## This will be our insert...
  INSERT INTO
    xref
  SELECT DISTINCT
    #COUNT(*)
    display.*
  FROM
    temp_scrunch INNER JOIN ${table} USING (${table}_id)
    INNER JOIN temp_puke display ON display_xref_id = display.xref_id;
"




LIST=plant_20_db.list
#LIST=plant_21_db.list

while read -r db; do
    echo $db
    
    ## DEBUGGING
    #db=brachypodium_distachyon_core_20_73_12
    
    $SERVER2 $db -Ne "${SQL2}" > puke
    wc -l puke
    
    db=${db/_20_73_/_21_74_}

    #$SERVER1 $db --table -e "${SQL1} ${SQL1b}"
    $SERVER1 $db --table -e "${SQL1} ${SQL1c}"

    echo; echo;
done \
    < <( grep _core_ ${LIST} \
    | grep -Pv "aegilops_tauschii|hordeum_vulgare|triticum_urartu" ) \
    > display_xref-2.thing







