# See
# http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
# Checksum-based+Xref+Pipeline OR
# Alignment-based+Xref+Pipeline OR
# Combined+Xref+Pipeline

pipeline=xref

## Ensembl
source /homes/dbolser/EG_Places/Devel/lib/libensembl-94/setup.sh

## Ensembl Genomes (pick your dir)
#libdir=/homes/dbolser/EG_Places/Devel/lib/lib-eg/eg-pipelines-branch
libdir=/homes/dbolser/EG_Places/Devel/lib/lib-eg/eg-pipelines

export PERL5LIB=$PERL5LIB:${libdir}/modules

#registry=~/Registries/s1pan.reg
#registry=~/Registries/p1pan.reg
registry=~/Registries/p2pan.reg
#registry=~/Registries/p3pan.reg
#registry=~/Registries/d1pan.reg
#registry=~/Registries/d2pan.reg

#hive_server=mysql-prod-1-ensrw
#hive_server=mysql-prod-2-ensrw
hive_server=mysql-prod-3-ensrw
#hive_server=mysql-hive-ensrw

## Just for convenience...
ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version

tmpdir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines/\
${USER}/$pipeline/$ensembl_version
mkdir -p $tmpdir
ls $tmpdir


## Select
run_for="-division EnsemblPlants"
run_for="-species nicotiana_attenuata"



## HIVE TIME!

## CHECKSUM BASED...

## For some reason this stops LoadUniProt from failing... Actually,
## now it seems to /cause/ it to fail!
#export ORACLE_HOME=/sw/arch/dbtools/oracle/product/11.1.0.6.2/client

# MSG: Could not connect to database UAPRO as user uniparc_read using
# [DBI:Oracle:] as a locator: DBI connect('','uniparc_read@UAPRO',...)



#echo \
time \
init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::Xref_conf \
    $($hive_server --details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    $run_for \
    --gene_name_source   reviewed \
    --description_source reviewed \
    --description_source unreviewed \
    --uniprot_xref_external_dbs RefSeq=RefSeq_peptide \
    --uniprot_xref_external_dbs GeneID=EntrezGene \
    --hive_force_init 0

## The pipeline sets it's own name, but it's usefull to guess it
## here...
hive_db=${USER}_${pipeline}_${ensembl_version}

url=$($hive_server details url)$hive_db

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -sleep 0.1
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive

# OR





## ALIGNMENT BASED...

pipeline=alignment_xref

#echo \
time \
init_pipeline.pl Bio::EnsEMBL::EGPipeline::PipeConfig::AlignmentXref_conf \
    $($hive_server --details script) \
    --registry ${registry} \
    --pipeline_dir $tmpdir \
    $run_for \
    --refseq_dna 1 \
    --refseq_peptide 1 \
    --refseq_tax_level plant \
    --hive_force_init 0

#    --refseq_tax_level complete \

hive_db=${USER}_${pipeline}_${ensembl_version}

url=$($hive_server details url)$hive_db

echo $url
echo $url | xclip

## FUCKERELLA!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
beekeeper.pl -url ${url} -reg_conf ${registry} -loop -keep_alive
