#!/usr/bin/env perl

# Projects generic features ... hopefully

use strict;
use warnings;

use Data::Dumper;

use Bio::EnsEMBL::Registry;

my $feature       = "Exon";
my $species       = "beta_vulgaris";
my $type          = "core";

warn "Loading the registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db(qw(mysql-eg-prod-1.ebi.ac.uk 4238 ensrw xxxxxxxx))
    or die;

warn "Getting a database adaptor\n";
my $db_adaptor = Bio::EnsEMBL::Registry->
  get_DBAdaptor($species, $type)
    or die;

warn "Getting a feature adaptor ($feature)\n";
my $f_adaptor = $db_adaptor->
  get_adaptor($feature)
    or die;

warn "Counting features ($feature)\n";
warn "There are ", $f_adaptor->generic_count, " ", $feature, "s\n";

## Seems this method has disappeared.
#warn "Getting a feature itterator ($feature)\n";
#my $f_iterator = $f_adaptor->
#  fetch_Iterator
#    or die;

## Use this instead
warn "Getting all features ($feature)\n";
my $items = $f_adaptor->fetch_all();

## So we can't use this
#warn "Itterating over features ($feature)\n";
#while(my $f = $f_iterator->next){

warn "Looping through features ($feature)\n";
while(my $f = shift(@$items)){
    #warn "Working on ", $f->name, "\n";
    #warn "Working on ", $f->display_id(), "\n";
    
    # print
    #     join("\t",
    #          $f->dbID,
    #          $f->coord_system_name,
    #          $f->slice->get_seq_region_id,
    #          $f->seq_region_name,
    #          $f->start,
    #          $f->end,
    #          $f->strand,
    #     ), "\n";
    
    ## Don't do what we have already done
    next if $f->slice->is_toplevel;
    
    #warn "Projecting to toplevel\n";
    my $fp = $f->transform('toplevel')
        or die;
    
    print
        join("\t",
             $fp->dbID,
             $fp->coord_system_name,
             $fp->slice->get_seq_region_id,
             $fp->seq_region_name,
             $fp->start,
             $fp->end,
             $fp->strand,
        ), "\n";
    
    ## Store the new slice in the old feature
    
    ## This fails
    # $f->slice( $fp->slice )
    #     or die;
    
    # $f->start  ( $fp->start  );
    # $f->end    ( $fp->end    );
    # $f->strand ( $fp->strand );
    # $f->slice  ( $fp->slice  ); # Does coord_system and seq_region.name
    
    #$f_adaptor->update( $f )
    #    or die;
    #warn "\n";

    #exit;
}
