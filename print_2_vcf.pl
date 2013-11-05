#!/usr/bin/perl
#
#print_2_vcf.pl
#10/25/2013 
#takes a list of genes and a vcf. Prints out lines in the vcf that match the genes in the list and that have the indicated genotype.
#to run: perl <gene_list> <snv_annotated_with_annovar>.vcf
#
#Dalia Ghoneim
use strict;
use warnings;
use Getopt::Long;

my $proband_index=35;
GetOptions ('PROBAND:i'=>\$proband_index);
my $file1 = shift;
my $file2 = shift;
my $father_index=$proband_index+1;
my $mother_index=$proband_index+2;

open my ($F1), $file1 or die $!;#genes list
open my ($F2), $file2 or die $!;#vcf

my @gene_list;

#save genes in array
LINE: while ($_=<$F1>){
        my @line = split /\t/;
                push @gene_list, $line[0];
}
close $F1;

#now iterate through vcf file and print lines that are in our list of genes that also have a specified pedigree pattern
my %genes_list = map { $_ => 1 } @gene_list;

LINE: while ($_=<$F2>){
        my @line = split /\t/;
        if (exists($genes_list{$line[1]})&&($line[$proband_index] =~ m{0/1})&&($line[$father_index] =~m{0/0}) && ($line[$mother_index] =~ m{0/1})){
                print join(qq/\t/,@line);
        }
        elsif (exists($genes_list{$line[1]})&&($line[$proband_index] =~ m{0/1})&&($line[$father_index] =~m{0/1}) && ($line[$mother_index] =~ m{0/0})){
                print join(qq/\t/,@line);
        }
}       
close $F2;

