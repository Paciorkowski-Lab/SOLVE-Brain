#!/usr/bin/perl
#
#determine_index.pl
#10/30/2013
#this is intended to help the user confirm the index number of samples in larger vcfs
#skips the first line of a vcf (in case there is a header line) and prints the index number and the content of each column in this second line
#prints to stdout
#usage: perl determine_index.pl <vcf_file>

use strict;
use warnings;

my $index_num=0;
my $line_num=0;
my $index;
my $file = shift;
open my ( $F ), $file or die $!;
LINE: while ($_=<$F>) {
    my @line = split /\t/;
        next if /^##/;
        $line_num++;
        if( $line_num == 2){
                my $arraySize = scalar(@line);
                for( $index=0; $index<$arraySize; $index++){
                        print "[$index] \t$line[$index]\n";
                }
        }
        
                                   
}

