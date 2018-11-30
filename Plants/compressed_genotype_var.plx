#!/usr/bin/env perl -w

use 5.14;
use strict;

use autodie;

use Bio::EnsEMBL::Registry;

say STDERR "building registry";
Bio::EnsEMBL::Registry->load_registry_from_db(
  -host    => 'mysql-eg-prod-1.ebi.ac.uk',
  -port    => '4238',
  -user    => 'ensro',
);

# my $a_aref =
#   Bio::EnsEMBL::Registry->get_all_adaptors( "zea_mays", "variation" );
# say STDERR $a_aref;

# foreach my $a (@$a_aref){
#     say STDERR "\t$a";
# }

say STDERR "getting a random adaptor";
my $a = Bio::EnsEMBL::Registry->
  get_adaptor( "zea_mays", "variation", "SampleGenotype" );
say STDERR $a;

say STDERR "getting a dbh";
my $dbh = $a->dbc->db_handle;
say STDERR $dbh;

say STDERR "preparing select";
my $sth = $dbh->prepare(qq{
  SELECT variation_id, genotypes FROM compressed_genotype_var
});

say STDERR "executing";
$sth->execute;



say STDERR "fetching results";
my ( $variation_id, $genotypes );
my %sample_ids;

$sth->bind_columns( \$variation_id, \$genotypes );

while( $sth->fetch ) {
    #say STDERR $variation_id;

    my @genotypes = unpack("(ww)*", $genotypes);

    my $i;
    while(@genotypes) {
        my $sample_id = shift @genotypes;
        my $gt_code = shift @genotypes;
        # say STDERR "\t", join("\t", $sample_id, $gt_code);
        $i++;
        $sample_ids{$sample_id}++;
    }

    #say "$variation_id\t$i";
}

say STDERR scalar keys %sample_ids;


say STDERR "OK";
