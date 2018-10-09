# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
# ncRNA+prediction+pipelines # OLD
# RNA+Features+Pipeline      # NEW PART 1
# RNA+Genes+Pipeline         # NEW PART 2

## Screen?

## Begin
pipeline_name=rna_features

## Ensembl
#libensembl=/nfs/panda/ensemblgenomes/apis/ensembl/current
#libensembl=/nfs/panda/ensemblgenomes/apis/ensembl/87
#libensembl=/homes/dbolser/EG_Places/Devel/lib/libensembl-93
libensembl=/homes/dbolser/EG_Places/Devel/lib/libensembl-94

source $libensembl/setup.sh

## Ensembl Genomes
lib_eg=/homes/dbolser/EG_Places/Devel/lib/lib-eg
PERL5LIB=$PERL5LIB:${lib_eg}/eg-pipelines/modules

## Check PERL5LIB
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'

## Check Ensembl
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version



## Set the speceis...
species_cmd=" \
    --division plants \
"

species_cmd=" \
    --species nicotiana_attenuata \
"

## Where are the cores for the above species?
#registry=${HOME}/Registries/p1pan.reg
registry=${HOME}/Registries/p2pan.reg

## Where do we want to store the hive database
#hive_server=mysql-hive-ensrw
#hive_server=mysql-prod-2-ensrw
hive_server=mysql-prod-3-ensrw

## Where do we want temporary files
tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines
tmpdir=$tmpdir/${USER}/$pipeline_name

mkdir $tmpdir
ls $tmpdir

## Random...
pipe_dir=${lib_eg}/eg-pipelines





## MIRBASE....

mirbase_dir=/nfs/panda/ensemblgenomes/external/data/mirbase

## Do this as the ensgen user...
cd $mirbase_dir
wget ftp://mirbase.org/pub/mirbase/CURRENT/genomes/*.gff3


## Get GCA from the files

## Naturally, this is a hack...
grep genome-build-accession *.gff3 > accessions


## Get GCA for the cores

list=/homes/dbolser/Plants/Lists/plant_list-41.txt

while read core
do
    echo -ne "$core\t"
    mysql-prod-2 $core -Ne "
      SELECT meta_value FROM meta WHERE meta_key = \"assembly.accession\""
done \
    < <(grep _core_ $list) \
    > /tmp/puke2

cut -f 2 /tmp/puke2

grep -wf <( cut -f 2 /tmp/puke2 ) accessions | tee /tmp/puke3

# aly.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000004255.1
# ath.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000001735.1
# bra.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000309985.1
# cst.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000004075.2
# gma.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000004515.3
# gra.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000327365.1
# ppe.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000346465.2
# pvu.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000499845.1
# sbi.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000003195.3
# sly.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000188115.2
# stu.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000226075.1
# vvi.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000003745.2
# zma.gff3:# genome-build-accession:  NCBI_Assembly:GCA_000005005.6


grep -wf <( cut -d: -f 4 /tmp/puke3 ) /tmp/puke2

# arabidopsis_lyrata_core_40_93_10	GCA_000004255.1
# arabidopsis_thaliana_core_40_93_11	GCA_000001735.1
# brassica_rapa_core_40_93_1		GCA_000309985.1
# cucumis_sativus_core_40_93_2		GCA_000004075.2
# glycine_max_core_40_93_3		GCA_000004515.3
# gossypium_raimondii_core_40_93_1	GCA_000327365.1
# phaseolus_vulgaris_core_40_93_1	GCA_000499845.1
# prunus_persica_core_40_93_2		GCA_000346465.2
# solanum_lycopersicum_core_40_93_250	GCA_000188115.2
# solanum_tuberosum_core_40_93_4	GCA_000226075.1
# sorghum_bicolor_core_40_93_30		GCA_000003195.3
# vitis_vinifera_core_40_93_3		GCA_000003745.2
# zea_mays_core_40_93_7			GCA_000005005.6


## And together...

