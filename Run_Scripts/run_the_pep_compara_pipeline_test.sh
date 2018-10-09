
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Peptide+Compara+pipeline

## Ensembl
## Usign 90, as described in confluence
source /homes/dbolser/EG_Places/Devel/lib/libensembl-90/setup.sh

## BioPerl!
## Compara needs at least 1.6.9 (the default above is 1.2.3)
PERL5LIB=/nfs/production/panda/ensemblgenomes/apis/bioperl/1.6.9:${PERL5LIB}

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Scripts path
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline



## Things to set...

#division=pan
division=plants

ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version 

eg_version=$(echo $ensembl_version-53 | bc)
echo $eg_version 

hive_server=mysql-prod-1-ensrw

tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines/${USER}
tmpdir=${tmpdir}/pep_pipeline/$division/${eg_version}
mkdir -p $tmpdir
ls $tmpdir



## Where is the Compara master database?
mast_server=mysql-pan-prod-ensrw
mast_db=${division}_compara_master



## Registry file for cores (ro) and master (rw)
## CHECK THE RELEASE WITHIN!

## THIS SHOULD MATCH THE CORE (AND THE MASTER) SERVER!
registry=${HOME}/Registries/registry.mysql-prod-1-2+panx.pm





## Now then...

## If you need to update species... You prolly do, else why would you
## be running this pipeline then eh?

## Backup master

time \
$mast_server mysqldump $mast_db \
    | gzip -c \
    > $tmpdir/${mast_db}-$(date +%Y%m%d%H%M).sql.gz

# ## An example of recovering from backup...
# time \
# mysql-pan-prod-ensrw plants_compara_master < \
#     <(gunzip -c $tmpdir/plants_compara_master-xxxxxxxxxxxx.sql.gz)





## For the scripts below, note the PATH setting above!

## 1) Add any new or updated species

## NOTE: If you are running a version behind, you need to run these
## steps on the /current/ version so that the magic release number
## comes out magically correct!

## Touches genome_db and dnafrag

echo \
time \
update_genome.pl \
    --reg_conf ${registry} \
    --compara $($mast_server --details url)$mast_db  \
    --release \
    --collection $division \




## 2) Update the collection (and species_set)

$mast_server $mast_db -Ne '
  SELECT name FROM genome_db
  WHERE last_release IS NULL
  AND genome_component IS NULL
  ORDER BY name' \
      > temp.file

echo \
time \
edit_collection.pl \
    --reg_conf ${registry} \
    --compara multi \
    --collection $division \
    --file temp.file \
    --nodry-run

## NOTE: This dropped one of the wheat components randomly, so I added
## it back.

SELECT * FROM genome_db where genome_component  = 'U';

INSERT INTO species_set (species_set_id, genome_db_id) VALUES (601163,2084);

SELECT * FROM species_set INNER JOIN genome_db USING (genome_db_id) WHERE species_set_id=601163;

UPDATE species_set_header SET size = 66 WHERE species_set_id=601163;






## I think the following set of queries encompas all changes in $mast_db

SELECT * FROM genome_db WHERE name RLIKE 'hord';
SELECT COUNT(*) FROM species_set WHERE genome_db_id = 2051;

SELECT * FROM method_link_species_set WHERE species_set_id IN (
  SELECT DISTINCT species_set_id FROM species_set WHERE genome_db_id = 2088
) ORDER BY method_link_id;

SELECT * FROM species_set_header WHERE name RLIKE 'collection';
SELECT * FROM species_set_header WHERE name RLIKE 'plants';

SELECT
  genome_db_id, taxon_id, name, assembly, genebuild, first_release, last_release
FROM
  species_set INNER JOIN genome_db USING(genome_db_id)
WHERE species_set_id IN (600452) AND genome_component IS NULL ORDER BY name;

SELECT * FROM method_link_species_set WHERE species_set_id = 600452;


# Try to do a 'foreign key' check for Compara master...

# Looking at all 'current' genomes.
SELECT
  genome_db_id, taxon_id, name, assembly, genebuild, strain_name,
  display_name, first_release, last_release
FROM
  genome_db
WHERE
  genome_component IS NULL AND last_release IS NULL ORDER BY name;


# ## Look to see that the species_set and species_set_header are
# ## consistent

# SELECT COUNT(DISTINCT species_set_id) FROM species_set;

# SELECT COUNT(DISTINCT species_set_id) FROM species_set
# INNER JOIN species_set_header USING (species_set_id);

# SELECT COUNT(*) FROM species_set_header;

