#!perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

die "pass the mapping file\n"
  unless @ARGV;

print "getting registry\n";
Bio::EnsEMBL::Registry->load_registry_from_db
    ( -host => 'mysql-eg-staging-1',
      -port => '4160',
      -user => 'ensrw',
      -pass => 'scr1b3s1',
      -species => 'oryza sativa',
    );

print "getting adaptors\n";
my $gene_adaptor = Bio::EnsEMBL::Registry->
    get_adaptor( 'Oryza sativa', 'Core', 'Gene' );
print "\t$gene_adaptor\n";

my $dbentry_adaptor = Bio::EnsEMBL::Registry->
    get_adaptor( 'Oryza sativa', 'Core', 'DBEntry' );
print "\t$dbentry_adaptor\n";

## TODO: Create an analysis object and use it here!



## Go time...
while(<>){
    chomp;
    my ($irgsp, $msus) = split/\t/;
    my @msu = split(/\,/, $msus);

    print "getting a gene for $irgsp\n";
    my $gene = $gene_adaptor->fetch_by_stable_id($irgsp);
    unless(defined $gene){
        print "failed to get gene for $irgsp!\n";
        next;
    }
    print "\t$gene\n";

    for (@msu){
        print "creating a dbentry for $_\n";
        my $dbentry = Bio::EnsEMBL::DBEntry->
          new ( -PRIMARY_ID  => $_,
                -DBNAME      => 'TIGR_LOCUS',
                -VERSION     => 1,
                -DISPLAY_ID  => $_,
                -INFO_TYPE   => 'DIRECT',
                -INFO_TEXT   => 'Mapping obtained from rap-db',
              )
            or die "failed to create dbentry for $_!\n";
        print "\t$dbentry\n";

        print "adding the dbentry to the gene\n";
        $gene->add_DBEntry($dbentry)
          or die "failed to add dbentry $_ to gene $irgsp!\n";

        print "storing dbentry\n";
        $dbentry_adaptor->store( $dbentry, $gene->dbID, 'Gene' )
          or die "failed to store dbentry $_ on gene $irgsp!\n";

    }
    #exit;
}
