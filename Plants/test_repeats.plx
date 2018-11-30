#! perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $species = 'arabidopsis_thaliana';

warn "Loading registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db(
    -host => 'mysql-eg-staging-1.ebi.ac.uk',
    -user => 'ensro',
    -port => '4160',
  );

## Get adaptor (we just use it to get a variation dbc!)
warn "Getting adaptor\n";
my $slice_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor($species, "core", "Slice")
  or die("ERROR: Failed to get Slice Adaptor");
warn "$slice_adaptor\n";


# my $beg=14945911;
# my $end=14977396;

my $beg=14898684;
my $end=15024627;

my $slice = $slice_adaptor->
  fetch_by_region( 'chromosome', '1', $beg, $end )
    or die;
print $slice, "\n";

my $repeat_features = $slice->
  get_all_RepeatFeatures('trf');
print $repeat_features, "\n";

for my $repeat (@$repeat_features){
    print "\t", $repeat, "\n";
    print "\t\t", $repeat->analysis->logic_name, "\n";
    #print "\t\t", $repeat->repeat_consensus->type, "\n";

    print "\t\tID:", $repeat->dbID, "\n";

    print "\t\t", $repeat->seq_region_start, "-", $repeat->seq_region_end, "\n";

    if ( $repeat->seq_region_start >= $beg &&
         $repeat->seq_region_end   <= $end){
        print "\t\tcontained\n";
        };
    print "\n";
}
