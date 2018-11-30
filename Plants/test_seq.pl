#!/usr/bin/perl

use Bio::EnsEMBL::Registry;

Bio::EnsEMBL::Registry->
    load_registry_from_db(
        -host => "mysql-eg-staging-2.ebi.ac.uk",
        -port => "4275",
        -user => "ensro")
    or die;

my $slice_adaptor = Bio::EnsEMBL::Registry->
    get_adaptor("hordeum_vulgare", "core", "slice")
    or die;

my $slice = $slice_adaptor->
    fetch_by_region('chromosome', 'chr1H', 553651089, mys553709382)
    or die;

print $slice, "\n";
print $slice->seq, "\n";

