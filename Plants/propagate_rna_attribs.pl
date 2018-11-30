#!/usr/bin/env/perl

use strict;
use warnings;

use Getopt::Long qw(:config no_ignore_case);
use Bio::EnsEMBL::DBSQL::DBAdaptor;

my ($host, $port, $user, $pass, $dbname, @logic_name);

GetOptions(
  "host=s", \$host,
  "P|port=i", \$port,
  "user=s", \$user,
  "p|pass=s", \$pass,
  "dbname=s", \$dbname,
  "logic_name=s", \@logic_name,
    );

my $dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new
(
    -host   => $host,
    -port   => $port,
    -user   => $user,
    -pass   => $pass,
    -dbname => $dbname,
);

my $dafa = $dba->get_adaptor('DnaAlignFeature');
my $aa   = $dba->get_adaptor('Attribute');

foreach my $logic_name (@logic_name) {
    my @features = @{ $dafa->fetch_all_by_logic_name($logic_name) };
  
    foreach my $feature (@features) {
        my $metadata = $feature->extra_data;
    
        my $accession   = $$metadata{'Accession'};
        my $accuracy    = $$metadata{'Accuracy'};
        my $bias        = $$metadata{'Bias'};
        my $biotype     = $$metadata{'Biotype'};
        my $desc        = $$metadata{'Desc'};
        my $gc          = $$metadata{'GC'};
        my $significant = $$metadata{'Significant'};
        my $structure   = $$metadata{'Structure'};
        my $trunc       = $$metadata{'Trunc'};
    
        my @attribs;
    
        if ($accession && $accession ne '-') {
            push @attribs, create_attrib('rfam_accession', $accession);
        }
    
        if ($accuracy) {
            push @attribs, create_attrib('cmscan_accuracy', $accuracy);
        }
      
        if ($bias) {
            push @attribs, create_attrib('cmscan_bias', $bias);
        }
    
        if ($biotype) {
            push @attribs, create_attrib('rna_gene_biotype', $biotype);
        }
    
        if ($desc) {
            push @attribs, create_attrib('description', $desc);
        }
    
        if ($gc) {
            push @attribs, create_attrib('cmscan_gc', $gc);
        }
    
        if ($significant && $significant eq '!') {
            push @attribs, create_attrib('cmscan_significant', 1);
        }
    
        if ($structure) {
            push @attribs, create_attrib('ncRNA', $structure);
        }
    
        if ($trunc && $trunc ne 'no' && $trunc ne '-') {
            push @attribs, create_attrib('cmscan_truncated', $trunc);
        }
    
        $aa->store_on_DnaDnaAlignFeature($feature, \@attribs);
    }
}

sub create_attrib {
    my ($key, $value) = @_;
  
  my $attrib = Bio::EnsEMBL::Attribute->new(
    -CODE  => $key,
    -VALUE => $value
      );
  
    return $attrib;
}
