#!perl

use strict;
use warnings;

## Aim is to expand CDS 3 bases downstream to include the stop codon,
## where appropriate.

my %STOP_CODON = (TAA => 1, TGA => 1, TAG => 1);


## INPUT is provided in FASTA format.

my $header;
while(<>){
    chomp;
    
    if(/^>(.*)$/){
        die if
          defined $header;
        $header = $1;
    }
    else{
        die unless
          defined $header;
        if(exists $STOP_CODON{$_}){
            print join("\t", split(/\|/, $header)), "\n";
        }
        $header = undef;
    }
}

