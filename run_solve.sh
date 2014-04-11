#!/bin/bash
#
#bash_solve.sh
#11/8/2013
#
#The first part of SOLVE-Brain. This portion is a command-line tool that filters vcfs according to user specifications,
#and reduces the vcfs to only  variants of interest. The tool also checks for known 
#neurodevelopmental variants present in the DBDB database. See Documentation for more detail.
#usage: sh bash_solve.sh [options] -P <pedigree_hypothesis> -i <proband_index> -I <INDEL_vcf_file> -S <SNV_vcf_file>
#
#Dalia Ghoneim

#set some default values
pedigree_supplied=0
snv_supplied=0
indel_supplied=0
combined_vcf_supplied=0
proband_index=0
remove_synon=1
remove_nonframe=1
remove_dbSNPs=1
gq99_filter=0
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

usage="usage:\nsh run_solve.sh [required_arguments] [optional_arguments]\n\nrequired:\n-P <pedigree> . Indicates the pedigree hypothesis. The following are valid options: AD, AR, DN, XL\n\tAD  = Autosomal Dominant inherited from either the father or the mother.\n\tAR  = Autosomal Recessive. Will filter for recessive SNVs and INDELs (if supplied by user)\n\tDN  = De novo. Will filter for De novo variants found only in the proband and not in the parents.\n\tXL  = X-linked. Will filter for x linked variants.\n-i <proband index>. Integer representing the index (column) that holds the proband in supplied vcf. In the case of multiple affecteds, the proband index would be the column of the first proband listed in the vcf. Remember: when counting the index, start at 0 not 1!\n\nat least ONE of the following required:\n-S <snv_file> The input SNV vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.\n-I <indel_file> The annotated indel vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.\n-C <combined_vcf_file> The annotated combined vcf file. Must be annotated with gene name in column index [1] and in the following order: proband,[proband2, proband3,...probandn,] father, mother.\n\noptional:\n-O </path/to/output/output_prefix>. This allows user to specify the path and prefix of output files. If this is not specified, output prefix will be the name of input files.\n-a <number_of_affecteds> This is an integer representing the number of affecteds. The affecteds must be in the rows directly after the proband. This value defaults to 1.\n-k <file> . User-suppled list of known pathogenic genes. Can be dbdb gene list or user generated list.\n-s keep synonymous SNVs. The default is to remove synonymous SNVs\n-n keep nonframeshift INDELs. The default is to remove nonframeshift indels.\n-q quality filter. Keep only high quality reads. Removes all variants in the proband that had a GQ score lower than 99.\n-d Keep variants in dbSNP. The default is to remove these variants.\n"


#process command line arguments
#required:
#-P <pedigree> . Indicates the pedigree hypothesis. The following are valid options:AD, AR, DN, XL.
#       AD  = Autosomal Dominant. Will filter for variants inherited from the father and the mother and output into two separate files.
#       AR  = Autosomal Recessive. Will filter for recessive SNVs and INDELs (if supplied by user). Will filter for compound heterosyzous SNVs and also in INDEL file if supplied by the user.
#       DN  = De novo. Will filter for De novo variants found only in the proband and not in the parents.
#       XL  = X-linked. Will filter for X-linked variants (for male probands).
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
#-q quality filter. Remove all variants in the proband that had a GQ score lower than 99.
#-d keep variants in dbSNP. The default is to remove variants found in dbSNP

echo "Running SOLVE-Brain"
while getopts ":hsnqda:P:i:k:I:S:O:C:" opt; do
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
                echo "-q you have elected to remove variants with GQ score less than 99"
                gq99_filter=1
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
        printf "Error: You did not supply required argument -P <pedigree>. Please provide your pedigree hypothesis.\n"
        exit 1
fi
if [[ "$pedigree" != "AD" && "$pedigree" != "AR" && "$pedigree" != "DN" && "$pedigree" != "XL" ]]; then
        printf "Error: Pedigree hypothesis supplied is invalid. Valid pedigrees are: AD, AR, DN, XL.\n"
        exit 1
fi

