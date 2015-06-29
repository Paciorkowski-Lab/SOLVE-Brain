import sys, getopt, re

#--NUM_AFFECTED=$num_affected --PROBAND=$proband_index --SNV=$active_snv_vcf --INDEL=$active_snv_vcf --OUTPUT=$output_base
num_affected = '';
proband_index = '';
absent = '';
snv = '';
indel = '';
pedigree = '';
output = '';

def main(argv):
	try:
		opts, args = getopt.getopt(args, "ha:i:S:I:O:P:A:", ["ABSENT=", "NUM_AFFECTED=", "PROBAND=", "SNV=", "INDEL=", "PEDIGREE=", "OUTPUT="]);
	except getopt.GetoptError:
		print usage;
		sys.exit(2);
	for opt, arg in opts:
		if opt == '-h':
			print usage;
			sys.exit();
		elif opt in ("--NUM_AFFECTED", "-a"):
			num_affected = arg;
		elif opt in ("--PROBAND", "-i"):
			proband_index = arg;
		elif opt in ("--SNV", "-S"):
			snv = arg;
		elif opt in ("--INDEL", "-I"):
			indel = arg;
		elif opt in ("--PEDIGREE", "-P"):
			pedigree = arg;
		elif opt in ("--ABSENT", "-A"):
			absent = arg;
		elif opt in ("--OUTPUT", "-O"):
			output = arg;
