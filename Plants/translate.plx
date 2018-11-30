#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

Bio::EnsEMBL::Registry->
  load_registry_from_db(
    -host => 'mysql-eg-staging-1.ebi.ac.uk',
    -port => '4160',
    -user => 'ensro',
);

# Bio::EnsEMBL::Registry->
#   load_registry_from_db(
#     -host => 'mysql-eg-staging-2.ebi.ac.uk',
#     -port => '4275',
#     -user => 'ensro',
# );

# Bio::EnsEMBL::Registry->
#   load_registry_from_db(
#     -host => 'mysql-eg-prod-1.ebi.ac.uk',
#     -port => '4238',
#     -user => 'ensro',
# );

my $species = 'triticum_urartu';
my $stable_id = 'AGP51250';

# my $species = 'tomato';
# my $stable_id = 'Solyc10g006890.2.1';

#my $species = 'barley';
#my $stable_id = 'MLOC_26274.11';

my $transcript_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor( $species, 'Core', 'Transcript' );

my $transcript = $transcript_adaptor->
  fetch_by_stable_id($stable_id);

print $transcript->translation()->stable_id(), "\n";
print $transcript->translate()->seq(),         "\n";

print $transcript->translation()->transcript()->stable_id(), "\n";
