#!perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

Bio::EnsEMBL::Registry->load_registry_from_db(
  -host => 'mysql.ebi.ac.uk',
  -user => 'anonymous',
  -port => '4157',
  -db_version => 74,
);

my $slice_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor( 'brachypodium_distachyon', 'Core', 'Slice' )
    or die;
print $slice_adaptor, "\n";

my $slice = $slice_adaptor->
  fetch_by_region( 'chromosome', '3', 13_066_450, 13_068_287 )
    or die;
print $slice, "\n";

# Is there a better way to do this? The canonical 'get_adaptor' method
# fails here...
my $compara_db_adaptor = Bio::EnsEMBL::Compara::DBSQL::DBAdaptor->
  new( -host => 'mysql.ebi.ac.uk',
       -user => 'anonymous',
       -port => '4157',
       -dbname => 'ensembl_compara_plants_21_74',
     )
    or die;
print $compara_db_adaptor, "\n";

my $dna_align_feature_adaptor = $compara_db_adaptor->
  get_DnaAlignFeatureAdaptor
    or die;
print $dna_align_feature_adaptor, "\n";

my ($seq_region, $cp, $strand) = $dna_align_feature_adaptor->
  interpolate_best_location( $slice, 'triticum_aestivum', 'LASTZ_NET' )
    or die;
print "Seq region: $seq_region:$cp:$strand\n";

## Keep looking then eh?
my $daf_arayref = $dna_align_feature_adaptor->
  fetch_all_by_Slice( $slice, 'triticum_aestivum', 'IWGSP1', 'LASTZ_NET' )
    or die;

for (@$daf_arayref){
    print "$_\n";
    print $_-> seq_region_name, ':', $_-> start, '-', $_-> end, $_->strand, "\n";
    print $_->hseq_region_name, ':', $_->hstart, '-', $_->hend, $_->hstrand, "\n";
    print "\n";
}
