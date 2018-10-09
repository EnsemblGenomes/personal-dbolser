
pipeline_name=ortholog_qm_alignment

libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl-93
source ${libdir}/setup.sh

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

division=plants

release=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
release_eg=$(echo $release-53 | bc)

comp_server=mysql-prod-1-ensrw
comp_db=ensembl_compara_${division}_${release_eg}_${release}

mast_server=mysql-pan-prod
mast_db=plants_40_93_compara_master

hive_server=mysql-prod-1-ensrw


echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::Compara::PipeConfig::OrthologQM_Alignment_conf \
    $($hive_server details script) \
    -password $($hive_server pass) \
    -compara_db $($comp_server --details url)${comp_db} \
    -master_db  $($mast_server --details url)${mast_db} \
    -species_set_name collection-${division} \
    -current_release $release \
    -hive_force_init 0

## ??
pipeline_name=wga

url=$($hive_server --details url)\
${USER}_${pipeline_name}_${release}

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"


beekeeper.pl -url $url -sync
beekeeper.pl -url $url -loop 





#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::Compara::PipeConfig::HighConfidenceOrthologs_conf \
    $($hive_server details script) \
    -password $($hive_server pass) \
    -compara_db $($comp_server --details url)${comp_db} \
    -hive_force_init 0

pipeline_name=high_confidence_orthologs

url=$($hive_server --details url)\
${USER}_${pipeline_name}_${release}

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"


beekeeper.pl -url $url -sync
runWorker.pl -url $url
beekeeper.pl -url $url -loop 

