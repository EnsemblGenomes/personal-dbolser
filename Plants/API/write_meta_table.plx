#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

Bio::EnsEMBL::Registry->
    load_registry_from_multiple_dbs(
        { -host => 'mysql-eg-prod-2',
          -port => '4239',
          -user => 'ensrw',
          -pass => 'xxxxxxxx',
        },
    );

warn "Got the registry\n";



my @headers;

while(<>){
    chomp;

    ## The row is the header row
    unless(@headers){
        @headers = split/\t/;
        #print join("\t", @headers), "\n";
        next;
    }

    ## The following rows are the data
    my @columns = split/\t/;

    ## Build a hash based on headers
    my %columns;
    for (my $i = 0; $i < @headers; $i++){
        die if exists $columns{$headers[$i]};
        $columns{$headers[$i]} = $columns[$i] || '';
    }



    ## Now grab the meta container
    my $species_name = $columns{'species.production_name'}
      or die;
    print "'$species_name'\n";

    my $mc =
      Bio::EnsEMBL::Registry->
          get_adaptor( $species_name, 'core', 'MetaContainer' )
            or die "Failed\n";
    #print $mc, "\n";

    foreach my $header (@headers){
        #print $header, "\n";

        ## We want to ignore the two artificial database name and
        ## species name columns
        next if $header eq 'db';
        next if $header eq 'species';

        $mc->delete_key($header);

        my @values = split(/ :sep: /, $columns{$header});

        foreach my $value (@values){
            $mc->store_key_value( $header, $value )
              if $value ne '';
        }
    }
}
