#!perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

# ## Use these for Ensembl examples:
# my $host = 'ensembldb.ensembl.org';
# my $user = 'anonymous';
# my $port = '3306';
# my $compara_db = 'ensembl_compara_74';

# ## Ensembl example:
# my $ref_species = 'mouse';
# my $alt_species = 'human';
# my @slice_data = ('chromosome', 'X', 105_500_250, 105_500_638);
# my @slice_data = ('chromosome', 'X',  67_829_178,  67_832_345);

## Use these for Ensembl Genomes examples:
my $host = 'mysql-eg-staging-1.ebi.ac.uk';
my $user = 'ensro';
my $port = '4160';

# my $host = 'mysql.ebi.ac.uk';
# my $user = 'anonymous';
# my $port = '4157';

my $compara_db = 'ensembl_compara_plants_21_74';

# ## Ensembl Genomes example:
# my $ref_species = 'brachypodium_distachyon';
# my $alt_species = 'triticum_aestivum';
# my @slice_data = ('chromosome', '3',  13_066_450,  13_068_287);
# #my @slice_data = ('chromosome', '3',  13_056_450,  13_078_287);

# ## Ensembl Genomes example 2:
my $ref_species = 'oryza_sativa';
my $alt_species = 'aegilops_tauschii';
my @slice_data = ('chromosome', '1',  3_001, 23_000);



## Get a registry the canonical way
print "getting a registry\n";
Bio::EnsEMBL::Registry->load_registry_from_db(
  -host => $host,
  -user => $user,
  -port => $port,
  -db_version => 74,
);

print "getting a slice adaptor\n";
my $slice_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor( $ref_species, 'Core', 'Slice' )
    or die;
print $slice_adaptor, "\n\n";

## May as well do this here
print "getting a slice\n";
my $slice = $slice_adaptor->
  fetch_by_region( @slice_data )
    or die;
print $slice, "\n\n";



# Getting a compara database adaptor. Not sure why this is explicitly
# needed, i.e. why get_adaptor as above fails for the adaptors below.
print "getting a compara db adaptor\n";
my $compara_db_adaptor = Bio::EnsEMBL::Compara::DBSQL::DBAdaptor->
  new( -host => $host,
       -user => $user,
       -port => $port,
       -dbname => $compara_db,
     )
    or die;
print $compara_db_adaptor, "\n";

## Old script uses DAF
print "getting a DnaAlignFeature (daf) adaptor\n";
my $dna_align_feature_adaptor = $compara_db_adaptor->
  get_adaptor("DnaAlignFeature")
    or die;
print $dna_align_feature_adaptor, "\n\n";

## New script uses GAB (via MLSS (via GenomeDB))...
print "getting a GenomeDB (gdb) adaptor\n";
my $genome_db_adaptor = $compara_db_adaptor->
  get_adaptor("GenomeDB")
    or die;
print $genome_db_adaptor, "\n\n";

print "geting a MethodLinkSpeciesSet (mlss) adaptor\n";
my $mlss_adaptor = $compara_db_adaptor->
  get_adaptor("MethodLinkSpeciesSet")
    or die;
print $mlss_adaptor, "\n\n";

print "geting a GenomicAlignBlock (gab) adaptor\n";
my $gab_adaptor = $compara_db_adaptor->
  get_adaptor("GenomicAlignBlock")
    or die;
print $gab_adaptor, "\n\n";





## LOOKING AT interpolate_best_location

print "running interpolate_best_location\n";
# DnaAlignFeatureAdaptor.pm
my ($seq_region, $center_point, $strand) = $dna_align_feature_adaptor->
  interpolate_best_location( $slice, $alt_species, 'LASTZ_NET' )
    or die;
print "Got: $seq_region\t$center_point\t$strand\n\n\n";





## Fuck that then!

print "getting align features for LASTZ_NET\n";
my $dna_align_features =
    $dna_align_feature_adaptor->
        fetch_all_by_Slice($slice, $alt_species, undef, 'LASTZ_NET');
print "got ", scalar @$dna_align_features, " align features\n\n";

