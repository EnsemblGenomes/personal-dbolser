list=~/Plants/plant_list-29.txt

SQL='
  SELECT
    COUNT(*),
    source,
    analysis_id,
    logic_name,
    ad.description
  FROM
    gene
  LEFT JOIN
    analysis
  USING
    (analysis_id)
  LEFT JOIN
    analysis_description ad
  USING
    (analysis_id)
  WHERE
    source = "ensembl"
  GROUP BY
    source, analysis_id;
'

while read -r db; do
    echo $db

    mysql-staging-1 $db --table -e "$SQL1"

    echo
done \
    < <( grep -P "core|otherfeatures" $list ) \
    > FFFFFFFFFFFFFFFFF


## FFFFFFFFFFFFFFFFF

SQL1="
  SELECT
    COUNT(*)
  FROM gene INNER JOIN transcript USING (gene_id)
  WHERE gene.analysis_id != transcript.analysis_id;
"

SQL2="
  SELECT
    COUNT(*)
  FROM gene INNER JOIN transcript USING (gene_id)
  WHERE gene.source != transcript.source;
"

while read -r db; do
    echo $db

    mysql-staging-1 $db -Ne "$SQL2"

    echo
done \
    < <( grep -P "core|otherfeatures" $list )



SQL3="
  UPDATE gene INNER JOIN transcript USING (gene_id)
  SET transcript.source = gene.source;
"

while read -r db; do
    echo $db

    mysql-staging-1-ensrw $db --table -e "$SQL3"

    echo
done \
    < <( grep -P "core|otherfeatures" $list )














SQLx="
  UPDATE
    gene
  INNER JOIN
    analysis
  USING
    (analysis_id)
  INNER JOIN
    analysis_description ad
  USING
    (analysis_id)
"

SQLe="
  $SQLx
  SET
    source = \"ena\"
  WHERE
    logic_name = \"ena\"
"

SQLer="
  $SQLx
  SET
    source = \"ena\"
  WHERE
    logic_name = \"ena_rna\"
"

SQLeg="
  $SQLx
  SET
    source = \"ensembl_genomes\"
  WHERE
    logic_name = \"ncrna_eg\"
"






while read -r db; do
    echo $db

    mysql-staging-1-ensrw $db -e "$SQLe; $SQLer; $SQLeg"

    echo
done \
    < <( grep -P "core|otherfeatures" $list )
