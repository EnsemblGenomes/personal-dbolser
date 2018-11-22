#!perl

use strict;
use warnings;

use Bio::EnsEMBL::Registry;
use Bio::EnsEMBL::Analysis;

die "pass a GAF\n"
  unless @ARGV;

warn "loading the registry\n";
Bio::EnsEMBL::Registry->
  load_registry_from_db(
    -HOST => 'mysql-eg-devel-2.ebi.ac.uk',
    -PORT => '4207',
    -USER => 'ensrw',
    -PASS => 'scr1b3d2',
  );

my $analysis_obj = Bio::EnsEMBL::Analysis->
    new( -logic_name      => 'gaf_loader',
         # TODO: these settings should be made configurable on the
         # command line, and probably changed here too...
         -program         => 'gaf_loader.pl',
         -description     => 'GAF loader implemented by DB',
         -display_label   => 'GAF loader',
         # ... Other analysis fields useful here?
    );

warn "getting adaptors\n";
my $gene_adaptor = Bio::EnsEMBL::Registry->
    get_adaptor( 'Arabidopsis', 'Core', 'Gene' )
      or die "xx\n";
my $dbEntry_adaptor = Bio::EnsEMBL::Registry->
    get_adaptor( 'Arabidopsis', 'Core', 'DBEntry' )
      or die "yy\n";



warn "parsing\n";
while(<>){
    ## Skip comments
    next if /^!/;

    ## Parse columns
    chomp;
    my @cols = split(/\t/, $_, 17);

    ## Check for the expected 17 cols
    die "is this GAF2.0?\n" unless @cols == 17;

    ## Get column values to descriptive variables
    my ($db, $db_object_id, $db_object_symbol, $qualifiers, $go_id,
        $db_references, $evidence_code, $with_or_froms, $aspect,
        $db_object_name, $db_object_synonyms, $db_object_type,
        $taxons, $date, $assigned_by, $annotation_extensions,
        $gene_product_form_id
       ) = @cols;

    ## Check for mandatory options
    die "'",
      join("'\t'",
           $db, $db_object_id, $db_object_symbol, $go_id,
           $db_references, $evidence_code, $aspect, $db_object_type,
           $taxons, $date, $assigned_by,
          ), "'\n"
        unless
           $db && $db_object_id && $db_object_symbol && $go_id &&
           $db_references && $evidence_code && $aspect &&
           $db_object_type && $taxons && $date && $assigned_by;

    ## There are some things we don't talk about...
    next if
        ( $go_id eq 'GO:0005575' ||   ## Cellular component
          $go_id eq 'GO:0003674' ||   ## Molecular function
          $go_id eq 'GO:0008150' ) && ## Biological process
        $db_references eq 'TAIR:Communication:1345790' &&
        $evidence_code eq 'ND';

    ## Split possible multiple options
    my @qualifiers            = split(/\|/, $qualifiers);
    my @db_references         = split(/\|/, $db_references);
    my @with_or_froms         = split(/\|/, $with_or_froms);
    my @db_object_synonyms    = split(/\|/, $db_object_synonyms);
    my ($taxon, $pathogen)    = split(/\|/, $taxons, 2);
    my @annotation_extensions = split(/\|/, $annotation_extensions);



    ## Try to do a lookup in EnsemblPlants...

    ## TODO: Make use of taxon here?

    ## We'll use these columns to find the gene object to annotate
    # print $db_object_id, "\n";
    # print $db_object_symbol, "\n";
    # print $db_object_name, "\n";
    # print $db_object_synonyms, "\n";
    # print "\n";

    my $gene_obj;

    ## First, try to use the db_object_name as a stable_id...
    if ($db_object_name){
        $gene_obj = $gene_adaptor->
          fetch_by_stable_id( $db_object_name );
    }

    ## If not, see if we have *one* XRef for the db_object_symbol...
    unless ($gene_obj){
        my $gene_obj_aref = $gene_adaptor->
          fetch_all_by_external_name( $db_object_symbol );
        if (@$gene_obj_aref == 1){
            $gene_obj = $gene_obj_aref->[0];
        }
    }

    ## If not, lets look at the synonyms as XRefs, one by one...
    unless ($gene_obj){
        if(@db_object_synonyms){
            my %best_guess;
            ## There can be more than one synonym...
            for my $db_object_synonym (@db_object_synonyms){
                my $gene_obj_aref = $gene_adaptor->
                    fetch_all_by_external_name( $db_object_synonym );
                ## and each synonym can match more than one gene...
                for my $gene_obj (@$gene_obj_aref){
                    # print join("\t",
                    #   $db_object_synonym, $gene_obj->stable_id ), "\n";
                    ## so lets just take the consensus vote...
                    $best_guess{$gene_obj->stable_id}++;
                }
            }
            ## TODO: what about ties?
            my ($best_guess) =
                (sort {$best_guess{$b} <=> $best_guess{$a}} keys %best_guess);
            # print "picking ", $best_guess, "\n";
            $gene_obj =  $gene_adaptor->
                fetch_by_stable_id( $best_guess );
        }
    }

    ## If not, you can't say we didn't try...
    unless ($gene_obj){
        warn "Cant match this record\n$_\n\n";
        next;
    }

    ## LOG IT!
    print
        join("\t",
             $gene_obj->stable_id, $go_id
        ), "\n";



    ## Now we have a gene to annotate, lets annotate it in the core

    ## Actually we annotate the genes 'canonical translation'
    my $ensembl_obj = $gene_obj->canonical_transcript->translation;
    my $ensembl_obj_type = 'Translation';

    ## but some genes (such as snoRNAs or annotated pseudogenes) don't
    ## have a translation!
    unless($ensembl_obj){
        $ensembl_obj = $gene_obj->canonical_transcript;
        $ensembl_obj_type = 'Transcript';
    }

    ## OH WHAT NOW!
    unless($ensembl_obj){
        warn "line $. : WHAT NOW FOR CHRISTS SAKE!\n";
        next;
    }



    ## First we create a new dbEntry for the GO term (if needed)...

    my $dbEntry = Bio::EnsEMBL::DBEntry->
        new( -primary_id   => $go_id,
             -display_id   => $go_id,
             -dbname       => 'GO',
             -linkage_type => $evidence_code,
             -analysis     => $analysis_obj,
             ## TODO: This is just for debugging...
             -linkage_annotation => $ARGV,
        );

    ## TODO: Handle qualifiers, db_references, with_or_froms and, last
    ## but not least, annotation_extensions.



    ## Finally, attach our shiny new XRef to the ensembl object!
    $ensembl_obj->add_DBEntry( $dbEntry );

    ## STORE THEM!
    $dbEntry_adaptor->
        store( $dbEntry, $ensembl_obj->dbID, $ensembl_obj_type, 1 );

}

warn "OK\n";
