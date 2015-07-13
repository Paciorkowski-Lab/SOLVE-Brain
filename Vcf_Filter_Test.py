import unittest
from vcf import *

class Vcf_Filter_Test(unittest.TestCase):

	snv_file_QTB    = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/test_results/New_Analysis_May_2015_snv_exonic.hg19_multianno.txt"
	indel_file_QTB  = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/test_results/New_Analysis_May_2015_indel_exonic.hg19_multianno.txt"
	snv_file_June   = "/home/alex/Documents/Frankie_Analysis/solve-brain-jf-master/June_2015_REORDERED_snv_exonic.hg19_multianno.txt"
	indel_file_June = "/home/alex/Documents/Frankie_Analysis/solve-brain-jf-master/June_2015_REORDERED_indel_exonic.hg19_multianno.txt"
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



if __name__ == '__main__':
    unittest.main()