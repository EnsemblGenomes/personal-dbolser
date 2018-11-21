#!/bin/env perl

use strict;
use warnings;

use Log::Log4perl qw(:easy);
#Log::Log4perl->easy_init($DEBUG);
Log::Log4perl->easy_init($WARN);

## The list of assumptions made by this script (for speed):

## 0) No existing data in the target variation database.

## 1) One source, ID given below.

## 2) One population, ID given below.

## 2.1) There is exactly one line starting with a single #, which
##      gives the column headers (and the sample list).

## 3) One line per-locus, per-variation. i.e. no multiply mapped
##    variations and no sets of 'overlapping' VCF files.

## 4) Variations have IDs (we don't generate them!).

## 5) GT is the first field of FORMAT (and is unphased). This
##    positional requirement is just for speed, and could be coded to
##    match the format more cleanly.

## 6) A static hash mapping sequence names to internal IDs can be
##    provided as a simple TSV (see MAP below).


## See: 
## https://github.com/Ensembl/ensembl-variation/blob/master/scripts/import/post_process_variation_feature_variation_set.pl
## TODO: Should be unnecessary!




## One variation can only ever be linked to one source!
my $source_id = 1;

## This /could/ be a hash linking individuals to populations...
my $population_id = 1;

## These are those currently used by import_vcf.pl with IDs from the
## schema attribs table.

my %class_attrib_id =
    qw( SNV                  2
        substitution         5
        insertion           10
        deletion            12
        sequence_alteration 18
    );



## We use a file to map 'chromosome names' in the VCF to
## seq_region_ids in the variation database.

## Use something like this to generate the mapping...
## mysql-prod-1 triticum_aestivum_core_27_80_2 -Ne '
##   SELECT name, seq_region_id FROM seq_region
##   INNER JOIN seq_region_attrib USING (seq_region_id)
##   WHERE attrib_type_id = 6
## ' > my.mapping

my %seq_region_id;

#my $mapping_file = 'seq_region_id-hordeum_vulgare_core_25_78_2.mapping';
#my $mapping_file = 'seq_region_id-solanum_lycopersicum_core_27_80_2.mapping';
#my $mapping_file = 'seq_region_id-triticum_aestivum_core_27_80_2.mapping';
my $mapping_file = 'Mapping/seq_region_id-oryza_sativa_core_31_84_7.mapping';

open MAP, '<', $mapping_file
    or die "failed to open mapping file $mapping_file: $?\n";

while(<MAP>){
    chomp;

    my ($name, $seq_region_id) = split/\t/;

    warn "Multiple mappings for '$name'\n"
        if exists $seq_region_id{$name};

    $seq_region_id{$name} = $seq_region_id;
}

warn "got ", scalar keys %seq_region_id, " mappings\n";



## GO

die "pass a vcf at least\n"
  unless @ARGV;

my $outdir = './MySQL';



## The files we're writing
my @file =
    qw( individual
        allele_code
        genotype_code
        population_allele
        population_genotype
        sample_genotype_sbp
        sample_genotype_mbp
        variation
        variation_feature
        variation_set
        variation_set_variation
        variation_synonym
    );

## Open all files for writing
my %file;

for my $file (@file){
    local *FILE;
    open( FILE, '>', "$outdir/$file.tsv")
      or die "failed to open file $outdir/$file.tsv : $!\n";
    $file{$file} = *FILE;
}





## OK

my $variation_id;

my $allele_id;
my $genotype_id;

## The maps we build
my %allele_code;
my %genotype_code;
my %variation_set_id;

