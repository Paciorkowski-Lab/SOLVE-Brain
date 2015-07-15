#Author: @imyjimmy, @fjames003
import logging, sys, getopt, re
	
class vcf: 
	
	# def __init__(self):
	# 	self.num_affected = '' 
	# 	self.proband = ''
	# 	self.absent = ''
	# 	self.absentMother = ''
	# 	self.absentFather = ''
	# 	self.mother = 0
	# 	self.father = 0
	# 	self.snv = ''
	# 	self.indel = ''
	# 	self.pedigree = ''
	# 	self.output = ''
	# 	self.num_affected = ''
	# 	self.idOffset = 0; #do computations on id's which are not first
	# 	self.filein = None;
	# 	self.fileout = None; 
	
	def __init__(self, proband_index = None, num_affected = None, absent = None, snv = None, indel = None, pedigree = None, output = None):
		self.proband = proband_index
		self.num_affected = num_affected
		self.absent = absent
		self.snv = snv
		self.indel = indel
		self.pedigree = pedigree
		self.output = output
		self.mother = 0
		self.father = 0
		self.parent_num = 0                                                       
		self.absentMother = ''
		self.absentFather = ''
		self.idOffset = None
		self.filein = None
		self.fileout = None
		self.false_array = [False for skipped in range(self.proband)]             
		#build gene dict
		self.geneHash = {}
			
		#could be better.generalize to input file. outputfile has name snv or indel.
		if self.snv != None:
			print('filein is snv')
			self.filein = open(self.snv, 'r')
		elif self.indel != None:
			self.filein = open(self.indel, 'r')
		else:
			pass
			# logging.error('no input files are given')
			# print('no input files were given')
			# sys.exit(2)
		#filein = open('June_2015_snv_exonic.hg19_multianno.txt', 'r')
	
		#hard-coded for now. we can determine proband offset based on this. should be a param
		#indexin = open('June_2015.list', 'rb')
 
		if self.fileout != None:
			self.fileout = open(output, 'w')
			logging.info('computePedigree(filein, fileout): ' + str(self.filein) + ' , ' + str(self.fileout))
			print('computePedigree(filein, fileout): ' + str(self.filein) + ' , ' + str(self.fileout))
	
	def close(self):	
		self.filein.close()
		self.fileout.close()
		#self.indexin.close()

	#father, mother indices are set in relation to proband
	def computeParents(self):
		self.parseAbsentParents()
		print('computeParents():' )
		if not self.absentFather:
			self.father = self.proband + int(self.num_affected)
			self.parent_num += 1                                                  
		if not self.absentMother:
			if not self.absentFather:
				self.mother = self.proband + int(self.num_affected) + 1
			else:
				self.mother = self.proband + int(self.num_affected)
			self.parent_num += 1                                                  
		print('\tproband: ' + str(self.proband))
		print('\tfather: ' + str(self.father))
		print('\tmother: ' + str(self.mother))

		#added for testing
		return [self.father, self.mother]
	 
	#parse absent parents.
	def parseAbsentParents(self):
		print('parseAbsentParents(): ')
		self.absentFather = re.search('F', self.absent) != None
		self.absentMother = re.search('M', self.absent) != None
		print('\tabsentMother: ' + str(self.absentMother))
		print('\tabsentFather: ' + str(self.absentFather))

		#added for testing
		return [self.absentFather, self.absentMother]
	
	#returns an array of [True, False, False, True, etc]
	#could be used to hard filter out exonic vs non-
	def mapReturn(self,searchStr,line):
		print('mapReturn(searchStr, line):')
		print('\tsearchStr: ' + searchStr + ' line: ' + line)
		v = map(lambda x: re.search(searchStr, x) != None, line.split('\t')[self.proband:(self.proband + self.num_affected + self.parent_num)])       
		#v = map(lambda x: re.search(searchStr, x) != None, line.split('\t')[self.proband:])       
		print('v: ' + str(self.false_array + v))                                                  
	#	variant = map(lambda x: x != None, v)
	#	print('variant: ' + str(variant))
		return self.false_array + v                                                               
	
	#detects the proband offset for the current line.
	#could use a general method, compute all offsets.
	# def probandOffset(self, line, offset = None):
	# 	if offset != None:
	# 		self.idOffset = offset

	# 	print('probandOffset:')
	# 	arrIndex = self.mapReturn('GT:AD:DP:GQ:PL', line)
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
		homo = self.mapReturn('1/1', line)
		hetero = self.mapReturn('0/1', line)
		absent = self.mapReturn('0/0', line)
		#return {"homozygous": homo, "heterozygous": hetero, "absent": absent}          
		return (homo, hetero, absent)
	
	def computeAR(self, line):
		triplet = self.computeVCFLine(line)
		#variant, inherited = triplet["homozygous"], triplet["heterozygous"]            
		variant, inherited = triplet[0], triplet[1]

		#call perl for CH aspect...
		
		return self.isProbands(variant) and (self.isFather(inherited) and self.isMother(inherited))

		# return (variant[self.proband] and\
		# (not self.absentMother and inherited[self.mother]) and\
		# (not self.absentFather and inherited[self.father])) #definition of homozygous recessive

	def computeAD(self, line):
		triplet = self.computeVCFLine(line)
		variant, inherited, notPresent = triplet[1], triplet[1], triplet[2]

		#return self.isProbands(variant) and (self.isFather(inherited) != self.isMother(inherited))
		if self.absentFather and self.absentMother:
			return self.isProbands(variant)
		else:
			return self.isProbands(variant) and ((self.isFather(inherited) != self.absentFather) != (self.isMother(inherited) != self.absentMother))
		
		# return ((variant[self.proband] and\
		# ((not self.absentFather and inherited[self.father])  or self.absentFather) and\
		# ((not self.absentMother and notPresent[self.mother])  or self.absentMother)) or\
		# (variant[self.proband] and ((not self.absentMother and\
		# inherited[self.mother])  or self.absentMother) and ((not self.absentFather and notPresent[self.father])  or self.absentFather)))
	
	def computeDN(self, line):
		triplet = self.computeVCFLine(line)
		variant, inherited, notPresent = triplet[1], triplet[1], triplet[2]
		
		return self.isProbands(variant) and (self.isFather(notPresent) and self.isMother(notPresent))

		# return (variant[self.proband] and ((not self.absentFather and notPresent[self.father]) or self.absentFather) and\
		# (not self.absentMother and notPresent[self.mother] or self.absentMother))
	
	def computeXL(self, line):
		#xChrom = self.mapReturn('X', line)             
		#if xChrom[0]: #X chromosome                    
		if re.search("X", line[:1]) != None:            
			triplet = self.computeVCFLine(line)
			variant, inherited , notPresent = triplet[1], triplet[1], triplet[2]

			return self.isProbands(variant) and (self.isFather(notPresent) and self.isMother(inherited))

			# return (variant[self.proband] and\
			# (not self.absentMother and variant[self.mother]) and\
			# (not self.absentFather and notPresent[self.father]))
	
