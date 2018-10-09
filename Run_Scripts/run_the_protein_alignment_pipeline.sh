# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# Protein+Alignment+Pipeline


## Ensembl
source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh


## Ensembl Genomes (pick your dir)
libdir=/homes/dbolser/EG_Places/Devel/lib/lib-eg

export PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules


## Databases to use
registry=~/Registries/p1pan.reg
hive_server=mysql-prod-3-ensrw


## Just for convenience...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
hive_db=${USER}_blast_protein_${ensembl_version}


## Select species
run_for="--species triticum_aestivum"


## Input files
seqdir=/homes/dbolser/EG_Places/Data/Wheat/Monococcum
seq_file_cmd="--db_fasta_file $seqdir/TmDV92_pep.fa"


## We overload this currently...
tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/blast_protein



## GO!

echo \
time \
init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::BlastProtein_conf \
    $($hive_server details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    $run_for \
    $seq_file_cmd \
    --blastp 0 \
    --hive_force_init 0

url=$($hive_server --details url)$hive_db

echo $url; echo $url; echo $url; 

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop

## Or perhaps...
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -run