while(<>){
    next if /^##/;
    chomp;

    ## Catch the individuals here, you'll need to add columns to this
    ## table as appropriate...
    if (/^#/){
        my @cols = split/\t/;
        my $i = 1;
        my $type = 3; # See the schema
        print { $file{'individual'} } $i++, "\t$_\t$type\n"
            for @cols[9..$#cols];

        next;
    }

    $variation_id++;

    ## See the VCF format to understand this
    my ($chr, $pos, $id, $ref, $alt,

        ## None of these are (currently) used here
        undef, # qual
        undef, # filter

        ## We soemetimes use this for variation sets (else it's unused
        ## here)
        $info, # info

        ## TODO: We should use this correctly, but assume just
        ## "GT". See make_genotype_codes
        undef, # format

        ## We need the sample (genotypes)
        @sample

        ) = split/\t/;

    ## Debugging
    DEBUG(
        join("\t", $chr, $pos, $id, $ref, $alt)
    );

    if (!exists $seq_region_id{$chr}){
        LOGWARN(
            "cant find seq_region_id for '$chr'"
        );
        next;
    }

    ## Calculate the variation 'class' (id) from the alleles
    my $class_attrib_id = 18;

    my @alleles = split(/\,/, $alt);

    ## Hash all alleles into allele codes (%allele_codes)
    make_allele_codes( [$ref, @alleles] );

    ## Skipping this step?
    $class_attrib_id = 
        find_class_attrib($ref, \@alleles);

    ## Variation sets and variation set mappings
    my $variation_set_id_aref = make_variation_set_ids( $info );
    
    ## Print them...
    for (@$variation_set_id_aref){
        print { $file{variation_set_variation} }
          join("\t",
               $variation_id,
               $_,
              ), "\n";
    }



    ## Handle variation synonyms
    my @synonyms = split(/;/, $id);

    ## The first in the list is the 'primary id'
    $id = shift @synonyms;

    ## Print the variation synonyms
    for my $synonym (@synonyms){
        print { $file{variation_synonym} }
        join("\t",
             $variation_id,
             $source_id,
             $synonym,
            ), "\n";
    }



    ## Print the variation
    print { $file{variation} }
    join("\t",
         $variation_id,
         $source_id,
         $id, # name
         # validation_status
         # ancestral_allele
         # flipped
         $class_attrib_id,
         # somatic
         # minor_junk
         # clinical_significance
         # evidence_attribs
        ), "\n";

    ## and the variation feature
    print { $file{variation_feature} }
    join("\t",
         $variation_id, # variation_feature_id
         $seq_region_id{$chr},
         $pos,
         $pos + length($ref) - 1,
         1, # strand
         $variation_id, # variation_id
         join('/', $ref, @alleles),
         $id, # variation_name
         1, # map_weight
         # flags
         $source_id,
         # validation_status
         # consequence_types
         join(',', @$variation_set_id_aref), # variation_set_id
         $class_attrib_id,
         # somatic
         # minor_junk
         # alignment quality
         # evidence_attribs
         # clinical_significance
        ), "\n";



    ## Start processing individual genotypes

    my $individual_id;

    ## We need these counts to calculate frequencies later
    my %population_allele_count;
    my %population_genotype_count;

    for my $sample ( @sample ){
        $individual_id++;

        ## We only care about the GT field (this is horrible)
        ($sample) = split(/:/, $sample);

        ## Ignore samples with no genotype information
        next if $sample eq '.';

        ## Hack to ignore weird genotypes in rice...
        if($sample =~ /^(.\/.)(\/.)*$/){
            $sample = $1;
        }

        next if $sample eq './.';

        ## TESTING SOMETHING
        ## TODO: Use coverage to encode this instead?
        next if $sample eq '0/0';

        ## Debugging
        DEBUG("\t$sample");

        ## Hash all genotypes into genotype codes
        my @genotype =
            make_genotype_codes( [$ref, @alleles], $sample );
        #warn "gt ne 2\n" if @genotype != 2;
        next if @genotype != 2; # ug

        ## WTF, quite frankly
        my $file = $file{individual_genotype_mbp};
        if($class_attrib_id == 2){ ## SNV
            $file = $file{individual_genotype_sbp};
        }

        print $file
            join("\t",
                 $variation_id,
                 # subsnp_id
                 $genotype[0],
                 $genotype[1],
                 $individual_id
                ), "\n";

        ## Collect the population allele counts for later
        $population_allele_count{$_}++
            for @genotype;

        ## Collect the population genotype counts for later
        $population_genotype_count{ join('/', @genotype) }++;
    }



    ## Move on to the final two tables

    my $allele_count_total;
    $allele_count_total += $_
        for values %population_allele_count;

    next unless $allele_count_total;

    ## Note we loop through all possible alleles, not just those we
    ## see in individuals, e.g. the ref may never be seen.
    for ($ref, @alleles){
        $allele_id++;
        print { $file{population_allele} }
        join("\t",
             $allele_id,
             $variation_id,
             # subsnp_id
             $allele_code{$_},
             $population_id,
             ($population_allele_count{$_} || 0) / $allele_count_total,
             ($population_allele_count{$_} || 0),
             # frequency_submitter_handle
            ), "\n";
    }

    my $genotype_count_total;
    $genotype_count_total += $_
        for values %population_genotype_count;

    ## Note, we only loop through those genotypes we've seen!
    for (keys %population_genotype_count){
        $genotype_id++;
        print { $file{population_genotype} }
        join("\t",
             $genotype_id,
             $variation_id,
             # subsnp_id
             $genotype_code{$_},
             $population_genotype_count{$_} / $genotype_count_total,
             $population_id,
             $population_genotype_count{$_},
            ), "\n";
    }
    #exit;
}

print "got $variation_id variations\n";
print "got ", scalar keys %allele_code,   " alleles\n";
print "got ", scalar keys %genotype_code, " genotypes\n";



## Finally, dump them here...
print { $file{allele_code} } "$allele_code{$_}\t$_\n"
    for keys %allele_code;

for my $genotype (keys %genotype_code){
    my $haplotype_id = 0;
    for my $allele (split(/\//, $genotype)){
        $haplotype_id++;
        print { $file{genotype_code} }
        join("\t",
             $genotype_code{ $genotype },
             $allele_code{ $allele },
             $haplotype_id,
             0, # phased
            ), "\n";
    }
}

print { $file{variation_set} } "$variation_set_id{$_}\t$_\n"
    for keys %variation_set_id;




warn "DONE\n";



sub find_class_attrib {
    my $ref = shift;
    my $alt_aref = shift;

    my $ref_len = length($ref);

    my $class_attrib =
        $ref_len == 1 ? 'SNV' : 'substitution';

    my %indel;
    for my $alt (@$alt_aref){
        $indel{ length($alt) <=> $ref_len }++;
    }

    if(0){}

    elsif(defined $indel{+1}){
        if(defined $indel{-1}){
            $class_attrib = 'sequence_alteration';
        }
        else{
            $class_attrib = 'insertion';
        }
    }
    elsif(defined $indel{-1}){
        $class_attrib = 'deletion';
    }

    ## Return the class attrib as an id
    return $class_attrib_id{ $class_attrib };
}

sub make_allele_codes {
    my $allele_aref = shift;

    for my $allele ( @$allele_aref ){
        next if defined( $allele_code{$allele} );
        ## Map codes to an index
        $allele_code{ $allele } =
            1 + (scalar keys %allele_code);
    }
}

sub make_genotype_codes {
    my $allele_aref = shift;
    my $sample = shift;

    ## This is just the way VCF is. TODO: Parse Format correctly here!
    my @genotype =
        @$allele_aref[ split('/', (split(':', $sample))[0]) ];
    my $genotype = join('/', @genotype);
    $genotype_code{ $genotype } = 1 + scalar keys %genotype_code
        unless defined $genotype_code{ $genotype };

    # usefull side effect:
    return @genotype;
}

sub make_variation_set_ids {
    my $info = shift;
    my @ids;

    for my $field (split(/;/, $info)){
        DEBUG("$field");
        my ($key, $value) =
            split(/=/, $field, 2);
        if ($key eq 'STUDY'){
            for my $study (split(/,/, $value)){

                ## Map studies to an id...
                $variation_set_id{ $study } =
                    1 + (scalar keys %variation_set_id)
                        unless defined $variation_set_id{ $study };

                ## Store them
                push @ids, $variation_set_id{ $study };

            }
        }
    }
    return \@ids;
}

