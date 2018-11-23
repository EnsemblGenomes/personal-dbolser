#!/usr/bin/perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;


## Get a registry

## This one for Ensembl

# Bio::EnsEMBL::Registry->
#   load_registry_from_db( -host => 'ensembldb.ensembl.org',
#                          -user => 'anonymous',
#                          -port => 5306,
#                        );


## This one for Ensembl Genomes

Bio::EnsEMBL::Registry->
  load_registry_from_db( -host => 'mysql-eg-staging-2.ebi.ac.uk',
                         -user => 'ensro',
                         -port => 4275,
                       );


## Pick a Compara

#my $type = 'Multi';
#my $type = 'Bacteria';
#my $type = 'Fungi';
#my $type = 'Metazoa';
#my $type = 'Plants';
my $type = 'Protists';


## Get Adaptors to do the work

my $gene_tree_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor( $type, 'compara', 'GeneTree' );
print $gene_tree_adaptor, "\n";

my $genome_adaptor = Bio::EnsEMBL::Registry->
  get_adaptor( $type, 'compara', 'GenomeDB' );
print $genome_adaptor, "\n";



## Debugging
print "we have ",
  scalar( @{ $genome_adaptor->fetch_all } ), " genomes\n";

## Get all trees in one easy step...

my $trees = $gene_tree_adaptor->
  fetch_all( -TREE_TYPE => 'tree',
             -MEMBER_TYPE => 'protein',
           );
print "processing ", scalar @$trees, " trees\n";



## Check the type of the root node of all these trees

my %tree_root_types;

foreach my $tree (@$trees){
    my $tree_root_type =
      $tree->root->get_tagvalue('node_type');
    #print "$tree_root_type\n";
    $tree_root_types{ $tree_root_type || 'undef' }++;
    #last;
}

print "$_\t$tree_root_types{$_}\n" for keys %tree_root_types;

warn "OK\n";
