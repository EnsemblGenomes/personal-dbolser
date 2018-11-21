#!/usr/bin/perl

use strict;
use warnings;

=pod

Script to grab sequences of a given ID from the DB

=cut

use lib qw(
    /homes/dbolser/cvs_cos/ensembl/modules
    /nfs/panda/ensemblgenomes/apis/bioperl/1.2.3
  );

use Bio::EnsEMBL::Registry;

## This 'string' is used as a coderef
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db
    ( -host => 'mysql-eg-staging-1',
      -port => 4160,
      -db_version => 66,
    );
print $registry, "\n";

my $sa = $registry->
    get_adaptor( 'Populus trichocarpa', 'Core', 'Slice' );

my $s = $sa->
    fetch_by_region( 'scaffold', 'scaffold_3134' );

print "$s\n";


print $s->seq, "\n";

