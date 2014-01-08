#!/usr/bin/perl
#
#print_2_vcf.pl
#10/25/2013 
#takes a list of genes and a vcf. Prints out lines in the vcf that match the genes in the list and that have the indicated genotype.
#in this case, the pedigree is CH
#to run: perl print_2_vcf.pl <gene_list> <snv_annotated_with_annovar>.vcf
#
#Dalia Ghoneim
use strict;
use warnings;
use Getopt::Long;
my $aff_geno_match;
my $proband_index=35;
my $NUM_AFFECTED=1;
my $i;
GetOptions ('NUM_AFFECTED:i'=>\$NUM_AFFECTED, 'PROBAND:i'=>\$proband_index);
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
		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){		
			print join(qq/\t/,@line);
		}
	}
        elsif (exists($genes_list{$line[1]})&&($line[$proband_index] =~ m{0/1})&&($line[$father_index] =~m{0/1}) && ($line[$mother_index] =~ m{0/0})){
       		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){		
			print join(qq/\t/,@line);
		}
        }
}       
close $F2;

