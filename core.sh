#!/bin/bash
#
#bash_solve.sh
#12/15/2014
#
#The first part of SOLVE-Brain. This portion is a command-line tool that filters vcfs according to user specifications,
#and reduces the vcfs to only  variants of interest. The tool also checks for known 
#neurodevelopmental variants present in the DBDB database. See Documentation for more detail.
#usage: sh bash_solve.sh [options] -P <pedigree_hypothesis> -i <proband_index> -I <INDEL_vcf_file> -S <SNV_vcf_file>
#
#Dalia Ghoneim
#Jeff Clegg

#set some default values
pedigree_supplied=0
snv_supplied=0
indel_supplied=0
combined_vcf_supplied=0
proband_index=0
remove_synon=1
remove_nonframe=1
remove_dbSNPs=1
gq99_filter=1
pedigree=0
known_gene_list=0
snv_vcf=0
indel_vcf=0
combined_vcf=0
index_supplied=0
snv_vcf_2=0
snv_vcf_3=0
indel_vcf_2=0
indel_vcf_3=0
combined_vcf_2=0
combined_vcf_3=0
snv_2=0
indel_2=0
combined_2=0
snv_basename_2=0
indel_basename_2=0
combined_basename_2=0
output_indicated=0
ouput_base=0
num_affected=1
retain_int_files=0
gene_index_supplied=0
gene_index=0

usage="usage:\nsh run_solve.sh [required_arguments] [optional_arguments]\n\nrequired:\n-P <pedigree> . Indicates the pedigree hypothesis. The following are valid options: AD, AR, DN, XL\n\tAD  = Autosomal Dominant inherited from either the father or the mother.\n\tAR  = Autosomal Recessive. Will filter for recessive SNVs and INDELs (if supplied by user)\n\tDN  = De novo. Will filter for De novo variants found only in the proband and not in the parents.\n\tXL  = X-linked. Will filter for x linked variants.\n\tnone = In the case that a user would like to simply filter vcfs to remove members of dbSNP, low quality, synonymous, or nonframeshift variants (or any combination). If this option is selected, -r is forced to be set to true.\n-i <proband index>. Integer representing the index (column) that holds the proband in supplied vcf. In the case of multiple affecteds, the proband index would be the column of the first proband listed in the vcf. Remember: when counting the index, start at 0 not 1!\n\nat least ONE of the following required:\n-S <snv_file> The input SNV vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.\n-I <indel_file> The annotated indel vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.\n-C <combined_vcf_file> The annotated combined vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.\n\noptional:\n-O </path/to/output/output_prefix>. This allows user to specify the path and prefix of output files. If this is not specified, output prefix will be the name of input files.\n-a <number_of_affecteds> This is an integer representing the number of affecteds. The affecteds must be in the rows directly after the proband. This value defaults to 1.\n-k <file> . User-suppled list of known pathogenic genes. Can be dbdb gene list or user generated list.\n-s keep synonymous SNVs. The default is to remove synonymous SNVs\n-n keep nonframeshift INDELs. The default is to remove nonframeshift indels.\n-q no quality filter. Keep all variants regardless of GQ score. Default is to remove all variants in the proband with GQ score lower than 99.\n-d Keep variants in dbSNP. The default is to remove these variants.\n-r remove intermediate files.\n-g <gene_name_index> The column index of gene name. This value must be set if input vcf does not have header with gene column labeled Gene or Gene.refGene\n"