#check that proband index is provided
if [[ $index_supplied = 0 ]]; then
        printf "Error: Proband index was not supplied.\n"
        exit 1
fi

#check that atleast one vcf was supplied
if [[ $snv_supplied = 0 && $indel_supplied = 0 && $combined_vcf_supplied = 0 ]]; then
        printf "Error: Please supply at least one annotated vcf file.\n"
        exit 1
fi

#this represents the vcf that is actively being used in each specific step of the filtration process
active_snv_vcf=$snv_vcf
active_indel_vcf=$indel_vcf
active_combined_vcf=$combined_vcf
snv_basename=${active_snv_vcf%.*}
indel_basename=${active_indel_vcf%.*}
combined_basename=${active_combined_vcf%.*}

#set indices
father_index=$(($proband_index + 1))
mother_index=$(($proband_index + 2))

#where is ouput going? if no output path was indicated, output will be the same path base as input
if [[ $output_indicated = 1 ]]; then
	combined_basename=$output_base
        snv_basename="$output_base"_snv
        indel_basename="$output_base"_indel
fi

#remove synonymous SNVs unless otherwise indicated
if [[ $remove_synon = 1 ]]; then
	if [[ $snv_supplied = 1 ]]; then
        	less $active_snv_vcf | grep -v -w synonymous > "$snv_basename"_nosynon.vcf
        	active_snv_vcf="$snv_basename"_nosynon.vcf
        	snv_basename=${active_snv_vcf%.*}
	fi
	if [[ $combined_vcf_supplied = 1 ]]; then
		less $active_combined_vcf | grep -v -w synonymous > "$combined_basename"_nosynon.vcf
		active_combined_vcf="$combined_basename"_nosynon.vcf
		combined_basename=${active_combined_vcf%.*}
	fi
fi

#remove nonframeshift INDELs unless otherwise indicated
if [[ $remove_nonframe = 1 ]]; then
	if [[ $indel_supplied = 1 ]]; then
		less $active_indel_vcf | grep -v -w nonframeshift > "$indel_basename"_no_nonframe.vcf
        	active_indel_vcf="$indel_basename"_no_nonframe.vcf
        	indel_basename=${active_indel_vcf%.*}
	fi
	if [[ $combined_vcf_supplied = 1 ]]; then
		less $active_combined_vcf | grep -v -w nonframeshift > "$combined_basename"_no_nonframe.vcf
        	active_combined_vcf="$combined_basename"_no_nonframe.vcf
        	combined_basename=${active_combined_vcf%.*}
	fi
fi
#remove known SNPs unless otherwise indicated
if [[ $remove_dbSNPs = 1 ]]; then

        if [[ $snv_supplied = 1 ]]; then
                less $active_snv_vcf | grep -v rs > "$snv_basename"_nodbSNP.vcf
                active_snv_vcf="$snv_basename"_nodbSNP.vcf
                snv_basename=${active_snv_vcf%.*}
        fi
        if [[ $indel_supplied = 1 ]]; then
                less $active_indel_vcf | grep -v rs > "$indel_basename"_nodbSNP.vcf
                active_indel_vcf="$indel_basename"_nodbSNP.vcf
                indel_basename=${active_indel_vcf%.*}
        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                less $active_combined_vcf | grep -v rs > "$combined_basename"_nodbSNP.vcf
                active_combined_vcf="$combined_basename"_nodbSNP.vcf
                combined_basename=${active_combined_vcf%.*}
        fi

fi

#remove variants with GQ score < 99 if indicated by user
if [[ $gq99_filter = 1 ]]; then

        if [[ $snv_supplied = 1 ]]; then
                perl GQ99.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_GQ99.vcf
                active_snv_vcf="$snv_basename"_GQ99.vcf
                snv_basename=${active_snv_vcf%.*}
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl GQ99.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_GQ99.vcf
                active_indel_vcf="$indel_basename"_GQ99.vcf
                indel_basename=${active_indel_vcf%.*}
        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                perl GQ99.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_GQ99.vcf
                active_combined_vcf="$combined_basename"_GQ99.vcf
                combined_basename=${active_combined_vcf%.*}
        fi

