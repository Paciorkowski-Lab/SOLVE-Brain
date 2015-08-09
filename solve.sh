#!/bin/bash
#
#solve.sh
#
#06/04/2015
#
#By: Frankie James
#
#File that will run the core.sh script provided a Who's-who file where the probands are marked
#The Proband Identifer should be in column 1 and the index for the vcf should be in column 2
#
#
#
#
columns=$(tput cols)
breaker=""
for (( i=0; i<$columns; i++ )) ; do breaker="$breaker=" ; done

display_results=0
pause_on_display=0
proband_detected=0
verbose_desired=0
output_provided=0
whos_who_provided=0
run_whos_who=0
snv_vcf_provided=0
indel_vcf_provided=0
combined_vcf_provided=0
name_of_who_provided=0
rarity_files_desired=0

whos_who_display=$(printf "\t\t\t%-30s %-30s %-30s %-30s %-30s\n\t\t\t%-30s %-30s %-30s %-30s %-30s\n\t\t\t%-30s %-30s" "COLUMN_1" "COLUMN_2" "COLUMN_3" "COLUMN_4" "COLUMN_5" "PROBAND_IDENTIFIER" "PROBAND_INDEX" "'proband'" "<number_affected>" "<absent parents> (M|F|MF|'')" "OTHER_IDENTIFIER(Parent)" "OTHER_INDEX(if wanted)")
usage="USAGE:\nThis file is meant to accompany 'core.sh' and should be placed in the same folder.\n\tIt is run in the following manner:\n\tsh solve.sh [ARGUMENTS FOR SOLVE] [ARGUMENTS FOR CORE]\n\nARGUMENTS FOR SOLVE - REQUIRED:\n\tOnly one of the following:\n\n\t\t-i <Who's who file>\n\t\t\tSet up in the following manner(tab delimited):\n$whos_who_display\n\n\t\t-U <Unannotated_VCF_file> used to automatically generate Who's who file.\n\n-O <Output location> (/path/to/output/) with the final '/' included.\n\tNOTE: The output location must not contain any files with 'genes' in the name to avoid ERROR message.\n-Arguments required by core listed below.\n\nARGUMENTS FOR SOLVE - OPTIONAL:\n-T This is our 'Training Wheels' flag and is meant to provide default functionality to those less savy with the command line.\n\tThe 'Training Wheels' option will default to common used functionality without remembering many flags.\n\tThis default run is equivalent to running, -X, -v, -R (Display and pause, Verbose files, Rare_Variant_Files)\n-N <Name_of_whos_who_file> to be used in conjunction with '-U' and will be disregarded otherwise.\n\tNOTE: If no name is provided and a recent whos who file is in output location you will be asked to provide a name not found in the output location.\n-x This will display the results of 'ALL' gene file produced after all probands have run and for all combinations, i.e. ALL_indel_genes and ALL_snv_genes if both are provided.\n-X This will display the results of the ALL gene file with pauses in between different files for clearer output.\n-h Will display the usage of solve as well as core.\n-v Verbose File creator. This will create files that contain not only the gene but the corresponding data from VCF file as well.\n\tNOTE: Can be used with or without the display options ('-x', '-X').\n-R Will produce files that are similar to the files created in Verbose mode (will automatically enable verbose mode) but filtered for only rare variants. i.e. not found in parents outside family.\n\tNOTE: Also added to these files are headings used in the analysis of all rare-genes to be used in conjunction with SOLVE-Brain's web interface. (found at: https://paciorkowski-lab.urmc.rochester.edu/static/code/solve_brain_webi.html)\n$breaker"

printf "$breaker\nRUNNING AUTOMATED SOLVE:\n"

while getopts ":vhsnqdrxXTRa:g:P:i:k:I:S:O:C:U:N:" opt
do
	case "$opt" in
		i)
			printf "\n-i Who's who file provided: $OPTARG\n"
			whos_who_provided=1
			whos_who_original=$OPTARG
			;;
		O)
			printf "\n-O Output location is: $OPTARG\n"
			output_location=$OPTARG
			output_provided=1
			;;
		x)
			printf "\n-x You have chosen to display results.\n"
			display_results=1
			;;
		X)
			printf "\n-X You have chosen to display results with pause functionality.\n"
			display_results=1
			pause_on_display=1
			;;
		v)
			printf "\n-v Verbose mode desired. For each gene found, the contents of the vcf related to gene will be included in 'VERBOSE' file.\n"
			verbose_desired=1
			;;
		h)
			printf "\n$usage\n"
			sh core.sh -h | grep -v -e "-i" -e "-O"
			exit 0
			;;
		U)
			printf "\n-U Unannotated vcf file provided for Who's who generation: $OPTARG\n"
			run_whos_who=1
			unanno_vcf=$OPTARG
			;;
		I)
			printf "\n-I Indel vcf provided: $OPTARG\n"
			indel_vcf_provided=1
			indel_vcf=$OPTARG
			;;
		S)
			printf "\n-S Snv vcf provided: $OPTARG\n"
			snv_vcf_provided=1
			snv_vcf=$OPTARG
			;;
		C)
			printf "\n-C Combined vcf provided: $OPTARG\n"
			combined_vcf_provided=1
			combined_vcf=$OPTARG
			;;
		N)
			printf "\n-N Name for Who's who file provided: $OPTARG\n"
			name_of_who_provided=1
			name_of_who=$OPTARG
			;;
		R)
			printf "\n-R Rarity files will be created.\n"
			verbose_desired=1
			rarity_files_desired=1
			;;
		T)
			printf "\n-T 'Training Wheels' enabled.\n"
                        verbose_desired=1
                        display_results=1
                        pause_on_display=1
                        rarity_files_desired=1
                        ;;
		\?)
			printf "\nError: Invalid option: -$OPTARG\n$breaker\n"
			exit 1
			;;
		:)
			printf "\nError: Option -$OPTARG requires an argument.\n$breaker\n"
			exit 1
			;;
	esac
