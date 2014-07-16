#!/usr/bin/perl
#
#07-16-14
#get_gene_column.pl <annotated_vcf.vcf>
#extracts gene column from vcf with header. In case of no header with gene column labeled Gene or Gene.refGene,
#the script will return NO_HEADER.
#currently cannot handle comments before header
#usage: perl get_gene_column.pl <vcf_file>
#Dalia Ghoneim
#
use strict;
use warnings;
my $file = shift;
my $i;
my $gene_column = "NO_HEADER";
open my ($F), $file or die $!;
my $header_line = <$F>;
close $F;
my @header = split(/\t/, $header_line);
my $header_size = $#header + 1;
for ($i=0;$i<$header_size;$i++){
	if (($header[$i] eq "Gene") || ($header[$i] eq "Gene.refGene")){
		$gene_column = $i;
	}
}
print "$gene_column\n";

