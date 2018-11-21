#!/usr/bin/perl

use strict;
use warnings;

## I'm sure there is a module somewhere for this...

my $VERSION = '13_66';
my $SERVER_SCRIPT1 = 'mysql-pan-1';
my $SERVER_SCRIPT2 = 'mysql-staging-1';

open( DB_LIST, '-|', qq( $SERVER_SCRIPT1 ensembl_production -Ne '
  SELECT
    full_db_name
  FROM
    db_list
  INNER JOIN
    db
  USING
    (db_id)
  WHERE
    db.db_type = "core"
  AND
    db.db_release = "$VERSION"
  '));


my %total;

while (<DB_LIST>){
  chomp;
  
  my $database_id = $_;
  warn "doing $database_id\n";
  
  open( DESC_LIST, '-|', qq( $SERVER_SCRIPT2 $database_id -Ne '
    SELECT
      CONCAT("~START~", description, "~END~")
    FROM
      gene
    WHERE
      description IS NOT NULL
    '));
  
  
  
  my %source_databases;
  
  while(<DESC_LIST>){
    chomp;
    ## Ignore line breaks (my dumb script should use DBI)
    next unless /^~START~(.*)~END~$/;
    
    my $description = $1;
    
    if($description =~ /\[[Ss]ource:/){
      
      die "failed to parse '$_'\n"
	unless $description =~ /\[[Ss]ource:(.*?)(?:;Acc:((?:\w|-|\.)+))?\]/;
      $source_databases{$1}++;
      $total{$1}++;
      #print "$1\n";
    }
    else{
      $source_databases{'NONE!'}++;
      $total{'NONE'}++;
    }
  }
  
  print $database_id, "\n";
  for (sort keys %source_databases){
    print "\t", $_, "\t", $source_databases{$_}, "\n";
  }
  warn "\n";
}



for (sort keys %total){
    print "\t'", $_, "'\t", $total{$_}, "\n";
  }
  warn "\n";
