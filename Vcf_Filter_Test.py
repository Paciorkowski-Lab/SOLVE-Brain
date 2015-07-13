import unittest
from vcf import *

class Vcf_Filter_Test(unittest.TestCase):

	snv_file_QTB    = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/test_results/New_Analysis_May_2015_snv_exonic.hg19_multianno.txt"
	indel_file_QTB  = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/test_results/New_Analysis_May_2015_indel_exonic.hg19_multianno.txt"
	snv_file_June   = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/solve-brain-jf-master/June_2015_REORDERED_snv_exonic.hg19_multianno.txt"
	indel_file_June = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/solve-brain-jf-master/June_2015_REORDERED_indel_exonic.hg19_multianno.txt"
	map_return_all_ONE_ONE = "1\t877831\t877831\tT\tC\texonic\tSAMD11\tnonsynonymous SNV\tSAMD11:NM_152486:exon10:c.T1027C:p.W343R\tScore=559;Name=lod=249\tNA\trs6672356\tNA\tNA\tNA\t1\t877831\t.\tT\tC \t2813.08\t.\tAC=28;AF=1.00;AN=28;DP=100;Dels=0.00;FS=0.000;HaplotypeScore=0.0702;InbreedingCoeff=-0.0129;MLEAC=28;MLEAF=1.00;MQ=59.81;MQ0=0;QD=28.13\tGT:AD:DP:GQ:PL\t1/1:0,7:7:18:198,18,0\t1/1:0,11:11:33:349,33,0\t1/1:0,10:10:27:285,27,0\t1/1:0,5:5:15:147,15,0\t1/1:0,4:4:9:108,9,0\t1/1:0,7:7:15:185,15,0\t1/1:0,7:7:21:222,21,0\t1/1:0,5:5:15:154,15,0\t1/1:0,6:6:15:176,15,0\t1/1:0,8:8:15:177,15,0\t1/1:0,7:7:15:181,15,0\t1/1:0,7:7:18:202,18,0\t1/1:0,8:8:24:250,24,0\t1/1:0,8:8:18:203,18,0"
	#map_return_all_ONE_ONE_array = [False, False, False, False, False, False, False,]
	map_return_last_true = "1\t14677\t14677\tG\tA\tncRNA_exonic\tWASH7P\tNA\tNA\tNA\tScore=0.993729;Name=chr9:10843\trs112391680\tNA\tNA\tNA\t1\t14677\t.\tG\tA\t37.07\t.\tAC=1;AF=0.036;AN=28;BaseQRankSum=-2.595;DP=223;Dels=0.00;FS=9.234;HaplotypeScore=0.1426;InbreedingCoeff=-0.0646;MLEAC=1;MLEAF=0.036;MQ=24.12;MQ0=72;MQRankSum=-0.328;QD=1.61;ReadPosRankSum=0.546\tGT:AD:DP:GQ:PL\t0/0:11,0:11:12:0,12,158\t0/0:9,0:9:12:0,12,122\t0/0:16,0:16:9:0,9,134\t0/0:5,0:5:3:0,3,45\t0/0:22,0:22:27:0,27,327\t0/0:19,0:19:21:0,21,229\t0/0:11,0:11:12:0,12,159\t0/0:19,0:19:30:0,30,340\t0/0:18,0:18:21:0,21,211\t0/0:11,0:11:15:0,15,175\t0/0:28,1:29:20:0,20,416\t0/0:17,0:17:33:0,33,351\t0/0:13,0:13:18:0,18,188\t0/1:18,5:23:72:72,0,317"
	proband_index_QTB  = [24, 27, 30, 33, 36, 39, 42]
	proband_index_June = [24, 28, 31, 35, 36]
	parent_index_June  = [[26, 27], [29, 30], [33, 34], [0, 0] ,[0, 37]]
	number_affected_QTB = [1, 1, 1, 1, 1, 1, 1]
	number_affected_June = [2, 1, 2, 1, 1]
	absent_June = ["", "", "", "MF", "F"]
	no_absent = ""
	mom_absent = "M"
	dad_absent = "F"
	both_absent = "MF"
	pedigree = ["DN", "AR", "XL"]

	def setUp(self):
		pass

	#Test parent parsing
	def test_parse_parents_no_absent(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.no_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
		self.assertEqual(vcf_test.parseAbsentParents(), [False, False], "Parents were not recognized as absent.")

	def test_parse_parents_no_mother(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.mom_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
		self.assertEqual(vcf_test.parseAbsentParents(), [False, True], "Mother was not recognized as absent and/or father was not recognized as present.")

	def test_parse_parents_no_father(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.dad_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
		self.assertEqual(vcf_test.parseAbsentParents(), [True, False], "Father was not recognized as absent and/or mother was not recognized as present.")

	def test_parse_parents_both_absent(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.both_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
		self.assertEqual(vcf_test.parseAbsentParents(), [True, True], "Parents were not recognized as both being absent")

	#Test parent computation
	def test_compute_parents_no_absent(self):
		for index in range(0, len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.no_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [self.proband_index_QTB[index] + self.number_affected_QTB[index], self.proband_index_QTB[index] + self.number_affected_QTB[index] + 1])

	def test_compute_parents_no_mother(self):
		for index in range(0, len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.mom_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [self.proband_index_QTB[index] + self.number_affected_QTB[index], 0])

	def test_compute_parents_no_father(self):
		for index in range(0, len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.dad_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [0, self.proband_index_QTB[index] + self.number_affected_QTB[index]])

	def test_compute_parents_both_absent(self):
		for index in range(0, len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.both_absent, self.snv_file_QTB, self.indel_file_QTB, self.pedigree[0])
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [0, 0])

	def test_compute_parents_june_cohort(self):
		for index in range(0, len(self.proband_index_June)):
			vcf_test = vcf(self.proband_index_June[index], self.number_affected_June[index], self.absent_June[index], self.snv_file_June, self.indel_file_June, self.pedigree[0])
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), self.parent_index_June[index], "Parent indecies not computed correctly for June cohort")

	def test_map_return_array_length(self):
		index = 0
		vcf_test = vcf(self.proband_index_June[index], self.number_affected_June[index], self.absent_June[index], self.snv_file_June, self.indel_file_June, self.pedigree[0])
		self.assertEqual(len(vcf_test.mapReturn("0/0", self.map_return_all_ONE_ONE)), 38)

	def test_map_return_all_false(self):
		index = 0
		vcf_test = vcf(self.proband_index_June[index], self.number_affected_June[index], self.absent_June[index], self.snv_file_June, self.indel_file_June, self.pedigree[0])
		self.assertFalse(all(vcf_test.mapReturn("0/0", self.map_return_all_ONE_ONE)), "Map Return thought a 0/0 existed when it did not")

	def test_map_return_all_true(self):
		index = 0
		vcf_test = vcf(self.proband_index_June[index], self.number_affected_June[index], self.absent_June[index], self.snv_file_June, self.indel_file_June, self.pedigree[0])
		self.assertTrue(all(vcf_test.mapReturn("1/1", self.map_return_all_ONE_ONE)[24:]), "Map Return thought did not find all to be true searching for 1/1")

	def test_map_return_last_true_only(self):
		index = 0
		vcf_test = vcf(self.proband_index_June[index], self.number_affected_June[index], self.absent_June[index], self.snv_file_June, self.indel_file_June, self.pedigree[0])
		returned_array = vcf_test.mapReturn("0/1", self.map_return_last_true)
		self.assertFalse(all(returned_array[24:len(returned_array) - 1]), "Map Return find a 0/1 in a sea of all 0/0")
		self.assertTrue(returned_array[len(returned_array) - 1:][0], "Map Return did not find the last index to be 0/1")

if __name__ == '__main__':
	unittest.main()