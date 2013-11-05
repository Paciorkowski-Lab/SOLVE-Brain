#!/usr/bin/perl
#
#comp_het.pl
#08/28/2013 - allows user to spcify proband index
#08/22/2013 - previous version skips pedigree analysis of initial call of multihit gene
#05/29/2013
#Finds variants that are compound heterozygous and prints them: proband 0/1, parent1 0/1, parent2 0/0 AND proband 0/1, parent1 0/0, and parent2 0/1
#uses vcf annotated with annovar as input that contains only variants with multihits. Run multi_hits.pl first.
#to run: perl comp_het.pl [options] <multi_hits_output_file>
# available options:    --PROBAND=[integer]  this allows the user to specify the proband index. Default value is 35
#
#Dalia Ghoneim
use strict;
use warnings;
use Getopt::Long;

my $parent1;
my $parent2;
my @comp_hets;
my $gene_nameA="";
my $proband_index=35; 
GetOptions ('PROBAND:i'=>\$proband_index);
my $file = shift;
#print "proband is $proband_index";
my $father_index=$proband_index+1;
my $mother_index=$proband_index+2;
open my ($F), $file or die $!;
LINE: while ($_=<$F>){
        my @line = split /\t/;
        my $gene_nameB = $line[1];
        #if this is a new gene, reset parameters
        if(!($gene_nameB eq $gene_nameA)){
                $parent1=0;
                $parent2=0;
        }
        #is this homozygous genotype passed from one parent
        if (defined($line[$proband_index])&&($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/1})&&($line[$mother_index] =~ m{0/0})){
                $parent1=1;#variant passed from parent1=TRUE
        }
        if (defined($line[$proband_index])&&($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/0})&&($line[$mother_index] =~ m{0/1})){
                $parent2=1;#variant passed from parent2=TRUE
        }       
        
        #if this gene is compound het, store gene name
        if (($parent1) && ($parent2)){
                push @comp_hets, $line[1];
        }

        $gene_nameA = $line[1];
}
close $F;
open my ($F2), $file or die $!;
my %comp_het = map { $_ => 1} @comp_hets;
LINE: while ($_=<$F2>){
        my @line = split /\t/;
        if ((exists($comp_het{$line[1]})) && (($line[$proband_index] =~ m{0/1})&& (($line[$father_index] =~ m{0/0})&&($line[$mother_index] =~ m{0/1}))||(       ($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/1})&&($line[$mother_index] =~ m{0/0})))){
print join(qq/\t/, @line);
}


}
close $F2;
