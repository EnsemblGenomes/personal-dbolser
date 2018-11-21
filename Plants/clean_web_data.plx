#!/usr/bin/env perl

use strict;
use warnings;

use Data::Dumper;
$Data::Dumper::Sortkeys = 1;
$Data::Dumper::Indent = 0;
$Data::Dumper::Terse = 1;

while(<>){
    my $x = clean_web_data($_);
}

sub clean_web_data {
    my $string = shift;
    my $hash = eval $string;
    print Dumper $hash;
    print "\n";
}