#process command line arguments
#required:
#-P <pedigree> . Indicates the pedigree hypothesis. The following are valid options:AD, AR, DN, XL.
#       AD  = Autosomal Dominant. Will filter for variants inherited from the father and the mother and output into two separate files.
#       AR  = Autosomal Recessive. Will filter for recessive SNVs and INDELs (if supplied by user). Will filter for compound heterosyzous SNVs and also in INDEL file if supplied by the user.
#       DN  = De novo. Will filter for De novo variants found only in the proband and not in the parents.
#       XL  = X-linked. Will filter for X-linked variants (for male probands).
#	none = In the case that a user would like to simply filter vcfs to remove members of dbSNP, low quality, synonymous, or nonframeshift variants (or any combination). If this option is selected, -r is forced to be set to true.
#-i <proband index>. Integer representing the index (column) that holds the proband in supplied vcf. default value is 35; however, this value can vary depending on how the vcf has been annotated. Remeber: when counting the index, start at 0 not 1! 
#
#at least ONE of the following required:
#-S <snv_file> The input SNV vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.
#-I <indel_file> The input INDEL vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.
#-C <combined_vcf> The input vcf containing both SNVs and INDELs. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.
#
#
#optional:
#-O </path/to/output/output_prefix>. This option allows the user to specify the location and prefix for output files. If this option is not used, output files will have the same path and prefix as their corresponding input vcfs.
#-a <number_of_affecteds>. This is an integer representing the number of affecteds. The default value is 1. Multiple affecteds must be in the columns directly following the proband.
#-k <file list of knwon genes>. User supplied file containing list of known genes. This can be dbdb gene list or a user generated list. If user does not supply a file. Solve^Brain will still filter vcfs; however, list will not be queried for known genes.
#-s keep synonymous SNVs. The default is to remove synonymous SNVs
#-n keep nonframeshift INDELs. The default is to remove nonframeshift INDELs
#-q quality filter. Keep all variants regardless of GQ score. Default is to remove variants in proband with GQ score < 99.
#-d keep variants in dbSNP. The default is to remove variants found in dbSNP
#-r retain intermediate files.
#-g <gene_name_index> column index in annotated vcf with name of genes. Setting this value is required if input vcf does not contain header with gene column labeled Gene or Gene.refGene.

echo -e "\nRunning SOLVE-Brain"
while getopts ":hsnqdra:g:P:i:k:I:S:O:C:A:" opt; do
case $opt in
	h)	
		printf "$usage"
		exit 1
		;;
	s)
                echo "-s you have elected to keep synonymous SNVs"
                remove_synon=0
                ;;
        n)
                echo "-n you have elected to keep nonframeshift INDELs"
                remove_nonframe=0
                ;;
        q)
                echo "-q you have elected to keep variants with GQ score less than 99"
                gq99_filter=0
                ;;
        d)
                echo "-d you have elected to keep known SNPs"
                remove_dbSNPs=0
                ;;
        P)
                echo "-P you have elected to filter by the following pedigree hypothesis: $OPTARG"
                pedigree=$OPTARG
                pedigree_supplied=1
                ;;
        i)
                echo "-i proband index is: $OPTARG"
                index_supplied=1
                proband_index=$OPTARG
                ;;
		
        a)
                echo "-a number of affecteds is: $OPTARG"
                num_affected=$OPTARG
                ;;

        k)
                echo "-k you have elected to search for known genes contained in: $OPTARG"
                known_gene_list=$OPTARG
                ;;

        I)
                echo "-I indel vcf is: $OPTARG"
                indel_vcf=$OPTARG
                indel_supplied=1
                ;;
        S)
                echo "-S snv vcf is: $OPTARG"
                snv_vcf=$OPTARG
                snv_supplied=1
                ;;
	C)
		echo "-C combined vcf (indels and SNVs) is: $OPTARG"
		combined_vcf=$OPTARG
		combined_vcf_supplied=1
		;;
        O)
                echo "-O output saved in: $OPTARG"
                output_base=$OPTARG
                output_indicated=1
                ;;

	g)
		echo "-g gene column in index position: $OPTARG"
		gene_index=$OPTARG
		gene_index_supplied=1
		;;
	r)
		echo "-r intermediate files will be retained"
		retain_int_files=1
		;;
        A)
                echo "-A absent parents: $OPTARG"
                absent=$OPTARG
                ;;

        \?)
                printf "Error: Invalid option: -$OPTARG. $usage"
                exit 1
                ;;
        :)
                printf "Error: Option -$OPTARG requires an argument."
                exit 1
                ;;
esac
done
shift $((OPTIND-1))

