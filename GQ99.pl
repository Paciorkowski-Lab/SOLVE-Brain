#!/usr/bin/perl
#
#GQ99.pl
#09/24/2013
#filter out any variants calls in the proband that have a GQ quality score less than 99. User indicates proband index and number of affecteds.
#default proband index is 35, default number of affecteds is 1
#usage: perl <options> GQ99.pl <vcf_file>
#available options:
#       --PROBAND <proband_index>  This is an integer value representing the index position (column) that hold the proband. Remember when counting index number, the first index starts at 0, not 1. Default value is 35.
#       --NUM_AFFECTED <integer> This is an integer that represents the number of affecteds. This assumes that the extra affecteds are all after the first affected, and that the father and mother are listed next in the vcf. Default value is 1.
#Dalia Ghoneim
#
use strict;
use warnings;
use Getopt::Long;

#options
my $NUM_AFFECTED=1;
my $proband_index=35;
my $aff_geno_match;
GetOptions ('NUM_AFFECTED:i'=>\$NUM_AFFECTED, 'PROBAND:i'=>\$proband_index);
my $file = shift;
my $i;

#filter user specified for only high quality calls
open my ($F), $file or die $!;
LINE: while ($_=<$F>){
        my @line = split /\t/;
        if (defined($line[$proband_index])&&($line[$proband_index] =~ m{:99:})){
                #handle multiple affected
                $aff_geno_match=1;
                for($i=1;$i<$NUM_AFFECTED;$i++){
                        if (defined($line[$proband_index+$i]) && $line[$proband_index+$i]=~m{:99:}){
                                $aff_geno_match++;
                        }
                }
                if ($aff_geno_match == $NUM_AFFECTED){
                        print join(qq/\t/, @line);
                }
}
}
close $F;
