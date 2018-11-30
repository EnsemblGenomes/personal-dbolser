#!/bin/env perl

use v5.12;
use warnings;

use autodie;

use DBI;

my $verbose = 0;


## We're checking the mirror for 'inappropriate patches'
my $dsn = "DBI:mysql:host=mysql-eg-mirror.ebi.ac.uk;port=4157";
my $dbh = DBI->connect($dsn, 'ensro');

my $dbsth = $dbh->
  prepare('SHOW DATABASES LIKE "%_funcgen_%"')
    or die "prepare statement failed: $dbh->errstr()";

$dbsth->
  execute()
    or die "execution failed: $dbh->errstr()";

print $dbsth->rows . " databases found.\n";

while (my $dbref = $dbsth->fetchrow_arrayref) {
    print "Checking $dbref->[0]\n";
    my $db = $dbref->[0];

    die "failed to parse '$db'\n"
      unless $db =~ /^\w+_\w+_\w+_\d+_(\d+)_\d+$/;

    my $ensembl_version = $1;

    my $sth = $dbh->
      prepare("SELECT * FROM $db.meta WHERE meta_key = 'patch'")
        or die "prepare statement failed: $dbh->errstr()";

    $sth->
      execute()
        or die "execution failed: $dbh->errstr()";

    print $sth->rows . " patches found.\n"
      if $verbose;

    while (my $ref = $sth->fetchrow_arrayref) {
        print "\tChecking $ref->[3]\n"
          if $verbose;
        my $patch = $ref->[3];

        die "failed to parse '$patch'\n"
          unless $patch =~ /^patch_(\d+)_(\d+)_[a-z]+.sql\|/;

        my $ensembl_version_from = $1;
        my $ensembl_version_to   = $2;

        print "\t\tWARNING: $patch\n" if $ensembl_version_from >= $ensembl_version;
        print "\t\tOK: $patch\n" if $ensembl_version_to == $ensembl_version;
    }

    $sth->finish;

}

$dbsth->finish;

warn "OK\n";
