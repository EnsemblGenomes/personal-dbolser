pipeline=xref_gpr
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh
#source /homes/dbolser/EG_Places/Devel/lib/libensembl/setup.sh
source /homes/dbolser/EG_Places/Devel/lib/libensembl-95/setup.sh
libdir=/homes/dbolser/EG_Places/Devel/lib/lib-eg/eg-pipelines
export PERL5LIB=$PERL5LIB:${libdir}/modules:.
#dbserver=mysql-prod-1-ensrw
#dbserver=mysql-prod-2-ensrw
dbserver=mysql-prod-3-ensrw
hive_server=mysql-prod-3-ensrw
#registry=~/Registries/p2pan.reg
registry=~/Registries/p3pan.reg
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
hive_db=${USER}_${pipeline}_${ensembl_version}
#run_for="-division Plants"
#run_for="-species arabidopsis_thaliana"
#run_for="-species oryza_sativa"
run_for="-species theobroma_cacao"
#xref_file=Data/Gramene_Plant_Reactome_r52_Ensembl_gene_list.tab
#xref_file=Data/Ensembl2PlantReactome_PE_Pathway.txt
#xref_file=Data/Ensembl2PlantReactome_PE_Pathway-rice.txt

# Get these files from http://plantreactome.gramene.org/index.php?option=com_content&view=article&id=18&Itemid=242&lang=en

xref_reac_file=Data/Ensembl2PlantReactome.txt
xref_path_file=Data/Ensembl2PlantReactomeReactions.txt


tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines/\
${USER}/$pipeline/$ensembl_version

mkdir -p $tmpdir
ls $tmpdir

#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::EGPipeline::PipeConfig::Xref_GPR_conf \
    $($hive_server details script) \
    -registry $registry \
    -pipeline_dir $tmpdir \
    $run_for \
    -xref_reac_file $xref_reac_file \
    -xref_path_file $xref_path_file \
    -hive_force_init 0

url=$($hive_server details url)$hive_db

echo $url; echo $url; echo $url

echo $url | xclip

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
#beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive

break
exit




# Check results...

list=~/Plants/plant_list-39.txt



## Basic sanity...
SQL="
  SELECT
    TABLE_NAME, TABLE_TYPE, ENGINE, TABLE_ROWS, UPDATE_TIME
  FROM
    information_schema.TABLES
  WHERE
    TABLE_SCHEMA = DATABASE()
  AND
    TABLE_ROWS > 0 ORDER BY UPDATE_TIME DESC
  LIMIT
    5;
"

while read -r db; do
    echo -en "$db\t"
    ${dbserver} --table $db -e "$SQL"
    echo
done \
     < <( grep _core_ $list )



## Counts (pick your db!)
SQL='
  SELECT
    db_name,
    COUNT(DISTINCT xref_id),
    COUNT(DISTINCT ensembl_id),
    COUNT(*)
  FROM
    external_db
  INNER JOIN
    xref        USING (external_db_id)
  INNER JOIN
    object_xref USING (xref_id)
  INNER JOIN
    gene ON ensembl_id = gene_id
  WHERE
    #db_name = "Plant_Reactome_Reaction";
    #db_name = "Plant_Reactome_Pathway";
'

while read -r db; do
    echo -en "$db\t"
    ${dbserver} $db -Ne "$SQL"
done \
     < <( grep _core_ $list ) | xclip




## Get counts from file

## Total per species
cut -f 8 $xref_file | sort | uniq -c | perl -ne 's/^\s+//; s/ /\t/; print' | xclip

## Unique Reactions per speceis
cut -f 1,2,8 $xref_file | sort | uniq | cut -f 2 | sort | uniq -c | perl -ne 's/^\s+//; s/ /\t/; print' | xclip

## Unique Pathways per speceis
cut -f 1,4,8 $xref_file | sort | uniq | cut -f 2 | sort | uniq -c | perl -ne 's/^\s+//; s/ /\t/; print' | xclip






### CLEANUP...


## Counts (pick your db!)
SQL='
  SELECT
    db_name,
    COUNT(DISTINCT xref_id),
    COUNT(DISTINCT ensembl_id),
    COUNT(*)
  FROM
    external_db
  INNER JOIN
    xref        USING (external_db_id)
  INNER JOIN
    object_xref USING (xref_id)
  INNER JOIN
    gene ON ensembl_id = gene_id
  WHERE
    db_name RLIKE "Reactome"
  GROUP BY
    external_db_id