#check that pedigree was provided by the user and that it is a valid pedigree value. If not, exit.
if [[ $pedigree_supplied = 0 ]]; then
        printf "Error: Please supply required argument -P <pedigree_hypothesis>. Valid options are: AD, AR, DN, XL, none\n"
        exit 1
fi
if [[ "$pedigree" != "AD" && "$pedigree" != "AR" && "$pedigree" != "DN" && "$pedigree" != "XL" && "$pedigree" != "none" ]]; then
        printf "Error: Pedigree hypothesis supplied is invalid. Valid pedigrees are: AD, AR, DN, XL, none.\n"
        exit 1
fi

#check that proband index is provided
if [[ $index_supplied = 0 ]]; then
        printf "Error: Proband index -i <integer> was not supplied.\n"
        exit 1
fi

#check that atleast one vcf was supplied
if [[ $snv_supplied = 0 && $indel_supplied = 0 && $combined_vcf_supplied = 0 ]]; then
        printf "Error: Please supply at least one annotated vcf file.\n"
        exit 1
fi

#if user selected -P none and -r, alert user that -r will be forced to false
if [[ "$pedigree" = "none" && $retain_int_files = 0 ]]; then
	printf "Pedigree -P set to \"none\" requires user to keep intermediate files. -r will be set to true.\n"
	retain_int_files=1
fi

path_to=${0%core.sh}
#search for gene_column index
if [[ $gene_index_supplied = 0 ]]; then
	if [[ $combined_vcf_supplied = 1 ]]; then vcf=$combined_vcf
	elif [[ $snv_supplied = 1 ]]; then vcf=$snv_vcf
	elif [[ $indel_supplied = 1 ]]; then vcf=$indel_vcf; fi
	gene_index=$( perl "$path_to"get_gene_column.pl $vcf )
	if [[ $gene_index = "NO_HEADER" ]]; then
		printf "Error: Could not detect header in supplied vcf. Please rerun using -g to indicate the gene symbol column index.\n"
		exit 1
	fi
fi
#this represents the vcf that is actively being used in each specific step of the filtration process
active_snv_vcf=$snv_vcf
active_indel_vcf=$indel_vcf
active_combined_vcf=$combined_vcf
snv_basename=${active_snv_vcf%.*}
indel_basename=${active_indel_vcf%.*}
combined_basename=${active_combined_vcf%.*}
original_snv_base=$snv_basename
original_indel_base=$indel_basename
original_combined_base=$combined_basename
#set indices
father_index=$(($proband_index + 1))
mother_index=$(($proband_index + 2))
#arrays to store intermediate file names for deletion later
snv_added_suffixes=()
indel_added_suffixes=()
combined_added_suffixes=()

#where is ouput going? if no output path was indicated, output will be the same path base as input
if [[ $output_indicated = 1 ]]; then
	combined_basename=$output_base
        snv_basename="$output_base"_snv
        indel_basename="$output_base"_indel
fi

printf "filtering vcfs...\n"
#filter for exonic and UTR regions only. SOLVE currently supports only whole exome sequence data
 	if [[ $indel_supplied = 1 ]]; then
                less $active_indel_vcf | grep -e exonic -e UTR > "$indel_basename"_exons_utr.vcf
                active_indel_vcf="$indel_basename"_exons_utr.vcf
                indel_basename=${active_indel_vcf%.*}
                indel_added_suffixes=("${indel_added_suffixes[@]}" _exons_utr)

        fi
        if [[ $snv_supplied = 1 ]]; then
                less $active_snv_vcf | grep -e exonic -e UTR > "$snv_basename"_exons_utr.vcf
                active_snv_vcf="$snv_basename"_exons_utr.vcf
                snv_basename=${active_snv_vcf%.*}	
		snv_added_suffixes=("${snv_added_suffixes[@]}" _exons_utr)
        fi
        if [[ $combined_supplied = 1 ]]; then
                less $active_combined_vcf | grep -e exonic -e UTR > "$combined_basename"_exons_utr.vcf
		active_combined_vcf="$combined_basename"_exons_utr.vcf
		combined_basename=${active_combined_vcf%.*}
		combined_added_suffixes=("${combined_added_suffixes[@]}" _exons_utr)
        fi