# ## Which ones are in species_set_header that aren't in species set?
# SELECT * FROM species_set_header WHERE species_set_id NOT IN (
#   SELECT DISTINCT species_set_id FROM species_set
# );

# ## Delete them if necessary
# DELETE FROM species_set_header WHERE species_set_id NOT IN (
#   SELECT DISTINCT species_set_id FROM species_set
# );

# ## Which ones are in species_set that aren't in species set_header?
# SELECT * FROM species_set WHERE species_set_id NOT IN (
#   SELECT DISTINCT species_set_id FROM species_set_header
# );

# ## Delete them if necessary
# DELETE FROM species_set WHERE species_set_id NOT IN (
#   SELECT DISTINCT species_set_id FROM species_set_header
# );


# ## Look to see that the species_set and genome_db are
# ## consistent

# SELECT COUNT(DISTINCT genome_db_id) FROM species_set;

# SELECT COUNT(DISTINCT genome_db_id) FROM species_set
# INNER JOIN genome_db USING (genome_db_id);

# SELECT COUNT(*) FROM genome_db;

# ## Which ones are in genome_db that aren't in species set?
# SELECT * FROM genome_db WHERE genome_db_id NOT IN (
#   SELECT DISTINCT genome_db_id FROM species_set
# );

# ## Which ones are in species_set that aren't in genome_db (to fix)
# SELECT * FROM species_set WHERE genome_db_id NOT IN (
#   SELECT DISTINCT genome_db_id FROM genome_db
# );





# ## CHECK MLSS
# SELECT COUNT(*), COUNT(DISTINCT species_set_id)
# FROM method_link_species_set;

# SELECT COUNT(*), COUNT(DISTINCT species_set_id)
# FROM method_link_species_set
# INNER JOIN species_set_header USING(species_set_id);



## CHECK MLSS_TAG
SELECT COUNT(*), COUNT(DISTINCT method_link_species_set_id)
FROM method_link_species_set_tag;

SELECT method_link_id, COUNT(*), COUNT(DISTINCT method_link_species_set_id)
FROM method_link_species_set_tag INNER JOIN method_link_species_set
USING (method_link_species_set_id) GROUP BY 1;

## Which tags are not in mlss?
SELECT COUNT(*), COUNT(DISTINCT method_link_species_set_id)
FROM method_link_species_set_tag WHERE method_link_species_set_id NOT IN (
  SELECT DISTINCT method_link_species_set_id FROM method_link_species_set
);

## Delete them if necessary
DELETE FROM method_link_species_set_tag WHERE method_link_species_set_id NOT IN (
  SELECT DISTINCT method_link_species_set_id FROM method_link_species_set
);

## Which mlss have no tags?
SELECT COUNT(*), COUNT(DISTINCT method_link_species_set_id)
FROM method_link_species_set WHERE method_link_species_set_id NOT IN (
  SELECT DISTINCT method_link_species_set_id FROM method_link_species_set_tag
);


# ## Fucked? Or just no stats yet? Stats are added later, so if any are
# ## missing from the master, they should get added later.

# SELECT
#   method_link_id, COUNT(*), COUNT(DISTINCT method_link_species_set_id)
# FROM method_link_species_set_tag INNER JOIN method_link_species_set
# USING (method_link_species_set_id) GROUP BY 1;

# SELECT
#   method_link_id, COUNT(*), COUNT(DISTINCT method_link_species_set_id)
# FROM method_link_species_set WHERE method_link_species_set_id NOT IN (
#   SELECT DISTINCT method_link_species_set_id FROM method_link_species_set_tag
# ) GROUP BY 1;



## Are the first and last release columns sane?

SELECT COUNT(*) FROM genome_db               WHERE first_release IS NULL;
SELECT COUNT(*) FROM species_set_header      WHERE first_release IS NULL;
SELECT COUNT(*) FROM method_link_species_set WHERE first_release IS NULL;

SELECT COUNT(*) FROM genome_db               WHERE last_release IS NOT NULL;
SELECT COUNT(*) FROM species_set_header      WHERE last_release IS NOT NULL;
SELECT COUNT(*) FROM method_link_species_set WHERE last_release IS NOT NULL;

# Given first_release is never null, and last release is always null...
SELECT COUNT(*) FROM species_set_header h INNER JOIN method_link_species_set m USING (species_set_id)
WHERE h.first_release != m.first_release;

# OK, fine...
SELECT COUNT(*) FROM species_set_header h INNER JOIN method_link_species_set m USING (species_set_id)
WHERE h.first_release < m.first_release;



## Is the first_release column within the range defined by the species in the set?

