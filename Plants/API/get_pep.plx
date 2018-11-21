#!perl

use strict;
use warnings;

=pod

Script to grab the peptide sequence of a given ID from the DB

=cut

use Bio::EnsEMBL::Registry;

## This 'string' is used as a coderef
my $registry = 'Bio::EnsEMBL::Registry';

$registry->load_registry_from_db
    ( -host => 'mysql-eg-staging-1',
      -port => 4160,
    );
print $registry, "\n";

my $ta = $registry->
    get_adaptor( 'Setaria italica', 'Core', 'translation' );
print $ta, "\n";


my $translation = $ta->
  fetch_by_stable_id('Si014024m');
print $translation, "\n";

## I just guessed this, as it doesn't appear to be in the API docs:
print $translation->seq, "\n";