#remove synonymous SNVs unless otherwise indicated
if [[ $remove_synon = 1 ]]; then
	if [[ $snv_supplied = 1 ]]; then
        	less $active_snv_vcf | grep -v -w synonymous > "$snv_basename"_nosynon.vcf
        	active_snv_vcf="$snv_basename"_nosynon.vcf
        	snv_basename=${active_snv_vcf%.*}
		snv_added_suffixes=("${snv_added_suffixes[@]}" _nosynon)
	fi
	if [[ $combined_vcf_supplied = 1 ]]; then
		less $active_combined_vcf | grep -v -w synonymous > "$combined_basename"_nosynon.vcf
		active_combined_vcf="$combined_basename"_nosynon.vcf
		combined_basename=${active_combined_vcf%.*}
		combined_added_suffixes=("${combined_added_suffixes[@]}" _nosynon)
	fi
fi

#remove nonframeshift INDELs unless otherwise indicated
if [[ $remove_nonframe = 1 ]]; then
	if [[ $indel_supplied = 1 ]]; then
		less $active_indel_vcf | grep -v -w nonframeshift > "$indel_basename"_no_nonframe.vcf
        	active_indel_vcf="$indel_basename"_no_nonframe.vcf
        	indel_basename=${active_indel_vcf%.*}
		indel_added_suffixes=("${indel_added_suffixes[@]}" _no_nonframe)

	fi
	if [[ $combined_vcf_supplied = 1 ]]; then
		less $active_combined_vcf | grep -v -w nonframeshift > "$combined_basename"_no_nonframe.vcf
        	active_combined_vcf="$combined_basename"_no_nonframe.vcf
        	combined_basename=${active_combined_vcf%.*}
		combined_added_suffixes=("${combined_added_suffixes[@]}" _no_nonframe)
	fi
fi
#remove known SNPs unless otherwise indicated
if [[ $remove_dbSNPs = 1 ]]; then

        if [[ $snv_supplied = 1 ]]; then
                grep -v rs[0-9] $active_snv_vcf > "$snv_basename"_nodbSNP.vcf
                active_snv_vcf="$snv_basename"_nodbSNP.vcf
                snv_basename=${active_snv_vcf%.*}
		snv_added_suffixes=("${snv_added_suffixes[@]}" _nodbSNP)

        fi
        if [[ $indel_supplied = 1 ]]; then
                grep -v rs[0-9] $active_indel_vcf > "$indel_basename"_nodbSNP.vcf
                active_indel_vcf="$indel_basename"_nodbSNP.vcf
                indel_basename=${active_indel_vcf%.*}
		indel_added_suffixes=("${indel_added_suffixes[@]}" _nodbSNP)

        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                grep -v rs[0-9] $active_combined_vcf > "$combined_basename"_nodbSNP.vcf
                active_combined_vcf="$combined_basename"_nodbSNP.vcf
                combined_basename=${active_combined_vcf%.*}
		combined_added_suffixes=("${combined_added_suffixes[@]}" _nodbSNP)
        fi

fi

#remove variants with GQ score < 99 unless user indicates keeping them
if [[ $gq99_filter = 1 ]]; then

        if [[ $snv_supplied = 1 ]]; then
                perl "$path_to"GQ99.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_GQ99.vcf
                active_snv_vcf="$snv_basename"_GQ99.vcf
                snv_basename=${active_snv_vcf%.*}
		snv_added_suffixes=("${snv_added_suffixes[@]}" _GQ99)
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl "$path_to"GQ99.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_GQ99.vcf
                active_indel_vcf="$indel_basename"_GQ99.vcf
                indel_basename=${active_indel_vcf%.*}
		indel_added_suffixes=("${indel_added_suffixes[@]}" _GQ99)

        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                perl "$path_to"GQ99.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_GQ99.vcf
                active_combined_vcf="$combined_basename"_GQ99.vcf
                combined_basename=${active_combined_vcf%.*}
		combined_added_suffixes=("${combined_added_suffixes[@]}" _GQ99)
        fi

fi

