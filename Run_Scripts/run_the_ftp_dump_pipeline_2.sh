## See:
## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## DNA+Features+Pipeline (Hive)

## Screen?
pipeline=file_dump

## Ensembl
source /homes/dbolser/EG_Places/Devel/lib/libensembl-92/setup.sh
#source /homes/dbolser/EG_Places/Devel/lib/libensembl/setup.sh

## Sets Ensembl Genomes environment
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules

ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version



## Set the speceis
species_cmd=" \
  --species triticum_aestivum \
"

# species_cmd=" \
#   --division             EnsemblPlants \
# "



## Where are the cores for the above species?
#registry=${HOME}/Registries/p1pan.reg
registry=${HOME}/Registries/p2pan.reg
#registry=${HOME}/Registries/p3pan.reg

## Set the tmpdir
tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines
tmpdir=$tmpdir/${USER}/$pipeline
mkdir -p $tmpdir

ls $tmpdir



## OK, HIVE TIME...

#hive_server=mysql-devel-1-ensrw
#hive_server=mysql-devel-2-ensrw
#hive_server=mysql-devel-3-ensrw
hive_server=mysql-prod-1-ensrw
#hive_server=mysql-prod-2-ensrw
#hive_server=mysql-prod-3-ensrw
#hive_server=mysql-hive-ensrw

#echo \
time \
init_pipeline.pl \
    Bio::EnsEMBL::EGPipeline::PipeConfig::FileDump_conf \
    $($hive_server --details script) \
    -registry ${registry} \
    -base_dir $tmpdir \
    $species_cmd \
    -skip_dumps fasta_toplevel \
    -skip_dumps fasta_transcripts \
    -skip_dumps fasta_peptides \
    -skip_dumps gtf_genes \
    -skip_dumps gff3_genes \
    -hive_force_init 0

## Currently matches what the pipeline sets (but could change)
hive_db=${USER}_${pipeline}_${ensembl_version}

url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

##
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive
