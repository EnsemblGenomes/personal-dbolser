## PROTEIN ONE
SQL="
SELECT
  logic_name, COUNT(*)
FROM
  protein_feature
LEFT JOIN
  analysis
USING
  (analysis_id)
GROUP BY
  analysis_id
ORDER BY
  logic_name
"

## XREF ONE
SQL="
SELECT
  COUNT(*),
  COUNT(DISTINCT xref.xref_id) AS XREF,
  COUNT(DISTINCT ensembl_id)   AS OBJS,
  linkage_type,
  ensembl_object_type,
  analysis_id,
    xref.external_db_id,
  source.external_db_id,
  db_name
FROM
  ontology_xref
INNER JOIN
  object_xref USING (object_xref_id)
INNER JOIN
  xref        USING (xref_id)
INNER JOIN
  xref source
ON
  source_xref_id =
  source.xref_id
INNER JOIN
  external_db sourcx
ON
  source.external_db_id =
  sourcx.external_db_id
WHERE 
    xref.external_db_id = 1000
AND
  source.external_db_id IN (2000, 2200)
#GROUP BY
#  linkage_type,
#  ensembl_object_type,
#  analysis_id,
#    xref.external_db_id,
#  source.external_db_id;
"

## XREF TWO
#SQL="
#  SELECT external_db_id, COUNT(*) FROM xref GROUP BY external_db_id"

## RUNEM
#SERVER=mysql-staging-1
SERVER=mysql-staging-2
#SERVER=mysql-devel-2

LIST=plant_20_db.list
#LIST=plant_21_db.list

while read -r db; do
    echo $db
    ${SERVER} $db --table -e "${SQL}"
    echo; echo
done \
    < <( grep _core_ ${LIST} ) \
    > $SERVER.thing







# ## TRUNCATE OLD XRefs...

# SERVER=mysql-staging-1-ensrw

# SQL="
# DELETE
#   ontology_xref,
#   object_xref,
#   xref,
#   source
# FROM
#   ontology_xref
# INNER JOIN
#   object_xref USING (object_xref_id)
# INNER JOIN
#   xref        USING (xref_id)
# INNER JOIN
#     xref source
# ON
#   source_xref_id =
#   source.xref_id
# WHERE
#   xref.external_db_id = 1000
# "

# ## LOOK FOR OTHERS...
# SQL="
# SELECT
#   COUNT(*)
# FROM
#   ontology_xref
# INNER JOIN
#   object_xref USING (object_xref_id)
# "

# ## TRY AGAIN
# SQL="
# DELETE
#   ontology_xref
# FROM
#   ontology_xref
# LEFT JOIN
#   object_xref USING (object_xref_id)
# WHERE
#   object_xref.object_xref_id IS NULL
# ;
# DELETE
#   ontology_xref,
#   object_xref
# FROM
#   ontology_xref
# INNER JOIN
#   object_xref USING (object_xref_id)
# LEFT JOIN
#   xref        USING (       xref_id)
# WHERE
#   xref.xref_id IS NULL
# ;
# "


# while read -r db; do
#     echo $db
#     ${SERVER} $db --table -e "${SQL}"
#     echo; echo
# done \
#     < <( grep _core_ plant_21_db.list )



# ## NOW ALL DIE...
# SQL='
# SELECT "ox", MAX(object_xref_id) FROM object_xref UNION SELECT "x", MAX(xref_id) from xref
# '


# ## PUPULATE XREFS FROM A te B...

# ## The alternative is an API script, bitch.

# SERVER1=mysql-devel-2
# SERVER2=mysql-staging-1-ensrw

# A='SELECT DISTINCT
#      object_xref_id + 20000000,
#      source_xref_id + 20000000,
#      linkage_type'
# B='SELECT DISTINCT
#      object_xref_id + 20000000,
#      ensembl_id,
#      ensembl_object_type,
#      xref.xref_id   + 20000000,
#      linkage_annotation,
#      analysis_id'
# C='SELECT DISTINCT
#      xref.xref_id   + 20000000,
#      xref.external_db_id,
#      xref.dbprimary_acc,
#      xref.display_label,
#      xref.version,
#      xref.description,
#      xref.info_type,
#      xref.info_text'
# D='SELECT DISTINCT
#      source.xref_id + 20000000,
#      source.external_db_id,
#      source.dbprimary_acc,
#      source.display_label,
#      source.version,
#      source.description,
#      source.info_type,
#      source.info_text'

# BASE='
# FROM
#   ontology_xref
# INNER JOIN
#   object_xref USING (object_xref_id)
# INNER JOIN
#   xref        USING (xref_id)
# INNER JOIN
#     xref source
# ON
#   source_xref_id =
#   source.xref_id
# WHERE ## GO GO GO!
#   xref.external_db_id = 1000
# '

# while read -r db; do
#     echo $db
#     $SERVER1 ${db} -Ne "${A}${BASE}" > A.file #&& $SERVER2 --show-warnings ${db} -e 'LOAD DATA LOCAL INFILE "A.file" INTO TABLE ontology_xref'
#     $SERVER1 ${db} -Ne "${B}${BASE}" > B.file #&& $SERVER2 --show-warnings ${db} -e 'LOAD DATA LOCAL INFILE "B.file" INTO TABLE object_xref'
#     $SERVER1 ${db} -Ne "${C}${BASE}" > C.file #&& $SERVER2 --show-warnings ${db} -e 'LOAD DATA LOCAL INFILE "C.file" INTO TABLE xref'
#     $SERVER1 ${db} -Ne "${D}${BASE}" > D.file #&& $SERVER2 --show-warnings ${db} -e 'LOAD DATA LOCAL INFILE "D.file" INTO TABLE xref'
#     echo; echo
# done \
#     < <( grep _core_ plant_21_db.list )
