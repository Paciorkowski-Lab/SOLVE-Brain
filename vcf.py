#Author: @imyjimmy, @fjames003
import logging, sys, getopt, re
	
class vcf: 
	
	def __init__(self, proband_index = None, num_affected = None, absent = None, snv = None, indel = None, pedigree = None, output = None):
		self.proband = int(proband_index)
		self.num_affected = int(num_affected)
		self.absent = absent
		self.snvFile = snv
		self.indelFile = indel
		self.pedigree = pedigree
		self.output = None
		self.mother = 0
		self.father = 0
		self.parent_num = 0                                                       
		self.absentMother = ''
		self.absentFather = ''
		self.idOffset = None
		self.filein = None
		self.fileout = None
		if self.proband != None:
			#self.false_array = [False for skipped in range(self.proband)]   
			self.false_array = [False] * self.proband         
		#build gene dict
		self.geneHash = {}
		self.snvHash = {"father": {}, "mother": {}}
		self.indelHash = {"father": {}, "mother": {}}

		#dirty but okay for now
		if (file_check(self.snvFile) == 1 and file_check(self.indelFile) == 1):
			geneFile = open(self.snvFile.split('.vcf')[0] + '_indel_CH_genes.txt', 'w')
			geneFile.close()

	def close(self):	
		self.filein.close()
		self.fileout.close()
		#self.indexin.close()

	#father, mother indices are set in relation to proband
	def computeParents(self):
		self.parseAbsentParents()
		if not self.absentFather:
			self.father = self.proband + int(self.num_affected)
			self.parent_num += 1                                                  
		if not self.absentMother:
			if not self.absentFather:
				self.mother = self.proband + int(self.num_affected) + 1
			else:
				self.mother = self.proband + int(self.num_affected)
			self.parent_num += 1                                                  

		#added for testing
		return [self.father, self.mother]
	 
	#parse absent parents.
	def parseAbsentParents(self):
		self.absentFather = re.search('F', self.absent.upper()) != None
		self.absentMother = re.search('M', self.absent.upper()) != None

		#added for testing
		return [self.absentFather, self.absentMother]

	def computeFam(self, searchStr, line):
		family = self.mapSearch(searchStr, line.split('\t')[self.proband:(self.proband + self.num_affected + self.parent_num)])
		return self.false_array + family

	#returns an array of [True, False, False, True, etc]
	#could be used to hard filter out exonic vs non-
	def mapSearch(self,searchStr,arr):
		v = map(lambda x: re.search(searchStr, x) != None, arr)       
		return v                                                               
	
	#detects the proband offset for the current line.
	#could use a general method, compute all offsets.
	# def probandOffset(self, line, offset = None):
	# 	if offset != None:
	# 		self.idOffset = offset

	# 	print('probandOffset:')
	# 	arrIndex = self.mapSearch('GT:AD:DP:GQ:PL', line)
	# 	index = 0 #index('')
	# 	for i in arrIndex:
	# 		index = 1+index
	# 		if i:
	# 			self.proband = index + self.idOffset #breaking any rules here..?
	# 			return index+self.idOffset #global--declares the offset from 1st proband correspondint to person of interest.
	# 														#no need to reshuffle columns. make sure it reflects the person you need.
	# 	#fail case
	# 	return -1 
	
	def isProbands(self, variant):
		for i in range(self.num_affected):
			if not variant[self.proband + i]:
				return False
		return True

	def isFather(self, the_array):
		return (not self.absentFather and the_array[self.father]) or self.absentFather

	def isMother(self, the_array):
		return (not self.absentMother and the_array[self.mother]) or self.absentMother

	#you can pass in a built in flag if you want
	def computeVCFLine(self, line): #filein = None, fileout = None
		homo = self.computeFam('1/1', line)
		hetero = self.computeFam('0/1', line)
		absent = self.computeFam('0/0', line)
		return {"homo": homo, "hetero": hetero, "absent": absent}          
	
	def computeAR(self, line):
		triplet = self.computeVCFLine(line)           
		variant, inherited = triplet['homo'], triplet['hetero']
		
		return self.isProbands(variant) and (self.isFather(inherited)  and self.isMother(inherited))

	def computeAD(self, line):
		triplet = self.computeVCFLine(line)
		variant, inherited, notPresent = triplet['hetero'], triplet['hetero'], triplet['absent']

		if self.absentFather and self.absentMother:
			return self.isProbands(variant)
		else:
			return self.isProbands(variant) and ((self.isFather(inherited) != self.absentFather) != (self.isMother(inherited) != self.absentMother))
	
	def computeDN(self, line):
		triplet = self.computeVCFLine(line)
		variant, inherited, notPresent = triplet['hetero'], triplet['hetero'], triplet['absent']
		
		return self.isProbands(variant) and (self.isFather(notPresent) and self.isMother(notPresent))

	def computeXL(self, line):                  
		if re.search("X", line[:1]) != None:            
			triplet = self.computeVCFLine(line)
			variant, inherited , notPresent = triplet['hetero'], triplet['hetero'], triplet['absent']

			return self.isProbands(variant) and (self.isFather(notPresent) and self.isMother(inherited))
		return False

	def prettyPrintPedigree(self):
		if self.pedigree == 'AR':
			return 'HM'
		else:
			return self.pedigree
		
