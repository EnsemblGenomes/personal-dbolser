#!/usr/bin/perl

use strict;
use warnings;

use Bio::EnsEMBL::Variation::VariationSet;
use Bio::EnsEMBL::Registry;

use Data::Dumper;

Bio::EnsEMBL::Registry->
    load_all( "test_variation_genotypes.reg" );

my $species = "solanum_lycopersicum";
#my $species = "triticum_aestivum";

# Get adaptor to Variation object
my $va = Bio::EnsEMBL::Registry->
  get_adaptor($species, "variation", "Variation")
  or die "could not get adaptor";

&get_single_var( $va, "vcZWL8FA") ;
#&get_single_var( $va, "vcZ2O06NN") ;

for ( my $i=0; $i <= 9; ++$i ){
    &get_single_var( $va, "vcz10000$i") ;
}

sub get_single_var{

    my $va = shift @_;
    my $locus = shift @_;
    
    my $var = $va->fetch_by_name($locus);
    
    print $var->name , " = ";
    
    if ( $var->has_somatic_source ){ print "fail somatic source test\n" }
    
    my $gts = $var->get_all_IndividualGenotypes();
    
    print scalar @$gts , "\n";
}



