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

my $file = shift;
open my ($F), $file or die $!;
open my ($F2), $file or die $!;
my %seen;
my @duplicate;
LINE: while ($_=<$F>){
        my @line = split /\t/;
        # skip line if this is the first time the gene is found
        if(defined($line[1])&& (! $seen{$line[1]})){
                $seen{$line[1]}=1;
                next;
        }
        #store genes with multiple variants in the array @duplicates
        if(defined($line[1])){
                push @duplicate, $line[1]; 
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
        if (defined($line[1]) && (exists($multihits{$line[1]})||($line[1] =~m{^Gene})) ){
                print join(qq/\t/, @line);

        }
}
close $F2;