intermed_snv_files=$snv_basename
intermed_indel_files=$indel_basename
intermed_combined_files=$combined_basename

#DO NOT NEED
#REPLACE IMMEDIATELY
	python vcf.py --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --SNV=$active_snv_vcf --INDEL=$active_indel_vcf --PEDIGREE=$pedigree --OUTPUT=$output_base --ABSENT=$absent
if [ "$pedigree" == "AR" ]; then
	active_indel_vcf=${indel_basename}_HM.vcf
	active_snv_vcf=${snv_basename}_HM.vcf
	indel_vcf_2=${indel_basename}_CH.vcf
	snv_vcf_2=${snv_basename}_CH.vcf
	snv_2=1
	indel_2=1
	snv_basename=${active_snv_vcf%.*}
	snv_basename_2=${snv_vcf_2%.*}
	indel_basename=${active_indel_vcf%.*}
	indel_basename_2=${indel_vcf_2%.*}
else
	active_indel_vcf=${indel_basename}_${pedigree}.vcf
	active_snv_vcf=${snv_basename}_${pedigree}.vcf
	snv_basename=${active_snv_vcf%.*}
	indel_basename=${active_indel_vcf%.*}
fi      
				#indel_vcf_2=${output_base}_indels_CH.vcf
        #snv_vcf_2=${output_base}_snv_CH.vcf


#filter by pedigree
# if [ "$pedigree" == "AD" ]; then

#         if [[ $snv_supplied = 1 ]]; then
#                 perl "$path_to"AD_father.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_AD_father.vcf
#                 perl "$path_to"AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_AD_mother.vcf
#                 snv_2=1
#                 active_snv_vcf="$snv_basename"_AD_father.vcf
#                 snv_vcf_2="$snv_basename"_AD_mother.vcf
#                 snv_basename=${active_snv_vcf%.*}
#                 snv_basename_2=${snv_vcf_2%.*}
#         fi
#         if [[ $indel_supplied = 1 ]]; then
#                 perl "$path_to"AD_father.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_AD_father.vcf
#                 perl "$path_to"AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_AD_mother.vcf
#                 indel_2=1
#                 active_indel_vcf="$indel_basename"_AD_father.vcf
#                 indel_vcf_2="$indel_basename"_AD_mother.vcf
#                 indel_basename=${active_indel_vcf%.*}
#                 indel_basename_2=${indel_vcf_2%.*}

#         fi
#         if [[ $combined_vcf_supplied = 1 ]]; then
#                 perl "$path_to"AD_father.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_AD_father.vcf
#                 perl "$path_to"AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_AD_mother.vcf
#                 combined_2=1
#                 active_combined_vcf="$combined_basename"_AD_father.vcf
#                 combined_vcf_2="$combined_basename"_AD_mother.vcf
#                 combined_basename=${active_combined_vcf%.*}
#                 combined_basename_2=${combined_vcf_2%.*}

#         fi

# elif [ "$pedigree" == "AR" ]; then

         #SNV+INDEL compound hets
#         if [[ $snv_supplied = 1 && $indel_supplied = 1 ]]; then
#                 perl "$path_to"comp_het_indels.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --GENE_INDEX=$gene_index $active_snv_vcf $active_indel_vcf > "$snv_basename"_indels_CH_genes.txt
#                 active_snv_indel_list="$snv_basename"_indels_CH_genes.txt
#                 perl "$path_to"print_2_vcf.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --GENE_INDEX=$gene_index "$snv_basename"_indels_CH_genes.txt $active_snv_vcf > "$snv_basename"_indels_CH.vcf
#                 perl "$path_to"print_2_vcf.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --GENE_INDEX=$gene_index "$snv_basename"_indels_CH_genes.txt $active_indel_vcf >> "$snv_basename"_indels_CH.vcf

#                 if [[ $known_gene_list != 0 ]]; then
#                 perl "$path_to"shared_genes.pl $known_gene_list $active_snv_indel_list > "$snv_basename"_indels_CH_known_genes.txt
#                 fi
#         fi

         #SNV + SNV compound hets and AR
