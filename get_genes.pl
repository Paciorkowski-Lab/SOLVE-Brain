#!/usr/bin/perl
#
# get_genes.pl
#
# It takes a vcf annotated by Annovar
# and extracts the gene symbols
#
# Written 9 Mar 2013
# Alex Paciorkowski, Dalia Ghoneim

use strict;
use warnings;
use Getopt::Long;
my $GENE_INDEX=1;
GetOptions ('GENE_INDEX:i'=>\$GENE_INDEX);
my $file = shift;

open my ( $F ), $file or die $!;
LINE: while ($_=<$F>) {
    my @line = split /\t/;
        my @gene_symbol = $line[$GENE_INDEX];

            my $printme = 0;
                ++$printme if @gene_symbol;
                                   
            print join(qq/\t/, @gene_symbol, qq/\n/) if $printme;
                              }