#could potentially makes this more of a "standalone" method
	#in that case probandOffset, offsets are needed
	def computePedigree(self, filein=None, fileout=None):
#		self.__computePedigree(self.filein, self.fileout)
		#pre: either self.snvFile is there or self.indelFile is there
		base = fileout 
		if self.snvFile is filein:
			#print('splitting the snvFile name: ' + self.snvFile + ' into: ' + self.snvFile.split('.vcf')[0])
			base = self.snvFile.split('.vcf')[0] 	
		elif self.indelFile is filein:
			base = self.indelFile.split('.vcf')[0] 
		else:
			raise ValueError("No annotated vcf provided")

		if filein != None:
			self.filein = open(filein, "r")
		if fileout != None:
			pedigreeSuffix = "_" + self.prettyPrintPedigree() + ".vcf"
			#print('outputting: ' + base)
			self.fileout = open(base + pedigreeSuffix, "w")	
		
	
		#print('computePedigree(filein, fileout)')
		#print('\tpedigree: ' + self.pedigree)
		self.computeParents()
		if self.pedigree == 'AR':
			for line in self.filein:
				if self.computeAR(line):
					self.fileout.write(line)

			#slightly diff scenario for CH due to comparisons on a gene to gene basis
			#rather than a line basis
			if self.snvFile is filein:
				self.computeCompoundHet(self.snvFile, base)
			else:
				self.computeCompoundHet(self.indelFile, base)
		elif self.pedigree == 'AD':
			for line in self.filein:
				if self.computeAD(line):
					self.fileout.write(line)
		elif self.pedigree == 'DN':
			for line in self.filein:
				if self.computeDN(line):
					self.fileout.write(line)
		elif self.pedigree == 'XL':
			for line in self.filein:
				if self.computeXL(line):
					self.fileout.write(line)

	def buildGeneHash(self, filein = None):
		geneHash = {}
		if filein != None:
			self.filein = open(filein, 'r')

		for line in self.filein:
			l = line.split("\t");
			geneName = l[6]
			key = ':'.join(l[0:5])
			if geneName in geneHash:
				geneHash[geneName][key] = line
			else:
				variant = {}
				variant[key] = line
				geneHash[geneName] = variant
		#not esoteric debate: the pros and cons of self.geneHash vs returning a geneHash
		return geneHash

	#def addGeneHash():
		
	#whether self.geneHash is a thing or not will greatly affect this.
	def printGeneHash(self):
		for gene in self.geneHash:
			print len(self.geneHash[gene])
			for var in self.geneHash[gene]:
				if len(self.geneHash[gene]) >= 2:
					print self.geneHash[gene][var]

	#still in progress

	#writes the variant line, in order of the position (same as before)
	#will probably change a bit when passing self.fileout (may already be open) and will not need to be closed.
	def writeHash(self, variantHash, fileout=None):
		if fileout is not None:
			output_file = open(fileout, "a")
			for variant in sorted(variantHash):
				output_file.write(variantHash[variant])
		output_file.close()
	
	#verify this later
	def intersectGeneHash(self, gH1, gH2):
		pass

	#python has sets! omg
	def computeCHetHelper(self, snvFather, snvMother, indelFather, indelMother):
		snvFatherSet = set(snvFather.keys())
		snvMotherSet = set(snvMother.keys())

		indelFatherSet = set(indelFather.keys())
		indelMotherSet = set(indelMother.keys())

		#now have a set of keys which represent genes whose criteria match snvCH, indelCH, indelSNVCH
		return ((snvFatherSet & indelMotherSet),(snvMotherSet & indelFatherSet))
	
	#should return true, fase..?
	def computeCompoundHet(self, filein=None, fileout=None):
		geneHash = self.buildGeneHash(filein)
		sorted_gene_hash = sorted(geneHash.items(), key = lambda x : int(x[1].items()[0][0].split(':')[0]) if x[1].items()[0][0].split(':')[0] != 'X' and x[1].items()[0][0].split(':')[0] != 'Y' else x[1].items()[0][0].split(':')[0])
		for gene in sorted_gene_hash: #iterates over keys
			gene_dict = {}
			parentsCH = self.compileParentHash(geneHash[gene[0]])
			if (len(parentsCH[0]) > 0 and len(parentsCH[1]) > 0) :
				#some way to out to file. i know. use a method that doesnt exist yet
				gene_dict = dict(parentsCH[0], **parentsCH[1])

			if self.snvFile is filein:
				if len(parentsCH[0]) > 0:
					self.snvHash['father'][gene[0]] = parentsCH[0]
				if len(parentsCH[1]) > 0:
					self.snvHash['mother'][gene[0]] = parentsCH[1]
				self.writeHash(gene_dict, fileout + "_CH.vcf")
			else:
				if len(parentsCH[0]) > 0:
					self.indelHash['father'][gene[0]] = parentsCH[0]
				if len(parentsCH[1]) > 0:
					self.indelHash['mother'][gene[0]] = parentsCH[1]
				self.writeHash(gene_dict, fileout + "_CH.vcf")
	
		#there could be no snv_indel compHet and therfore should be checked...
		if (len(self.snvHash['father']) > 0 and len(self.indelHash['mother']) > 0) or (len(self.snvHash['mother']) > 0 and len(self.indelHash['father']) > 0):
			keySets = self.computeCHetHelper(self.snvHash['father'], self.snvHash['mother'], self.indelHash['father'], self.indelHash['mother'])
			geneFile = open(fileout + '_indel_CH_genes.txt', 'a')
			
			for key in keySets[0]:
				self.writeHash(self.snvHash['father'][key], fileout + '_indel_CH.vcf')
				self.writeHash(self.indelHash['mother'][key], fileout + '_indel_CH.vcf')
				geneFile.write(key)
			for key in keySets[1]:
				self.writeHash(self.indelHash['father'][key], fileout + '_indel_CH.vcf')
				self.writeHash(self.snvHash['mother'][key], fileout + '_indel_CH.vcf')
				geneFile.write(key)
	#in this method, we are looking at variants of this particular gene
	def compileParentHash(self, variantHash): #geneHash[gene] returns a hash of variants for that gene. I know.
		compHet = {}
		#hows this workaround:
		compHet['father'] = {}
		compHet['mother'] = {}
			
		if len(variantHash) >= 2:
			for variantKey in variantHash:

				variantLine = variantHash[variantKey]
					
				triplet = self.computeVCFLine(variantLine)
				hetero, inherited, notPresent = triplet['hetero'], triplet['hetero'], triplet['absent']

				fromFather = self.isFather(inherited) and not self.absentFather
				fromMother = self.isMother(inherited) and not self.absentMother
				# using for testing purposes...
				# print(variantKey, fromFather, fromMother)
				if (self.isProbands(hetero) and (fromFather != fromMother)):
					#the proband has this (how to deal w parents) dd to compHet
					if fromFather and not fromMother:
						if self.isMother(notPresent) and not self.absentMother:
							if 'father' in compHet and compHet['father'] is not None:
								#found another match for father--dont do nothin
								#or add to an existing hash that keeps track of father-inherited variants
								compHet['father'][variantKey] = variantLine
							else:
								fatherVariants = {}
								fatherVariants[variantKey] = variantLine
								compHet['father'] = fatherVariants
					elif fromMother and not fromFather:
						if self.isFather(notPresent) and not self.absentFather:
							if 'mother' in compHet and compHet['mother'] is not None:
								compHet['mother'][variantKey] = variantLine
							else:
								motherVariants = {}
								motherVariants[variantKey] = variantLine
								compHet['mother'] = motherVariants

		return (compHet['father'], compHet['mother'])

	def computeAlleleFreq(self, line):
		print("in computeallelefreq: " + line)	
		line = line.split('\t')
		arrIndex = line.index('GT:AD:DP:GQ:PL') + 1
		#other info starts at line[arrIndex]
		print('arrIndex: ' + str(arrIndex))
		zero_one_count = self.mapSearch('0/1', line[arrIndex:]).count(True)
		one_one_count = self.mapSearch('1/1', line[arrIndex:]).count(True)
		
		numSamples = len(line[arrIndex:]) 
		#- self.mapSearch('./.', line[arrIndex:]).count(True)
		numBlank = self.mapSearch('\./\.', line[arrIndex:]).count(True)
		print {numBlank: numBlank}
		return (float(zero_one_count) + 2.0 * float(one_one_count)) / float(2*(numSamples-numBlank))

