#!perl

use strict;
use warnings;

my $query = <<SQL;
  SELECT *
  FROM assembly
  #INNER JOIN seq_region asm ON asm_seq_region_id = asm.seq_region_id
  #INNER JOIN seq_region cmp ON cmp_seq_region_id = cmp.seq_region_id
SQL

die "pass the output of query\n$query\n"
  unless @ARGV;


my %maps;
while(<>){
    my ($asm_seq_region_id,
        $cmp_seq_region_id,
        $asm_start,
        $asm_end,
        $cmp_start,
        $cmp_end,
        $ori) = split/\t/;

    ## Basic santity test...
    die "gah!\n$_"
      if $asm_end < $asm_start or
        $asm_end-$asm_start !=
        $cmp_end-$cmp_start;

    push @{$maps{$asm_seq_region_id.':'.$cmp_seq_region_id}},
      [$asm_start, $asm_end];
}

warn 'got ', scalar keys %maps, " maps\n";

for (keys %maps){
    next unless @{$maps{$_}} > 1;
    print "multimap: ", scalar @{$maps{$_}}, "\t$_\n";
}
