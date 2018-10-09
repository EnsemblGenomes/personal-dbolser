
## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Compara+Database+Merging

## Ensembl
#source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/79/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/80/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/85/setup.sh # or
#source /nfs/panda/ensemblgenomes/apis/ensembl/87/setup.sh # or

libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-93
source ${libdir}/setup.sh

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Scripts path
PATH=$PATH:${ENSEMBL_ROOT_DIR}/ensembl-compara/scripts/pipeline



## Things to set

division=plants

release=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
release_eg=$(echo $release-53 | bc)

pelease=$(echo $release-1 | bc)
pelease_eg=$(echo $release_eg-1 | bc)

echo $release $release_eg $pelease $pelease_eg

tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/merge_pipeline
mkdir -p $tmpdir
ls $tmpdir



## Databases

## Where do we want to build the new, merged compara database?
comp_server=mysql-prod-1-ensrw
#comp_server=mysql-prod-2-ensrw
#comp_server=mysql-prod-3-ensrw

comp_db=ensembl_compara_${division}_${release_eg}_${release}
echo $comp_db

$comp_server $comp_db -e "SELECT DATABASE()"


## Where is the old compara database from the last release?
prev_server=mysql-staging-1
#prev_server=mysql-staging-2
#prev_server=mysql-eg-mirror-ensrw

prev_db=ensembl_compara_${division}_${pelease_eg}_${pelease}

$prev_server $prev_db -e "SELECT DATABASE()"



## Where is the Compara master database?
mast_server=mysql-pan-prod
#mast_db=plants_compara_master
mast_db=plants_40_93_compara_master

$mast_server $mast_db -e "SELECT DATABASE()"



## Where is the new peptide Compara database? i.e. the one you just
## ran.
#pept_server=mysql-prod-1-ensrw # RW needed?
#pept_server=mysql-prod-2 # RW needed?
pept_server=mysql-prod-3 # RW needed?

pept_db=${USER}_${division}_hom_${release_eg}_${release}
pept_db=ensembl_compara_${division}_hom_${release_eg}_${release}

$pept_server $pept_db -e "SELECT DATABASE()"



## Where do you want your hive database (for the final step)
#hive_server=mysql-prod-2-ensrw
hive_server=mysql-hive-ensrw




## Now then...

## Run step 0 and 1 if you're starting from scratch. Skip to step 2 if
## you're just merging in extra WGA data...

## Step 0) Create a compara database

#$comp_server -e "DROP DATABASE $comp_db"
$comp_server mysqladmin CREATE $comp_db

$comp_server $comp_db < $ENSEMBL_ROOT_DIR/ensembl-compara/sql/table.sql



## Step 1) Pull over existing DNA and synteny from the previous
## release

#echo \
time \
  populate_new_database.pl \
    --master $($mast_server --details url)$mast_db \
    --old    $($prev_server --details url)$prev_db \
    --new    $($comp_server --details url)$comp_db \
    --collection $division \
    --filter_by_mlss 1

# real    56m28.148s
# real    50m16.770s
# real    50m48.938s
# real    52m12.544s



## Step 2) Merge new DNA

## Step 2.1) Example of merging 1

## The new DNA compara database(s)
#from_server=mysql-hive
#from_server=mysql-prod-1
#from_server=mysql-prod-2
from_server=mysql-prod-3

#from_db=dbolser_lastz_90_atha_coll
#from_db=dbolser_slyc_coll_lastz_80
#from_db=dbolser_lastz_91_vvin_coll
#from_db=dbolser_lastz_91_atha_coll
#from_db=dbolser_lastz_91_osat_coll
#from_db=dbolser_lastz_91_poly_taes_ab
#from_db=dbolser_lastz_91_poly_taes_ad
#from_db=dbolser_lastz_91_poly_taes_bd
from_db=plants_compara_wga_40_92

$from_server $from_db -e "SELECT DATABASE()"

#echo \
time \
  copy_data.pl \
    --from_url $($from_server --details url)$from_db \
    --to_url   $($comp_server --details url)$comp_db \
    --method_link_type LASTZ_NET

OR...

    --mlss 9552 \
    --mlss 9553 \
    --mlss 9554



## If this fails, you may need to manually copy over the mlss (if it
## isn't copied from or wasn't present in the master). Else it may
## crash if your meta-data differs, such as first_release or genebuild.

## Copy mlss
$from_server mysqldump --no-create-info \
    $from_db method_link_species_set \
    -w "method_link_species_set_id < 100001" \
    | $comp_server $comp_db --show-warnings

## And the ss and ssh for the collection...
$from_server mysqldump --no-create-info \
    $from_db  species_set species_set_header \
    | $comp_server $comp_db --show-warnings