fi

#filter by pedigree
if [ "$pedigree" == "AD" ]; then

        if [[ $snv_supplied = 1 ]]; then
                perl AD_father.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_AD_father.vcf
                perl AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_AD_mother.vcf
                snv_2=1
                active_snv_vcf="$snv_basename"_AD_father.vcf
                snv_vcf_2="$snv_basename"_AD_mother.vcf
                snv_basename=${active_snv_vcf%.*}
                snv_basename_2=${snv_vcf_2%.*}
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl AD_father.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_AD_father.vcf
                perl AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_AD_mother.vcf
                indel_2=1
                active_indel_vcf="$indel_basename"_AD_father.vcf
                indel_vcf_2="$indel_basename"_AD_mother.vcf
                indel_basename=${active_indel_vcf%.*}
                indel_basename_2=${indel_vcf_2%.*}

        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                perl AD_father.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_AD_father.vcf
                perl AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_AD_mother.vcf
                combined_2=1
                active_combined_vcf="$combined_basename"_AD_father.vcf
                combined_vcf_2="$combined_basename"_AD_mother.vcf
                combined_basename=${active_combined_vcf%.*}
                combined_basename_2=${combined_vcf_2%.*}

        fi

elif [ "$pedigree" == "AR" ]; then

        #SNV+INDEL compound hets
        if [[ $snv_supplied = 1 && $indel_supplied = 1 ]]; then
                perl comp_het_indels.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf $active_indel_vcf > "$snv_basename"_indels_CH_genes.txt
                active_snv_indel_list="$snv_basename"_indels_CH_genes.txt
                perl print_2_vcf.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index "$snv_basename"_indels_CH_genes.txt $active_snv_vcf > "$snv_basename"_indels_CH.vcf
                perl print_2_vcf.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index "$snv_basename"_indels_CH_genes.txt $active_indel_vcf >> "$snv_basename"_indels_CH.vcf

                if [[ $known_gene_list != 0 ]]; then
                perl shared_genes.pl $known_gene_list $active_snv_indel_list > "$snv_basename"_indels_CH_known_genes.txt
                fi
        fi

        #SNV + SNV compound hets and AR
        if [[ $snv_supplied = 1 ]]; then
                perl multi_hits.pl $active_snv_vcf > "$snv_basename"_multihits.vcf
                perl comp_het_proband.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index "$snv_basename"_multihits.vcf > "$snv_basename"_CH.vcf
                perl AR.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_HM.vcf
                snv_2=1
                active_snv_vcf="$snv_basename"_CH.vcf
                snv_vcf_2="$snv_basename"_HM.vcf
                snv_basename=${active_snv_vcf%.*}
                snv_basename_2=${snv_vcf_2%.*}

        fi

        #INDEL + INDEL compound hets and AR
        if [[ $indel_supplied = 1 ]]; then
                perl multi_hits.pl $active_indel_vcf > "$indel_basename"_multihits.vcf
                perl comp_het_proband.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index "$indel_basename"_multihits.vcf > "$indel_basename"_CH.vcf
                perl AR.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_HM.vcf
                indel_2=1
                active_indel_vcf="$indel_basename"_CH.vcf
                indel_vcf_2="$indel_basename"_HM.vcf
                indel_basename=${active_indel_vcf%.*}
                indel_basename_2=${indel_vcf_2%.*}

        fi
	#Combined vcf compound hets and AR
        if [[ $combined_vcf_supplied = 1 ]]; then
                perl multi_hits.pl $active_combined_vcf > "$combined_basename"_multihits.vcf
                perl comp_het_proband.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index "$combined_basename"_multihits.vcf > "$combined_basename"_CH.vcf
                perl AR.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_HM.vcf
                combined_2=1
                active_combined_vcf="$combined_basename"_CH.vcf
                combined_vcf_2="$combined_basename"_HM.vcf
                combined_basename=${active_combined_vcf%.*}
                combined_basename_2=${combined_vcf_2%.*}

        fi