'

SQL='
  DELETE
    xref, object_xref
  FROM
    external_db
  INNER JOIN
    xref        USING (external_db_id)
  INNER JOIN
    object_xref USING (xref_id)
  WHERE
    db_name = "Reactome";
'

while read -r db; do
    echo "$db"
    ${dbserver} $db -Ne "$SQL" --table
    echo
done \
     < <( grep _core_ $list ) 





aegilops_tauschii_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     967 |                        880 |      967 |
| Plant_Reactome_Pathway  |                     182 |                        880 |     1268 |
+-------------------------+-------------------------+----------------------------+----------+

amborella_trichopoda_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     711 |                        644 |      711 |
| Plant_Reactome_Pathway  |                     193 |                        644 |      914 |
+-------------------------+-------------------------+----------------------------+----------+

arabidopsis_lyrata_core_39_92_10
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1169 |                       1038 |     1169 |
| Plant_Reactome_Pathway  |                     193 |                       1038 |     1517 |
+-------------------------+-------------------------+----------------------------+----------+

arabidopsis_thaliana_core_39_92_11
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1154 |                       1021 |     1154 |
| Plant_Reactome_Pathway  |                     194 |                       1021 |     1487 |
+-------------------------+-------------------------+----------------------------+----------+

beta_vulgaris_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      53 |                       1141 |     1686 |
| Plant_Reactome_Reaction |                     844 |                        742 |      844 |
| Plant_Reactome_Pathway  |                     192 |                        742 |     1080 |
+-------------------------+-------------------------+----------------------------+----------+

brachypodium_distachyon_core_39_92_12
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1025 |                        926 |     1025 |
| Plant_Reactome_Pathway  |                     187 |                        926 |     1298 |
+-------------------------+-------------------------+----------------------------+----------+

brassica_napus_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      54 |                       4788 |     7205 |
| Plant_Reactome_Reaction |                    3305 |                       2947 |     3305 |
| Plant_Reactome_Pathway  |                     192 |                       2947 |     4296 |
+-------------------------+-------------------------+----------------------------+----------+

brassica_oleracea_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1732 |                       1528 |     1732 |
| Plant_Reactome_Pathway  |                     194 |                       1528 |     2227 |
+-------------------------+-------------------------+----------------------------+----------+

brassica_rapa_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1767 |                       1552 |     1767 |
| Plant_Reactome_Pathway  |                     191 |                       1552 |     2274 |
+-------------------------+-------------------------+----------------------------+----------+

chlamydomonas_reinhardtii_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     298 |                        261 |      298 |
| Plant_Reactome_Pathway  |                     143 |                        261 |      405 |
+-------------------------+-------------------------+----------------------------+----------+

chondrus_crispus_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      45 |                        366 |      615 |
| Plant_Reactome_Reaction |                     233 |                        192 |      233 |
| Plant_Reactome_Pathway  |                     118 |                        192 |      341 |
+-------------------------+-------------------------+----------------------------+----------+

corchorus_capsularis_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     745 |                       3929 |    15867 |
| Plant_Reactome_Reaction |                     849 |                        753 |      849 |
| Plant_Reactome_Pathway  |                     190 |                        753 |     1089 |
+-------------------------+-------------------------+----------------------------+----------+

cucumis_sativus_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     783 |                       3955 |    16329 |
| Plant_Reactome_Reaction |                     903 |                        808 |      903 |
| Plant_Reactome_Pathway  |                     191 |                        808 |     1173 |
+-------------------------+-------------------------+----------------------------+----------+

cyanidioschyzon_merolae_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     210 |                        181 |      210 |
| Plant_Reactome_Pathway  |                     119 |                        181 |      299 |
+-------------------------+-------------------------+----------------------------+----------+

dioscorea_rotundata_core_39_92_3
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     639 |                        562 |      639 |
| Plant_Reactome_Pathway  |                     183 |                        562 |      804 |
+-------------------------+-------------------------+----------------------------+----------+

galdieria_sulphuraria_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      47 |                        451 |      738 |
| Plant_Reactome_Reaction |                     234 |                        202 |      234 |
| Plant_Reactome_Pathway  |                     123 |                        202 |      323 |
+-------------------------+-------------------------+----------------------------+----------+

