#!/usr/bin/perl
#
#AR.pl
#10/25/2013
#
#AR.pl <annotated_vcf.vcf>
#filters annotated vcf for homozygous autosomal recessive variants.
#usage: perl AR.pl [options] <vcf_file>
#options:       --PROBAND=<proband_index>. Defaults to 35
#               --NUM_AFFECTED=<number_of_affecteds>. Defaults to 1.
#Dalia Ghoneim
#
use strict;
use warnings;
use Getopt::Long;
my $NUM_AFFECTED=1;
my $proband_index=35;
my $aff_geno_match;
GetOptions ('NUM_AFFECTED:i'=>\$NUM_AFFECTED, 'PROBAND:i'=>\$proband_index);
my $file = shift;
my $i;

my $father_index=$proband_index+$NUM_AFFECTED;
my $mother_index=$proband_index+1+$NUM_AFFECTED;
open my ($F), $file or die $!;
#filter for AR homozygous variants
LINE: while ($_=<$F>){
        my @line = split /\t/;
        if (defined($line[$proband_index])&&(($line[$proband_index] =~ m{1/1})&&($line[$father_index] =~ m{0/1})&&($line[$mother_index] =~ m{0/1}))){
                #handle multiple affecteds
                $aff_geno_match=1;
                for($i=1;$i<$NUM_AFFECTED;$i++){
                        if ($line[$proband_index+$i]=~m{1/1}){
                                $aff_geno_match++;
                        }
                }
                if ($aff_geno_match == $NUM_AFFECTED){
                        print join(qq/\t/, @line);
                }
}
}
close $F;
