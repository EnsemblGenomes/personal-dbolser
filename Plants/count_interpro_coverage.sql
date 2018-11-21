

SQL='
 SELECT
   (SELECT COUNT(*) FROM translation),
   --
   COUNT(DISTINCT                               translation_id),
   COUNT(DISTINCT(IF(logic_name="seg"         , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="blastprodom" , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="gene3d"      , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="hmmpanther"  , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="ncoils"      , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="pfam"        , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="pfscan"      , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="pirsf"       , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="prints"      , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="scanprosite" , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="signalp"     , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="smart"       , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="superfamily" , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="tigrfam"     , translation_id, NULL))),
   COUNT(DISTINCT(IF(logic_name="tmhmm"       , translation_id, NULL)))
 FROM
   protein_feature
 INNER JOIN
   analysis
 USING
   (analysis_id)
 #GROUP BY
 #  analysis_id
'

#echo "$SQL"

while read -r db; do
    echo -ne "$db\t"
    mysql-staging-2 $db -Ne "$SQL"
done \
    < <(grep _core_ plant_22_db.list)

