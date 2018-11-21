#!/usr/bin/env perl

use strict;
use warnings;

## Piping hot pipes
$|++;

# For debugging
use Data::Dumper;

# Connect to Ensembl and friends
use Bio::EnsEMBL::Registry;

## For command line arguments
use Getopt::Long;


my $file_name_prefix;
my $fucky_offset = 0;
my $fucky_chunk = 100_000_000;

GetOptions(
    "offset=i" => \$fucky_offset,
    "chunki=i" => \$fucky_chunk,
    "prefix=s" => \$file_name_prefix,
    )
    or die("Error in command line arguments\n");

die "Pass a file name --prefix\n"
    unless defined $file_name_prefix;


# open filehandle out.txt
open (my $OUT, '>', "Scratch/$file_name_prefix-$fucky_offset.tsv");

# open filehandle out.log
open (my $ERR, '>', "Scratch/$file_name_prefix-$fucky_offset.err");



# Feature type to project
my $feature = "Variation";

# In this database
my $db_type = "variation";

my $species = "solanum_lycopersicum";
#my $species = "sorghum_bicolor";
#my $species = "hordeum_vulgare";
#my $species = 'brachypodium_distachyon';

# To this coordinate system
my $to_cs   = "toplevel";

# Dump old position for debugging
my $verbose = 0;



print $ERR "Loading the registry\n";

Bio::EnsEMBL::Registry->
  load_registry_from_db(qw(mysql-eg-prod-2.ebi.ac.uk 4239 ensro ))
    or die;

# Bio::EnsEMBL::Registry->
#   load_registry_from_db(qw(mysql-eg-prod-1.ebi.ac.uk 4238 ensro ))
#     or die;



print $ERR "Getting a database adaptor ($db_type:$species)\n";

my $db_adaptor = Bio::EnsEMBL::Registry->
  get_DBAdaptor($species, $db_type)
    or die;

print $ERR "Getting a feature adaptor ($feature)\n";
my $f_adaptor = $db_adaptor->
  get_adaptor($feature)
    or die;

print $ERR $f_adaptor, "\n";

if ($verbose>0){
    warn "Counting features ($feature)\n";
    warn "There are ", $f_adaptor->generic_count, " ", $feature, "s\n";
}



## VARIATION FEATURE ADAPTORS DO HAVE ITERATORS...

print $ERR "Getting a feature iterator ($feature)\n";

my $item_iterator = $f_adaptor->fetch_Iterator;
print $ERR $item_iterator, "\n";


my $i = 0;

print $ERR "Looping through features ($feature)\n";
while (my $v = $item_iterator->next){
    
    $i++;
    
    ## RESTARTING...
    if ($fucky_offset){
        next if $i < $fucky_offset;
        last if $i > $fucky_offset + $fucky_chunk;
    }
    
    ## DEBUGGING
    #last if $i >= 100;
    
    print $ERR scalar localtime. " projecting $i\n"
        if $i % 1000 == 0;
    
    if ($verbose){
        warn $v, "\n";
        warn $v->name, "\n";
    }
    
    ## For some species we know that there is exactly 1 variation
    ## feature per variation (go check now k?)...

    my $f = $v->get_all_VariationFeatures->[0];
    
    if ($verbose){
        warn "$f\n";
        warn "Working on ", $f->display_id, "\n";
        
        warn "current position\n";
        warn
            join("\t",
                 $f->dbID,
                 $f->display_id,
                 $f->slice->get_seq_region_id,
                 $f->seq_region_name,
                 $f->slice->coord_system->dbID,
                 $f->coord_system_name,
                 $f->start,
                 $f->end,
                 $f->strand,
            ), "\n";
        
        warn "Projecting to $to_cs\n";
    }
    
    my $p;
    
    ## This is where the time goes...
    unless ( $p = $f->transform($to_cs) ){
        print $ERR "failed to project ", $f->display_id, "\n";
        next;
    }
    
    warn "new position\n" if $verbose;
    print $OUT
        join("\t",
             $p->dbID,
             $p->display_id,
             $p->slice->get_seq_region_id,
             $p->seq_region_name,
             $p->slice->coord_system->dbID,
             $p->coord_system_name,
             $p->start,
             $p->end,
             $p->strand,
        ), "\n";
    
    ## Assuming we could use the API to update the feature...
    
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

print $ERR "DONE\n";
