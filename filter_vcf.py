import logging, sys, getopt, re

#--NUM_AFFECTED=$num_affected --PROBAND=$proband_index --SNV=$active_snv_vcf --INDEL=$active_snv_vcf --OUTPUT=$output_base
num_affected = '';
proband_index = '';
absent = ''; #no one is absent right now.

snv = ''; #either one is the input file.
indel = '';

pedigree = '';
output = '';

def map(input): #input could be snv or indel, we don't really care.


def filter(pedigree, absent):
	if absent == "":
		
	elif absent == "M":

	elif absent == "MF":
			

def main(argv):
	try:
		#SNV, INDEL are the inputs.
		opts, args = getopt.getopt(args, "hA:a:i:S:I:O:P:", ["ABSENT=", "NUM_AFFECTED=", "PROBAND=", "SNV=", "INDEL=", "PEDIGREE=", "OUTPUT="]);
	except getopt.GetoptError:
		print usage;
		sys.exit(2);
	for opt, arg in opts:
		logging.info(opt + ": " + arg);
		if opt == '-h':
			print usage;
			sys.exit();
		elif opt in ("--NUM_AFFECTED", "-a"):
			num_affected = arg;
		elif opt in ("--PROBAND", "-i"):
			#index of the proband..?
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
		#done capturing params
	#todo:
	#fn = os.path.join(os.path.dirname(__file__), 'my_file')h	
	filein = '';
	if snv != "":
		filein = open(snv, 'r');
	elif indel != "":
		filein = open(, 'r');
	else
		logging.error("no input files are given");
		sys.exit(2);
#	filter(pedigree, absent)