elif [ "$pedigree" == "DN" ]; then

        if [[ $snv_supplied = 1 ]]; then
                perl DN.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf > "$snv_basename"_DN.vcf
                active_snv_vcf="$snv_basename"_DN.vcf
                snv_basename=${active_snv_vcf%.*}
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl DN.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf > "$indel_basename"_DN.vcf
                active_indel_vcf="$indel_basename"_DN.vcf
                indel_basename=${active_indel_vcf%.*}
        fi
	if [[ $combined_vcf_supplied = 1 ]]; then
                perl DN.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf > "$combined_basename"_DN.vcf
                active_combined_vcf="$combined_basename"_DN.vcf
                combined_basename=${active_combined_vcf%.*}
        fi


elif [ "$pedigree" == "XL" ]; then

        if [[ $snv_supplied = 1 ]]; then
                perl AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_snv_vcf | grep -w X > "$snv_basename"_XL.vcf
                active_snv_vcf="$snv_basename"_XL.vcf
                snv_basename=${active_snv_vcf%.*}
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_indel_vcf | grep -w X > "$indel_basename"_XL.vcf
                active_indel_vcf="$indel_basename"_XL.vcf
                indel_basename=${active_indel_vcf%.*}
        fi
	if [[ $combined_vcf_supplied = 1 ]]; then
                perl AD_mother.pl --NUM_AFFECTED=$num_affected --PROBAND=$proband_index $active_combined_vcf | grep -w X > "$combined_basename"_XL.vcf
                active_combined_vcf="$combined_basename"_XL.vcf
                combined_basename=${active_combined_vcf%.*}
        fi

fi

#run solve part1 to extract gene names
if [[ $snv_supplied = 1 ]]; then
        perl get_genes.pl $active_snv_vcf | uniq | grep -v -w Gene > "$snv_basename"_genes.txt
        if [[ $snv_2 = 1 ]]; then
        perl get_genes.pl $snv_vcf_2 | uniq | grep -v -w Gene > "$snv_basename_2"_genes.txt
        fi

fi
if [[ $indel_supplied = 1 ]]; then
        perl get_genes.pl $active_indel_vcf | uniq | grep -v -w Gene > "$indel_basename"_genes.txt
        if [[ $indel_2 = 1 ]]; then
                perl get_genes.pl $indel_vcf_2 | uniq | grep -v -w Gene > "$indel_basename_2"_genes.txt
        fi

fi
if [[ $combined_vcf_supplied = 1 ]]; then
        perl get_genes.pl $active_combined_vcf | uniq | grep -v -w Gene > "$combined_basename"_genes.txt
        if [[ $combined_2 = 1 ]]; then
                perl get_genes.pl $combined_vcf_2 | uniq | grep -v -w Gene > "$combined_basename_2"_genes.txt
        fi

fi

#compare to known genes
if [[ $known_gene_list != 0 ]]; then
        if [[ $snv_supplied = 1 ]]; then
                perl shared_genes.pl $known_gene_list "$snv_basename"_genes.txt | uniq > "$snv_basename"_known_genes.txt

                if [[ $snv_2 = 1 ]]; then
                        perl shared_genes.pl $known_gene_list "$snv_basename_2"_genes.txt | uniq > "$snv_basename_2"_known_genes.txt

                fi
        fi
        if [[ $indel_supplied = 1 ]]; then
                perl shared_genes.pl $known_gene_list "$indel_basename"_genes.txt | uniq > "$indel_basename"_known_genes.txt
                if [[ $indel_2 = 1 ]]; then
                        perl shared_genes.pl $known_gene_list "$indel_basename_2"_genes.txt | uniq > "$indel_basename_2"_known_genes.txt

                fi
        fi
        if [[ $combined_vcf_supplied = 1 ]]; then
                perl shared_genes.pl $known_gene_list "$combined_basename"_genes.txt | uniq > "$combined_basename"_known_genes.txt
                if [[ $combined_2 = 1 ]]; then
                        perl shared_genes.pl $known_gene_list "$combined_basename_2"_genes.txt | uniq > "$combined_basename_2"_known_genes.txt

                fi
        fi


fi

