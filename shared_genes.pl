#!/usr/bin/perl
#
#shared_genes.pl
#05/28/2013
#Finds genes that are shared in file_1 and file_2 
#to run: perl shared_genes.pl  <file_1> <file_2>
#to write results to a file: perl shared_genes.pl <file_1> <file_2>  >  <output_file>
#Alex Paciorkowski, Dalia Ghoneim
#
use strict;
use warnings;

my $file1 = shift;
my $file2 = shift;
open my ($F1), $file1 or die $!;
open my ($F2), $file2 or die $!;

my @genes_1;#this is an array that will contain the shared genes

#iterate through file 1
LINE: while (my $line=<$F1>){
        push @genes_1, $line;#variant passed from parent1

}
close $F1;

#now iterate through  file 2
my %gene = map { $_ => 1 } @genes_1;
LINE: while (my $line =<$F2>){
        print $line if (exists($gene{$line}));

}       
close $F2;
#print STDERR "Done.\n";