#         if [[ $snv_supplied = 1 ]]; then
#                 perl "$path_to"multi_hits.pl --GENE_INDEX=$gene_index $active_snv_vcf > "$snv_basename"_multihits.vcf
#                 perl "$path_to"comp_het_proband.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --GENE_INDEX=$gene_index "$snv_basename"_multihits.vcf > "$snv_basename"_CH.vcf
#                 perl "$path_to"AR.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_HM.vcf
#                 snv_2=1
#                 active_snv_vcf="$snv_basename"_CH.vcf
#                 snv_vcf_2="$snv_basename"_HM.vcf
# 		rm "$snv_basename"_multihits.vcf
#                 snv_basename=${active_snv_vcf%.*}
#                 snv_basename_2=${snv_vcf_2%.*}

#         fi

#         #INDEL + INDEL compound hets and AR
#         if [[ $indel_supplied = 1 ]]; then
#                 perl "$path_to"multi_hits.pl --GENE_INDEX=$gene_index $active_indel_vcf > "$indel_basename"_multihits.vcf
#                 perl "$path_to"comp_het_proband.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --GENE_INDEX=$gene_index "$indel_basename"_multihits.vcf > "$indel_basename"_CH.vcf
#                 perl "$path_to"AR.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_HM.vcf
#                 indel_2=1
#                 active_indel_vcf="$indel_basename"_CH.vcf
#                 indel_vcf_2="$indel_basename"_HM.vcf
# 		rm "$indel_basename"_multihits.vcf
#                 indel_basename=${active_indel_vcf%.*}
#                 indel_basename_2=${indel_vcf_2%.*}

#         fi
# 	#Combined vcf compound hets and AR
#         if [[ $combined_vcf_supplied = 1 ]]; then
#                 perl "$path_to"multi_hits.pl --GENE_INDEX=$gene_index $active_combined_vcf > "$combined_basename"_multihits.vcf
#                 perl "$path_to"comp_het_proband.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --GENE_INDEX=$gene_index "$combined_basename"_multihits.vcf > "$combined_basename"_CH.vcf
#                 perl "$path_to"AR.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_HM.vcf
#                 combined_2=1
#                 active_combined_vcf="$combined_basename"_CH.vcf
#                 combined_vcf_2="$combined_basename"_HM.vcf
# 		rm "$combined_basename"_multihits.vcf
#                 combined_basename=${active_combined_vcf%.*}
#                 combined_basename_2=${combined_vcf_2%.*}

#         fi

# elif [ "$pedigree" == "DN" ]; then

#         if [[ $snv_supplied = 1 ]]; then
#                 perl "$path_to"DN.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_DN.vcf
#                 active_snv_vcf="$snv_basename"_DN.vcf
#                 snv_basename=${active_snv_vcf%.*}
#         fi
#         if [[ $indel_supplied = 1 ]]; then
#                 perl "$path_to"DN.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_DN.vcf
#                 active_indel_vcf="$indel_basename"_DN.vcf
#                 indel_basename=${active_indel_vcf%.*}
#         fi
# 	if [[ $combined_vcf_supplied = 1 ]]; then
#                 perl "$path_to"DN.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_DN.vcf
#                 active_combined_vcf="$combined_basename"_DN.vcf
#                 combined_basename=${active_combined_vcf%.*}
#         fi


# elif [ "$pedigree" == "XL" ]; then

#         if [[ $snv_supplied = 1 ]]; then
#                 perl "$path_to"AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf | grep -w X > "$snv_basename"_XL.vcf
#                 active_snv_vcf="$snv_basename"_XL.vcf
#                 snv_basename=${active_snv_vcf%.*}
#         fi
#         if [[ $indel_supplied = 1 ]]; then
#                 perl "$path_to"AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf | grep -w X > "$indel_basename"_XL.vcf
#                 active_indel_vcf="$indel_basename"_XL.vcf
#                 indel_basename=${active_indel_vcf%.*}
#         fi
# 	if [[ $combined_vcf_supplied = 1 ]]; then
#                 perl "$path_to"AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf | grep -w X > "$combined_basename"_XL.vcf
#                 active_combined_vcf="$combined_basename"_XL.vcf
#                 combined_basename=${active_combined_vcf%.*}
#         fi