## But don't forget...
#    | $mast_server $mast_db





## 2.2) Trying to merge several...

## The new DNA compara database(s)
#from_server=mysql-prod-1
#from_server=mysql-prod-2
#from_server=mysql-prod-3
from_server=mysql-hive

for data in \
    dbolser_osat_taeaa_lastz_default_84:9453 \
    dbolser_osat_taebb_lastz_default_84:9454 \
    dbolser_osat_taedd_lastz_default_84:9455 \
    dbolser_osat_taeuu_lastz_default_84:9456
...

for data in \
    dbolser_bdis_taea_lastz_85:9467 \
    dbolser_bdis_taeb_lastz_85:9468 \
    dbolser_bdis_taed_lastz_85:9469
...

for data in \
    dbolser_taea_taeb_lastz_xlow_sens_homoeo_85:9465 \
    dbolser_taea_taed_lastz_xlow_sens_homoeo_85:9452 \
    dbolser_taeb_taed_lastz_xlow_sens_homoeo_85:9466
...

for data in \
    dbolser_aclum_olong_lastz_default_85:9425 \
    dbolser_olong_orufi_lastz_default_85:9438 \
    dbolser_athal_cmero_lastz_default_85:8760 \
    dbolser_lperr_olong_lastz_default_85:9427 \
    dbolser_olong_opunc_lastz_default_85:9437
...


for data in \
    dbolser_lastz_90_bdis_oind:9559 \
    dbolser_lastz_90_atha_vvin:9556 \
    dbolser_lastz_90_osat_hvul:9557 \
    dbolser_lastz_90_bdis_hvul:9558
