## http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## SRA+Study+Pipeline

source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh

## Note the above source is buggy, and leaves a trailing ':' in
## PERL5LIB
export PERL5LIB=${PERL5LIB}/nfs/panda/ensemblgenomes/development/dbolser/lib/lib-eg/eg-pipelines/modules
export PERL5LIB=${PERL5LIB}:/nfs/panda/ensemblgenomes/development/dbolser/lib/lib-eg/eg-ena/modules

export PATH=/nfs/panda/ensemblgenomes/external/samtools:$PATH
export PATH=/nfs/panda/ensemblgenomes/external/bwa:$PATH
export PATH=/nfs/panda/ensemblgenomes/external/gmap-gsnap/bin:$PATH
export PATH=/nfs/panda/ensemblgenomes/external/STAR:$PATH

dbserver=mysql-staging-1-ensrw
tmpdir=/nfs/nobackup2/ensemblgenomes/dbolser/sra

core_db_name=musa_acuminata_core_22_75_1
study=SRS373715

core_db_name=theobroma_cacao_core_23_76_1
study=SRP004925

init_pipeline.pl \
    Bio::EnsEMBL::ENA::SRA::PipeConfig::ProcessStudies_conf \
    $( ${dbserver} --details script_core_db_ ) \
    -core_db_name ${core_db_name} \
    -work_directory ${tmpdir} \
    -cleanup \
    -study ${study}


beekeeper.pl -url sqlite:///process_studies -sync
beekeeper.pl -url sqlite:///process_studies -loop


