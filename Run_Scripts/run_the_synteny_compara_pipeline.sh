## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Compara+Synteny+Pipeline

pipeline_name=synteny



## Ensembl
source /homes/dbolser/EG_Places/Devel/lib/libensembl/setup.sh

ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version

PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/synteny



## Ensembl Genomes
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules



## The all important registry (must match prod_server and mast_db)
registry=/homes/dbolser/Registries/registry.mysql-prod-1+panx.pm



## Where is the production and the mater database
prod_server=mysql-prod-1
prod_db=ensembl_compara_plants_39_92

mast_server=mysql-pan-prod-ensrw
mast_db=plants_compara_master_39_92

## Make sure mast is are available via the registry!!!
grep $mast_db $registry



## Use one dir for 'alignment_db' (align)
## and one for 'ptree_db' (ortho)

tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines
tmpdir=$tmpdir/${USER}/$pipeline_name

#tmpdir=$tmpdir/align
tmpdir=$tmpdir/ortho

mkdir -p $tmpdir
ls $tmpdir



## Hive database (sometimes called production database)
#hive_server=mysql-prod-2-ensrw
hive_server=mysql-prod-3-ensrw



## Backup the compara master database?
$mast_server mysqldump --single-transaction \
    $mast_db > ${tmpdir}/${mast_db}-$(date +%Y%m%d%H%M).sql



## HIVE TIME...

## Note, here we run for 'all' (either in alignment_db or ptree_db
## mode), however, you can pass an MLSS_ID to run one pair at a
## time. If so, for alignment_db mode, pass the MLSS_ID of the lastz
## data, for the pair. For ptree_db mode, pass the MLSS_ID of the
## orthologues for the pair.

#echo \
time \
init_pipeline.pl Bio::EnsEMBL::Compara::PipeConfig::Synteny_conf \
    $($hive_server --details hive) \
    --master_db    $($mast_server --details url)$mast_db \
    --ptree_db     $($prod_server --details url)$prod_db \
    --work_dir $tmpdir \
    --registry ${registry} \
    --recompute_existing_syntenies 1 \
    --hive_force_init 0

# ## Pick one of these...
#     --alignment_db $($prod_server --details url)$prod_db \
#     --ptree_db     $($prod_server --details url)$prod_db \

# ## To get the MLSS_ID, see below
#     --pairwise_mlss_id $mlss_id \


## We guess the pipeline name...
hive_db=${USER}_${pipeline_name}_${ensembl_version}

## And use it to guess the url...
url=$($hive_server --details url)$hive_db

echo $url; echo $url; echo $url
echo $url | xclip

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive


break








## Interlude

## Synteny Stats Hive

## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Synteny+Statistics+Pipeline

pipeline_name=synteny_stats

echo \
time \
init_pipeline.pl Bio::EnsEMBL::Compara::PipeConfig::SyntenyStats_conf \
    $($hive_server --details hive) \
    --registry ${registry} \
    --division plants

url=$($hive_server --details url)${USER}_${pipeline_name}_${ensembl_version}

echo $url; echo $url; echo $url

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop





## Now 'merge'...

## Because this is for testing, I can just clobber all existing
## synteny data... You probably don't want to do that in general...


## Assuming the master was just created from the production db, and
## both contain all genome_dbs and species sets we're using here, the
## following tables should not need to be merged...

table_list=(

    ## Hopefully identical
    dnafrag                    
    genome_db                  
    method_link                
    species_set                
    species_set_header         

    ## Data
    dnafrag_region             
    synteny_region             

    ## Meta data
    method_link_species_set    
    method_link_species_set_tag
)

## Step 1) convert them to MyISAM

## Oh fuckarella

$hive_server $hive_db -Ne '
  SELECT CONCAT(
    "ALTER TABLE ", TABLE_NAME, " DROP FOREIGN KEY ", CONSTRAINT_NAME, ";")
  FROM information_schema.KEY_COLUMN_USAGE
  WHERE CONSTRAINT_SCHEMA=DATABASE()
  AND REFERENCED_TABLE_SCHEMA=DATABASE()' \
      > pukey1