done

# Check that output location is provided
if [[ $output_provided == 0 ]]
then
	printf "\nError:\n\tPlease provide an output location with -O option.\n\n$usage\n."
	exit 1
fi

# check that adequate files were provided for Who's who.
if [[ $whos_who_provided == 1 && $run_whos_who == 1 ]]
then
	printf "\nError:\n\tWho's who file detected as well as unannotated vcf. Please choose one or the other.\n$breaker\n"
	exit 1
elif [[ $whos_who_provided == 0 && $run_whos_who == 0 ]]
then
	printf "\nError:\n\tNo Who's who file provided or unannotated vcf for Who's who generation. Please provide one or the other.\n\n$usage\n"
	exit 1
fi

# Run Whos_who_generator if need be
if [[ $run_whos_who == 1 ]]
then
	if [[ $snv_vcf_provided == 0 && $indel_vcf_provided == 0 && $combined_vcf_provided == 0 ]]
	then
		printf "\nError:\n\tNo annotated vcf file provided. Please provide at least one (SNV, Indel, Combined) or a Who's who file.\n\n$usage\n"
		exit 1
	fi
	if [[ $snv_vcf_provided == 1 ]]
	then 
		usable_vcf=$snv_vcf
	elif [[ $indel_vcf_provided == 1 ]]
	then
		usable_vcf=$indel_vcf
	else
		usable_vcf=$combinded_vcf
	fi

	if [[ $name_of_who_provided == 1 ]]
	then
		sh whos_who_generator.sh -O $output_location -U $unanno_vcf -A $usable_vcf -N $name_of_who || bad_exit=1
	else
		sh whos_who_generator.sh -O $output_location -U $unanno_vcf -A $usable_vcf || bad_exit=1
	fi
fi

#Check exit status of whos who generator before proceeding
if [[ $bad_exit == 1 ]]
then
	printf "\n***Who's who generator failed. Please check error message and rerun.***\n\n"
	exit 1
fi

if [[ $whos_who_provided == 1 ]]
then
	usable_whos_who_file=$whos_who_original
else
	if [[ $name_of_who_provided == 1 ]]
	then
		usable_whos_who_file=${output_location}${name_of_who}.txt
	else
		usable_whos_who_file=${output_location}"Who_is_who_"$(date +"%b_%d_%Y").txt
	fi
fi

cat "$usable_whos_who_file" | grep proband > "${usable_whos_who_file%.*}"_proband.txt
whos_who_proband=$(echo "${usable_whos_who_file%.*}_proband.txt")
proband_number=$(cat $whos_who_proband | wc -l)
rm -f $affected_whos_who

if [[ $proband_number == 0 ]]
then
       	printf "\nERROR:\n\tWho's who does not contain any probands.\n$usage\n"
	rm -f $whos_who_proband
	exit 1
else
	printf "\nWho's who list contains:\n"
	cat $whos_who_proband
fi

#Check that output location is empty of gene files
file_checker_count=$(find $output_location -maxdepth 1 -type f -name "*genes*")
#echo $file_checker_count
if [[ -n $file_checker_count ]]
then 
	printf "\nERROR:\n\tOutput location already contains gene files."
	printf "\n\tPlease choose another output location.\n$breaker\n"
	rm -f $whos_who_proband
	exit 1
fi

