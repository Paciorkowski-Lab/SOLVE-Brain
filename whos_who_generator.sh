#!/bin/bash
#
#Frankie James
#6/8/15
#
#Script to generate whos who file
#
#Must provide an unannotated vcf as well as an annotated vcf
#	-From the unannotated vcf the cohort identifiers will be grabbed
#	-From the annotated vcf the indecies of the identifiers will be grabbed
#	-Will then ask user for each identifier, whether subject is a proband or not --> Sanity check
#**Possibly add option for 'standard input' where the first identifier is proband followed by two parents followed by the next proband

columns=$(tput cols)
breaker=""

for (( i=0; i<$columns; i++ )) ; do breaker="$breaker=" ; done

usage="USAGE:\nThis file is for the purpose of generating a Who's who file that then can be passed to auto_run_solve.sh for automation of of the run_solve.sh script.\n\nIt is ran in the following manner:\n\tsh whos_who_generator.sh [REQUIRED ARGUMENTS] [OPTIONAL ARGUMENTS]\n\nRequired Arguments:\n\t-O /path/to/output/ with the final '/' included.\n\t-U <Unannotated_VCF_file> used to retrieve cohort identifiers. *MUST BE IN GATK3 FORMAT*\n\t-A <Annotated_VCF_file> used to retrieve indices corresponding to the cohort identifiers.\n\nOptional Arguments:\n\t-N 'Name_of_whos_who_file' used for output. *If not provided will default to 'Whos_who_[date]'*\n\t-x Display resulting file after processing.\n\t-h Display this help document and exit.\n$breaker\n"

unanno_vcf_provided=0
anno_vcf_provided=0
output_location_provided=0
name_provided=0
display_result=0

printf "\n$breaker\nRUNNING WHO'S_WHO_GENERATOR:\n"

while getopts ":hxO:U:A:N:" opt
do
	case "$opt" in
		O)
			printf "\n-O Output location provided: $OPTARG\n"
			output_location_provided=1
			output_location=$OPTARG
			;;
		U)
			printf "\n-U Unannotated VCF file provided: $OPTARG\n"
			unanno_vcf_provided=1
			unanno_vcf=$OPTARG
			;;
		A)
			printf "\n-A Annotated VCF file provided: $OPTARG\n"
			anno_vcf_provided=1
			anno_vcf=$OPTARG
			;;
		N)
			printf "\n-N Name for Who's who file provided: $OPTARG\n"
			name_provided=1
			output_name=${OPTARG%.*}
			;;
		x)
			printf "\n-x You have chosen to display resulting Who's who file.\n"
			display_result=1
			;;
		h)
			printf "\n$usage\n"
			exit 0
			;;
		\?)
			printf "\n$breaker\nError: Invalid option: -$OPTARG\n$breaker\n$usage\n"
			exit 1
			;;
		:)
			printf "\n$breaker\nError: Option -$OPTARG requires an argument.\n$breaker\n$usage\n"
			exit 1
			;;
	esac
done

if [[ $unanno_vcf_provided == 0 ]]
then
	printf "\n$breaker\nError:\n\tNo unannotated VCF provided.\n$breaker\n$usage\n"
	exit 1
fi

if [[ $anno_vcf_provided == 0 ]]
then
	printf "\n$breaker\nError:\n\tNo annotated VCF provided.\n$breaker\n$usage\n"
	exit 1
fi

if [[ $output_location_provided == 0 ]]
then
	printf "\n$breaker\nError:\n\tNo output location provided.\n$breaker\n$usage\n"
	exit 1
fi

if [[ $name_provided == 0 ]]
then
	output_name="Who_is_who_"$(date +"%b_%d_%Y")
fi

#check that output name will not cause issues
file_checker=$(find $output_location -type f -name "${output_name%.*}*" -prune)
if [[ -n $file_checker ]] 
then
	printf "\n$breaker\nError:\n\tOutput location already contains a file called: $output_name\n"
	if [[ $name_provided == 0 ]]
	then
		printf "\nPlease provide a name using the -N option.\n$breaker\n$usage\n"
	else
		printf "\nPlease provide a more specific/ different name for output file, or omit -N option.\n\n$breaker\n"
	fi
	exit 1
fi
printf "\n$breaker\n\n"

#Get identifiers from unannotated vcf
less $unanno_vcf | grep CHROM | awk '{for(i=10;i<=NF;i++)print $i}' >> $output_location$output_name.txt
whos_who_file=$output_location$output_name.txt

#Get index of first subject from the annotated vcf. (Dirty, I'm sure could be more elegant)
first_index=$(less $anno_vcf | grep -m 1 'GT:AD' | sed 's|\t|\n|g' | sed -n '/GT:AD/=')

#Append indecies starting from the first found for every line of 'whos_who_file'
#Ask user if identifier is a proband... If so append 'proband' as well
#All appending is tab delimited
number_of_identifiers=$(cat $whos_who_file | wc -l)
i=1
while [[ $i -le $number_of_identifiers ]]
do
	sed -i "${i}s/$/\t$first_index/" $whos_who_file
	current_label=$(tail -n+$i $whos_who_file | head -n1 | sed "s|\t.*||g")
	printf "Is $current_label a proband? (y/n)?\n"
	read -n 1 choice 
	echo
	if [[ $choice == [Yy] ]]
	then
		sed -i "${i}s/$/\tproband/" $whos_who_file
		printf "Number of affected siblings? (or just [ENTER] for 0)\n"
		read  sibling_count
		printf "Any absent parents? Enter 'm' for absent mother, 'f' for father or 'mf' for both or [ENTER] for neither.\n"
		read  absent
		if [[ $sibling_count != [0-9] ]]; then sibling_count=1;else ((sibling_count++)); fi
		sed -i "${i}s/$/\t$sibling_count\t$absent/" $whos_who_file
		if [[ $absent == [mM] || $absent == [fF] ]]
		then
			i=$((i + sibling_count + 1))
			new_index=$((sibling_count + 1))
		elif [[ $absent == "mf" || $absent == "MF" ]]
		then
			i=$((i + sibling_count))
			new_index=$((sibling_count))
		else
			i=$((i + sibling_count + 2))
			new_index=$((sibling_count + 2))
		fi
	else
		new_index=1
		((i++))

	fi
	first_index=$((first_index + new_index))
done
if [[ $display_result == 1 ]]
then
	printf "\n$breaker\n\n"
	cat $whos_who_file
fi
printf "\n\nDone!\n$breaker\n"
exit 0
