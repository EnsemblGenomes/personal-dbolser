# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# Exonerate+Alignment+Pipeline

pipeline_name=exonerate_83



## Define our species (note, use -division EnsemblPlants if that's
## what you want)
species_cmd="\
  --species amborella_trichopoda \
  --species prunus_persica \
  --species oryza_barthii \
  --species oryza_glumaepatula \
  --species oryza_meridionalis \
  --species oryza_nivara \
  --species oryza_punctata \
"
species_cmd="\
  --species oryza_longistaminata \
"
species_cmd="\
  --species solanum_lycopersicum \
"
species_cmd="\
  --division EnsemblPlants \
  --antispecies triticum_aestivum \
"

species_cmd="\
  --species triticum_aestivum \
"



fadir=/nfs/production/panda/ensemblgenomes/data/Plants/Wheat/IWGSC_3B

seq_file_cmd="\
  --seq_file $fadir/ta3bPseudomolecule.cds.fna \
  --seq_file $fadir/ta3bUnlocalized.cds.fna \
"



## My lib
#libdir=/nfs/panda/ensemblgenomes/apis/ensembl/current
#libdir=/nfs/panda/ensemblgenomes/apis/ensembl/83
libdir=/homes/dbolser/EG_Places/Devel/lib/libensembl

## This sets Ensembl environment (PERL5LIB and ENSEMBL_ROOT_DIR)...
source ${libdir}/setup.sh

## Sets Ensembl Genomes environment
#PERL5LIB=$PERL5LIB:${ENSEMBL_ROOT_DIR}/../../eg-pipelines/modules
PERL5LIB=$PERL5LIB:${ENSEMBL_ROOT_DIR}/../lib-eg/eg-pipelines/modules

## Check...
perl -e 'print join("\n", split(/:/, $ENV{PERL5LIB})), "\n"'



## Moving on
registry=/homes/dbolser/Registries/p2pan-wheat.reg

hive_server=mysql-prod-1-ensrw

tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/exonerate_alignment_pipeline



init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::ExonerateAlignment_conf \
    $($hive_server details script) \
    -registry ${registry} \
    -pipeline_dir $tmpdir \
    $species_cmd \
    $seq_file_cmd \
    -data_type cdna \
    -make_genes 1 \
    -logic_name exonerate_3b \
    -delete_existing 0 \
    -reformat_header 0 \
    -hive_force_init 1

hive_db=${USER}_${pipeline_name}
url=$($hive_server --details url)$hive_db

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop

## Or perhaps...
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -run
