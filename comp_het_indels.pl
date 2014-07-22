#!/usr/bin/perl
#
#comp_het_indels.pl
#09/18/2013 - allow user to specify proband index. Default value if 35, prints entire vcf, not just the genelist
#05/23/2013
#Finds variants in snv files that that are heterozygous recessive and search indel file for compound heterozygous
#relationship with these same genes.
#to run: perl comp_het_indels <snv_annotated_with_annovar>.vcf <indel_annotated_with_annovar>.vcf
#
#Dalia Ghoneim
#
use strict;
use warnings;
use Getopt::Long;
my $NUM_AFFECTED=1;
my $proband_index=35;
my $aff_geno_match;
my $GENE_INDEX=1;
GetOptions ('NUM_AFFECTED:i'=>\$NUM_AFFECTED,'PROBAND:i'=>\$proband_index,'GENE_INDEX:i'=>\$GENE_INDEX);
my $file1 = shift;
my $file2 = shift;
my $i;
my $father_index=$proband_index+$NUM_AFFECTED;
my $mother_index=$proband_index+$NUM_AFFECTED+1;

open my ($F1), $file1 or die $!;#snv vcf
open my ($F2), $file2 or die $!;#indel vcf

my @parent1_snv;
my @parent2_snv;
my @compound_hets;

#iterate through snv file for heterozygous variants
LINE: while ($_=<$F1>){
        my @line = split /\t/;
        if (defined($line[$proband_index])&&($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/1})&&($line[$mother_index] =~ m{0/0})){
		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){
			push @parent1_snv, $line[$GENE_INDEX];#variant passed from parent1
		}
        }
        if (defined($line[$proband_index])&&($line[$proband_index] =~ m{0/1})&& ($line[$father_index] =~ m{0/0})&&($line[$mother_index] =~ m{0/1})){
		#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){		
			push @parent2_snv, $line[$GENE_INDEX];#variant passed from parent2
        
		}       
	}
}
close $F1;

#now iterate through indel file
my %par1_snv = map { $_ => 1 } @parent1_snv;
my %par2_snv = map { $_ => 1 } @parent2_snv;
LINE: while ($_=<$F2>){
        my @line = split /\t/;
        #is this gene variant from parent1 in snvs and parent2 in indels
        if (defined($line[$GENE_INDEX]) && exists($par1_snv{$line[$GENE_INDEX]})&&($line[$proband_index] =~ m{0/1})&&($line[$father_index] =~m{0/0}) && ($line[$mother_index] =~ m{0/1})){
              	#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){
			push @compound_hets, $line[$GENE_INDEX];
		}
        }
        #is this gene variant from parent2 in snvs and parent1 in indels
        if (defined($line[$GENE_INDEX]) && exists($par2_snv{$line[$GENE_INDEX]})&&($line[$proband_index] =~ m{0/1})&&($line[$father_index] =~m{0/1}) && ($line[$mother_index] =~ m{0/0})){
               	#handle multiple affecteds
		$aff_geno_match=1;
		for($i=1;$i<$NUM_AFFECTED;$i++){
			if ($line[$proband_index+$i]=~m{0/1}){
				$aff_geno_match++;
			}
		}
		if ($aff_geno_match == $NUM_AFFECTED){
		       	push @compound_hets, $line[$GENE_INDEX];
		}
        }
}       
close $F2;

#print compound het gene names
foreach my $compound_hets (@compound_hets){
        print "$compound_hets\t\n";
}