glycine_max_core_39_92_3
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     758 |                      10482 |    39367 |
| Plant_Reactome_Reaction |                    2127 |                       1905 |     2127 |
| Plant_Reactome_Pathway  |                     194 |                       1905 |     2700 |
+-------------------------+-------------------------+----------------------------+----------+

gossypium_raimondii_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     741 |                       8184 |    31997 |
| Plant_Reactome_Reaction |                    1528 |                       1380 |     1528 |
| Plant_Reactome_Pathway  |                     193 |                       1380 |     1932 |
+-------------------------+-------------------------+----------------------------+----------+

helianthus_annuus_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      42 |                        182 |      816 |
| Plant_Reactome_Reaction |                    1688 |                       1492 |     1688 |
| Plant_Reactome_Pathway  |                     192 |                       1492 |     2150 |
+-------------------------+-------------------------+----------------------------+----------+

hordeum_vulgare_core_39_92_3
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1035 |                        924 |     1035 |
| Plant_Reactome_Pathway  |                     193 |                        924 |     1330 |
+-------------------------+-------------------------+----------------------------+----------+

leersia_perrieri_core_39_92_14
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1016 |                        917 |     1016 |
| Plant_Reactome_Pathway  |                     195 |                        917 |     1306 |
+-------------------------+-------------------------+----------------------------+----------+

lupinus_angustifolius_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     720 |                       2741 |    11608 |
| Plant_Reactome_Reaction |                     673 |                        591 |      673 |
| Plant_Reactome_Pathway  |                     163 |                        591 |      859 |
+-------------------------+-------------------------+----------------------------+----------+

manihot_esculenta_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     166 |                        105 |      416 |
| Plant_Reactome_Reaction |                    1362 |                       1205 |     1362 |
| Plant_Reactome_Pathway  |                     195 |                       1205 |     1732 |
+-------------------------+-------------------------+----------------------------+----------+

medicago_truncatula_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      54 |                       2301 |     3180 |
| Plant_Reactome_Reaction |                    1340 |                       1179 |     1340 |
| Plant_Reactome_Pathway  |                     190 |                       1179 |     1706 |
+-------------------------+-------------------------+----------------------------+----------+

musa_acuminata_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1305 |                       1170 |     1305 |
| Plant_Reactome_Pathway  |                     187 |                       1170 |     1660 |
+-------------------------+-------------------------+----------------------------+----------+

nicotiana_attenuata_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     757 |                       3430 |    14411 |
| Plant_Reactome_Reaction |                     777 |                        682 |      777 |
| Plant_Reactome_Pathway  |                     185 |                        682 |      985 |
+-------------------------+-------------------------+----------------------------+----------+

oryza_barthii_core_39_92_3
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1051 |                        947 |     1051 |
| Plant_Reactome_Pathway  |                     193 |                        947 |     1362 |
+-------------------------+-------------------------+----------------------------+----------+

oryza_brachyantha_core_39_92_14
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1022 |                        921 |     1022 |
| Plant_Reactome_Pathway  |                     194 |                        921 |     1320 |
+-------------------------+-------------------------+----------------------------+----------+

oryza_glaberrima_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1049 |                        943 |     1049 |
| Plant_Reactome_Pathway  |                     197 |                        943 |     1352 |
+-------------------------+-------------------------+----------------------------+----------+

oryza_glumaepatula_core_39_92_15
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1076 |                        962 |     1076 |
| Plant_Reactome_Pathway  |                     197 |                        962 |     1384 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_indica_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1148 |                       1035 |     1148 |
| Plant_Reactome_Pathway  |                     199 |                       1035 |     1469 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_longistaminata_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     915 |                        822 |      915 |
| Plant_Reactome_Pathway  |                     192 |                        822 |     1201 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_meridionalis_core_39_92_13
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     904 |                        813 |      904 |
| Plant_Reactome_Pathway  |                     188 |                        813 |     1163 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_nivara_core_39_92_10
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1062 |                        952 |     1062 |
| Plant_Reactome_Pathway  |                     193 |                        952 |     1361 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_punctata_core_39_92_12
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1075 |                        968 |     1075 |
| Plant_Reactome_Pathway  |                     192 |                        968 |     1382 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_rufipogon_core_39_92_11
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1074 |                        968 |     1074 |
| Plant_Reactome_Pathway  |                     195 |                        968 |     1384 |
+-------------------------+-------------------------+----------------------------+----------+
oryza_sativa_core_39_92_7
ostreococcus_lucimarinus_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     267 |                        237 |      267 |
| Plant_Reactome_Pathway  |                     127 |                        237 |      371 |
+-------------------------+-------------------------+----------------------------+----------+

