SOLVE-Brain 1.0.4
===========

Brain-specific annotation of next-generation sequencing data. 

Release date 22 October 2015

Authors: Dalia Ghoneim, Francis James, Jimmy Zhang, Jeff Clegg, Alex Paciorkowski

The Paciorkowski Lab

*****
The MIT License (MIT)

Copyright (c) 2013 Paciorkowski Lab

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*****
To use on Linux or MacOSX systems just clone our GitHub repository:

$ git clone https://github.com/Paciorkowski-Lab/SOLVE-Brain.git

That's it.

*****
Installation on Windows

We haven't made SOLVE-Brain Windows compatible yet. You can probably do this through installing Cygwin (http://ww.cygwin.com/), but we haven't tested in this environment yet.

Tutorial:

Start with an Annovar-annotated multisample vcf, as well as a vcf that has not been subject to annotation (optional, see below). The vcf file should be consistent with VCFv4.1 to properly use all functionality. We recommend labeling your trio members the following way: (i.e. proband is first, father is second, mother is third). But this could be different so it is important to know how your data is laid out. 

For recessive pedigree analyses it is important that for each family the columns in the vcf are consistent with the following order: affected(1), [affected(2), affected(3)...affected(n)], father, mother. SOLVE-Brain can only handle vcfs that are in this order. You can read more about this in Tutorial 2 for recessive analysis below.


The Set-Up:
-----------
When running SOLVE-Brain you have two options for letting the program know how your data is laid out.
	OPTION 1: You can provide the software with an unnannoted vcf file, where the program will go and search for your cohort identifier names. It will then ask you for each identifer found, whether the individual is a proband or not in which you respond with a simple (y/n). It will then ask how many affected siblings the proband has in the cohort, followed by a question of whether the proband has any missing parents in the cohort.This file is placed in your output folder and can be used with OPTION 2 for subsequent runs (different pedigree hypothesis).
	OPTION 2: You pre-make a text file that has the name of your cohort identifiers in column one along with the index they correspond to in column two (OPTION 1 handles this for you) as well as the word 'proband' in the third column, if the individual is a proband. Column 4 should contain the number of affected ('1' if proband has no affected siblings). Lastly, Column 5 should contain a string representing any absent parents. This can be 'M', 'F', 'MF', or just a blank string '' if both parents are present (capitalization is not important).

	Demonstration of OPTION 1:
		Is 'Identifier_1' a proband? (y/n)?
		y
		Number of affected siblings? (or just [ENTER] for 0)
		1
		Any absent parents? Enter 'm' for absent mother, 'f' for father or 'mf' for both or [ENTER] for neither.

		Is 'Identifier_2' a proband? (y/n)?
		y
		Number of affected siblings? (or just [ENTER] for 0)

		Any absent parents? Enter 'm' for absent mother, 'f' for father or 'mf' for both or [ENTER] for neither.

		Is 'Identifier_3' a proband? (y/n)?
		y
		Number of affected siblings? (or just [ENTER] for 0)

		Any absent parents? Enter 'm' for absent mother, 'f' for father or 'mf' for both or [ENTER] for neither.
		mf
		Is 'Identifier_n' a proband? (y/n)?
		.
		.
		.
		*The program uses the information provided by the user to know which members of the cohort are probands, while it asks "Is 'Identifier_n' a proband? (y/n)?", it knows based on input that this is a proband. The question is to allow the user to exclude probands, by saying 'n' or even just pressing [ENTER] the user can have SOLVE-Brain exclude 'Identifier_n' from analysis. In both subsequent questions, [ENTER] may be used for the default answer, i.e. '0' sibilings in the cohort, and both parents present in the cohort (a typical trio).
		In the above demonstration, the software has been told that proband1 has one sibling directly following in the VCF as well as both parents, proband2 is a classic trio, and proband3 has no siblings as well as both parents absent (i.e. only data for proband3 is present). In cases such as proband3 it is important to note that many results will come up since referencing parents is not an option. All pedigree hypotheses are available they just carry a slightly different meaning, for instance De Novo will find any '0/1' in the proband but a parent could possibly posses this variant as well.

