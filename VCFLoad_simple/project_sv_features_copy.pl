#!/usr/bin/env perl

use strict;
use warnings;

## Piping hot pipes
$|++;

# For debugging
use Data::Dumper;

# Connect to Ensembl and friends
use Bio::EnsEMBL::Registry;

# Feature type to project
my $feature = "StructuralVariation";

# In this database
#my $species = "solanum_lycopersicum";
my $species = "sorghum_bicolor";
my $db_type = "variation";

# To this coordinate system
my $to_cs   = "toplevel";

# Dump old position for debugging
my $verbose = 0;

warn "Loading the registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db(qw(mysql-eg-prod-1.ebi.ac.uk 4238 ensro ))
    or die;

warn "Getting a database adaptor ($db_type:$species)\n";
my $db_adaptor = Bio::EnsEMBL::Registry->
  get_DBAdaptor($species, $db_type)
    or die;

warn "Getting a feature adaptor ($feature)\n";
my $f_adaptor = $db_adaptor->
  get_adaptor($feature)
    or die;
warn $f_adaptor, "\n";

if ($verbose>0){
    warn "Counting features ($feature)\n";
    warn "There are ", $f_adaptor->generic_count, " ", $feature, "s\n";
}





# warn "Looping through features ($feature)\n";
# while (my $v = $item_iterator->next){

## STRUCTURAL VARIATION FEATURE ADAPTORS DO NOT HAVE ITERATORS...

my $sv_aref = $f_adaptor->fetch_all()
    or die;

my $method = "get_all_". $feature. "Features";

for my $v (@$sv_aref){
    
    ## For some species we know that there is exactly 1 variation
    ## feature per variation...
    my $f = $v->$method->[0];
    
    warn "Working on ", $f->display_id, "\n"
        if $verbose;
    
    warn "current position\n" if $verbose;
    warn
      join("\t",
           $f->dbID,
           $f->display_id,
           $f->slice->get_seq_region_id,
           $f->seq_region_name,
           $f->slice->coord_system->dbID,
           $f->coord_system_name,
           $f->outer_start || '\N',
           $f->start,
           $f->inner_start || '\N',
           $f->inner_end || '\N',
           $f->end,
           $f->outer_end || '\N',
           $f->strand,
      ), "\n"
        if $verbose;
    
    warn "Projecting to $to_cs\n" if $verbose;
    
    my $p;
    
    unless ( $p = $f->transform($to_cs) ){
        warn "failed to project ", $f->display_id, "\n";
        next;
    }

    warn "new position\n" if $verbose;

    # print
    #   join("\t",
    #        $f->dbID,
    #        $f->display_id,
    #        $f->slice->get_seq_region_id,
    #        $f->seq_region_name,
    #        $f->slice->coord_system->dbID,
    #        $f->coord_system_name,
    #        $f->outer_start || '\N',
    #        $f->start,
    #        $f->inner_start || '\N',
    #        $f->inner_end || '\N',
    #        $f->end,
    #        $f->outer_end || '\N',
    #        $f->strand,
    #   ), "\n";

    print
      join("\t",
           $p->dbID,
           $p->display_id,
           $p->slice->get_seq_region_id,
           $p->seq_region_name,
           $p->slice->coord_system->dbID,
           $p->coord_system_name,
           $p->outer_start || '\N',
           $p->start,
           $p->inner_start || '\N',
           $p->inner_end || '\N',
           $p->end,
           $p->outer_end || '\N',
           $p->strand,
      ), "\n";
    
    #exit;


    # warn "storing the position\n";
    # $f->start  ( $p->start  );
    # $f->end    ( $p->end    );
    # $f->strand ( $p->strand );
    
    # # Sets coord_system and seq_region.name
    # $f->slice  ( $p->slice  );
    
    # warn "updating the position (SLOW)\n";
    # $f_adaptor->update( $f )
    #   or die;
}