do
    from_db=${data%:*}
    mlss_id=${data#*:}

    echo DB=$from_db MLSS=$mlss_id
    echo $from_server/$from_db

    $from_server $from_db -e 'SHOW TABLES' | wc -l

    # Check the MLSS
    $comp_server $comp_db --table -e "
      SELECT * FROM method_link_species_set
      WHERE method_link_species_set_id = $mlss_id"

    # # Add the MLSS
    # mysqldump --no-create-info --show-warnings \
    #     $($mast_server --details script) $mast_db \
    #     method_link_species_set -w method_link_species_set_id=$mlss_id \
    #     #| $comp_server --show-warnings $comp_db

    time \
    copy_data.pl \
        --from_url $($from_server --details url)$from_db \
        --to_url   $($comp_server --details url)$comp_db \
        --mlss $mlss_id \
        --re_enable 0
    
    echo
done





## Merge Peptide Compra

#time source /nfs/software/ensembl/RHEL7/envs/basic.sh ## ??

export PERL5LIB

#echo \
time \
init_pipeline.pl \
  Bio::EnsEMBL::Compara::PipeConfig::EBI::EG::MergeDBsIntoRelease_conf \
  $($hive_server details script) \
  -password $($hive_server pass) \
  -curr_rel_db $($comp_server --details url)$comp_db \
  -src_db_aliases master_db=$($mast_server --details url)$mast_db \
  -src_db_aliases protein_db=$($pept_server --details url)$pept_db \
  -hive_force_init 0



## AND FINALLY...

url=$($hive_server --details url)\
${USER}_pipeline_dbmerge_${release}

echo $url
echo $url | xclip 

## Fuck!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -loop # OR
beekeeper.pl -url ${url} -run  # OR
runWorker.pl -url ${url}

beekeeper.pl -url ${url} -loop -analyses_pattern merge_table





## NOW Run STATS!
 
echo \
time \
init_pipeline.pl \
  Bio::EnsEMBL::Compara::PipeConfig::EBI::EG::GeneMemberHomologyStats_conf \
    $($hive_server details script) \
    -password $($hive_server pass) \
    -curr_rel_db $($comp_server --details url)$comp_db \
    -collection $division \
    -hive_force_init 0

## 91?
url=$($hive_server --details url)\
${USER}_gene_member_homology_stats_${release}



echo $url
echo $url | xclip

## Fuck!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync

runWorker.pl -url ${url}
beekeeper.pl -url ${url} -loop 



## Rough sanity check?

SELECT
  genome_db_id,
  name,
  SUM(IF(gene_trees=1,1,0)) AS one,
  SUM(IF(gene_trees=0,1,0)) AS zero
FROM
  gene_member_hom_stats
  INNER JOIN gene_member USING(gene_member_id)
  INNER JOIN genome_db   USING(genome_db_id)
GROUP BY
  1
;



## NOW Run Gene Tree Highlighting!

## Production do this now though don't they?

## Yes, why do you ask?



## Now run orthoQC or whatever....
















### OUTPUT FROM STEP 1)


Storing all default genome_dbs...
Storing all previous valid method_link_species_sets...
Storing all previous valid species_sets...

Copying dna-dna alignments for V.vin-A.tha blastz_net (8650): ..ok!
Copying dna-dna alignments for A.tha-P.pat blastz_net (8652): ..ok!
Copying dna-dna alignments for A.tha-C.rei blastz_net (8653): ..ok!
Copying dna-dna alignments for A.tha-A.lyr blastz_net (8654): ..ok!
Copying dna-dna alignments for A.tha-B.dis blastz_net (8655): ..ok!
Copying dna-dna alignments for A.tha-G.max blastz_net (8656): ..ok!
Copying dna-dna alignments for A.tha-O.gla blastz_net (8657): ..ok!
Copying dna-dna alignments for A.tha-O.ind blastz_net (8658): ..ok!
Copying dna-dna alignments for A.tha-S.moe blastz_net (8660): ..ok!
Copying dna-dna alignments for B.dis-O.ind blastz_net (8715): ..ok!

Copying dna-dna alignments for A.tha-C.mer lastz_net (8760): ..ok!
Copying dna-dna alignments for A.tha-P.tri lastz_net (8766): ..ok!
Copying dna-dna alignments for A.tha-S.ita lastz_net (8772): ..ok!
Copying dna-dna alignments for A.tha-O.bra lastz_net (8773): ..ok!
Copying dna-dna alignments for V.vin-A.lyr lastz_net (8778): ..ok!
Copying dna-dna alignments for V.vin-G.max lastz_net (8780): ..ok!
Copying dna-dna alignments for V.vin-P.tri lastz_net (8783): ..ok!
Copying dna-dna alignments for O.gla-O.ind lastz_net (8882): ..ok!
Copying dna-dna alignments for O.gla-O.bra lastz_net (8890): ..ok!
Copying dna-dna alignments for O.ind-O.bra lastz_net (8898): ..ok!
Copying dna-dna alignments for V.vin-S.tub lastz_net (8955): ..ok!
Copying dna-dna alignments for A.tha-B.rap lastz_net (9024): ..ok!
Copying dna-dna alignments for A.tha-M.acu lastz_net (9026): ..ok!
Copying dna-dna alignments for V.vin-B.rap lastz_net (9027): ..ok!
Copying dna-dna alignments for A.tha-O.sat lastz_net (9148): ..ok!
Copying dna-dna alignments for V.vin-O.sat lastz_net (9151): ..ok!
Copying dna-dna alignments for P.pat-O.sat lastz_net (9154): ..ok!
Copying dna-dna alignments for C.rei-O.sat lastz_net (9155): ..ok!
Copying dna-dna alignments for C.mer-O.sat lastz_net (9156): ..ok!
Copying dna-dna alignments for A.lyr-O.sat lastz_net (9157): ..ok!
Copying dna-dna alignments for B.dis-O.sat lastz_net (9158): ..ok!
Copying dna-dna alignments for G.max-O.sat lastz_net (9159): ..ok!
Copying dna-dna alignments for O.gla-O.sat lastz_net (9160): ..ok!
Copying dna-dna alignments for O.ind-O.sat lastz_net (9161): ..ok!
Copying dna-dna alignments for P.tri-O.sat lastz_net (9162): ..ok!
Copying dna-dna alignments for S.moe-O.sat lastz_net (9163): ..ok!
Copying dna-dna alignments for B.rap-O.sat lastz_net (9166): ..ok!
Copying dna-dna alignments for S.ita-O.sat lastz_net (9168): ..ok!
Copying dna-dna alignments for O.bra-O.sat lastz_net (9169): ..ok!
Copying dna-dna alignments for S.tub-O.sat lastz_net (9170): ..ok!
Copying dna-dna alignments for M.acu-O.sat lastz_net (9172): ..ok!
Copying dna-dna alignments for T.ura-O.sat lastz_net (9174): ..ok!
Copying dna-dna alignments for A.tau-O.sat lastz_net (9175): ..ok!
Copying dna-dna alignments for O.bar-O.niv lastz_net (9256): ..ok!
Copying dna-dna alignments for O.glu-O.niv lastz_net (9257): ..ok!
Copying dna-dna alignments for O.ind-O.niv lastz_net (9258): ..ok!
Copying dna-dna alignments for O.gla-O.niv lastz_net (9260): ..ok!
Copying dna-dna alignments for O.bra-O.niv lastz_net (9261): ..ok!
Copying dna-dna alignments for O.sat-O.niv lastz_net (9262): ..ok!
Copying dna-dna alignments for O.bar-O.pun lastz_net (9263): ..ok!
Copying dna-dna alignments for O.bar-O.glu lastz_net (9264): ..ok!
Copying dna-dna alignments for O.ind-O.bar lastz_net (9265): ..ok!
Copying dna-dna alignments for O.gla-O.bar lastz_net (9267): ..ok!
Copying dna-dna alignments for O.bra-O.bar lastz_net (9268): ..ok!
Copying dna-dna alignments for O.sat-O.bar lastz_net (9269): ..ok!
Copying dna-dna alignments for O.glu-O.pun lastz_net (9270): ..ok!
Copying dna-dna alignments for O.ind-O.pun lastz_net (9271): ..ok!
Copying dna-dna alignments for O.gla-O.pun lastz_net (9273): ..ok!
Copying dna-dna alignments for O.bra-O.pun lastz_net (9274): ..ok!
Copying dna-dna alignments for O.sat-O.pun lastz_net (9275): ..ok!
Copying dna-dna alignments for O.ind-O.glu lastz_net (9276): ..ok!
Copying dna-dna alignments for O.gla-O.glu lastz_net (9278): ..ok!
Copying dna-dna alignments for O.bra-O.glu lastz_net (9279): ..ok!
Copying dna-dna alignments for O.sat-O.glu lastz_net (9280): ..ok!
Copying dna-dna alignments for O.niv-O.pun lastz_net (9283): ..ok!
Copying dna-dna alignments for A.tha-P.per lastz_net (9290): ..ok!
Copying dna-dna alignments for V.vin-P.per lastz_net (9291): ..ok!
Copying dna-dna alignments for O.sat-P.per lastz_net (9292): ..ok!
Copying dna-dna alignments for O.niv-O.ruf lastz_net (9303): ..ok!
Copying dna-dna alignments for O.niv-L.per lastz_net (9304): ..ok!
Copying dna-dna alignments for O.pun-O.ruf lastz_net (9305): ..ok!
Copying dna-dna alignments for O.glu-O.ruf lastz_net (9307): ..ok!
Copying dna-dna alignments for O.glu-L.per lastz_net (9308): ..ok!
Copying dna-dna alignments for O.ind-O.ruf lastz_net (9309): ..ok!
Copying dna-dna alignments for O.ind-L.per lastz_net (9310): ..ok!
Copying dna-dna alignments for O.bar-O.ruf lastz_net (9313): ..ok!
Copying dna-dna alignments for O.bar-L.per lastz_net (9314): ..ok!
Copying dna-dna alignments for O.gla-O.ruf lastz_net (9315): ..ok!
Copying dna-dna alignments for O.gla-L.per lastz_net (9316): ..ok!
Copying dna-dna alignments for O.bra-O.ruf lastz_net (9317): ..ok!
Copying dna-dna alignments for L.per-O.ruf lastz_net (9318): ..ok!
Copying dna-dna alignments for O.sat-O.ruf lastz_net (9319): ..ok!
Copying dna-dna alignments for O.sat-L.per lastz_net (9321): ..ok!
Copying dna-dna alignments for B.rap-B.ole lastz-net (9354): ..ok!
Copying dna-dna alignments for A.tha-B.ole lastz-net (9385): ..ok!
Copying dna-dna alignments for G.max-M.tru lastz-net (9405): ..ok!
Copying dna-dna alignments for O.sat-M.tru lastz-net (9406): ..ok!
Copying dna-dna alignments for A.tha-M.tru lastz-net (9407): ..ok!
Copying dna-dna alignments for M.tru-V.vin lastz-net (9408): ..ok!
Copying dna-dna alignments for A.tha-S.lyc lastz-net (9416): ..ok!
Copying dna-dna alignments for O.sat-S.lyc lastz-net (9418): ..ok!
Copying dna-dna alignments for S.lyc-V.vin lastz-net (9419): ..ok!
Copying dna-dna alignments for S.tub-S.lyc lastz-net (9420): ..ok!
Copying dna-dna alignments for T.cac-A.tha lastz-net (9421): ..ok!
Copying dna-dna alignments for T.cac-V.vin lastz-net (9422): ..ok!
Copying dna-dna alignments for T.cac-O.sat lastz-net (9423): ..ok!
Copying dna-dna alignments for O.glu-O.mer lastz-net (9424): ..ok!
Copying dna-dna alignments for O.glu-O.lon lastz-net (9425): ..ok!
Copying dna-dna alignments for L.per-O.mer lastz-net (9426): ..ok!
Copying dna-dna alignments for L.per-O.lon lastz-net (9427): ..ok!
Copying dna-dna alignments for O.mer-O.pun lastz-net (9428): ..ok!
Copying dna-dna alignments for O.mer-O.ruf lastz-net (9429): ..ok!
Copying dna-dna alignments for O.mer-O.ind lastz-net (9430): ..ok!
Copying dna-dna alignments for O.mer-O.bra lastz-net (9431): ..ok!
Copying dna-dna alignments for O.mer-O.bar lastz-net (9432): ..ok!
Copying dna-dna alignments for O.mer-O.lon lastz-net (9433): ..ok!
Copying dna-dna alignments for O.mer-O.sat lastz-net (9434): ..ok!
Copying dna-dna alignments for O.mer-O.niv lastz-net (9435): ..ok!
Copying dna-dna alignments for O.mer-O.gla lastz-net (9436): ..ok!
Copying dna-dna alignments for O.pun-O.lon lastz-net (9437): ..ok!
Copying dna-dna alignments for O.ruf-O.lon lastz-net (9438): ..ok!
Copying dna-dna alignments for O.ind-O.lon lastz-net (9439): ..ok!
Copying dna-dna alignments for O.bra-O.lon lastz-net (9440): ..ok!
Copying dna-dna alignments for O.bar-O.lon lastz-net (9441): ..ok!
Copying dna-dna alignments for O.lon-O.sat lastz-net (9442): ..ok!
Copying dna-dna alignments for O.lon-O.niv lastz-net (9443): ..ok!
Copying dna-dna alignments for O.lon-O.gla lastz-net (9444): ..ok!
Copying dna-dna alignments for A.tha-O.lon lastz-net (9445): ..ok!
Copying dna-dna alignments for A.tha-O.mer lastz_net (9446): ..ok!
Copying dna-dna alignments for O.sat-Z.may lastz-net (9457): ..ok!
Copying dna-dna alignments for S.ita-Z.may lastz-net (9458): ..ok!
Copying dna-dna alignments for V.vin-Z.may lastz-net (9459): ..ok!
Copying dna-dna alignments for A.tha-Z.may lastz-net (9461): ..ok!
Copying dna-dna alignments for B.dis-Z.may lastz-net (9462): ..ok!
Copying dna-dna alignments for M.acu-Z.may lastz-net (9463): ..ok!
Copying dna-dna alignments for P.pat-Z.may lastz-net (9464): ..ok!
Copying dna-dna alignments for B.dis-T.aes lastz-net (9470): ..ok!
Copying dna-dna alignments for T.aes-T.aes lastz-net (9480): ..ok!
Copying dna-dna alignments for O.sat-T.aes lastz-net (9547): ..ok!
Copying dna-dna alignments for A.tha-S.bic lastz-net (9552): ..ok!
Copying dna-dna alignments for O.sat-S.bic lastz-net (9553): ..ok!
Copying dna-dna alignments for Z.may-S.bic lastz-net (9554): ..ok!
Copying dna-dna alignments for S.ita-S.bic lastz-net (9555): ..ok!
Copying dna-dna alignments for A.tha-V.vin lastz-net (9556): ..ok!
Copying dna-dna alignments for O.sat-H.vul lastz-net (9557): ..ok!
Copying dna-dna alignments for B.dis-H.vul lastz-net (9558): ..ok!
Copying dna-dna alignments for B.dis-O.ind lastz-net (9559): ..ok!

Copying dna-dna alignments for A.tha-A.tri translated-blat-net (9293): ..ok!
Copying dna-dna alignments for A.tri-O.sat translated-blat-net (9295): ..ok!

Copying dna-dna alignments for T.ura-A.tau atac (9409): ..ok!

Copying dna-dna alignments for ara_blastz_update lastz-net (9560): ..ok!

Copying dna-dna alignments for T.aes A-T.aes B lastz-net (9465): ..ok!
Copying dna-dna alignments for T.aes B-T.aes D lastz-net (9466): ..ok!
Copying dna-dna alignments for T.aes A-T.aes D lastz-net (9452): ..ok!

Copying dna-dna alignments for B.dis-T.aes A lastz-net (9467): ..ok!
Copying dna-dna alignments for B.dis-T.aes B lastz-net (9468): ..ok!
Copying dna-dna alignments for B.dis-T.aes D lastz-net (9469): ..ok!

Copying dna-dna alignments for O.sat-T.aes A lastz-net (9453): ..ok!
Copying dna-dna alignments for O.sat-T.aes B lastz-net (9454): ..ok!
Copying dna-dna alignments for O.sat-T.aes D lastz-net (9455): ..ok!
Copying dna-dna alignments for O.sat-T.aes U lastz-net (9456): ..ok!





### OUTPUT FROM STEP 2)

Will be adding MLSS 'A.tha-P.pat lastz-net (on A.tha)' with dbID '9561' requested
Will be adding MLSS 'A.tha-C.rei lastz-net (on A.tha)' with dbID '9562' requested
Will be adding MLSS 'A.tha-A.lyr lastz-net (on A.tha)' with dbID '9563' requested
Will be adding MLSS 'A.tha-B.dis lastz-net (on A.tha)' with dbID '9564' requested
Will be adding MLSS 'A.tha-G.max lastz-net (on A.tha)' with dbID '9565' requested
Will be adding MLSS 'A.tha-O.gla lastz-net (on A.tha)' with dbID '9566' requested
Will be adding MLSS 'A.tha-O.ind lastz-net (on A.tha)' with dbID '9567' requested
Will be adding MLSS 'A.tha-S.moe lastz-net (on A.tha)' with dbID '9568' requested

-------------------------------
Will be adding a total of 8 MLSS objects
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9567]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1558)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1558)]...  from = 0; to = 0; both = 10497   ok.
max_gab 95670001326026 min_gab 95670000000001 max_ga 95670002652058 min_ga 95670000000001 max_gab_gid 5631279 min_gab_gid 3470931
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9561]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1506)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1506)]...  from = 0; to = 0; both = 2113   ok.
max_gab 95610001318810 min_gab 95610000000001 max_ga 95610002637734 min_ga 95610000000001 max_gab_gid 5631908 min_gab_gid 2315711
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9568]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1560)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1560)]...  from = 0; to = 0; both = 766   ok.
max_gab 95680001325181 min_gab 95680000000001 max_ga 95680002650363 min_ga 95680000000001 max_gab_gid 5632739 min_gab_gid 2315427
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9566]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1557)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1557)]...  from = 0; to = 0; both = 1958   ok.
max_gab 95660001318997 min_gab 95660000000001 max_ga 95660002638058 min_ga 95660000000001 max_gab_gid 5539561 min_gab_gid 2324114
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9565]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1556)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1556)]...  from = 0; to = 0; both = 1175   ok.
max_gab 95650001346916 min_gab 95650000000001 max_ga 95650002693844 min_ga 95650000000001 max_gab_gid 5550532 min_gab_gid 2399295
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9562]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1537)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1537)]...  from = 0; to = 0; both = 1565   ok.
max_gab 95620000994476 min_gab 95620000000001 max_ga 95620001988867 min_ga 95620000000001 max_gab_gid 5424362 min_gab_gid 2315389
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9564]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1555)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1555)]...  from = 0; to = 0; both = 90   ok.
max_gab 95640001320056 min_gab 95640000000001 max_ga 95640002640106 min_ga 95640000000001 max_gab_gid 5585949 min_gab_gid 2316329
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9563]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 1554)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 1554)]...  from = 0; to = 0; both = 702   ok.
max_gab 95630001358019 min_gab 95630000000001 max_ga 95630002716038 min_ga 95630000000001 max_gab_gid 5617637 min_gab_gid 2397384





