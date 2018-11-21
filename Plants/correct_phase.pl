#!/usr/bin/env/perl
use strict;
use warnings;

use Getopt::Long qw(:config no_ignore_case);
use Bio::EnsEMBL::DBSQL::DBAdaptor;

# Calculate phase for all exons, and store in db.
# Print any discrepancies with existing data to stdout.

my ($host, $port, $user, $pass, $dbname, $validate, $verbose);

GetOptions(
  "host=s", \$host,
  "P|port=i", \$port,
  "user=s", \$user,
  "p|pass:s", \$pass,
  "dbname=s", \$dbname,
  "validate", \$validate,
  "verbose", \$verbose,
);
die "One or more missing parameters: --host, --port, --user, --dbname"
  unless $host && $port && $user && $dbname;
$validate = 0 unless $validate;
$verbose = 0 unless $verbose;

my $dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new
(
    -host   => $host,
    -port   => $port,
    -user   => $user,
    -pass   => $pass,
    -dbname => $dbname,
);

my $tra = $dba->get_adaptor('Transcript');
my $transcripts = $tra->fetch_all_by_biotype('protein_coding');

# There's no method to update an exon in the API, so have to do it by hand.
my $sql = 'UPDATE exon SET phase = ?, end_phase = ? WHERE stable_id = ?;';
my $sth = $dba->dbc->prepare($sql);

my $incorrect_phase = 0;
foreach my $transcript (sort { $a->stable_id cmp $b->stable_id } @{$transcripts}) {
  # The logic here isn't clever enough when different transcripts use
  # the same exons, but in different phases. You can get in a loop where
  # you correct it for one, but break it for the other, and so on.
  my $incorrect = set_exon_phase($transcript);
  
  if ($incorrect) {
    $incorrect_phase++;
    if (!$validate) {
      foreach my $exon (@{$transcript->get_all_Exons}) {
        $sth->execute($exon->phase, $exon->end_phase, $exon->stable_id);
      }
      print "Updated exons for ".$transcript->stable_id."\n" if $verbose;
    }
  }
}

print "$incorrect_phase transcripts with incorrect phase in $dbname\n";

sub set_exon_phase {
  my ($transcript) = @_;
  
  my ($phase, $end_phase, $incorrect) = (undef, undef, 0);
  my $offset = $transcript->translation->start - 1;
  
  foreach my $exon (@{$transcript->get_all_Exons()}) {
    if (defined $exon->coding_region_start($transcript)) {
      if ($transcript->translation->start_Exon->dbID eq $exon->dbID) {
        # Start exon should be -1 if there's a 5' UTR, 0 otherwise.
        if ($transcript->translation->start == 1) {
          if ($exon->phase == -1) {
            print "Exon ".$exon->stable_id." phase is ".$exon->phase.", should be 0\n" if $verbose;
            $exon->phase(0);
            $incorrect = 1;
          } elsif ($exon->phase != 0) {
            print "Exon ".$exon->stable_id." phase is ".$exon->phase.", which is invalid for the first coding exon. It won't we changed, however, since you need to decide whether the transcript or the translation should be cropped.\n";
            $incorrect = 1;
            last;
          }
        } else {
          if ($transcript->translation->start > 1 && $exon->phase != -1) {
            print "Exon ".$exon->stable_id." phase is ".$exon->phase.", should be -1\n" if $verbose;
            $exon->phase(-1);
            $incorrect = 1;
          }
        }
        $end_phase = ($exon->length - $offset) % 3;
        
      } else {
        if (!defined($phase)){
          print "Exon ". $exon->stable_id. " is weird!\n";
        }
        if ($exon->phase != $phase) {
          print "Exon ".$exon->stable_id." phase is ".$exon->phase.", should be $phase\n" if $verbose;
          $exon->phase($phase);
          $incorrect = 1;
        }
        $end_phase = ($phase + $exon->length) % 3;
      }
      # Phase for next exon is current end_phase.
      $phase = $end_phase;
      
      if ($transcript->translation->end_Exon->dbID eq $exon->dbID
          && $transcript->translation->end < $exon->length)
      {
        # The end_phase of the end exon should be -1 iff there is a UTR also on that exon.
        if ($exon->end_phase != -1) {
          print "Exon ".$exon->stable_id." end phase is ".$exon->end_phase.", should be -1\n" if $verbose;
          $exon->end_phase(-1);
          $incorrect = 1;
        }
      } else {
        if ($exon->end_phase != $end_phase) {
          print "Exon ".$exon->stable_id." end phase is ".$exon->end_phase.", should be $end_phase\n" if $verbose;
          $exon->end_phase($end_phase);
          $incorrect = 1;
        }
      }
      
    } else {
      if ($exon->phase != -1) {
        print "Exon ".$exon->stable_id." phase is ".$exon->phase.", should be -1\n" if $verbose;
        $exon->phase(-1);
        $incorrect = 1;
      }
      if ($exon->end_phase != -1) {
        print "Exon ".$exon->stable_id." end phase is ".$exon->end_phase.", should be -1\n" if $verbose;
        $exon->end_phase(-1);
        $incorrect = 1;
      }
    }
  }
  
  return $incorrect;
}