phaseolus_vulgaris_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     777 |                       5339 |    20552 |
| Plant_Reactome_Reaction |                    1167 |                       1050 |     1167 |
| Plant_Reactome_Pathway  |                     194 |                       1050 |     1493 |
+-------------------------+-------------------------+----------------------------+----------+

physcomitrella_patens_core_39_92_11
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1046 |                        910 |     1046 |
| Plant_Reactome_Pathway  |                     178 |                        910 |     1338 |
+-------------------------+-------------------------+----------------------------+----------+
populus_trichocarpa_core_39_92_20
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1476 |                       1301 |     1476 |
| Plant_Reactome_Pathway  |                     193 |                       1301 |     1845 |
+-------------------------+-------------------------+----------------------------+----------+

prunus_persica_core_39_92_2
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                      12 |                         16 |       43 |
| Plant_Reactome_Reaction |                    1050 |                        927 |     1050 |
| Plant_Reactome_Pathway  |                     194 |                        927 |     1323 |
+-------------------------+-------------------------+----------------------------+----------+

selaginella_moellendorffii_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1298 |                       1166 |     1298 |
| Plant_Reactome_Pathway  |                     189 |                       1166 |     1682 |
+-------------------------+-------------------------+----------------------------+----------+
setaria_italica_core_39_92_21
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1120 |                       1016 |     1120 |
| Plant_Reactome_Pathway  |                     192 |                       1016 |     1466 |
+-------------------------+-------------------------+----------------------------+----------+
solanum_lycopersicum_core_39_92_250
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1141 |                       1009 |     1141 |
| Plant_Reactome_Pathway  |                     193 |                       1009 |     1466 |
+-------------------------+-------------------------+----------------------------+----------+
solanum_tuberosum_core_39_92_4
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1081 |                        962 |     1081 |
| Plant_Reactome_Pathway  |                     187 |                        962 |     1399 |
+-------------------------+-------------------------+----------------------------+----------+

sorghum_bicolor_core_39_92_30
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Reactome                |                     721 |                       4217 |    17441 |
| Plant_Reactome_Reaction |                    1099 |                       1000 |     1099 |
| Plant_Reactome_Pathway  |                     194 |                       1000 |     1409 |
+-------------------------+-------------------------+----------------------------+----------+

theobroma_cacao_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     981 |                        872 |      981 |
| Plant_Reactome_Pathway  |                     194 |                        872 |     1282 |
+-------------------------+-------------------------+----------------------------+----------+

trifolium_pratense_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1081 |                        961 |     1081 |
| Plant_Reactome_Pathway  |                     194 |                        961 |     1407 |
+-------------------------+-------------------------+----------------------------+----------+

triticum_aestivum_core_39_92_3
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    3520 |                       3189 |     3520 |
| Plant_Reactome_Pathway  |                     194 |                       3189 |     4509 |
+-------------------------+-------------------------+----------------------------+----------+

triticum_urartu_core_39_92_1
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     896 |                        811 |      896 |
| Plant_Reactome_Pathway  |                     183 |                        811 |     1162 |
+-------------------------+-------------------------+----------------------------+----------+

vitis_vinifera_core_39_92_3
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                     973 |                        872 |      973 |
| Plant_Reactome_Pathway  |                     192 |                        872 |     1235 |
+-------------------------+-------------------------+----------------------------+----------+

zea_mays_core_39_92_7
+-------------------------+-------------------------+----------------------------+----------+
| db_name                 | COUNT(DISTINCT xref_id) | COUNT(DISTINCT ensembl_id) | COUNT(*) |
+-------------------------+-------------------------+----------------------------+----------+
| Plant_Reactome_Reaction |                    1393 |                       1255 |     1393 |
| Plant_Reactome_Pathway  |                     191 |                       1255 |     1759 |
+-------------------------+-------------------------+----------------------------+----------+
