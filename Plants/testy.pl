#!/usr/bin/perl

use strict;
use warnings;

# For debugging
use Data::Dumper;

# Connect to Ensembl and friends
use Bio::EnsEMBL::Registry;


# In this database
my $species = "solanum_lycopersicum";
my $db_type = "core";

warn "Loading the registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db('mysql-eg-staging-1.ebi.ac.uk', 4160, 'ensro', undef)
    or die;

warn "Getting a database adaptor ($db_type:$species)\n";
my $db_adaptor = Bio::EnsEMBL::Registry->
  get_DBAdaptor($species, $db_type)
    or die;

warn "Getting a feature adaptor (Slice)\n";
my $f_adaptor = $db_adaptor->
  get_adaptor('Slice')
    or die;

my $f =
  $f_adaptor->fetch_by_region( 'chromosome', '1', 300_000, 301_000 )
    or die;

my $strainSlice =
  $f->get_by_strain('Moneymaker')
    or die;

# get the sequence from the Strain Slice
my $seq = $strainSlice->seq
    or die;
print substr($seq, 0, 10), "\n";

# get allele features between this StrainSlice and the reference
my $afs =
  $strainSlice->get_all_AlleleFeatures_Slice
    or die;

foreach my $af ( @{$afs} ) {
    print
        "AlleleFeature in position ", $af->start, "-", $af->end,
        " in strain with allele ", $af->allele_string, "\n";
}


__END__

# compare a strain against another strain
my $strainSlice_2 =
  $f->get_by_strain('Thessaloniki')
    or die;

my $dfs =
  $strainSlice->get_all_differences_StrainSlice($strainSlice_2)
    or die;

foreach my $df ( @{$dfs} ) {
    print
        "Difference in position ", $df->start, "-", $df->end,
        " in strain with allele ", $df->allele_string, "\n";
}
