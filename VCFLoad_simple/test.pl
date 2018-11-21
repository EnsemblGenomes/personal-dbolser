#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

# Feature type
my $feature = "StructuralVariation";

# In this database
my $species = "sorghum_bicolor";
my $db_type = "variation";


warn "Loading the registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db(qw(mysql-eg-prod-1.ebi.ac.uk 4238 ensro ))
    or die;

warn "Getting a database adaptor ($db_type:$species)\n";
my $db_adaptor = Bio::EnsEMBL::Registry->
  get_DBAdaptor($species, $db_type)
    or die;
warn $db_adaptor, "\n";

warn "Getting the feature adaptor ($feature)\n";
my $f_adaptor = $db_adaptor->
  get_adaptor($feature)
    or die;
warn $f_adaptor, "\n";

warn "Counting features ($feature)\n";
warn "There are ", $f_adaptor->generic_count, " ", $feature, "s\n";

## NOTE: Variation feature adaptors have iterators, but structural
## variation feature adaptors dont...


# warn "Getting a feature iterator ($feature)\n";
# my $item_iterator = $f_adaptor->fetch_Iterator;

# warn "Looping through features ($feature)\n";
# while (my $v = $item_iterator->next){
#     ...

my $sv_aref = $f_adaptor->fetch_all()
    or die;

for my $v (@$sv_aref){
    print $v, "\n";
}
