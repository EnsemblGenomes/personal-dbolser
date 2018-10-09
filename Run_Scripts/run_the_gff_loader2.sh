## See http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Load+GFF3+Pipeline

## Screen?

pipeline=load_gff3

## Ensembl
source /homes/dbolser/EG_Places/Devel/lib/libensembl-95/setup.sh

## Sets Ensembl Genomes environment
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=$PERL5LIB:${libdir}/eg-pipelines/modules

ensembl_version=$(perl -MBio::EnsEMBL::ApiVersion -e "print software_version")
echo $ensembl_version

## Where is the core for the above speceis?
#registry=${HOME}/Registries/p1pan.reg
registry=${HOME}/Registries/p2pan.reg
#registry=${HOME}/Registries/p3pan.reg

## Which hive server do you want to use
hive_server=mysql-hive-ensrw

## Where to store junk files
pipeline_dir=/hps/cstor01/nobackup/crop_genomics/Production_Pipelines
pipeline_dir=$pipeline_dir/${USER}/$pipeline/$species

ls $pipeline_dir



## Species
species=dioscorea_rotundata
species=vigna_radiata
species=arabidopsis_halleri

## The GFF and protein FASTA for that species...
# dir=/homes/dbolser/EG_Places/Data/Yam/GFF
# gff3_file=$dir/TDr96_F1_Pseudo_Chromosome_v1.0.gff_20170804.gff3
# protein_fasta_file=$dir/TDr96_F1_v1.0.protein_20170801.fasta

dir=/homes/dbolser/EG_Places/Data/Vigna_radiata
#gff3_file=$dir/GCF_000741045.1_Vradiata_ver6_genomic.gff
#protein_fasta_file=$dir/GCF_000741045.1_Vradiata_ver6_protein.faa
gff3_file=$dir/vigra.VC1973A.gnm6.ann1.M1Qs.gene_models_main-fix.gff3
protein_fasta_file=$dir/vigra.VC1973A.gnm6.ann1.M1Qs.protein.faa.gz

# dir=/homes/dbolser/EG_Places/Data/Arabidopsis_halleri
# gff3_file=$dir/annotation.gff
# protein_fasta_file=$dir/protein.fa

ll $gff3_file $protein_fasta_file



## Do you need GBFF?
# genbank_file=$dir/GCF_000741045.1_Vradiata_ver6_genomic.gbff.gz

# ll $genbank_file



## Can't locate Bio/DB/SeqFeature/Store.pm ??
PERL5LIB=$PERL5LIB:$EG_APIS/bioperl/ensembl-stable
PERL5LIB=$PERL5LIB:$EG_APIS/bioperl/run-stable

#gene_source=IBRC
#gene_source=Gnomon
gene_source=maker
#gene_source=halleri


## Add this if you have GBFF
#    --genbank_file $genbank_file \
#    --genbank_file $genbank_file \

#echo \
time \
init_pipeline.pl \
  Bio::EnsEMBL::EGPipeline::PipeConfig::LoadGFF3_conf \
    $($hive_server details script) \
    --registry $registry \
    --pipeline_dir $pipeline_dir \
    --species $species \
    --gff3_file $gff3_file \
    --protein_fasta_file $protein_fasta_file \
    --gene_source "$gene_source" \
    --hive_force_init 0

## Currently matches what the pipeline sets
hive_db=${USER}_${pipeline}_${species}

url=$($hive_server --details url)$hive_db

echo $url
echo $url | xclip

## Fuck!
url="${url};reconnect_when_lost=1"

beekeeper.pl -url ${url} -sync
runWorker.pl -url ${url} -reg_conf ${registry}
beekeeper.pl -url ${url} -reg_conf ${registry} -loop
