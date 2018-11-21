#!/usr/bin/env/perl
use strict;
use warnings;

# Update a database with external_db data from the production
# database, with the exception of the db_release field.

use Getopt::Long qw(:config no_ignore_case);
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Bio::EnsEMBL::DBSQL::AnalysisAdaptor;
use DBI;

my ($host, $port, $user, $pass, $dbname,
    $mhost, $mport, $muser, $mpass, $mdbname,
    $no_insert, $no_update, $no_delete, $no_backup);

GetOptions(
  "host=s", \$host,
  "P|port=i", \$port,
  "user=s", \$user,
  "p|pass=s", \$pass,
  "dbname=s", \$dbname,
  "mhost=s", \$mhost,
  "mP|mport=i", \$mport,
  "muser=s", \$muser,
  "mp|mpass=s", \$mpass,
  "mdbname=s", \$mdbname,
  "no_insert", \$no_insert,
  "no_update", \$no_update,
  "no_delete", \$no_delete,
  "no_backup", \$no_backup,
);

die "--host required" unless $host;
die "--port required" unless $port;
die "--user required" unless $user;
die "--pass required" unless $pass;
die "--dbname required" unless $dbname;
die "--mhost required" unless $mhost;
die "--mport required" unless $mport;
die "--muser required" unless $muser;
$mdbname = "ensembl_production" unless $mdbname;
$no_insert = 0 unless $no_insert;
$no_update = 0 unless $no_update;
$no_delete = 0 unless $no_delete;
$no_backup = 0 unless $no_backup;

# Note that db_release is missing from the first list of columns.
my @cols = qw(external_db_id db_name status priority db_display_name type secondary_db_name secondary_db_table description);
my @all_cols = ('db_release', @cols);

my $backup_sql = 'CREATE TABLE external_db_bak AS SELECT * FROM external_db;';
my $select_sql = 'SELECT '.join(', ', @all_cols).' FROM external_db;';
my $insert_sql = 'INSERT INTO external_db ('.join(', ', @all_cols).') VALUES ('.join(', ', (map {"?"} @all_cols)).');';
my $update_sql = 'UPDATE external_db SET '.join(', ', (map {"$_ = ?"} @cols)).' WHERE external_db_id = ?;';
my $delete_sql = 'DELETE FROM external_db WHERE external_db_id = ?;';

my %mdata;
my $mdsn = "DBI:mysql:host=$mhost;port=$mport;database=$mdbname";
my $mdbh = DBI->connect($mdsn, $muser, $mpass, { 'PrintError'=>1, 'RaiseError'=>1 });
my $msth = $mdbh->prepare($select_sql);
$msth->execute();
%mdata = %{$msth->fetchall_hashref('external_db_id')};
$mdbh->disconnect();

my %data;
my $dsn = "DBI:mysql:host=$host;port=$port;database=$dbname";
my $dbh = DBI->connect($dsn, $user, $pass, { 'PrintError'=>1, 'RaiseError'=>1 });
my $sth = $dbh->prepare($select_sql);
$sth->execute();
%data = %{$sth->fetchall_hashref('external_db_id')};

# Backup existing table
if (!$no_backup) {
  $sth = $dbh->prepare($backup_sql);
  $sth->execute();
}

# Add new data
if (!$no_insert) {
  $sth = $dbh->prepare($insert_sql);
  foreach my $external_db_id (keys %mdata) {
    if (!exists $data{$external_db_id}) {
      $sth->execute(map {$mdata{$external_db_id}{$_}} @all_cols);
      print "Inserted data for external_db_id $external_db_id (".$mdata{$external_db_id}{'db_name'}.")\n";
    }
  }
}

# Update data
if (!$no_update) {
  $sth = $dbh->prepare($update_sql);
  foreach my $external_db_id (keys %mdata) {
    if (exists $data{$external_db_id}) {
      if (join('', (map {$mdata{$external_db_id}{$_} || ''} @cols)) ne 
          join('', (map {$data{$external_db_id}{$_} || ''} @cols))
      ) {
        $sth->execute((map {$mdata{$external_db_id}{$_}} @cols), $external_db_id);
        print "Updated data for external_db_id $external_db_id (".$mdata{$external_db_id}{'db_name'}.")\n";
      }
    }
  }
}

# Delete data
if (!$no_delete) {
  $sth = $dbh->prepare($delete_sql);
  foreach my $external_db_id (keys %data) {
    if (!exists $mdata{$external_db_id}) {
      $sth->execute($external_db_id);
      print "Deleted data for external_db_id $external_db_id (".$data{$external_db_id}{'db_name'}.")\n";
    }
  }
}