This software makes use of command line flags or options in order to know exactly what it is the user wants to happen. It is recommended that you look at the usage which can be accessed by running 'sh solve.sh -h' in the command line, however a small summary will be provided here.

To start, the software is looking for a couple required flags in which it cannot run without. The following are flags you must include:

	-P followed by a two letter pedigree hypothesis. (DN, AR, AD, XL, none)
	
	-O followed by the path to your output location.
	
	AT LEAST one of the following:
	
		-S followed by the path to your Annovar annotated snv file.
		
		-I followed by the path to your Annovar annotated indel file.
		
			*Note: it is common to run both the snv and indel files simultanously.
			
		-C followed by the path to your Annovar annotated combined snv/indel file.
		
	ONLY one of the following:
	
		-i followed by the path to your Who is who file described above.
		
		-U followed by the path to your Unannotated vcf file. (type does not matter)
		

The following are optional flags that can be used depending on your data/needs:

	-T 'Training Wheels', this will default enable a few commonly used flags: -X, -v, -R will all be enabled.
	
	-g followed by the index of gene names in your annotated vcf (if not labeled) 
	
	-N followed by the desired name of Who is who file. (only if -U also used)
	
		*Note: if -U is used and -N is not, the Who is who file will be named with the date. 
		
	-d will have the program NOT filter out known SNPs.
	
	-q will have the program NOT filter out varation with GQ scores less than 99.
	
	-k will have the program cross reference found variation with a list of known genes. (provided in a seperate file)
	
	-x will display the outputed 'ALL' gene file. (List of all found genes for cohort)
	
	-X same as '-x' with pauses in between files for clearer visualization.
	
		*NOTE: if verbose mode is activated, verbose files will display after the consolidated gene files.
		
	-v will create 'VERBOSE' files that also contain the raw data related to found variation.
	
	-R will create files similar to verbose, filtering out variants found in other families (unless only in probands) as these are unlikely disease causing.
	
		*NOTE: for variants that are not filtered out, a convenient Analysis section is added after all variants are listed for a gene. (this matches with the available searches on SOLVE-Brain's web interface)



The following are some short tutorials to provide an example of how to use this software in a few common use cases.

Tutorial 1: De novo analysis:
-----------------------------
This first set of examples illustrates the command-line use of SOLVE-Brain to identify potentially interesting variants in a pedigree with hypothesized de novo inheritance. NOTE: While in the following three examples only one annotated file is used (snv or indel) both can be given in the same command producing output for snv's and indel's in a single run.

Example 1: Identify all nonsynonymous snv's in a de novo pedigree, keeping members of dbSNP, excluding snv's where GQ score is less than 99, generating a who is who file:

$ sh solve.sh -d -P DN -U /path/to/your/unannotated.vcf -S /path/to/your/annotated_snv.vcf -O /path/to/your/output/

This will give two output files for each proband, plus two final files:
Identifiers_snv_exons_utr_nosynon_GQ99_DN.vcf (This is a new vcf with your full results.)
Identifiers_snv_exons_utr_nosynon_GQ99_DN_genes.txt (This is a extract of just the gene symbols from your new vcf.)
ALL_snv_exons_utr_nosynon_GQ99_DN_genes.txt (This is a compilation of all gene files sorted by proband identifiers.)
Who_is_who_[date].txt (This is a Who's who file to be used in later runs with '-i' flag.)

Example 2: Identify all nonsynonymous snv's in a de novo pedigree, and exclude members of dbSNP, including snv's with a GQ score less than 99, using an already generated who is who file, and results displayed (no pauses):

$ sh solve.sh -q -P DN -i /path/to/your/whos_who.txt -S /path/to/your/annotated_snv.vcf -O /path/to/your/output/ -x

This will give two output files for each proband, plus one final file:
Identifiers_snv_exons_utr_nosynon_nodbSNP_DN.vcf (This is a new vcf with your full results, this time excluding snv's with membership in dbSNP.)
Identifiers_snv_exons_utr_nosynon_nodbSNP_DN_genes.txt (This is a extract of just the gene symbols from your new vcf.)
ALL_snv_exons_utr_nosynon_nodbSNP_DN_genes.txt (This is a compilation of all gene files sorted by proband identifiers.)

Example 3: Identify all framshift indels in a de novo pedigree, exclude members of dbSNP, excluding indel's with a GQ score less than 99, generating a who is who file, displaying results with pauses, creating a verbose file, creating a rare variant only file (These last three are included in 'Training Wheels'):

$ sh solve.sh -P DN -U /path/to/your/unannotated.vcf -I /path/to/your/annotated_indel.vcf -O /path/to/your/output/ -X -v -R
or
$ sh solve.sh -P DN -U /path/to/your/unannotated.vcf -I /path/to/your/annotated_indel.vcf -O /path/to/your/output/ -T

This will give two output files for each proband, plus three additional files:
Identifiers_indel_exons_utr_no_nonframe_nodbSNP_GQ99_DN.vcf (This is a new vcf with full results, this time excluding indel's in dbSNP and/or with a GQ score less than 99)
Identifiers_indel_exons_utr_no_nonframe_nodbSNP_GQ99_DN_genes.txt (This is a extract of just the gene symbols from your new vcf.)
ALL_indel_exons_utr_no_nonframe_nodbSNP_GQ99_DN_genes.txt (This is a compilation of all gene files sorted by proband identifiers.)
VERBOSE_indel_exons_utr_no_nonframe_nodbSNP_GQ99_DN_genes.txt (This file contains all variants found for each proband as well as relavent vcf data for the variant all in one file)
rare_only_VERBOSE_indel_exons_utr_no_nonframe_nodbSNP_GQ99_DN_genes.txt (This is similar to previous file, with vcf data removed for variants found outside the affected family [i.e. in unrelated parents])
Who_is_who_[date].txt


Tutorial 2: Autosomal recessive analysis:
-----------------------------------------
This set of examples illustrates the command-line use of SOLVE-Brain to identify potentially interesting variants in a pedigree with hypothesized autosomal recessive inheritance. We will show you how to use this tool to analyze both snv's and indels.

Autosomal recessive analysis poses a bit of extra complexity, since one can have any of the following combinations of variants for genotype: 
	1. snvA & snvA (Homozygosity for snv's)
	2. snvA & snvB (Compound heterozygosity for snv's)
	3. snvA & indelA (Compound heterozygosity for snv + indel)
	4. indelA & indelB (Compound heterozygosity for indels)
	5. indelA & indelA (Homozygosity for indels)

	*NOTE: Compound heterozygous cases are only valid if both parents are present in the cohort.

Also, we expect that either allele will be inhertied from either parent. So it helps to have parental sequencing data to evaluate these.

Fortunately, SOLVE-Brain can handle all of these situations. All it takes is knowing how to use the flags at the command-line.

Example 1: Identify all nonsynonymous snv's in an autosomal recessive pedigree, keeping members of dbSNP, excluding snv's with a GQ score less than 99, with already generated who is who file, no results displayed, creating a verbose file:

$ sh solve.sh -d -P AR -i /path/to/your/whos_who.txt -S /path/to/your/annotated_snv.vcf -O /path/to/your/output/ -v

This will give four output files for each proband, plus four additional files:
Identifiers_snv_exons_utr_nosynon_GQ99_HM.vcf (This is a new vcf with recessive variants that are homozygous in the proband and heterozygous in the parents.)
Identifiers_snv_exons_utr_nosynon_GQ99_HM_genes.txt (This is an extract of just the gene symbols from the homozygous variants vcf.)
Identifiers_snv_exons_utr_nosynon_GQ99_CH.vcf (This is a new vcf with recessive variants that are compound heterozygous in the proband, and appropriately heterozygous in the parents.)
Identifiers_snv_exons_utr_nosynon_GQ99_CH_genes.txt (This is an extract of just the gene symbols for compound heterozygous snvs)
ALL_snv_exons_utr_nosynon_GQ99_HM_genes.txt (This is a compilation of all homozygous snv gene symbols, labeled by proband identifier)
ALL_snv_exons_utr_nosynon_GQ99_CH_genes.txt (This is a compilation of all compound heterozygous snv gene symbols, labeled by proband identifier)
VERBOSE_snv_exons_utr_nosynon_GQ99_HM_genes.txt (This file contains all homozygous snv's found for each proband as well as relavent vcf data for the variant all in one file) 
VERBOSE_snv_exons_utr_nosynon_GQ99_CH_genes.txt (This file contains all compound heterozygous snv's found for each proband as well as relavent vcf data for the variant all in one file) 

Example 2: Identify all nonsynonymous snv's and frameshift indels in an autosomal recessive pedigree, including members of dbSNP, including snv's with a GQ score less than 99, generating a who is who file with a provided name, with 'Training Wheels' enabled:
*This is very verbose for Autosomal recessive*

$ sh solve.sh -d -q -P AR -U /path/to/your/unannotated.vcf -S /path/to/your/annotated_snv.vcf -I /path/to/your/annotated_indel.vcf -O /path/to/your/output/ -N Name_of_whos_who_file -T

This will give the following five output *.vcf along with their five corresponding *.txt files for each proband, plus 16 additional files listed:
Identifiers_snv_exons_utr_nosynon_HM.vcf
Identifiers_snv_exons_utr_nosynon_CH.vcf
Identifiers_indel_exons_utr_no_nonframe_HM.vcf
Identifiers_indel_exons_utr_no_nonframe_CH.vcf
Identifiers_snv_exons_utr_nosynon_indels_CH.vcf
ALL_snv_exons_utr_nosynon_HM_genes.txt
ALL_snv_exons_utr_nosynon_CH_genes.txt
ALL_indel_exons_utr_no_nonframe_HM_genes.txt
ALL_indel_exons_utr_no_nonframe_CH_genes.txt
ALL_snv_exons_utr_nosynon_indels_CH_genes.txt
VERBOSE_indel_exons_utr_no_nonframe_CH_genes.txt
VERBOSE_indel_exons_utr_no_nonframe_HM_genes.txt
VERBOSE_snv_exons_utr_nosynon_CH_genes.txt
VERBOSE_snv_exons_utr_nosynon_HM_genes.txt
VERBOSE_snv_exons_utr_nosynon_indels_CH_genes.txt
rare_only_VERBOSE_indel_exons_utr_no_nonframe_CH_genes.txt
rare_only_VERBOSE_indel_exons_utr_no_nonframe_HM_genes.txt
rare_only_VERBOSE_snv_exons_utr_nosynon_CH_genes.txt
rare_only_VERBOSE_snv_exons_utr_nosynon_HM_genes.txt
rare_only_VERBOSE_snv_exons_utr_nosynon_indels_CH_genes.txt
Name_of_whos_who_file.txt

Tutorial 3: X-linked analysis:
------------------------------

Example 1: Identify all nonsynonymous snv's inherited from the mother in an X-linked manner, providing the column that gene names are located in, with an already generated who is who file, using 'Training Wheels':

$ sh solve.sh -g 6 -P XL -i /path/to/your/whos_who.txt -S /path/to/your/annotated_snv.vcf -O /path/to/your/output/ -T

This will output the following two output files for each proband as well as three additional files listed below:
Identifiers_snv_exons_utr_nosynon_nodbSNP_GQ99_XL_genes.txt
Identifiers_snv_exons_utr_nosynon_nodbSNP_GQ99_XL.vcf
ALL_snv_exons_utr_nosynon_nodbSNP_GQ99_XL_genes.txt
VERBOSE_snv_exons_utr_nosynon_nodbSNP_GQ99_XL_genes.txt
rare_only_VERBOSE_snv_exons_utr_nosynon_nodbSNP_GQ99_XL_genes.txt