SELECT
  species_set_id,
  size,
  COUNT(*),
  MIN(COALESCE(g.first_release,      0)) AS gfirst_min,
  MAX(COALESCE(g.first_release,      0)) AS gfirst_max,
      COALESCE(h.first_release,      0)  AS hfirst
FROM
           genome_db          g
INNER JOIN species_set        s USING (genome_db_id)
INNER JOIN species_set_header h USING (species_set_id)
GROUP BY
  species_set_id
##
HAVING
  COUNT(*) != size
OR
  gfirst_min > hfirst
OR
  gfirst_max < hfirst
LIMIT 40;



## DNA FRAGGLE

SELECT COUNT(*), COUNT(DISTINCT genome_db_id) FROM dnafrag;

SELECT COUNT(DISTINCT genome_db_id) FROM genome_db;

SELECT COUNT(*), COUNT(DISTINCT genome_db_id) FROM dnafrag
INNER JOIN genome_db USING (genome_db_id);

SELECT COUNT(DISTINCT genome_db_id) FROM dnafrag
WHERE genome_db_id NOT IN (SELECT genome_db_id FROM genome_db);

DELETE FROM dnafrag
WHERE genome_db_id NOT IN (SELECT genome_db_id FROM genome_db);







##
## Don't forget to add these fellas to your $core_db!
##

ensembl_prev_version=90

## Find what's missing
for p in \
    caenorhabditis_elegans \
    drosophila_melanogaster \
    saccharomyces_cerevisiae \
    xxxx \
    ciona_savignyi \
    homo_sapiens
do
    echo $p
    
    echo s2
    mysql-staging-2 -Ne \
        "SHOW DATABASES LIKE \"${p}_core_%\""
    
    echo em
    mysql-ensembl-mirror -Ne \
        "SHOW DATABASES LIKE \"${p}_core_${ensembl_prev_version}_%\""

    echo cs
    $core_server -Ne \
        "SHOW DATABASES LIKE \"${p}_core_%\""
    
    echo
done



## Add them (from where)?

for p in \
    caenorhabditis_elegans \
    drosophila_melanogaster \
    saccharomyces_cerevisiae

for p in \
    ciona_savignyi \
    homo_sapiens
do
    echo $p
    
    # db=$(mysql-staging-2 -Ne \
    #     "SHOW DATABASES LIKE \"${p}_core_%\"" )
    # echo $db
    
    # time \
    #     mysql-staging-2-ensrw mysqldump \
    #     --databases $db | ${core_server}-ensrw & 
    
    db=$(mysql-ensembl-mirror -Ne \
        "SHOW DATABASES LIKE \"${p}_core_${ensembl_prev_version}_%\"" )
    echo $db
    
    time \
        mysql-ensembl-mirror mysqldump --skip-lock-tables \
        --databases $db | ${core_server}-ensrw & 
    
done


## Oh potatoes
mysqlnaga-rename --create --drop $(${core_server}-ensrw --details script) \
    --database ciona_savignyi_core_90_2 \
    --target   ciona_savignyi_core_91_2

mysqlnaga-rename --create --drop $(${core_server}-ensrw --details script) \
    --database homo_sapiens_core_89_38 \
    --target   homo_sapiens_core_90_38

## NOW PATCH BITCA!






## 2) Create (any) required MLSS_IDs for the given
##    collection. Existing MLSS_IDs are skipped.

## Note: The -f flag is required here for non-interactive mode
## (writing logs to file).  I found that some WARNING messages went
## away on re-run (i.e. they are more like INFO). The script seems to
## 'do the right thing'...

## Orthologs
echo \
create_mlss.pl \
    --method_link_type ENSEMBL_ORTHOLOGUES \
    --reg_conf ${registry} \
    --collection $division \
    --compara multi \
    --source ensembl \
    --pw --f \
    --release $ensembl_version \
    1> $tmpdir/ENSEMBL_ORTHOLOGUES.out

grep -c "You are about to store" $tmpdir/ENSEMBL_ORTHOLOGUES.out

# Paralogs
create_mlss.pl \
    --method_link_type ENSEMBL_PARALOGUES \
    --reg_conf ${registry} \
    --collection $division \
    --compara multi \
    --source ensembl \
    --sg --f \
    1> $tmpdir/ENSEMBL_PARALOGUES.out

grep -c "You are about to store" $tmpdir/ENSEMBL_PARALOGUES.out

# Homoeologs (Plants only)
create_mlss.pl \
    --method_link_type ENSEMBL_HOMOEOLOGUES \
    --reg_conf ${registry} \
    --collection $division \
    --compara multi \
    --source ensembl_genomes \
    --sg --f \
    1> $tmpdir/ENSEMBL_HOMOEOLOGUES.out \
    #2> $tmpdir/ENSEMBL_HOMOEOLOGUES.err

