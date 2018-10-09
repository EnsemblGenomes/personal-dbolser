# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# Short+Read+Alignment+Pipeline


## Ensembl
source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh


## Ensembl Genomes (pick your dir)
libdir=/homes/dbolser/EG_Places/Devel/lib/lib-eg

export PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules
export PERL5LIB=$PERL5LIB:${libdir}/eg-ena/modules


## Databases to use
registry=~/Registries/p1pan.reg
hive_server=mysql-prod-3-ensrw


## Just for convenience...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
hive_db=${USER}_short_read_alignment_${ensembl_version}


## Select species
run_for="--species triticum_aestivum"


## Input files
seqdir=/homes/dbolser/EG_Places/Data/Wheat/Monococcum
seq_file_cmd="--seq_file $seqdir/TmDV92_cDNA.fa"


## We overload this currently...
tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/short_read_alignment



## GO!

init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::ShortReadAlignment_conf \
    $($hive_server details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    --results_dir $tmpdir \
    --index_dir $tmpdir \
    $run_for \
    $seq_file_cmd \
    --aligner star \
    --run_mode long_reads \
    --bigwig 1 \
    --hive_force_init 0

# USING STAR? DON'T USE THIS, USE INDEX MODE HIMEM OPTION INSTEAD!!
    --index_memory_high 1 \


url=$($hive_server --details url)$hive_db

echo $url; echo $url; echo $url; 

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop

## Or perhaps...
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -run


/nfs/panda/ensemblgenomes/external/STAR/STAR --runMode genomeGenerate --genomeDir /nfs/nobackup/ensemblgenomes/dbolser/short_read_alignment/star/triticum_aestivum/ --genomeFastaFiles /nfs/nobackup/ensemblgenomes/dbolser/short_read_alignment/star/triticum_aestivum/triticum_aestivum.fa --runThreadN 4 --limitGenomeGenerateRAM 66000000000 