Will be adding MLSS 'B.dis-O.ind lastz-net' with dbID '9559' requested

-------------------------------
Will be adding a total of 1 MLSS objects
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9559]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1555, 1558)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1555, 1558)]...  from = 0; to = 0; both = 10573   ok.
max_gab 95590000287755 min_gab 95590000000001 max_ga 95590000575510 min_ga 95590000000001 max_gab_gid 1831716 min_gab_gid 769784

real    0m11.853s
user    0m5.283s
sys     0m0.243s



Will be adding MLSS 'A.tha-V.vin lastz-net' with dbID '9556' requested

-------------------------------
Will be adding a total of 1 MLSS objects
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9556]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1245, 1505)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1245, 1505)]...  from = 0; to = 0; both = 40   ok.
max_gab 95560000221841 min_gab 95560000000001 max_ga 95560000443682 min_ga 95560000000001 max_gab_gid 880831 min_gab_gid 380241

real    0m8.711s
user    0m3.903s
sys     0m0.179s



Will be adding MLSS 'O.sat-H.vul lastz-net' with dbID '9557' requested

-------------------------------
Will be adding a total of 1 MLSS objects
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9557]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1985, 2088)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1985, 2088)]...  from = 0; to = 0; both = 70   ok.
max_gab 95570000397893 min_gab 95570000000001 max_ga 95570000795786 min_ga 95570000000001 max_gab_gid 3082083 min_gab_gid 1355345

