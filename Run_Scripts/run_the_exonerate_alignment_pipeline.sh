# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/
# Exonerate+Alignment+Pipeline


## Ensembl
source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh


## Ensembl Genomes (pick your dir)
libdir=/homes/dbolser/EG_Places/Devel/lib/lib-eg

export PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules


## Databases to use
registry=~/Registries/p1pan.reg
hive_server=mysql-prod-2-ensrw
hive_server=mysql-prod-3-ensrw


## Just for convenience...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
hive_db=${USER}_exonerate_${ensembl_version}


## Select species
run_for=" \
  --species aegilops_tauschii \
  --species hordeum_vulgare \
  --species triticum_aestivum \
  --species triticum_urartu \
"

## Input files (location of the fasta sequences to align)
seqdir=/homes/dbolser/EG_Places/Data/Wheat/Monococcum

## Multiple files are aligned with the same logic_name. These specific
## two can be split out later, but in general you need to run multiple
## files in series.

seq_file_cmd=" \
  --seq_file $seqdir/TmDV92_cDNA.fa \
  --seq_file $seqdir/TmG3116_cDNA.fa \
"

## NOTE NOTE NOTE! If you run in series, you need to specify a custom
## -logic_name each time, or the new run will clobber the old.

## NOTE NOTE NOTE! If you run in series, you need to specicy a custom
## --pipeline_dir each time, or the new run will clobber the old.



## Split input files and results files are written under here
tmpdir=/nfs/nobackup/ensemblgenomes/${USER}/exonerate_alignment



## GO!

## NOTE, exonerate server is currently not working on RH7

init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::ExonerateAlignment_conf \
    $($hive_server details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    $run_for \
    $seq_file_cmd \
    --data_type cdna \
    --use_exonerate_server 0 \
    --max_seq_length_per_file 25000 \
    --hive_force_init 0


    
url=$($hive_server --details url)$hive_db

echo $url; echo $url; echo $url; 

beekeeper.pl -url ${url} -sync
beekeeper.pl -url ${url} -reg_conf ${registry} -loop

## Or perhaps...
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -run


