#!/usr/bin/env/perl
use strict;
use warnings;

use Getopt::Long qw(:config no_ignore_case);
use Bio::EnsEMBL::DBSQL::DBAdaptor;
use Digest::MD5;

my ($host, $port, $user, $pass, $dbname);

GetOptions(
  "host=s",   \$host,
  "P|port=i", \$port,
  "user=s",   \$user,
  "p|pass=s", \$pass,
  "dbname=s", \$dbname,
);

warn "host=$host port=$port user=$user pass=$pass dbname=$dbname\n";

my $dba = Bio::EnsEMBL::DBSQL::DBAdaptor->new
(
    -host   => $host,
    -port   => $port,
    -user   => $user,
    -pass   => $pass,
    -dbname => $dbname,
);
warn $dba, "\n";


my $tra = $dba->get_adaptor("Transcript");
my $transcripts = $tra->fetch_all_by_biotype('protein_coding');

warn "got ", scalar @$transcripts, " transcripts\n";

# There's no method to update exon data in the API, so have to do it by hand.
my $insert_sql = '
  INSERT INTO exon (seq_region_id, seq_region_start, seq_region_end, seq_region_strand, phase, end_phase, stable_id)
  VALUES (?, ?, ?, ?, ?, ?, ?);';
my $insert_sth = $dba->dbc->prepare($insert_sql);

my $update_sql = 'UPDATE exon SET seq_region_start = ?, seq_region_end = ?, phase = ?, end_phase = ? WHERE stable_id = ?;';
my $update_sth = $dba->dbc->prepare($update_sql);

my $eti_sql = 'INSERT INTO exon_transcript (exon_id, transcript_id, rank) VALUES (?, ?, ?);';
my $eti_sth = $dba->dbc->prepare($eti_sql);

my $etu_sql = 'UPDATE exon_transcript SET rank = ? WHERE exon_id = ? AND transcript_id = ?;';
my $etu_sth = $dba->dbc->prepare($etu_sql);

my ($last_exon_id, $last_exon_length);

foreach my $transcript (sort { $a->stable_id cmp $b->stable_id } @{$transcripts}) {
  next unless $transcript->translate()->seq() =~ /\*/;
  
  my $stable_id = $transcript->stable_id;
  my $rank = 0;
  
  warn "correcting $stable_id\n";

  foreach my $exon (@{$transcript->get_all_Exons()}) {
    $rank++;
    my $exon_seq = $exon->seq()->seq();
    if ($exon_seq =~ /N+[^N]/) {
      my $start = $exon->start;
      my $end = $exon->end;
      my $strand = $exon->strand;
      my $phase = $exon->phase;
      my $sr_id = $transcript->slice->get_seq_region_id;
      
      $exon_seq = reverse($exon_seq) if $strand != 1;
      my ($seq1, $seq2) = $exon_seq =~ /^([^N]+)N+([^N].*)$/;
      
      my ($new_start, $new_end);
      if ($strand == 1) {
        $new_start = $end - length($seq2) + 1;
        $new_end = $end;
        $end = $start + length($seq1) - 1 + 1;
      }
      else {
        $new_start = $start;
        $new_end = $start + length($seq1) - 1;
        $start = $end - length($seq2) + 1 - 1;
      }
      
      print "$stable_id ($strand): Existing: $start - $end, New: $new_start - $new_end\n";
      
      my $end_phase = ($phase + $end - $start + 1) % 3;
      my $new_stable_id = $transcript->stable_id.'-E'.++$rank;
      my $new_phase = $end_phase;
      my $new_end_phase = ($new_phase + $new_end - $new_start + 1) % 3;
      
      $update_sth->execute($start, $end, $phase, $end_phase, $exon->stable_id);
      $insert_sth->execute($sr_id, $new_start, $new_end, $strand, $new_phase, $new_end_phase, $new_stable_id);
      my $exon_id = $dba->dbc->db_handle->last_insert_id(undef, undef, undef, undef);
      $eti_sth->execute($exon_id, $transcript->dbID, $rank);
      
      $last_exon_id = $exon_id;
      $last_exon_length = $new_end - $new_start + 1;
    }
    else {
      $etu_sth->execute($rank, $exon->dbID, $transcript->dbID);
      $last_exon_id = $exon->dbID;
      $last_exon_length = length($exon->seq()->seq());
    }
  }

  # There's no method to update a translation in the API, so have to do it by hand.
  my $sql = 'UPDATE translation SET end_exon_id = ?, seq_end = ? WHERE stable_id = ?;';
  my $sth = $dba->dbc->prepare($sql);
  $sth->execute($last_exon_id, $last_exon_length, $transcript->translation->stable_id);
}
