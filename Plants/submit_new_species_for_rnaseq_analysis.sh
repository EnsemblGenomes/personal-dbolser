
# ## Usage:
# /nfs/production3/ma/home/atlas3-production/sw/islinstall_prod/isl/submitOrganism.sh \
#     submit_access_key \
#     organism \
#     ncbi_tax_id \
#     [ensembl|plants|metazoa|protists|fungi|wbps] \
#     ftp_loc_of_genome_reference_fasta \
#     ftp_loc_of_cdna_reference_fasta \
#     ftp_loc_of_gtf \
#     assemebly_id

# ## EXAMPLE
# /nfs/production3/ma/home/atlas3-production/sw/islinstall_prod/isl/submitOrganism.sh \
#     ebc743db-04af-4456-81cb-6b001c5f6c50 \
#     corchorus_capsularis \
#     210143 \
#     plants \
#     ftp://ftp.ensemblgenomes.org/pub/release-37/plants/fasta/corchorus_capsularis/dna/Corchorus_capsularis.CCACVL1_1.0.dna.toplevel.fa.gz \
#     ftp://ftp.ensemblgenomes.org/pub/release-37/plants/fasta/corchorus_capsularis/cdna/Corchorus_capsularis.CCACVL1_1.0.cdna.all.fa.gz \
#     ftp://ftp.ensemblgenomes.org/pub/release-37/plants/gtf/corchorus_capsularis/Corchorus_capsularis.CCACVL1_1.0.38.gtf.gz \
#     CCACVL1_1.0



## Instead of a specific release, literally use 'DOTrelease-RELNO' in the paths!

## For testing file paths...
real_prefix=.release-
real_release=40

## For actually submitting
fake_prefix=DOTrelease-
fake_release=RELNO

for species in \
    triticum_aestivum \
    daucus_carota \
    vigna_angularis
do
    echo $species
    db=$(mysql-prod-1 -Ne "SHOW DATABASES LIKE \"${species}_core_${real_release}%\"")
    echo $db

    tax_id=$(mysql-prod-1 $db -Ne 'SELECT meta_value FROM meta WHERE meta_key = "species.taxonomy_id"')
    assembly=$(mysql-prod-1 $db -Ne 'SELECT meta_value FROM meta WHERE meta_key = "assembly.name"')

    echo
    echo $tax_id $assembly

    real_gdna=ftp://ftp.ensemblgenomes.org/pub/${real_prefix}${real_release}/plants/fasta/$species/dna/${species^}.${assembly}.dna.toplevel.fa.gz
    real_cdna=ftp://ftp.ensemblgenomes.org/pub/${real_prefix}${real_release}/plants/fasta/$species/cdna/${species^}.${assembly}.cdna.all.fa.gz 
    real_ggtf=ftp://ftp.ensemblgenomes.org/pub/${real_prefix}${real_release}/plants/gtf/$species/${species^}.${assembly}.${real_release}.gtf.gz

    fake_gdna=ftp://ftp.ensemblgenomes.org/pub/${real_prefix}${fake_release}/plants/fasta/$species/dna/${species^}.${assembly}.dna.toplevel.fa.gz
    fake_cdna=ftp://ftp.ensemblgenomes.org/pub/${real_prefix}${fake_release}/plants/fasta/$species/cdna/${species^}.${assembly}.cdna.all.fa.gz 
    fake_ggtf=ftp://ftp.ensemblgenomes.org/pub/${real_prefix}${fake_release}/plants/gtf/$species/${species^}.${assembly}.${fake_release}.gtf.gz

    ## TEST URLs
    true && \
	HEAD -d $real_gdna && \
	HEAD -d $real_cdna && \
	HEAD -d $real_ggtf
    
    result="$?"

    if [ "$result" -ne 0 ]; then
	echo $result
	break
    fi

    /nfs/production3/ma/home/atlas3-production/sw/islinstall_prod/isl/submitOrganism.sh \
	ebc743db-04af-4456-81cb-6b001c5f6c50 \
	$species \
	$tax_id \
	plants \
	$fake_gdna \
	$fake_cdna \
	$fake_ggtf \
	$assembly

    echo
done

