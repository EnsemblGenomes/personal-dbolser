#!/usr/bin/perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

## This 'string' is used as a coderef
my $registry = 'Bio::EnsEMBL::Registry';

my @fields_to_check = qw(

  assembly.accession
  assembly.date
  assembly.name
  assembly.default

  genebuild.method
  genebuild.version
  genebuild.start_date

  provider.name

  species.scientific_name
  species.taxonomy_id
  species.species_name
  species.species_taxonomy_id

  species.production_name
  species.display_name
  species.url

  species.common_name
  species.strain

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
          -user => 'ensrw',
          -pass => 'xxxxxxxx',
        },

    );

warn "Got the registry $registry\n";



## Get all the DBAs
my @dba_o = @{
    $registry->
        get_all_DBAdaptors( -group => 'otherfeatures' )
    };

warn "Checking metadata for ", scalar @dba_o, " OtherFeatures DBs\n";

## Loop through...
for (sort sort_dba_by_species @dba_o ){
  my $species = $_->species;
  
  print $species, "\n";
  
  my $meta_container_c =
    $registry->get_adaptor
      ( $species, 'core', 'MetaContainer' );
  
  my $sd = gv( $meta_container_c, 'species.division' );
  
  unless($sd eq 'EnsemblPlants'){
    $_->dbc->disconnect_if_idle;
    next;
  }
  
  my $meta_container_o =
    $registry->get_adaptor
      ( $species, 'otherfeatures', 'MetaContainer' );

  print $species, "\n";
  
  for my $f (@fields_to_check){
      my $gv_o = gv($meta_container_o, $f);
      my $gv_c = gv($meta_container_c, $f);

      if ($gv_o eq $gv_c){
          print "\tno value for $f\n" if $gv_o eq '';
          next;
      }
      elsif($gv_o eq ''){
          print "\twriting '$gv_c' to OF for $f\n";
          $meta_container_o->store_key_value( $f, $gv_c );
      }
      elsif($gv_c eq ''){
          print "\tdeleting '$gv_c' from OF for $f\n";
      }
      else{
          print "\t$f\n";
          print "\tCORE!: $gv_c\n";
          print "\tOTHER: $gv_o\n";

          $meta_container_o->delete_key($f);
          $meta_container_o->store_key_value( $f, $gv_c );

      }

      print "\n";
  }




  # print
  #   join("\t",
  #        $db, $species,
         
  #        ## Loop through all fields
  #        map{
  #            gv( $db, $meta_container, $_ )
  #        } 

  
  $_->dbc->disconnect_if_idle;
}

sub sort_dba_by_species {
  $a->species cmp $b->species
}


sub gv {
  my $mc = shift;
  my $key = shift;
  
  my @vals =
    @{ $mc->list_value_by_key( $key ) };

  unless(@vals){
      return '';
  }

  return
      join(" :sep: ", @vals);
}
