
## Compare this release to the last in terms of Uniprot/SPTREMBL and
## Uniprot/SWISSPROT

list=plant_24_db.list
server=mysql-staging-2

#list=plant_25_db.list
#server=mysql-staging-1

SQL='
  SELECT
    db_name,
    external_db_id,
    COUNT(DISTINCT xref_id)    AS X,
    COUNT(DISTINCT ensembl_id) AS O,
    COUNT(DISTINCT ensembl_object_type) AS Z,
    COUNT(*) AS N
  FROM
    xref
  INNER JOIN
    object_xref
  USING
    (xref_id)
  INNER JOIN
    external_db
  USING
    (external_db_id)
  WHERE
    db_name IN ("Uniprot/SPTREMBL", "Uniprot/SWISSPROT")
  GROUP BY
    external_db_id
  WITH
    ROLLUP
  ;
'

while read -r db; do
    echo $db;
    $server $db -e "$SQL"

    echo
done \
    < <( grep _core_ $list )



__END__

list=plant_25_db.list
serv1=mysql-staging-1-ensrw
serv2=mysql-staging-2

while read -r db; do
    echo $db
    
    $serv2 mysqldump --skip-opt --no-create-info --insert-ignore \
        ${db/_25_78_/_24_77_} xref object_xref \
        -w 'xref_id IN (SELECT xref_id FROM xref
                        WHERE external_db_id IN (2000, 2200))' \
        | $serv1 $db

    $serv2 mysqldump --skip-opt --no-create-info --insert-ignore \
        ${db/_25_78_/_24_77_} identity_xref \
        | $serv1 $db

done \
    < <( grep _core_ $list )