def file_check(fn):
	if isinstance(fn, str):
	    try:
	      open(fn, "r")
	      return 1
	    except IOError:
	      return 0
	else:
		return 0

def main(argv):
	pedigree = '' 
	proband = '' 
	num_affected = ''
	father = '' 
	mother = ''
	absent = '' 
	absentFather = '' 
	absentMother = '' 
	idOffset = ''	
	indel = None 
	snv = None 
	try:
	#SNV, INDEL are the inputs
		opts, args = getopt.getopt(argv, 'hA:a:i:S:I:O:P:', ['ABSENT=', 'NUM_AFFECTED=', 'PROBAND=', 'SNV=', 'INDEL=', 'PEDIGREE=', 'OUTPUT='])
	except getopt.GetoptError:
		print 'python test.py -A|--ABSENT=<empty|M|F|MF> -a|--NUM_AFFECTED=<number> -i|--PROBAND=<index> -S|--SNV=<snv_infile> -I|--INDEL=<indel_infile> -O|--OUTPUT=<output_file> -P|--PEDIGREE=<AR|AD|DN|XL>' 
		sys.exit(2)
	for opt, arg in opts:
		logging.info(opt + ': ' + arg)
		if opt == '-h': #they need help lord save 'em
			print 'python test.py -A|--ABSENT=<empty|M|F|MF> -a|--NUM_AFFECTED=<number> -i|--PROBAND=<index> -S|--SNV=<snv_infile> -I|--INDEL=<indel_infile> -O|--OUTPUT=<output_file> -P|--PEDIGREE=<AR|AD|DN|XL>' 
			sys.exit()
		elif opt in ('--NUM_AFFECTED', '-a'):
			num_affected = arg
		elif opt in ('--PROBAND', '-i'):
			proband = arg; #but we dont really use it now
		elif opt in ('--SNV', '-S'):
			snv = arg
		elif opt in ('--INDEL', '-I'):
			indel = arg
		elif opt in ('--PEDIGREE', '-P'):
			pedigree = arg
			#print('pedigree: ' + pedigree)
		elif opt in ('--ABSENT', '-A'):
			absent = arg #new argument. 
		#	parseAbsentParent() #do it right away
		elif opt in ('--OUTPUT', '-O'):
			output = arg

	#will be indel or snv
	logging.info('Done capturing params')
	#print('Done capturing params')
 
	x = vcf(proband, num_affected, absent, snv, indel, pedigree, output)
	#x.buildGeneHash()


	
	if file_check(indel) == 1:	
		x.computePedigree(indel, output)
	if file_check(snv) == 1:
		x.computePedigree(snv, output)


	x.close()
 
if __name__ == "__main__":
		main(sys.argv[1:])
#Y	16952665	16952665	C	T	exonic	NLGN4Y	synonymous SNV	NLGN4Y:NM_001206850:exon6:c.C1470T:p.P490P,NLGN4Y:NM_014893:exon6:c.C1974T:p.P658P	Score=528;Name=lod=187	NA	NA	NA	NA	NA	16952665	.	C	T	640.45	.	AC=4;AF=0.222;AN=18;BaseQRankSum=3.058;DP=909;Dels=0.00;FS=61.926;HaplotypeScore=2.2695;MLEAC=4;MLEAF=0.222;MQ=46.65;MQ0=1;MQRankSum=-5.036;QD=2.10;ReadPosRankSum=1.979	GT:AD:DP:GQ:PL0/1:155,18:173:99:141,0,3707	./.	1/1:0,14:14:42:462,42,0	0/0:159,0:159:99:0,391,4281	0/0:123,0:123:99:0,277,3182	0/1:107,11:118:89:89,0,2494	./.	0/0:99,0:99:99:0,249,2654	./.	0/0:105,0:105:99:0,250,2828	./.	0/0:117,0:117:99:0,286,3187	./.	0/0:1,0:1:3:0,3,28
