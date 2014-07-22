#!/usr/bin/perl
#
#multi_hits.pl
#Finds variants in an annotated (annovar) vcf that have multiple hits.
#will print out lines
#05/23/2013
#to run: perl multi_hits.pl <snv_vcf>
#Dalia Ghoneim
use strict;
use warnings;
use Getopt::Long;
my $GENE_INDEX=1;
GetOptions ('GENE_INDEX:i'=>\$GENE_INDEX);
my $file = shift;
open my ($F), $file or die $!;
open my ($F2), $file or die $!;
my %seen;
my @duplicate;
LINE: while ($_=<$F>){
        my @line = split /\t/;
        # skip line if this is the first time the gene is found
        if(defined($line[$GENE_INDEX])&& (! $seen{$line[$GENE_INDEX]})){
                $seen{$line[$GENE_INDEX]}=1;
                next;
        }
        #store genes with multiple variants in the array @duplicates
        if(defined($line[$GENE_INDEX])){
                push @duplicate, $line[$GENE_INDEX]; 
        }
}
close $F;
#go through file again with duplicate list (This is redundant, must be a better way) and print lines
#if it is a gene with multiple hits
my %multihits = map { $_ => 1 } @duplicate;
@duplicate = keys %multihits;
my @multihit_lines;
LINE: while ($_=<$F2>){
        my @line = split /\t/;
        #also preserves header or vcf
        if (defined($line[$GENE_INDEX]) && (exists($multihits{$line[$GENE_INDEX]}))){
                print join(qq/\t/, @line);

        }
}
close $F2;

