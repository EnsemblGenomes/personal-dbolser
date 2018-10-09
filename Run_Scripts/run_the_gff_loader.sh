## See http://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## GFF+import

### Run the GFF loader

## Screen?



## FILE
#gff=GCA_000003195.3_Sorghum_bicolor_NCBIv3_genomic_chr_only.gff
gff=TDr96_F1_Pseudo_Chromosome_v1.0.gff_20170804.gff3

## CORE SERVER
core_server=mysql-prod-1-ensrw
#core_server=mysql-prod-2-ensrw

## CORE
#core_db=sorghum_bicolor_core_36_89_30
core_db=dioscorea_rotundata_core_38_91_2

source /nfs/panda/ensemblgenomes/apis/ensembl/current/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/83/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/85/setup.sh
#source /nfs/panda/ensemblgenomes/apis/ensembl/89/setup.sh

## Sets Ensembl Genomes environment
libdir=${HOME}/EG_Places/Devel/lib/lib-eg
PERL5LIB=$PERL5LIB:${libdir}/eg-gffloader/lib

## NEED TO FIX THE STRAND OF THE GENE FEATUES IN THE DEFAULT GFF!?
## See fix_strand.plx

# ## Now run the import (SLOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOW)
# perl ensembl_genomes/GffDoc/bin/GffDoc.pl \
#     $($core_server details naga) \
#     -dbname $core_db \
#     -coordsystem superscaffold \
#     -leafnonunique \
#     -file $gff

## OR...

## Split the files (FASTERISH)

perl \
    $libdir/eg-gffloader/bin/split_gff.plx \
    --genes-per-file 2000 \
    $gff



## And...

#time source /nfs/software/ensembl/RHEL7/envs/basic.sh
time source /nfs/software/ensembl/latest/envs/basic.sh

bsub -q production-rh7 -n 10 -Is -XF $SHELL

## Spits out a bunch of GFF
for f in \
    gff_file-*.gff; do
    
    echo $f;
    
    ## THIS RECIPY IS FOR GFF FOR YAM
    perl \
        $libdir/eg-gffloader/bin/GffDoc.pl \
        $($core_server --details script) \
        --dbname $core_db \
        --coordsystem supercontig \
        --ignore_id_duplicates \
        --non_coding_cds \
        --file $f \
        |& tee -a $f.out
    
done





    ## THIS RECIPY IS FOR GFF DOWNLOADED FROM GenBank
    perl \
        $libdir/eg-gffloader/bin/GffDoc.pl \
        $($core_server --details script) \
        --dbname $core_db \
        --coordsystem chromosome \
        --leafnonunique \
        --force_nasty_endings \
        --type region=ignore \
        --file $f \
        |& tee -a $f.out



exit;


    ## THIS RECIPY IS FOR GTF FROM MIPS (I THINK).
    perl $libdir/eg-gffloader/bin/GffDoc.pl \
        $($core_server --details script) \
        --dbname $core_db \
        --coordsystem chromosome \
        -M GffDoc::Convert::Gtf:e \
        --gtf \
        --type transcript=ignore \
        --type 3UTR=ignore \
        --type 5UTR=ignore \
        --non_protein_coding \

        --file $f \
        &> $f.out &