$hive_server $hive_db -Ne '
  SELECT CONCAT(
    "ALTER TABLE ", TABLE_NAME, " ENGINE=MyISAM;")
  FROM Information_schema.TABLES
  WHERE TABLE_SCHEMA=DATABASE()
  AND ENGINE = "InnoDB"' \
      > pukey2

$hive_server $hive_db -f < pukey1
$hive_server $hive_db -f < pukey2



## Step 2) Use nagwrap to compare the two databases, table by table,
## ensuring that none of the first 5 need to be updated...

'mysql-prod-1.ensembl_compara_plants_39_92'     'genome_db'
'mysql-prod-1.ensembl_compara_plants_39_92'     'method_link'
'mysql-prod-1.ensembl_compara_plants_39_92'     'species_set'
'mysql-prod-1.ensembl_compara_plants_39_92'     'species_set_header'
'mysql-prod-1.ensembl_compara_plants_39_92'     'species_set_tag'

## Ahhh... dnafrag in this database is a subset of the production
## dnafrag (for the species where we have karyotypes)!



## Step 3) copy over the data and the metadata!


## DATA

## NOTE, we trash these tables!
$hive_server mysqldump  $hive_db \
    dnafrag_region \
    synteny_region \
    | $prod_server-ensrw $prod_db

## METADATA

## NOTE, we partially trash these tabels!
$prod_server-ensrw $prod_db -vvv --show-warnings -e '
  DELETE mlss, mlsst
  FROM   method_link_species_set     mlss
  JOIN   method_link_species_set_tag mlsst
  USING (method_link_species_set_id)
  WHERE  method_link_id = 101;
  DELETE FROM method_link_species_set_tag
  WHERE tag = "synteny_mlss_id";
  DELETE FROM   method_link_species_set
  WHERE  method_link_id = 101;  
'

$hive_server mysqldump --no-create-info $hive_db \
    method_link_species_set \
    -w 'method_link_id = 101' \
    | $prod_server-ensrw $prod_db

$hive_server mysqldump --no-create-info $hive_db \
    method_link_species_set_tag \
    | $prod_server-ensrw $prod_db









## CLEAN UP EMPTY syntenty MLSS in the synteny database.

## I think I can drop the four tabels and load fresh?












# ## Pair
# ref_species=arabidopsis_thaliana
# oth_species=arabidopsis_lyrata

## 1) Lookup genome_db_ids for each species

$mast_server $mast_db --table -e "
  SELECT #*
    genome_db_id, name, assembly, genome_component,
    first_release, last_release
  FROM
    genome_db
  WHERE
    last_release IS NULL
  AND (
    ( name = \"$ref_species\" OR
      name = \"$oth_species\" )
    OR
    ( CONCAT(name, \".\", genome_component) = \"$ref_species\" OR
      CONCAT(name, \".\", genome_component) = \"$oth_species\" )
  )
"

## 2) Use the above genome_db_ids to get the here...
create_mlss.pl \
    --reg_conf ${registry} \
    --compara multi \
    --source "ensembl" \
    --method_link_type LASTZ \
    --url "" --species_set_name "" \
    \
    --genome_db_id 1505,1554

mlss_id=18729







## SCRIPT VSN (USE THE HIVE VERSION)

## ALIGNMENT VSN

mkdir -p $tmpdir/WGA/GFF

$prod_server $prod_db \
    --batch --column-names=false -e "
SELECT DISTINCT(dnafrag.name)
FROM dnafrag INNER JOIN genome_db USING (genome_db_id)
WHERE genome_db.name = \"$ref_species\"
AND coord_system_name=\"chromosome\"" \
    > $tmpdir/${ref_species}-chr.txt

while read -r chr; do
    echo $chr
    #echo \
    time \
    DumpGFFAlignmentsForSynteny.pl \
        --reg_conf ${registry} \
        --dbname $($prod_server --details url)$prod_db \
        --method_link_species_set $mlss_id \
        --qy "$ref_species" \
        --tg "$oth_species" \
        --seq_region $chr \
        --output_dir $tmpdir/WGA/GFF
done \
    < $tmpdir/${ref_species}-chr.txt

# not used \
#        --method_link_species_set $mlss_id \
#        --qy "$ref_species" \
#        --tg "$oth_species" \
#        --method_link_type "LASTZ_NET" \