#could potentially makes this more of a "standalone" method
	#in that case probandOffset, offsets are needed
	def computePedigree(self, filein=None, fileout=None):
#		self.__computePedigree(self.filein, self.fileout)
		if filein != None:
			self.filein = filein
		if fileout != None:
			self.fileout = fileout	
		
		print('computePedigree(filein, fileout)')
		print('\tpedigree: ' + self.pedigree)
		self.computeParents()
		if self.pedigree == 'AR':
			for line in self.filein:
				if self.computeAR(line):
					self.fileout.write(line)
		elif self.pedigree == 'AD':
			for line in self.filein:
				if self.computeAD(line):
					self.fileout.write(line)
		elif self.pedigree == 'DN':
			for line in self.filein:
				if self.computeDN(line):
					self.fileout.write(line)
		elif pedigree == 'XL':
			for line in self.filein:
				if self.computeXL(line):
					self.fileout.write(line)
	
	def buildGeneHash(self, filein = None):
		if filein != None:
			self.filein = open(filein, 'r')

		for line in self.filein:
			l = line.split();
			if l[6] in self.geneHash:
				self.geneHash[l[6]][l[1]] = line
			else:
				variant = {}
				variant[l[1]] = line
				self.geneHash[l[6]] = variant

	def printGeneHash(self):
		for gene in self.geneHash:
			print len(self.geneHash[gene])
			for var in self.geneHash[gene]:
				print self.geneHash[gene][var]

	#still in progress
	def computeCompoundHet(self):
		outfile = open('CH_out_1-1_strict_attempt2.txt', 'w')
		compHet = {}

		for gene in self.geneHash:
			if len(self.geneHash[gene]) >= 2:
				prevVariant = None;
				for v in self.geneHash[gene]:
					variantLine = self.geneHash[gene][v]
					proband = self.probandOffset(variantLine, 11) #super hard-coded for now
					
					#the following makes the next if statement go out of bounds. but is a good idea.
					#variant = self.mapReturn('0/1', variantLine[self.probandOffset(variantLine):])
					one_one = self.mapReturn('1/1', variantLine)
					zero_one = self.mapReturn('0/1', variantLine)
					
					#variant = self.mapReturn('1/1', variantLine)
					#todo: make this better
					if (one_one[proband] and one_one[proband-3] and one_one[proband-4]): #the proband has this. add to compHet
						if gene in compHet:
							compHet[gene][v] = variantLine
						else:
							variantHash = {}
							variantHash[v] = variantLine
							compHet[gene] = variantHash

		for gene in compHet:
			for var in compHet[gene]:
				if len(compHet[gene]) >= 2:
					print compHet[gene][var]
					outfile.write(compHet[gene][var])

		outfile.close()

	def filter(self, freq, file=None):
		pass

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
	indel = ''
	snv = ''
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
			print('pedigree: ' + pedigree)
		elif opt in ('--ABSENT', '-A'):
			absent = arg #new argument. 
		#	parseAbsentParent() #do it right away
		elif opt in ('--OUTPUT', '-O'):
			output = arg
	#will be indel or snv
	logging.info('Done capturing params')
	print('Done capturing params')
 
	x = vcf(proband, num_affected, absent, snv, indel, pedigree, output)
	#x.buildGeneHash()
	
	x.computePedigree()
	x.close()
 
if __name__ == "__main__":
		main(sys.argv[1:])
#Y	16952665	16952665	C	T	exonic	NLGN4Y	synonymous SNV	NLGN4Y:NM_001206850:exon6:c.C1470T:p.P490P,NLGN4Y:NM_014893:exon6:c.C1974T:p.P658P	Score=528;Name=lod=187	NA	NA	NA	NA	NA	16952665	.	C	T	640.45	.	AC=4;AF=0.222;AN=18;BaseQRankSum=3.058;DP=909;Dels=0.00;FS=61.926;HaplotypeScore=2.2695;MLEAC=4;MLEAF=0.222;MQ=46.65;MQ0=1;MQRankSum=-5.036;QD=2.10;ReadPosRankSum=1.979	GT:AD:DP:GQ:PL0/1:155,18:173:99:141,0,3707	./.	1/1:0,14:14:42:462,42,0	0/0:159,0:159:99:0,391,4281	0/0:123,0:123:99:0,277,3182	0/1:107,11:118:89:89,0,2494	./.	0/0:99,0:99:99:0,249,2654	./.	0/0:105,0:105:99:0,250,2828	./.	0/0:117,0:117:99:0,286,3187	./.	0/0:1,0:1:3:0,3,28