real    0m16.490s
user    0m7.294s
sys     0m0.256s


Will be adding MLSS 'B.dis-H.vul lastz-net' with dbID '9558' requested

-------------------------------
Will be adding a total of 1 MLSS objects
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9558]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1555, 2088)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1555, 2088)]...  from = 0; to = 0; both = 92   ok.
max_gab 95580000888787 min_gab 95580000000001 max_ga 95580001777574 min_ga 95580000000001 max_gab_gid 28805981 min_gab_gid 15778421

real    0m46.773s
user    0m18.352s
sys     0m0.604s



Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9555]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1581, 2089)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1581, 2089)]...  from = 0; to = 0; both = 1203   ok.
max_gab 95550000474406 min_gab 95550000000001 max_ga 95550000948812 min_ga 95550000000001 max_gab_gid 3641285 min_gab_gid 1569860



Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9554]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (2073, 2089)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (2073, 2089)]...  from = 0; to = 0; both = 1134   ok.
max_gab 95540000801680 min_gab 95540000000001 max_ga 95540001603360 min_ga 95540000000001 max_gab_gid 5600633 min_gab_gid 2548119
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9553]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1985, 2089)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1985, 2089)]...  from = 0; to = 0; both = 928   ok.
max_gab 95530000264169 min_gab 95530000000001 max_ga 95530000528338 min_ga 95530000000001 max_gab_gid 1808811 min_gab_gid 750857


