#!perl

use strict;
use warnings;

use Getopt::Long;

my $server;
my $database;

GetOptions( 'server=s' => \$server,
            'database=s' => \$dat2abase,
          )
  or die "failed to parse options\n";

die "please pass 'mysql-command' and database name\n"
  unless $server && $database;

## GETTING A DBH IS A PAIN IN THE ASSETS!

my $SQL = << 'SQL';
  SELECT
    DATABASE(),
    ##
    created,
    logic_name,
    db, db_version,
    program, program_version, parameters,
    module,
    ##
    display_label, displayable, description,
    ##
    COUNT(*)                               AS N,
    SUM(seq_region_end-seq_region_start+1) AS LEN
  FROM
    analysis
  INNER JOIN
    analysis_description USING (analysis_id)
SQL

my $SQLa = << 'SQL';
  INNER JOIN
    repeat_feature       USING (analysis_id)
#  INNER JOIN
#    repeat_consensus     USING (repeat_consensus_id)
  GROUP BY
    analysis_id
  ;
SQL

my $SQLb = << 'SQL';
  INNER JOIN
#    simple_feature       USING (analysis_id)
    dna_align_feature    USING (analysis_id)
  GROUP BY
    analysis_id
  ;
SQL

my $SQLc = << 'SQL';
  SELECT
    DATABASE(),
    array.*,
    COUNT(*)                               AS N,
    SUM(seq_region_end-seq_region_start+1) AS LEN
  FROM
    probe_feature
  INNER JOIN
    probe      USING (probe_id)
  INNER JOIN
    array_chip USING (array_chip_id)
  INNER JOIN
    array      USING (array_id)
  GROUP BY
    array_id
  ;
SQL


## PICK A QUERY...
#$SQL .= $SQLa;
$SQL .= $SQLb;

system("$server $database -e \"$SQL\"")
  and die "fooo!\n";

warn "OK\n";



__END__

while read -r db; do
  perl make_dumps.plx -s mysql-staging-2 -d $db
done \
  < <(grep -P "_core_|_otherfeatures_" ../plant_22_db.list) \
  > summarise_dna_align_features.2dump