for (@$dna_align_features){
    print $_, "\n";
    printf
        "%-30s %-30s %9d %9d %3d %9d %9d %3d\n",
        $_->seq_region_name,
        $_->species,
        $_->start,
        $_->end,
        $_->strand,
        $_->seq_region_start,
        $_->seq_region_end,
        $_->seq_region_strand;
    
    printf
        "%-30s %-30s %9d %9d %3d %9d %9d %3d %3d\n",
        $_->hseq_region_name,
        $_->hspecies,
        $_->hstart,
        $_->hend,
        $_->hstrand,
        $_->hseq_region_start,
        $_->hseq_region_end,
        $_->hseq_region_strand,
        ## Does it match above?
        $_->hseq_region_name eq $seq_region &&
        $_->hstart < $center_point &&
        $_->hend   > $center_point &&
        $_->hstrand;

    print "LEN:",      $_->alignment_length, "\n";
    print "SCORE:",    $_->score || 'unk', "\n";
    #print "PERC:",     $_->percent_id, "\n";
    #print "PVAL",      $_->p_value, "\n";
    #print "COV:",      $_->coverage, "\n";
    #print "IDENT:",    $_->identical_matches, "\n";
    #print "POS:",      $_->positive_matches, "\n";
    print "GROUP ID:", $_->group_id, "\n";
    print "LEVEL_ID:", $_->level_id, "\n";
    print join("\n", @{$_->alignment_strings}), "\n";

    print "\n";
}

print "\n";
print "\n";



## Now then...

my %daf_groups;

## Group DAFs by their group_ids
foreach my $daf (@$dna_align_features) {
    push @{$daf_groups{$daf->group_id}}, $daf;
}
  
## Find the best scoring daf_group
my %daf_group_scores;
for my $group_id (sort keys %daf_groups){
    my $dafs = 
    my $matches;
    my $length;
    for my $daf (@$dafs){
        my $alignment_strings = $daf->alignment_strings;
        #print join("\n", @{$daf->alignment_strings}), "\n";
        $length  += length($alignment_strings->[0]);
        $matches +=
            ($alignment_strings->[0] ^
             $alignment_strings->[1]) =~ tr/\0//;
    }
    $daf_group_scores{$group_id} = $matches/$length;
    print
        join("\t",
             $group_id, 
             scalar @$dafs,
             $dafs->[0]->hseq_region_name,
             $matches, $length,
             $matches/$length
        ), "\n";
}

print "\n";
print "\n";

my $best_group =
    (sort {$daf_group_scores{$b} <=> $daf_group_scores{$a}} keys %daf_group_scores)[0];

print $best_group, "\n";

## Get some stats for the best group...
my $min_start = +1_000_000_000_000_000_000;
my $max_end   = -1_000_000_000_000_000_000;

for (@{$daf_groups{$best_group}}){
    print $_->hseq_region_name, "\n";
    print $_->hstrand, "\n";
    $min_start = $_->hstart if $_->hstart < $min_start;
    $max_end   = $_->hend   if $_->hend   > $max_end;
}

print "$min_start\t$max_end\n";





## FUCK THAT THEN!!!



## OK, breath deeply

my $ref_species_gdb = $genome_db_adaptor->
  fetch_by_registry_name($ref_species)
    or die;
print $ref_species_gdb, "\n\n";

my $alt_species_gdb = $genome_db_adaptor->
  fetch_by_registry_name($alt_species)
    or die;
print $alt_species_gdb, "\n\n";

my $mlss = $mlss_adaptor->
  fetch_by_method_link_type_GenomeDBs(
      'LASTZ_NET', [$ref_species_gdb, $alt_species_gdb])
    or die;
print $mlss, "\n\n";

my $gabs = $gab_adaptor->
  fetch_all_by_MethodLinkSpeciesSet_Slice($mlss, $slice)
    or die;
print $gabs, "\n\n";

## debugging
#$_->_print for @$gabs;





## Now then...

my %gab_groups;
my %gab_group_scores;

## Group GABs by their group_ids AND collect the score for the group.
foreach my $gab (@$gabs) {
    ## Sanity check...
    die if @{$gab->get_all_GenomicAligns} != 2;
    push @{$gab_groups{$gab->group_id}}, $gab;
    
    ## Note, the score is *often* the same for each GAB in a given
    ## group. In such cases the score should be the score for the
    ## chain. However, the score isn't always the same for each GAB!
    ## In such cases is this the score for the GAB?
    $gab_group_scores{$gab->group_id} = $gab->score
        if $gab_group_scores{$gab->group_id} || 0 < $gab->score;
}    


my $best_gab_group =
    (sort {$gab_group_scores{$b} <=> $gab_group_scores{$a}}
     keys %gab_group_scores)[0];

print $best_gab_group, "\n";

## Get some stats for the best group...
my $min_start = +1_000_000_000_000_000_000;
my $max_end   = -1_000_000_000_000_000_000;

for (@{$gab_groups{$best_gab_group}}){
    print $_->hseq_region_name, "\n";
    print $_->hstrand, "\n";
    $min_start = $_->hstart if $_->hstart < $min_start;
    $max_end   = $_->hend   if $_->hend   > $max_end;
}

print "$min_start\t$max_end\n";