Will be adding MLSS 'A.tha-S.bic lastz-net' with dbID '9552' requested

-------------------------------
Will be adding a total of 1 MLSS objects
Checking  table method_link where [method_link_id = 16]...  from = 0; to = 0; both = 1   ok.
Checking  table method_link_species_set where [method_link_species_set_id = 9552]...  from = 0; to = 0; both = 1   ok.
Checking columns [genome_db_id, name, assembly, genebuild] of the table genome_db where [genome_db_id IN (1505, 2089)]...  from = 0; to = 0; both = 2   ok.
Checking  table dnafrag where [genome_db_id != -1 AND genome_db_id IN (1505, 2089)]...  from = 0; to = 0; both = 874   ok.
max_gab 95520000160540 min_gab 95520000000001 max_ga 95520000321080 min_ga 95520000000001 max_gab_gid 543609 min_gab_gid 226933










### OUTPUT FROM STEP 1)





### HC
org.ensembl.healthcheck.testcase.compara.MLSSTagStatsHomology


MLSSs for ENSEMBL_ORTHOLOGUES found with no statistics: 201088,201089,201090,201091,201092,201093,201094,201095,201096,201097,201098,201099,201100,201101,201102,201103,201104,201105,201106,201107,201108,201109,201110,201111,201112,201113,201114,201115,201116,201117,201118,201119,201120,201121,201122,201123,201124,201125,201126,201127,201128,201129,201130,201131,201132,201133,201134,201135,201136,201137,201138,201139,201140,201141,201142,201143,201144,201145,201146,201147,201148,201149,201150,201151,201152,201153,201154,201155,201156,201157,201158,201159,201160,201161,201162,201163,201164,201165,201166,201167,201168,201169,201170,201171,201172,201173,201174,201175,201176,201177,201178,201179,201180,201181,201182,201183,201184,201185,201186,201187,201188,201189,201190,201191,201192,201193,201194,201195,201196,201197,201198,201199,201200,201201,201202,201203,201204,201205,201206,201207,201208,201209,201210,201211,201212,201213,201214,201215,201216,201217,201218,201219,201220,201221,201222,201223,201224,201225,201226,201227,201228,201229,201230,201231,201232,201233,201234,201235,201236,201237,201238,201239,201240,201241,201242,201243,201244,201245,201246,201247,201248,201249,201250,201251,201252,201253,201254,201255,201256,201257,201258,201259,201260,201261,201262,201263,201264,201265,201266,201267,201268,201269,201270,201271,201272,201273,201274,201275,201276,201277,201278,201279,201280,201281,201282,201283,201284,201285,201286,201287,201288,201289,201290,201291,201292,201293,201294,201295,201296,201297,201298,201299,201300,201301,201302,201303,201304,201305,201306,201307,201308,201309,201310,201311,201312,201313,201314,201315,201316,201317,201318,201319,201320,201321,201322,201323,201324,201325,201326,201327,201328,201329,201330,201331,201332,201333,201334,201335,201336,201337,201338,201339,201340,201341,201342,201343,201344,201345,201346,201347,201348,201349,201350,201351,201352,201353,201354,201355,201356,201357,201358,201359,201360,201361,201362,201363,201364,201365,201366,201367,201368,201369,201370,201371,201372,201373,201374,201375,201376,201377,201378,201379,201380,201381,201382,201383,201384,201385,201386,201387,201388,201389,201390,201391,201392,201393,201394,201395,201396,201397,201398,201399,201400,201401,201402,201403,201404,201405,201406,201407,201408,201409,201410,201411,201412,201413,201414,201415,201416,201417,201418,201419,201420,201421,201422,201423,201424,201425,201426,201427,201428,201429,201430,201431,201432,201433,201434,201435,201436,201437,201438,201439,201440,201441,201442,201443,201444,201445,201446,201447,201448,201449,201450,201451,201452,201453,201454,201455,201456,201457,201458,201459,201460,201461,201462,201463,201464,201465,201466,201467,201468,201469,201470,201471,201472,201473,201474,201475,201476,201477,201478,201479,201480,201481,201482,201483,201484,201485,201486,201487,201488,201489,201490,201491,201492,201493,201494,201495,201496,201497,201498,201499,201500,201501,201502,201503,201504,201505,201506,201507,201508,201509,201510,201511,201512,201513,201514,201515,201516,201517,201518,201519,201520,201521,201522,201523,201524,201525,201526,201527,201528,201529,201530,201531,201532,201533,201534,201535,201536,201537,201538,201539,201540,201541,201542,201543,201544,201545,201546,201547,201548,201549,201550,201551,201552,201553,201554,201555,201556,201557,201558,201559,201560,201561,201562,201563,201564,201565,201566,201567,201568,201569,201570,201571,201572,201573,201574,201575,201576,201577,201578,201579,201580,201581,201582,201583,201584,201585,201586,201587,201588,201589,201590,201591,201592,201593,201594,201595,201596,201597,201598,201599,201600,201601,201602,201603,201604,201605,201606,201607,201608,201609,201610,201611,201612,201613,201614,201615,201616,201617,201618,201619,201620,201621,201622,201623,201624,201625,201626,201627,201628,201629,201630,201631,201632,201633,201634,201635,201636,201637,201638,201639,201640,201641,201642,201643,201644,201645,201646,201647,201648,201649,201650,201651,201652,201653,201654,201655,201656,201657,201658,201659
MLSSs for ENSEMBL_PARALOGUES found with no statistics: 201660,201661,201662,201663,201664,201665,201666,201667,201668,201669,201670


