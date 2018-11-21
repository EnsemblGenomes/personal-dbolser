#!perl

use strict;
use warnings;

die "pass results of coord_system.sql!\n"
  unless @ARGV;

my $debug = 0;
my %filter;



## Note that results are orderd longest range first

LINE:
while(<>){
    chomp;
    my ($asm_id,
        $cmp_id,
        $s_asm_st, $s_asm_en,
        $s_cmp_st, $s_cmp_en, $s_ori
       ) = split /\t/;
    
    ## Sanity check...
    warn "DOUBLE FUCK!\n$_\n" if
      ($s_asm_en - $s_asm_st) != ($s_cmp_en - $s_cmp_st);
    
    if ( ! exists $filter{$asm_id}{$cmp_id} ){
        if($debug){
            warn "pushing new\n";
            warn_assembly( $asm_id, $cmp_id,
                           $s_asm_st, $s_asm_en,
                           $s_cmp_st, $s_cmp_en, $s_ori );
        }
        push @{$filter{$asm_id}{$cmp_id}},
          [$s_asm_st, $s_asm_en,
           $s_cmp_st, $s_cmp_en, $s_ori];
        next LINE;
    }
    else{
        ## Check if this sub-alignment 'fits within' one of the
        ## existing master-alignments...
        
        for my $m (@{$filter{$asm_id}{$cmp_id}}){
            my ($m_asm_st, $m_asm_en,
                $m_cmp_st, $m_cmp_en, $m_ori) = @$m;
            
            ## Does the sub fall with within the master?
            if($m_asm_st <= $s_asm_st &&
               $m_asm_en >= $s_asm_en &&
               $m_ori    == $s_ori){
                
                ## Does the sub have the same 'alignment offset' as
                ## the master?
                my $mo_st = $m_asm_st - $m_cmp_st;
                my $so_st = $s_asm_st - $s_cmp_st;
                
                my $in_phase =
                  $mo_st == $so_st;
                
                if ($debug || (!$in_phase)){
                    warn_assembly( $asm_id, $cmp_id,
                                   $m_asm_st, $m_asm_en,
                                   $m_cmp_st, $m_cmp_en, $m_ori );
                    warn_assembly( $asm_id, $cmp_id,
                                   $s_asm_st, $s_asm_en,
                                   $s_cmp_st, $s_cmp_en, $s_ori );
                    warn "$in_phase\n\n";
                }
                
                ## If so, we can trash the sub
                if ($in_phase){
                    my $sql = "DELETE FROM assembly WHERE ";
                    $sql   .= "  asm_seq_region_id = $asm_id AND ";
                    $sql   .= "  cmp_seq_region_id = $cmp_id AND ";
                    $sql   .= "  asm_start = $s_asm_st AND ";
                    $sql   .= "  asm_end   = $s_asm_en AND ";
                    $sql   .= "  cmp_start = $s_cmp_st AND ";
                    $sql   .= "  cmp_end   = $s_cmp_en AND ";
                    $sql   .= "  ori       = $s_ori ";
                    $sql   .= "LIMIT 1;";
                    print "$sql\n";
                    
                    ## and skip on
                    next LINE;
                }
                
                ## Stuff out of phase is worrying...
                else{
                    warn "FUCK!\n" if $debug;
                }
            }
            warn "next master\n" if $debug;
        }
        ## Else, the sub-alignment doesnt fit within *any* master, so
        ## we create a new master
        if($debug){
            warn "pushing two\n";
            warn_assembly( $asm_id, $cmp_id,
                           $s_asm_st, $s_asm_en,
                           $s_cmp_st, $s_cmp_en, $s_ori );
        }
        push @{$filter{$asm_id}{$cmp_id}},
          [$s_asm_st, $s_asm_en,
           $s_cmp_st, $s_cmp_en, $s_ori];
    }
    warn "next line\n" if $debug;
}

warn "OK\n";


sub warn_assembly{
    my ($asm_id, $cmp_id,
        $asm_st, $asm_en,
        $cmp_st, $cmp_en, $s_ori,
       ) = @_;
    
    warn
      join(" ",
           map {sprintf("%12d",$_)}
           $asm_id, $cmp_id,
           $asm_st, $asm_en,
           $cmp_st, $cmp_en, $s_ori,
          ), "\n";
}
