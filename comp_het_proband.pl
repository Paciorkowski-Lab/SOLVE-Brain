#!/usr/bin/perl
#
#comp_het_proband.pl
#08/28/2013
#Finds variants that are compound heterozygous and prints them: proband 0/1, parent1 0/1, parent2 0/0 AND proband 0/1, parent1 0/0, and parent2 0/1
#uses vcf annotated with annovar as input that contains only variants with multihits. Run multi_hits.pl first.
#to run: perl comp_het_proband.pl [options] <multi_hits_output_file>
# available options:    --PROBAND=[integer]  this allows the user to specify the proband index. Default value is 35
#
#Dalia Ghoneim
use strict;
use warnings;
use Getopt::Long;
my $NUM_AFFECTED=1;
my $parent1;
my $parent2;
my $aff_geno_match;
my @comp_hets;
my $gene_nameA="";
my $proband_index=35;
my $GENE_INDEX=1;
GetOptions ('NUM_AFFECTED:i'=>\$NUM_AFFECTED, 'PROBAND:i'=>\$proband_index, 'GENE_INDEX:i'=>\$GENE_INDEX);
my $file = shift;
my $i;
#print "proband is $proband_index";
my $father_index=$proband_index+$NUM_AFFECTED;
my $mother_index=$proband_index+$NUM_AFFECTED+1;
open my ($F), $file or die $!;
LINE: while ($_=<$F>){
        my @line = split /\t/;
        my $gene_nameB = $line[$GENE_INDEX];
        #if this is a new gene, reset parameters
        if(!($gene_nameB eq $gene_nameA)){
                $parent1=0;
                $parent2=0;
        }
        #is this homozygous genotype passed from one parent
        if (defined($line[$proband_index])&&($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/1})&&($line[$mother_index] =~ m{0/0})){
		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){
			$parent1=1;#variant passed from parent1=TRUE
		}
	} elsif (defined($line[$proband_index])&&($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/0})&&($line[$mother_index] =~ m{0/1})){
		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){
			$parent2=1;#variant passed from parent2=TRUE
        
		}       
	}
        #if this gene is compound het, store gene name
        if (($parent1) && ($parent2)){
                push @comp_hets, $line[$GENE_INDEX];
        }

        $gene_nameA = $line[$GENE_INDEX];
}
close $F;
open my ($F2), $file or die $!;
my %comp_het = map { $_ => 1} @comp_hets;
LINE: while ($_=<$F2>){
        if ($_ =~ m{Gene}){ print $_; }
	my @line = split /\t/;
        if ((exists($comp_het{$line[$GENE_INDEX]})) && (($line[$proband_index] =~ m{0/1})&& (($line[$father_index] =~ m{0/0})&&($line[$mother_index] =~ m{0/1}))||(($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/1})&&($line[$mother_index] =~ m{0/0})))){
		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){
			print join(qq/\t/, @line);
		}
	}


}
close $F2;
