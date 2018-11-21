#!perl

use strict;
use warnings;

die "pass me a (list of) db names\n"
  unless @ARGV;

## There is a library for this somewhere...
my @servers = qw(
  mysql-staging-1
  mysql-staging-2
  mysql-staging-pre
  mysql-prod-1
  mysql-prod-2
  mysql-prod-3
  mysql-enaprod
  mysql-vmtest
  mysql-devel-1
  mysql-devel-2
  mysql-devel-3
);

my @databases;
while(<>){
    chomp;
    push @databases, $_;
}
warn "read ", scalar(@databases), " databases\n";

my $SQL = "
  SELECT
    TABLE_SCHEMA, TABLE_NAME,
    COALESCE(UPDATE_TIME, CREATE_TIME, NOW()) AS TIME
  FROM
    information_schema.TABLES
  WHERE
    TABLE_SCHEMA IN (\"". join("\",\"", @databases). "\")";


my %table_update_times;

for my $server (@servers){
    warn $server, "\n";
    open( IN, "-|", qq( $server -Ne '$SQL' ) )
      or die;
    while(<IN>){
        chomp;
        my ($db, $table, $time) = split/\t/;
        push @{$table_update_times{$db}{$table}}, [$time, $server];
    }
}


my %most_recent;

print "\t", join("\t", @servers), "\n";

for my $db (keys %table_update_times){
    for my $table (keys %{$table_update_times{$db}}){
        my @server_times = sort {$b->[0] cmp $a->[0]}
          @{$table_update_times{$db}{$table}};
        
        #warn
        #  join("\t", $db, $table, $server_times[0][1]), "\n";

        #warn
        #    join("\t", $db, $table, map {$_->[1]} @server_times), "\n";

        $most_recent{$db}{$server_times[0][1]}++;
    }
}


for my $db (sort keys %most_recent){
    print join("\t", $db,
               map {$most_recent{$db}{$_} || 0} @servers), "\n";
}
