#!/usr/bin/perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

## This 'string' is used as a coderef
my $registry = 'Bio::EnsEMBL::Registry';

my @fields_to_dump = qw(

  assembly.accession
  assembly.date
  assembly.name
  assembly.default

  genebuild.method
  genebuild.version
  genebuild.start_date

  provider.name
  provider.url

  species.scientific_name
  species.taxonomy_id
  species.species_name
  species.species_taxonomy_id

  species.production_name
  species.display_name
  species.url
  species.wikipedia_url

  species.common_name
  species.strain

  sample.search_text
  sample.gene_param
  sample.gene_text
  sample.location_param
  sample.location_text
  sample.transcript_param
  sample.transcript_text

);

$registry->
    load_registry_from_multiple_dbs(
        # { -host => 'mysql-eg-staging-2',
        #   -port => '4275',
        #   -user => 'ensro',
        # },

        # { -host => 'mysql-eg-staging-1',
        #   -port => '4160',
        #   -user => 'ensro',
        # },

        { -host => 'mysql-eg-prod-2',
          -port => '4239',
          -user => 'ensro',
        },

    );

warn "Got the registry $registry\n";



## Get all the DBAs
my @dba = @{
    $registry->
        get_all_DBAdaptors( -group => 'core' )
    };

warn "Dumping metadata for ", scalar @dba, " cores\n";

print
    join("\t", 'db', 'species', @fields_to_dump), "\n";

## Loop through...
for (sort sort_dba_by_species @dba ){
  my $species = $_->species;
  my $db      = $_->dbc->dbname;
  
  #print $species, "\n";
  
  my $meta_container =
    $registry->get_adaptor
      ( $species, 'core', 'MetaContainer' );
  
  my $sd = gv( $db, $meta_container, 'species.division' );
  
  unless($sd eq 'EnsemblPlants'){
    $_->dbc->disconnect_if_idle;
    next;
  }
  
  print
    join("\t",
         $db, $species,
         
         ## Loop through all fields
         map{
             gv( $db, $meta_container, $_ )
         } @fields_to_dump,

         ## OLD WAY
         # gv( $db, $meta_container, 'genebuild.id' ),
         # gv( $db, $meta_container, 'genebuild.method' ),
         # gv( $db, $meta_container, 'genebuild.start_date' ),
         # gv( $db, $meta_container, 'genebuild.last_geneset_update' ),
         # gv( $db, $meta_container, 'genebuild.version' ),
         
         # gv( $db, $meta_container, 'assembly.default' ),
         # gv( $db, $meta_container, 'assembly.name' ),
         # gv( $db, $meta_container, 'assembly.accession' ),
         # gv( $db, $meta_container, 'assembly.long_name' ),
         
         # gv( $db, $meta_container, 'provider.name' ),
         # gv( $db, $meta_container, 'provider.url' ),
        ), "\n";
  
  $_->dbc->disconnect_if_idle;
}

sub sort_dba_by_species {
  $a->species cmp $b->species
}


sub gv {
  my $db = shift;
  my $mc = shift;
  my $key = shift;
  
  my @vals =
    @{ $mc->list_value_by_key( $key ) };

  unless(@vals){
      #warn "FAIL '$db': key='$key' vals=NULL\n\n";
      return '';
  }

  if (@vals > 1){
      # warn "FAIL '$db': key='$key' vals='",
      #   join(" :sep: ", @vals), "'\n\n";
  }

  return
      join(" :sep: ", @vals);
}