mirbase_cmd=" \
    --mirbase_file   arabidopsis_lyrata=$mirbase_dir/aly.gff3 \
    --mirbase_file arabidopsis_thaliana=$mirbase_dir/ath.gff3 \
    --mirbase_file        brassica_rapa=$mirbase_dir/bra.gff3 \
    --mirbase_file      cucumis_sativus=$mirbase_dir/cst.gff3 \
    --mirbase_file          glycine_max=$mirbase_dir/gma.gff3 \
    --mirbase_file  gossypium_raimondii=$mirbase_dir/gra.gff3 \
    --mirbase_file   phaseolus_vulgaris=$mirbase_dir/pvu.gff3 \
    --mirbase_file       prunus_persica=$mirbase_dir/ppe.gff3 \
    --mirbase_file solanum_lycopersicum=$mirbase_dir/sly.gff3 \
    --mirbase_file      sorghum_bicolor=$mirbase_dir/sbi.gff3 \
    --mirbase_file       vitis_vinifera=$mirbase_dir/vvi.gff3 \
    --mirbase_file             zea_mays=$mirbase_dir/zma.gff3 \
"

##    -mirbase_file solanum_tuberosum       = stu.gff3 \ ??





## HIVE TIME!

## RNA+Features+Pipeline

#time source /nfs/software/ensembl/latest/envs/basic.sh

#echo \
time \
init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::RNAFeatures_conf \
    $($hive_server --details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    --eg_pipelines_dir $pipe_dir \
    --cmscan_cpu 3 \
    ${species_cmd} \
    ${mirbase_cmd} \
    --taxonomic_lca 1 \
    --hive_force_init 0




hive_db=${USER}_${pipeline_name}_${ensembl_version}

url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive





## HIVE TIME!

## RNA+Genes+Pipeline

pipeline_name=rna_genes

ID_DB_PASS=$(mysql-pan-prod-ensrw pass)

#echo \
time \
init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::RNAGenes_conf \
    $($hive_server --details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    --id_db_pass $ID_DB_PASS \
    ${species_cmd} \
    --all_new_species 1 \
    --allow_coding_overlap 1 \
    --maximum_per_hit_name snoRNA=100 \
    --score_threshold 65 \
    --maximum_per_hit_name "{ 'pre_miRNA' => 100, 'ribozyme' => 100 }" \
    --hive_force_init 0

hive_db=${USER}_${pipeline_name}_${ensembl_version}

url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive








## DELETE OLD ALIGNMENTS??

list=~/Plants/plant_list-35.txt

time \
while read -r core; do 
    mysql-prod-1 ${core/_core_35_88_/_core_36_89_} --table -Ne '
      SELECT
        DATABASE(),
        analysis_id,
        created,
        logic_name,
        COUNT(*) AS N
      FROM
        dna_align_feature INNER JOIN analysis USING(analysis_id)
      GROUP BY
        2
     '
done < \
    <( grep _core_ ${list} )







## DELETE OLD GENES FOR STABLE_ID_MAPPING?





## Find the list of logic names somehow (copy the above)...

## And...

time \
while read -r core; do
    mysql-prod-1 ${core/_core_35_88_/_core_36_89_} -Ne \
        "SELECT DISTINCT DATABASE(), logic_name
         FROM gene INNER JOIN analysis USING(analysis_id)
         WHERE logic_name IN (\"ncrna_eg\")"
done < \
    <( grep _core_ ${list} )

## Scrobble the result into this...

logic_name=ncrna_eg
logic_name=rfam_genes

for species in \
    amborella_trichopoda \
    brassica_rapa \
    cyanidioschyzon_merolae \
    hordeum_vulgare \
    medicago_truncatula \
    prunus_persica \
    solanum_lycopersicum \
    solanum_tuberosum \
    triticum_urartu

for species in \
    sorghum_bicolor \
    triticum_aestivum
do
    #echo \
    time \
    standaloneJob.pl Bio::EnsEMBL::EGPipeline::RNAFeatures::DeleteGenes \
        -reg_conf ${registry} \
        -species $species \
        -logic_name $logic_name
done




