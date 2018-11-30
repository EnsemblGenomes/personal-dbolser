#!/usr/bin/env perl

# Projects generic features ... hopefully

# Snarfed from /nfs/production/panda/ensemblgenomes/development/dbolser/APIs/ensembl_genomes/misc_scripts/Project_Features

use strict;
use warnings;

use Data::Dumper;

use Bio::EnsEMBL::Registry;

my $registry_file = "./myreg.pm";
my $feature       = "PredictionTranscript";
my $species       = "hordeum_vulgare";
my $type          = "core";

warn "Loading the registry\n";
Bio::EnsEMBL::Registry->load_all( $registry_file )
    or die;

warn "Getting a datbase adaptor\n";
my $db_adaptor = Bio::EnsEMBL::Registry->
    get_DBAdaptor($species, $type)
    or die;

warn "Getting a feature adaptor ($feature)\n";
my $f_adaptor = $db_adaptor->
    get_adaptor($feature)
    or die;

warn "Counting features ($feature)\n";
warn "There are ", $f_adaptor->generic_count, " ", $feature, "s\n";

# warn "Getting a feature itterator ($feature)\n";
# my $f_iterator = $f_adaptor->
#     fetch_Iterator
#     or die;

my $items = $f_adaptor->fetch_all();

warn "Looping through features ($feature)\n";
while(my $f = shift(@$items)){
    warn "Working on ", $f->display_id(), "\n";
    
    # print
    #     join("\t",
    #          $f->dbID,
    #          $f->coord_system_name,
    #          $f->slice->dbID,
    #          $f->seq_region_name,
    #          $f->start,
    #          $f->end,
    #          $f->strand,
    #     ), "\n";
    
    ## Don't do what we have already done
    #next if $f->slice->is_toplevel;
    
    #warn "Projecting to toplevel\n";
    my $fp = $f->transform('toplevel')
        or die;
    
    # print
    #     join("\t",
    #          $fp->dbID,
    #          $fp->coord_system_name,
    #          $fp->slice->dbID,
    #          $fp->seq_region_name,
    #          $fp->start,
    #          $fp->end,
    #          $fp->strand,
    #     ), "\n";

    my $dbid = $fp->dbID;
    my $srid = $fp->slice->dbID;
    my $start = $fp->seq_region_start;
    my $end = $fp->seq_region_end;
    my $strand = $fp->strand;

    print "UPDATE prediction_transcript \n";
    print "SET seq_region_start = $start, \n";
    print "seq_region_end = $end, \n";
    print "seq_region_strand = $strand, \n";
    print "seq_region_id = $srid \n";
    print "WHERE prediction_transcript_id = $dbid;\n";
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