org.ensembl.healthcheck.testcase.compara.ForeignKeyMLSSIdHomology

method_link_species_set.method_link_species_set_id 201099 is not linked.
method_link_species_set.method_link_species_set_id 201100 is not linked.
method_link_species_set.method_link_species_set_id 201101 is not linked.
method_link_species_set.method_link_species_set_id 201102 is not linked.
method_link_species_set.method_link_species_set_id 201103 is not linked.
method_link_species_set.method_link_species_set_id 201104 is not linked.
method_link_species_set.method_link_species_set_id 201105 is not linked.
method_link_species_set.method_link_species_set_id 201106 is not linked.
method_link_species_set.method_link_species_set_id 201107 is not linked.
method_link_species_set.method_link_species_set_id 201108 is not linked.
method_link_species_set.method_link_species_set_id 201109 is not linked.
method_link_species_set.method_link_species_set_id 201110 is not linked.
method_link_species_set.method_link_species_set_id 201111 is not linked.
method_link_species_set.method_link_species_set_id 201112 is not linked.
method_link_species_set.method_link_species_set_id 201113 is not linked.
method_link_species_set.method_link_species_set_id 201114 is not linked.
method_link_species_set.method_link_species_set_id 201115 is not linked.
method_link_species_set.method_link_species_set_id 201116 is not linked.
method_link_species_set.method_link_species_set_id 201117 is not linked.
method_link_species_set.method_link_species_set_id 201118 is not linked.
FAILED method_link_species_set -> homology using FK method_link_species_set_id(method_link_species_set_id) relationships
FAILURE DETAILS: 572 method_link_species_set entries are not linked to homology
USEFUL SQL: SELECT method_link_species_set.method_link_species_set_id FROM method_link_species_set LEFT JOIN homology ON method_link_species_set.method_link_species_set_id = homology.method_link_species_set_id WHERE homology.method_link_species_set_id iS NULL AND method_link_species_set.method_link_id >= 201 and method_link_id < 300

homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
homology.method_link_species_set_id 200516 is not linked.
FAILED homology -> method_link_species_set using FK method_link_species_set_id(method_link_species_set_id) relationships
FAILURE DETAILS: 22192876 homology entries are not linked to method_link_species_set
USEFUL SQL: SELECT homology.method_link_species_set_id FROM homology LEFT JOIN method_link_species_set ON homology.method_link_species_set_id = method_link_species_set.method_link_species_set_id WHERE method_link_species_set.method_link_species_set_id iS NULL
