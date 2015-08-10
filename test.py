import re
import vcf

def main():
	#filein = open('./test.txt', 'r')
	vcf1 = '../1k_exomes/compile/out_snv.hg19_multianno.txt'

	fileout = open('./output_test.txt' , 'w')

	x = vcf.vcf()
	gH = x.buildGeneHash(vcf1)
	#print x.geneHash
	fileout.write('gene\tchr\tstart\tstop\tOrig\tVrnt\trsID\talleleFreq\n')
	for gene in gH:
		#print gene
		for variant in gH[gene]:
			line = gH[gene][variant]
			freq = x.computeAlleleFreq(line)
			fileout.write(gene + '\t')
			v = variant.split(':')
			for thing in v:
				fileout.write(thing + '\t')
			fileout.write(line.split('\t')[11] + '\t' + str(freq) + '\n')
		fileout.write('\n')
	#print x
#for line in filein:
#	for entry in vcf:
#		variant = map(lambda x: re.search(line.split('\n')[0], x) != None, entry.split())
#		if any(variant):
#			print entry
#filein.close()
#fileout.close()
#vcf.close()

if __name__ == "__main__":
	main()
