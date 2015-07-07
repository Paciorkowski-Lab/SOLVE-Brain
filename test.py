#@imyjimmy
import re

id_offset = 0;

#could be used to hard filter out exonic vs non-
def mapReturn(searchStr,line):
	v = map(lambda x: re.search(searchStr, x), line.split())
	return map(lambda x: x != None, v)

#detects the proband offset for the current line.
def probandOffset(line):
	arrIndex = mapReturn('GT:AD:DP:GQ:PL', line)
	index = 0
	for i in arrIndex:
		index = 1+index
		if i:
			return index+id_offset #global--declares the offset from 1st proband correspondint to person of interest.
														#no need to reshuffle columns. make sure it reflects the person you need.
	#fail case
	return -1 

def computeAR(filein):
	for line in filein:
		proband = probandOffset(line)
		variant = mapReturn('1/1', line)
		inherited = mapReturn('0/1', line)
		
		#assume some global offsets
		if (variant[proband] and inherited[mother] and inherited[father]): #definition of recessive
			fileout.write(line)
			
def computeAD(filein):
	for line in filein:
		proband = probandOffset(line)
		variant = mapReturn('0/1', line)
		inherited = variant # this is a vanity.."nice" variable
		absent = mapReturn('0/0', line)
		if ((variant[proband] and inherited[father] and absent[mother]) or (variant[proband] and inherited[mother] and absent[father])):
			fileout.write(line)

def computeDN(filein):
	for line in filein:
		proband = probandOffset(line)
		variant = mapReturn('0/1', line)
		inherited = variant
		absent = mapReturn('0/0', line)
		if (variant[proband] and absent[father] and absent[mother]):
			fileout.write(line)

def main():
	#will be indel or snv
	filein = open('June_2015_snv_exonic.hg19_multianno.txt', 'r');
	indexin = open('June_2015.list', 'rb')

	for line in filein:
		index = probandOffset(line)
		variant = mapReturn('0/1', line)
		#print line
		#print str(index)	
		#print str(line.split()[index])
		#print variant	
	filein.close()
	indexin.close()

if __name__ == "__main__":
	main()
#Y	16952665	16952665	C	T	exonic	NLGN4Y	synonymous SNV	NLGN4Y:NM_001206850:exon6:c.C1470T:p.P490P,NLGN4Y:NM_014893:exon6:c.C1974T:p.P658P	Score=528;Name=lod=187	NA	NA	NA	NA	NA	16952665	.	C	T	640.45	.	AC=4;AF=0.222;AN=18;BaseQRankSum=3.058;DP=909;Dels=0.00;FS=61.926;HaplotypeScore=2.2695;MLEAC=4;MLEAF=0.222;MQ=46.65;MQ0=1;MQRankSum=-5.036;QD=2.10;ReadPosRankSum=1.979	GT:AD:DP:GQ:PL0/1:155,18:173:99:141,0,3707	./.	1/1:0,14:14:42:462,42,0	0/0:159,0:159:99:0,391,4281	0/0:123,0:123:99:0,277,3182	0/1:107,11:118:89:89,0,2494	./.	0/0:99,0:99:99:0,249,2654	./.	0/0:105,0:105:99:0,250,2828	./.	0/0:117,0:117:99:0,286,3187	./.	0/0:1,0:1:3:0,3,28