# fi

#run solve part1 to extract gene names
if [[ $snv_supplied = 1 && "$pedigree" != "none" ]]; then
        perl "$path_to"get_genes.pl --GENE_INDEX=$gene_index $active_snv_vcf | uniq | grep -v -w Gene > "$snv_basename"_genes.txt
        if [[ $snv_2 = 1 ]]; then
        perl "$path_to"get_genes.pl --GENE_INDEX=$gene_index $snv_vcf_2 | uniq | grep -v -w Gene > "$snv_basename_2"_genes.txt
        fi

fi
if [[ $indel_supplied = 1 && "$pedigree" != "none" ]]; then
        perl "$path_to"get_genes.pl --GENE_INDEX=$gene_index $active_indel_vcf | uniq | grep -v -w Gene > "$indel_basename"_genes.txt
        if [[ $indel_2 = 1 ]]; then
                perl "$path_to"get_genes.pl --GENE_INDEX=$gene_index $indel_vcf_2 | uniq | grep -v -w Gene > "$indel_basename_2"_genes.txt
        fi

fi
if [[ $combined_vcf_supplied = 1 && "$pedigree" != "none" ]]; then
        perl "$path_to"get_genes.pl --GENE_INDEX=$gene_index $active_combined_vcf | uniq | grep -v -w Gene > "$combined_basename"_genes.txt
        if [[ $combined_2 = 1 ]]; then
                perl "$path_to"get_genes.pl --GENE_INDEX=$gene_index $combined_vcf_2 | uniq | grep -v -w Gene > "$combined_basename_2"_genes.txt
        fi

fi

#compare to known genes
if [[ $known_gene_list != 0 && "pedigree" != "none" ]]; then
        if [[ $snv_supplied = 1 ]]; then
                perl "$path_to"shared_genes.pl $known_gene_list "$snv_basename"_genes.txt | uniq > "$snv_basename"_known_genes.txt

                if [[ $snv_2 = 1 ]]; then
                        perl "$path_to"shared_genes.pl $known_gene_list "$snv_basename_2"_genes.txt | uniq > "$snv_basename_2"_known_genes.txt

                fi
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl "$path_to"shared_genes.pl $known_gene_list "$indel_basename"_genes.txt | uniq > "$indel_basename"_known_genes.txt
                if [[ $indel_2 = 1 ]]; then
                        perl "$path_to"shared_genes.pl $known_gene_list "$indel_basename_2"_genes.txt | uniq > "$indel_basename_2"_known_genes.txt

                fi
        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                perl "$path_to"shared_genes.pl $known_gene_list "$combined_basename"_genes.txt | uniq > "$combined_basename"_known_genes.txt
                if [[ $combined_2 = 1 ]]; then
                        perl "$path_to"shared_genes.pl $known_gene_list "$combined_basename_2"_genes.txt | uniq > "$combined_basename_2"_known_genes.txt

                fi
        fi


fi

#remove intermediate files
if [[ $retain_int_files = 0 ]]; then
printf "removing intermediate files....\n"
suffixes=""
for i in "${!snv_added_suffixes[@]}"; do
        suffixes=${suffixes}${snv_added_suffixes[$i]}
        rm -f "$output_base"_snv"$suffixes.vcf"
printf "\t""$output_base"_snv"$suffixes.vcf""-->removed\n"
done
suffixes=""
for i in "${!indel_added_suffixes[@]}"; do
        suffixes=${suffixes}${indel_added_suffixes[$i]}
        rm -f "$output_base"_indel"$suffixes.vcf"
printf "\t""$output_base"_indel"$suffixes.vcf""-->removed\n"
done
suffixes=""
for i in "${!combined_added_suffixes[@]}"; do
        suffixes=${suffixes}${combined_added_suffixes[$i]}
        rm -f "$output_base$suffixes.vcf"
printf "\t""$output_base$suffixes.vcf""-->removed\n"
done
fi

printf "Done!\n"
