#! perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;

my $species = 'sorghum_bicolor';

warn "Loading registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db( -host => 'mysql-eg-staging-2.ebi.ac.uk',
                         -user => 'ensro',
                         -port => '4275',
                       );

## Get adaptor (we just use it to get a variation dbc!)
warn "Getting adaptor\n";
my $ga = Bio::EnsEMBL::Registry->
  get_adaptor($species, "variation", "individualgenotype")
  or die("ERROR: Failed to adaptor");
warn "$ga\n";

warn "Preparing SQL\n";
my $sth = $ga->dbc->
  prepare(qq{
    SELECT
      variation_id, subsnp_id, genotypes
    FROM
      compressed_genotype_var
    })
  or die;

warn "Preparing SQL2\n";
my $sth2 = $ga->dbc->
  prepare(qq{
    SELECT
      MAX(IF(haplotype_id=1, allele, 0)) AS allele_1,
      MAX(IF(haplotype_id=2, allele, 0)) AS allele_2
    FROM
      genotype_code
    INNER JOIN
      allele_code
    USING
      (allele_code_id)
    WHERE
      genotype_code_id = ?
    GROUP BY
      genotype_code_id
    })
  or die;

warn "Executing SQL\n";
$sth->execute
  or die;

warn "Processing results\n";
my ($variation_id, $subsnp_id, $compressed_genotypes);

$sth->
  bind_columns(\$variation_id, \$subsnp_id, \$compressed_genotypes);

my %done;
while($sth->fetch) {
    my @genotypes = unpack("(ww)*", $compressed_genotypes);
    
    while(@genotypes) {
        my $individual_id = shift @genotypes;
        my $gt_code_id    = shift @genotypes;
        
        #warn "Executing SQL2\n";
        $sth2->execute($gt_code_id)
          or die;
        
        my ($allele_1, $allele_2);
        $sth2->
          bind_columns(\$allele_1, \$allele_2);
        
        while($sth2->fetch){
            print
              join("\t",
                   $variation_id,
                   $subsnp_id || '\N',
                   $allele_1,
                   $allele_2,
                   $individual_id,
                  ), "\n";
        }
    }
    #exit;
}
$sth->finish();

warn "OK\n";