while read line
do
	#Get info from who's who...
	proband_identifier=$(echo "$line" | awk '{print $1}')
	proband_index=$(echo "$line" | awk '{print $2}')
	number_affected=$(echo "$line" | awk '{print $4}')
	absent_parents=$(echo "$line" | awk '{print $5}')

	#Make the switch from a file to an index and provide output identifier
	if [[ $whos_who_provided == 1 ]]
	then
		all_args=$(echo "${@}" | sed -e "s|$whos_who_original|$proband_index|;s|-O $output_location|&$proband_identifier|;s|-[xXvVNTR]||g;s|$name_of_who||")
	else
		all_args=$(echo "${@}" | sed -e "s|-U $unanno_vcf|-i $proband_index|;s|-O $output_location|&$proband_identifier|;s|-[xXvVNTR]||g;s|$name_of_who||")
	fi
	

	#Successively run data
	if [[ $absent_parents == "" ]]
	then
		printf "\nArguments being given to core.sh: -a $number_affected $all_args\n"
		sh core.sh -a $number_affected $all_args || bad_exit=1
	else
		printf "\nArguments being given to core.sh: -a $number_affected $all_args -A $absent_parents\n"
		sh core.sh -a $number_affected $all_args -A $absent_parents || bad_exit=1
	fi
	#Check exit status of run solve before proceeding
	if [[ $bad_exit == 1 ]]
	then
		printf "\n***Core failed. Please check error message and rerun script.***\n"
		rm -f $whos_who_proband
		exit 1
	fi

done <$whos_who_proband

#Create a more annotated master gene file
for file in ${output_location}*genes.txt 
do
	#Need to pull out proband identifier...
	file_name=$(echo "${file#$output_location}")
	identity=$(echo "${file_name%%_snv*}")
	identity=$(echo "${identity%%_indel*}")
	file_suffix="${file_name#$identity}"
	#Pull out genes and organize by identifier...
	all_gene_file="${output_location}"ALL$file_suffix
	echo -e "\n$identity" >> $all_gene_file
		#For verbose mode, $file with '_genes.txt' stripped off and .vcf added corresponds to vcf of interest
		#Add if statement to check for $verbose_desired == 1
		#If so, must read each line of $file, *and if line is not empty* then grep .vcf for line (aka gene) 
	        #This can be done in a while loop... append result of grep output to 'ALL_VERBOSE' file that will be created inside if statement.
		#How to make sure it is still readable... i.e. maybe add breaker lines after each identity is appended...
		if [[ $verbose_desired == 1 ]]
		then
			verbose_file="${output_location}"VERBOSE$file_suffix
			echo -e "\n$breaker" >> $verbose_file
			echo -e "\n$identity" >> $verbose_file
			while read gene_line
			do
				if [[ -n $gene_line ]]
				then	
					echo -e "\n\n$gene_line" >> $verbose_file
					echo "---------------" >> $verbose_file
					relavent_vcf=${file%_genes.txt}.vcf
					cat $relavent_vcf | grep $gene_line >> $verbose_file
				fi
			done <$file
                        if [[ $rarity_files_desired == 1 ]]
			then
				python ./rarity_finder.py -F $verbose_file -W $whos_who_proband
			fi
		fi	
	cat $file | awk '{printf "%d\t%s\n", NR, $0}' >> $all_gene_file
done

#Consolidate empty files
mkdir ${output_location}Empty_files
empty_file_dir=${output_location}Empty_files/
find $output_location -maxdepth 1 -type f -empty > ${empty_file_dir}list_of_empty_files.txt
for file in ${output_location}ALL*
do
	min_num_for_all=$((proband_number * 2))
	all_file_line_num=$(cat $file | wc -l)
	if [[ $all_file_line_num == $min_num_for_all ]]
	then
		echo $file >> ${empty_file_dir}list_of_empty_files.txt
	fi
done
for file in ${output_location}*VERBOSE*
do
	min_num_for_verbose=$((proband_number * 4))
	verbose_file_line_num=$(cat $file | wc -l)
	if [[ $verbose_file_line_num == $min_num_for_verbose ]]
	then
		echo $file >> ${empty_file_dir}list_of_empty_files.txt
	fi
done
while read line
do
	mv $line $empty_file_dir
done <${empty_file_dir}list_of_empty_files.txt

#Will display the contents of "ALL" gene file if the user includes the -x argument.
#Display can be paused in between files if so desired by providing a capital -X.
if [[ $display_results == 1 ]] ; then
	for ALL_file in ${output_location}ALL* ${output_location}VERBOSE*
	do
		if [[ $pause_on_display == 1 ]] ; then
			clear
		fi
		echo -e "\n$breaker"
		echo -e "\nGenes found in ${ALL_file#$output_location}:\n"
		if [[ $pause_on_display == 1 ]] ; then
			read -p "Press [Enter] key to continue... (then press 'q' to exit display)"
			less $ALL_file
		else
			cat $ALL_file
		fi
		
		
	done
	printf "\nAll files have been printed. Done.\n$breaker\n"
else 
	printf "\n$breaker\n"	
fi
# Delete proband file
rm -f $affected_whos_who
rm -f $whos_who_proband
exit 0
