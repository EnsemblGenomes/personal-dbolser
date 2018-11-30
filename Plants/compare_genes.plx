#!/usr/bin/env perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

use Data::Dumper;
use List::Util qw( max min );

my $verbose = 1;



## Connect to the databases for the 'old' and 'new' versions of the
## assembly. Only the new version has the 'assembly mapping' data.
warn "Connecting to databases\n";
my $reg = Bio::EnsEMBL::Registry->
    load_registry_from_multiple_dbs(
        { -host           => 'mysql-eg-staging-1',
          -user           => 'ensro',
          -pass           => '',
          -port           => '4160',
          -species        => 'oryza_sativa',
          -db_version     => '72',
          -species_suffix => '_72',
        },
        { -host           => 'mysql-eg-staging-2',
          -user           => 'ensrw',
          -pass           => 'scr1b3s2',
          -port           => '4275',
          -species        => 'oryza_sativa',
        }
    )
  or die;

## The 'old' version of the assembly
warn "Getting a gene adaptor for O. sativa MSU6\n";
my $msu6_gene_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor('oryza_sativa_72', 'core', 'Gene')
  or die;

## The 'new' version of the assembly
warn "Getting a gene adaptor for O.sativa IRGSP\n";
my $irgsp_gene_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor('oryza_sativa', 'core', 'Gene')
  or die;


## Get an adaptor and object needed for building a new slice later...

warn "Getting a slice adaptor for  O. sativa MSU6\n";
my $msu6_slice_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor('oryza_sativa_72', 'core', 'Slice')
  or die;

warn "Getting a coord adaptor for  O. sativa MSU6\n";
my $msu6_coord_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor('oryza_sativa_72', 'core', 'coordsystem')
  or die;

## Grab the coord for later
my $msu6_coord = $msu6_coord_adaptor->
  fetch_by_name( 'chromosome', 'MSU6' );





## DO SOMETHING!

my %source_gene;

warn "Doing something\n";
for my $i_gene (@{$irgsp_gene_adaptor->
                      fetch_all_by_biotype('protein_coding')}){
    
    warn "Working on ", $i_gene->stable_id, "\n"
      if $verbose;
    
    if($verbose){
        warn
          join("\t",
               $i_gene->dbID,
               $i_gene->coord_system_name,
               $i_gene->seq_region_name,
               #$i_gene->slice->get_seq_region_id,
               $i_gene->start,
               $i_gene->end,
               $i_gene->strand,
               $i_gene->slice->coord_system->version,
               $i_gene->stable_id,
              ), "\n";
    }
    
    ## Try to back project the gene...
    my $im_gene = $i_gene->
      transform( 'chromosome', 'MSU6' );
    
    unless(defined($im_gene)){
        ## Typically due to a feature not lying in a 'mapped' region
        warn "FLAILED TO PROJECT ", $i_gene->dbID, "!\n\n";
        ## TODO: gather some stats here...
        next;
    }
    
    if($verbose){
        warn
          join("\t",
               $im_gene->dbID,
               $im_gene->coord_system_name,
               $im_gene->seq_region_name,
               #$im_gene->slice->get_seq_region_id,
               $im_gene->start,
               $im_gene->end,
               $im_gene->strand,
               $im_gene->slice->coord_system->version,
               $im_gene->stable_id,
              ), "\n";
    }
    
    
    
    ## Now map this gene to an MSU6 gene 'in the region', if any
    
    ## Using this slice, convenient as it is, doesn't work below
    my $im_slice = $im_gene->slice;
    
    ## Build a new slice then...
    my $m_slice = Bio::EnsEMBL::Slice->
      new( -coord_system      => $msu6_coord,
           -start             => $im_gene->start,
           -end               => $im_gene->end,
           -strand            => $im_gene->strand,
           -seq_region_name   => $im_gene->seq_region_name,
           -seq_region_length => $im_gene->seq_region_length,
           -adaptor           => $msu6_slice_adaptor,
          );
    
    #print Dumper $im_slice;
    #print Dumper $m_slice;
    
    ## Here we get genes from the old assembly that are on the
    ## projected slice...
    my $m_genes = $msu6_gene_adaptor->
      fetch_all_by_Slice( $m_slice );
    
    unless(@$m_genes){
        warn "Nothing matching ", $im_gene->dbID, "!\n\n";
        ## TODO: gather some stats here...
        next;
    }
    
    #print Dumper $m_genes->[0];
    warn "Got ", scalar @$m_genes, " gene(s)\n"
      if $verbose;
    
    
    
    # Pick the one with the most overlap...
    my $max_overlap = 0;
    my $max_overlap_gene;
    for my $m_gene (@$m_genes){
        if($verbose){
            warn
              join("\t",
                   $m_gene->dbID,
                   $m_gene->coord_system_name,
                   $m_gene->seq_region_name,
                   #$m_gene->slice->get_seq_region_id,
                   $m_gene->seq_region_start,
                   $m_gene->seq_region_end,
                   $m_gene->strand,
                   $m_gene->slice->coord_system->version,
                   $m_gene->stable_id,
                  ), "\n";
        }
        
        ## Calculate the 'overlap'
        my $overlap = &gene_overlap( $m_gene, $im_gene );
        
        if ( $overlap > $max_overlap ){
            $max_overlap = $overlap;
            $max_overlap_gene = $m_gene;
        }
    }
    
    warn sprintf("overlap is %6.2f%%\n", $max_overlap*100)
        if $verbose;
    
    
    
    ## HERE WE ADD AN DBLink (XRef) to the IRGSP gene for the
    ## discovered MSU (max_overlap) gene!
    
    ## Feck it, lets just store the mappings and dump...
    
    warn "Mapping to ", $max_overlap_gene->stable_id, " again!\n\n"
        if $source_gene{$max_overlap_gene->stable_id}++;
    
    my $label;
    
    if    ($max_overlap>=.99){ $label = 'Strongly overlaps' }
    elsif ($max_overlap>=.95){ $label = 'Closely overlaps' }
    elsif ($max_overlap>=.80){ $label = 'Largely overlaps' }
    else                     { $label = 'Partially overlaps' }
    
    print
        join("\t",
             $i_gene->dbID,
             $label. ' '.
             $max_overlap_gene->stable_id,
             $max_overlap_gene->stable_id,
             $i_gene->stable_id. ' overlaps the MSUv6 gene '.
             $max_overlap_gene->stable_id. ' by '. 
             sprintf("%.0f%%", $max_overlap*100)
        ), "\n";
    
    warn "\n" if $verbose;
    #exit;
}

warn "OK\n";



## Calcualte the overlap of two genes as a fraction of the length of
## the first gene (ignoring anything outside the first).

sub gene_overlap {
    my $gene1 = shift;
    my $gene2 = shift;
    
    my $length_gene1 =
      $gene1->seq_region_end -
      $gene1->seq_region_start + 1;
    
    ## Overlap is min(end) - max(start) ??
    
    my $min_end =
      min($gene1->seq_region_end,
          $gene2->seq_region_end);
    my $max_start =
      max($gene1->seq_region_start,
          $gene2->seq_region_start);
    
    my $overlap = $min_end - $max_start + 1;
    
    return $overlap / $length_gene1;
}
