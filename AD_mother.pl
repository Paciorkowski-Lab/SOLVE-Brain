#!/usr/bin/perl
#
#10/01/2013 - allow user to enter proband index, default is still 35
#
#AD_mother.pl usage: AD_mother.pl [options] annotated_vcf.vcf>
#options:
#--PROBAND=<proband_index> . Defaults to 35
#--NUM_AFFECTED=<number_of_affecteds> . Defaults to 1.
#Filters annotated vcf for maternall inherited Autosomal Dominant variants. User can supply the proband index. 
#Default value is 35. Also can handle multiple affecteds. Default NUM_AFFECTED is 1.
#The order of the input vcf is important. Must follow this order: <proband_1> <proband_n> <father> <mother>
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
#filter for maternally inherited AD variants
LINE: while ($_=<$F>){
        my @line = split /\t/;
        if (defined($line[$proband_index]) && (($line[$proband_index] =~ m{0/1})&&($line[$father_index] =~ m{0/0})&&($line[$mother_index] =~ m{0/1}))){
                #handle multiple affected
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
close $F;
