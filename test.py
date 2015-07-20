import re
import vcf

def main():
	#filein = open('./test.txt', 'r')
	vcf1 = './highFreqVars/itu_1-20_snv.hg19_multianno.txt'
	vcf2 = './highFreqVars/itu_21-40_snv.hg19_multianno.txt'

	fileout = open('./output_test.txt' , 'w')

	x = vcf.vcf()
	gH = x.buildGeneHash(vcf1)
	#print x.geneHash
	fileout.write('gene' + '\t' + 'variant' + '\t' + 'alleleFreq' + '\n')
	for gene in gH:
		#print gene
		for variant in gH[gene]:
			freq = x.computeAlleleFreq(gH[gene][variant])
			fileout.write(gene + '\t' + variant + '\t' + str(freq) + '\n')
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
