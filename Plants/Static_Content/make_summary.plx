#!perl

use strict;
use warnings;

use Number::Format qw(:subs);

my %summary_data;

#summarise_dna_align_features.dump
#summarise_probe_features.dump
#summarise_simple_features.dump

open DNA, '<', 'summarise_dna_align_features.2dump'
  or die "failed to open summarise_dna_align_features.dump\n";

open REP, '<', 'summarise_repeats.dump'
  or die "failed to open summarise_repeats.dump\n";



while(<DNA>){
    # Skip headers
    next if /^DATABASE/;
    
    chomp;
    my @row = split/\t/;
    die scalar @row, "\n" unless @row == 14;
    
    ## DEBUGGING
    #print join("\t", @row[2,11]), "\n";
    
    my $db = $row[0];
    my $string = '';
    my $order = $row[11];
    
    ## Check 'displayable'
    if($row[10] ne 1){
        warn "ignoring un-displayable entry\n\t'$row[11]'\n";
        next;
    }
    
    $string = $row[11]. " run on $row[1] (track $row[9]).";
    
    push @{$summary_data{$db}{dna}{$order}}, $string;
}

while(<REP>){
    # Skip headers
    next if /^DATABASE/;
    
    chomp;
    my @row = split/\t/;
    die unless @row == 10;
    
    my $db = $row[0];
    my $string;
    my $order;
    
    if(0){} # I hate syntax
    
    ## Process the for types of repeats into HTML
    elsif($row[1] eq 'TRF' or $row[1] eq 'Dust'){
        $order = 1;
        #print join("\t", @row[1..7]), "\n";
        $string = $row[7]. ' Identified '.
            format_number($row[8]). ' repeats covering '.
            format_number($row[9]). ' bp.';
        #print $string, "\n";
    }
    elsif($row[1] eq 'RepeatMasker'){
        $order = 2;
        #print join("\t", @row[1..6]), "\n";
        
        ## Remove track specific text from the description line
        $row[7] =~ s/ This track usually shows repeats alone (not low-complexity sequences).//;
        
        ## Add one piece of extra information...
        $row[7] =~ s/is used to find/is used with per-species information to find/;
        
        $string = $row[7]. ' Identified '.
        format_number($row[8]). ' repeats covering '.
        format_number($row[9]). ' bp.';
        #print $string, "\n";
    }
    ## IMPORTS
    elsif($row[1] eq 'ENA' or $row[1] eq 'JGI' or $row[1] eq 'NULL'){
        $order = 3;
        #print join("\t", @row[1..7]), "\n";
        $string = $row[7]. '. Identified '.
        format_number($row[8]). ' repeats covering '.
        format_number($row[9]). ' bp.';
        #print $string, "\n";
    }
    else{
        die "$_\n";
    }
    
    push @{$summary_data{$db}{repeats}{$order}}, $string;
}


for my $db (sort keys %summary_data){
    print "$db\n";
    
    for my $type (sort keys %{$summary_data{$db}}){
        print "\t$type\n";
        
        for my $i (keys %{$summary_data{$db}{$type}}){
            my $li_aref = $summary_data{$db}{$type}{$i};
            for my $li (@$li_aref){
                print "\t\t$li\n";
            }
        }
    }
}







__END__


EDITS to METADATA!!! (MAKE THESE IN TEH DB NOW!

REPEATS

1) Removed inconsistent double spacing from the Dust description field.

2) Added module =~ s/NULL/RepeatMasker/ for brapa (description is for
   RepeatMasker! Same for TRF. Same for TRF and Dust in vvinifera.

3) Added module =~ s/NULL/ENA/ for ENA repeats in creinhardtii. Same
   for smoellendorffii. Set module =~ s/NULL/JGI/ in ppatens.

4) Added description s/NULL/Repeats detected using the
   Wessler/Bennetzen library using <a rel="external"
   href="http://www.repeatmasker.org">RepeatMasker</a>./ for
   zmays. Same (add a description) for the regular RepeatMasker run in
   zmays.


DNA

1) Typo: s/Alignmments of EST clusters (Unigenes, Gene Indices) from
   all dicot species/Alignments of EST clusters (Unigenes, Gene
   Indices) from all dicot species/.

2) Typo: s/hgrape/grape species/, s/from Arabidopsis/from Arabidopsis
   species/, s/from Maize/from Maize species/.

3) Standardize: s/Genomics/Genomic/, s/Genomic alignments of rice
   (Oryza) "restriction fragment length polymorphism" (RFLP)/Genomic
   alignments of rice (Oryza) RFLP (restriction fragment length
   polymorphism) markers/, s/genomics location of RFLP (restriction
   fragment length polymorphism) markers/Genomic location of RFLP
   (restriction fragment length polymorphism) markers/

4) s/Genomic alignments of rice (Oryza) EST clusters (Unigenes, Gene
   Indices)/Alignments of EST clusters (Unigenes, Gene Indices) from
   rice (Oryza) species/


      



Rerun for brapa?
Rerun for zmays?
Rerun for all?
