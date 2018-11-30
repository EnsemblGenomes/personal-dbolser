#!/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

Bio::EnsEMBL::Registry->
    load_registry_from_db(
        -host => 'mysql-eg-prod-1.ebi.ac.uk',
        -port => '4238',
        -user => 'ensro',
        -db_version => 90,
    );

my $slice_adaptor = Bio::EnsEMBL::Registry->
    get_adaptor( 'elaeis_guineensis', 'Core', 'Slice' );
print $slice_adaptor, "\n";

my $slice = $slice_adaptor->
    fetch_by_region('toplevel', 'EG9_Chr2a', '4103347', '4103751');
print $slice, "\n";

print $slice->seq, "\n";

my $genes_aref = $slice->get_all_Genes;

print "got ", scalar @$genes_aref, " genes\n";

print $genes_aref->[0]->stable_id, "\n";