grep -c "You are about to store" $tmpdir/ENSEMBL_HOMOEOLOGUES.out

# Trees
create_mlss.pl \
    --method_link_type PROTEIN_TREES \
    --reg_conf ${registry} \
    --collection $division \
    --compara multi \
    --source ensembl \
    --name protein_tree_${division}_eg${eg_version} \
    --f \
    1> $tmpdir/PROTEIN_TREES.out

tail -n 10 $tmpdir/PROTEIN_TREES.out

## Now review the above SQL queries again, and set first_release to
## the current release where necessary!






## From the final line of $tmpdir/PROTEIN_TREES.out
#mlss_id=121733
#mlss_id=200000
#mlss_id=40133
#mlss_id=40134
#mlss_id=40135
mlss_id=40136
mlss_id=40137

## CONFIG

config=./EGProteinTrees_conf.pm
config=./EGProteinTrees_amin_conf.pm
#config=./EGProteinTrees2_conf.pm
#config=./EGProteinTrees_pan_conf.pm

# cp $ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/\
# Compara/PipeConfig/EBI/EG/ProteinTrees_conf.pm \
# $config

## EDIT IT!

# diff -u $ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/\
# Compara/PipeConfig/EBI/EG/ProteinTrees_conf.pm \
# $config

diff -u $ENSEMBL_ROOT_DIR/ensembl-compara/modules/Bio/EnsEMBL/\
Compara/PipeConfig/Example/EGProteinTrees_conf.pm \
$config

## Is your species_tree in order?
ls $ENSEMBL_ROOT_DIR/\
ensembl-compara/scripts/pipeline/species_tree.treefam.topology.nw

emacs -nw \
/nfs/production/panda/ensemblgenomes/development/dbolser/species_tree.treefam.topology.nw

emacs -nw \
/nfs/production/panda/ensemblgenomes/development/gnaamati/compara_run/species_tree_38.treefam.topology.nw


## OK, HIVE TIME...
export PERL5LIB=.:${PERL5LIB}

time source /nfs/software/ensembl/latest/envs/basic.sh

#ensembl_version=90
#eg_version=$(echo $ensembl_version-53 | bc)

## Apparently missing now...
PERL5LIB=$PERL5LIB:/nfs/production/panda/ensemblgenomes/apis/bioperl/run-stable

echo \
time \
init_pipeline.pl $config \
    $($hive_server details script) \
    --password $($hive_server pass) \
    --dbowner dbolser \
    --division $division \
    --mlss_id $mlss_id \
    --ensembl_release $ensembl_version \
    --eg_release $eg_version \
    --ensembl_cvs_root_dir $ENSEMBL_ROOT_DIR \
    --master_db $($mast_server --details url)$mast_db \
    --hive_force_init 0

    --reg_conf ${registry} \


## AND FINALLY...

#hive_db=ensembl_compara_${division}_hom_${eg_version}_${ensembl_version}
hive_db=dbolser_${division}_hom_${eg_version}_${ensembl_version} # dbowner

url=$($hive_server --details url)$hive_db

## FUCKERELLA!
url="${url};reconnect_when_lost=1"

echo $url
echo $url | xclip

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
runWorker.pl -url ${url} -reg_conf ${registry}


# NOW MERGE!





## Stand alone stable_id mapping (rarely needed)

## Do this on a farm node?

## Ensembl
source /nfs/panda/ensemblgenomes/apis/ensembl/87/setup.sh # or

## BioPerl! Compara needs at least 1.6.9 (the default above is 1.2.3)

## SWITCH_TO_1.6.9
PERL5LIB=/nfs/production/panda/ensemblgenomes/apis/bioperl/1.6.9:${PERL5LIB}

## Scripts path
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline



comp_server=mysql-prod-1-ensrw
comp_db=ensembl_compara_pan_homology_34_87

mast_server=mysql-pan-prod-ensrw
mast_db=pan_compara_master

prev_server=mysql-eg-mirror
prev_db=ensembl_compara_pan_homology_32_85

## Needed?
UPDATE gene_tree_root SET stable_id NULL;
DELETE FROM stable_id_history ...;

echo \
time \
    standaloneJob.pl \
    Bio::EnsEMBL::Compara::RunnableDB::StableIdMapper \
    -compara_db  "$($comp_server --details url)$comp_db" \
    -master_db   "$($mast_server --details url)$mast_db" \
    -prev_rel_db "$($prev_server --details url)$prev_db" \
    -release 35 \
    -type t


