import unittest, os
from vcf import *

class Vcf_Filter_Test(unittest.TestCase):

	snv_file_QTB    = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/test_results/New_Analysis_May_2015_snv_exonic.hg19_multianno.txt"
	indel_file_QTB  = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/test_results/New_Analysis_May_2015_indel_exonic.hg19_multianno.txt"
	snv_file_June   = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/solve-brain-jf-master/June_2015_REORDERED_snv_exonic.hg19_multianno.txt"
	indel_file_June = "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/solve-brain-jf-master/June_2015_REORDERED_indel_exonic.hg19_multianno.txt"
	ch_lines_to_test = "./compound_het_test_file_1.txt"
	map_return_all_ONE_ONE = "1\t877831\t877831\tT\tC\texonic\tSAMD11\tnonsynonymous SNV\tSAMD11:NM_152486:exon10:c.T1027C:p.W343R\tScore=559;Name=lod=249\tNA\trs6672356\tNA\tNA\tNA\t1\t877831\t.\tT\tC \t2813.08\t.\tAC=28;AF=1.00;AN=28;DP=100;Dels=0.00;FS=0.000;HaplotypeScore=0.0702;InbreedingCoeff=-0.0129;MLEAC=28;MLEAF=1.00;MQ=59.81;MQ0=0;QD=28.13\tGT:AD:DP:GQ:PL\t1/1:0,7:7:18:198,18,0\t1/1:0,11:11:33:349,33,0\t1/1:0,10:10:27:285,27,0\t1/1:0,5:5:15:147,15,0\t1/1:0,4:4:9:108,9,0\t1/1:0,7:7:15:185,15,0\t1/1:0,7:7:21:222,21,0\t1/1:0,5:5:15:154,15,0\t1/1:0,6:6:15:176,15,0\t1/1:0,8:8:15:177,15,0\t1/1:0,7:7:15:181,15,0\t1/1:0,7:7:18:202,18,0\t1/1:0,8:8:24:250,24,0\t1/1:0,8:8:18:203,18,0"
	map_return_last_true = "1\t14677\t14677\tG\tA\tncRNA_exonic\tWASH7P\tNA\tNA\tNA\tScore=0.993729;Name=chr9:10843\trs112391680\tNA\tNA\tNA\t1\t14677\t.\tG\tA\t37.07\t.\tAC=1;AF=0.036;AN=28;BaseQRankSum=-2.595;DP=223;Dels=0.00;FS=9.234;HaplotypeScore=0.1426;InbreedingCoeff=-0.0646;MLEAC=1;MLEAF=0.036;MQ=24.12;MQ0=72;MQRankSum=-0.328;QD=1.61;ReadPosRankSum=0.546\tGT:AD:DP:GQ:PL\t0/0:11,0:11:12:0,12,158\t0/0:9,0:9:12:0,12,122\t0/0:16,0:16:9:0,9,134\t0/0:5,0:5:3:0,3,45\t0/0:22,0:22:27:0,27,327\t0/0:19,0:19:21:0,21,229\t0/0:11,0:11:12:0,12,159\t0/0:19,0:19:30:0,30,340\t0/0:18,0:18:21:0,21,211\t0/0:11,0:11:15:0,15,175\t0/0:28,1:29:20:0,20,416\t0/0:17,0:17:33:0,33,351\t0/0:13,0:13:18:0,18,188\t0/1:18,5:23:72:72,0,317"
	vcf_line_all_three_cases = "1\t1684472\t1684472\tC\tT\texonic\tNADK\tsynonymous SNV\tNADK:NM_001198995:exon10:c.G1116A:p.P372P,NADK:NM_001198993:exon12:c.G1212A:p.P404P,NADK:NM_023018:exon12:c.G1212A:p.P404P,NADK:NM_001198994:exon14:c.G1647A:p.P549P\tNA\tNA\trs7407\tNA\tNA\tNA\t1\t1684472\t.\tC\tT\t13057.71\t.\tAC=11;AF=0.393;AN=28;BaseQRankSum=7.341;DP=1367;Dels=0.00;FS=1.785;HaplotypeScore=1.3316;InbreedingCoeff=-0.0481;MLEAC=11;MLEAF=0.393;MQ=59.19;MQ0=1;MQRankSum=-0.525;QD=14.54;ReadPosRankSum=0.489\tGT:AD:DP:GQ:PL\t1/1:0,114:114:99:2992,238,0\t0/0:106,0:106:99:0,250,2778\t0/1:60,59:119:99:1300,0,1363\t0/1:48,42:92:99:976,0,1056\t0/1:39,65:104:99:1560,0,776\t0/0:95,0:96:99:0,201,2409\t1/1:1,83:84:99:2204,180,0\t0/0:106,0:106:99:0,226,2701\t0/0:91,0:91:99:0,198,2322\t0/0:70,0:70:99:0,180,1934\t0/1:50,37:87:99:792,0,1144\t0/1:49,53:102:99:1211,0,1041\t0/1:61,48:109:99:1170,0,1300\t0/1:46,41:87:99:929,0,1000"
	#only for DB14-029
	vcf_line_with_DN = "1\t11894427\t11894427\tG\tA\texonic\tCLCN6\tnonsynonymous SNV\tCLCN6:NM_001256959:exon15:c.G1595A:p.G532E,CLCN6:NM_001286:exon16:c.G1661A:p.G554E\tScore=369;Name=lod=42\tNA\tNA\tName=yes\tNA\tNA\t1\t11894427\t.\tG\tA\t630.50\t.\tAC=1;AF=0.036;AN=28;BaseQRankSum=-0.102;DP=894;Dels=0.00;FS=0.000;HaplotypeScore=1.2653;InbreedingCoeff=-0.0370;MLEAC=1;MLEAF=0.036;MQ=59.57;MQ0=0;MQRankSum=1.571;QD=11.26;ReadPosRankSum=0.187\tGT:AD:DP:GQ:PL\t0/0:65,0:65:99:0,147,1837\t0/0:64,0:64:99:0,153,1849\t0/0:77,0:77:99:0,183,2195\t0/0:71,0:71:99:0,162,1974\t0/1:27,29:56:99:666,0,609\t0/0:67,0:67:99:0,156,1934\t0/0:61,0:61:99:0,141,1731\t0/0:70,0:70:99:0,156,1939\t0/0:53,0:53:99:0,126,1533\t0/0:76,0:77:99:0,171,2132\t0/0:62,0:62:99:0,147,1778\t0/0:55,0:55:99:0,135,1625\t0/0:57,0:57:99:0,138,1657\t0/0:59,0:59:99:0,150,1743"
	#DN for 029, AD for 004, 003, present in all of MP14-001
	vcf_line_with_DN_2 = "20\t29628328\t29628328\tC\tG\tncRNA_exonic\tFRG1B\tNA\tNA\tScore=608;Name=lod=393\tScore=0.964669;Name=chr9:68425906\tNA\tNA\tName=yes\tNA\t20\t29628328\t.\tC\tG\t1003.67\t.\tAC=9;AF=0.321;AN=28;BaseQRankSum=-4.664;DP=3500;Dels=0.00;FS=4.928;HaplotypeScore=51.4232;InbreedingCoeff=-0.4738;MLEAC=9;MLEAF=0.321;MQ=37.34;MQ0=332;MQRankSum=-11.805;QD=0.45;ReadPosRankSum=2.957\tGT:AD:DP:GQ:PL\t0/1:217,33:250:93:93,0,4499\t0/0:232,18:250:99:0,169,5302\t0/0:234,16:250:99:0,206,5037\t0/0:225,25:250:28:0,28,4437\t0/1:212,38:250:99:171,0,4184\t0/0:225,25:250:99:0,109,4768\t0/0:218,32:250:63:0,63,4968\t0/1:220,30:250:53:53,0,4749\t0/1:213,37:250:60:60,0,4192\t0/1:223,27:250:45:45,0,4658\t0/1:223,27:250:99:121,0,4839\t0/1:213,37:250:99:181,0,4545\t0/1:213,37:250:99:127,0,5071\t0/1:221,29:250:99:218,0,4399"
	#AD for DB14-001 (both siblings from dad), also AD for 029, not in sibling for MP14-001, DN in 004 and present in 003
	vcf_line_with_DN_3 = "1\t17029257\t17029257\tT\tC\tncRNA_exonic\tESPNP\tNA\tNA\tScore=474;Name=lod=113\tScore=0.952198;Name=chr1:6487720\trs12125112\tNA\tNA\tNA\t1\t17029257\t.\tT\tC\t3028.67\t.\tAC=9;AF=0.321;AN=28;BaseQRankSum=10.941;DP=675;Dels=0.00;FS=4.191;HaplotypeScore=0.9870;InbreedingCoeff=-0.4739;MLEAC=9;MLEAF=0.321;MQ=57.95;MQ0=1;MQRankSum=2.043;QD=7.16;ReadPosRankSum=0.686\tGT:AD:DP:GQ:PL\t0/1:51,12:63:99:176,0,1388\t0/1:51,10:61:99:150,0,1382\t0/1:28,17:45:99:435,0,690\t0/0:46,3:50:25:0,25,1312\t0/1:52,10:62:99:109,0,1371\t0/1:17,31:48:99:741,0,442\t0/0:53,0:53:99:0,123,1502\t0/1:14,16:30:99:431,0,363\t0/0:64,0:65:99:0,162,1949\t0/0:48,0:48:99:0,135,1558\t0/1:26,19:45:99:454,0,640\t0/1:24,17:41:99:401,0,585\t0/1:19,9:28:99:197,0,527\t0/0:36,0:36:93:0,93,1086"
	#DN for DB14-001, AD for 029, not in sibling for MP14-001, DN in 004 and present in 003
	vcf_line_with_DN_4 = "1\t17029257\t17029257\tT\tC\tncRNA_exonic\tESPNP\tNA\tNA\tScore=474;Name=lod=113\tScore=0.952198;Name=chr1:6487720\trs12125112\tNA\tNA\tNA\t1\t17029257\t.\tT\tC\t3028.67\t.\tAC=9;AF=0.321;AN=28;BaseQRankSum=10.941;DP=675;Dels=0.00;FS=4.191;HaplotypeScore=0.9870;InbreedingCoeff=-0.4739;MLEAC=9;MLEAF=0.321;MQ=57.95;MQ0=1;MQRankSum=2.043;QD=7.16;ReadPosRankSum=0.686\tGT:AD:DP:GQ:PL\t0/1:51,12:63:99:176,0,1388\t0/1:51,10:61:99:150,0,1382\t0/0:28,17:45:99:435,0,690\t0/0:46,3:50:25:0,25,1312\t0/1:52,10:62:99:109,0,1371\t0/1:17,31:48:99:741,0,442\t0/0:53,0:53:99:0,123,1502\t0/1:14,16:30:99:431,0,363\t0/0:64,0:65:99:0,162,1949\t0/0:48,0:48:99:0,135,1558\t0/1:26,19:45:99:454,0,640\t0/1:24,17:41:99:401,0,585\t0/1:19,9:28:99:197,0,527\t0/0:36,0:36:93:0,93,1086"
	vcf_line_not_X_chromo = "1\t11894427\t11894427\tG\tA\texonic\tCLCN6\tnonsynonymous SNV\tCLCN6:NM_001256959:exon15:c.G1595A:p.G532E,CLCN6:NM_001286:exon16:c.G1661A:p.G554E\tScore=369;Name=lod=42\tNA\tNA\tName=yes\tNA\tNA\t1\t11894427\t.\tG\tA\t630.50\t.\tAC=1;AF=0.036;AN=28;BaseQRankSum=-0.102;DP=894;Dels=0.00;FS=0.000;HaplotypeScore=1.2653;InbreedingCoeff=-0.0370;MLEAC=1;MLEAF=0.036;MQ=59.57;MQ0=0;MQRankSum=1.571;QD=11.26;ReadPosRankSum=0.187\tGT:AD:DP:GQ:PL\t0/0:65,0:65:99:0,147,1837\t0/0:64,0:64:99:0,153,1849\t0/0:77,0:77:99:0,183,2195\t0/0:71,0:71:99:0,162,1974\t0/1:27,29:56:99:666,0,609\t0/0:67,0:67:99:0,156,1934\t0/1:61,0:61:99:0,141,1731\t0/0:70,0:70:99:0,156,1939\t0/0:53,0:53:99:0,126,1533\t0/0:76,0:77:99:0,171,2132\t0/0:62,0:62:99:0,147,1778\t0/0:55,0:55:99:0,135,1625\t0/0:57,0:57:99:0,138,1657\t0/0:59,0:59:99:0,150,1743"
	#DB14-001 XL but sibling does not contain variant, 004's mom contains variant that 004 does not, DN for 029, XL for MP14-001, 003 not present
	vcf_line_with_XL = "X\t12725701\t12725701\tC\tG\texonic\tFRMPD4\tsynonymous SNV\tFRMPD4:NM_014728:exon13:c.C1401G:p.V467V\tScore=617;Name=lod=431\tNA\trs6641078\tNA\tNA\tNA\tX\t12725701\t.\tC\tG\t1610.84\t.\tAC=3;AF=0.107;AN=28;BaseQRankSum=-3.730;DP=384;Dels=0.00;FS=5.291;HaplotypeScore=0.4845;InbreedingCoeff=-0.1200;MLEAC=3;MLEAF=0.107;MQ=59.32;MQ0=1;MQRankSum=-0.152;QD=13.10;ReadPosRankSum=-0.116\tGT:AD:DP:GQ:PL\t0/1:17,24:41:99:613,0,442\t0/0:21,0:21:48:0,48,618\t0/0:25,0:25:66:0,66,812\t0/1:25,29:54:99:724,0,696\t0/1:22,0:22:54:0,54,676\t0/0:25,0:25:54:0,54,700\t0/0:32,0:32:78:0,78,981\t0/1:14,0:14:36:0,36,441\t0/1:23,0:23:60:0,60,732\t0/0:18,0:18:39:0,39,506\t0/1:32,0:32:75:0,75,946\t0/0:15,0:15:42:0,42,496\t0/0:34,0:34:87:0,87,1077\t0/1:15,13:28:99:324,0,398"
	#MP14-001 inherited from dad not mom, 003 present, XL for 004, DB14-001 siblings have DN, XL for 029
	vcf_line_with_XL_2 = "X\t12725701\t12725701\tC\tG\texonic\tFRMPD4\tsynonymous SNV\tFRMPD4:NM_014728:exon13:c.C1401G:p.V467V\tScore=617;Name=lod=431\tNA\trs6641078\tNA\tNA\tNA\tX\t12725701\t.\tC\tG\t1610.84\t.\tAC=3;AF=0.107;AN=28;BaseQRankSum=-3.730;DP=384;Dels=0.00;FS=5.291;HaplotypeScore=0.4845;InbreedingCoeff=-0.1200;MLEAC=3;MLEAF=0.107;MQ=59.32;MQ0=1;MQRankSum=-0.152;QD=13.10;ReadPosRankSum=-0.116\tGT:AD:DP:GQ:PL\t0/1:17,24:41:99:613,0,442\t0/1:21,0:21:48:0,48,618\t0/0:25,0:25:66:0,66,812\t0/0:25,29:54:99:724,0,696\t0/1:22,0:22:54:0,54,676\t0/0:25,0:25:54:0,54,700\t0/1:32,0:32:78:0,78,981\t0/1:14,0:14:36:0,36,441\t0/1:23,0:23:60:0,60,732\t0/1:18,0:18:39:0,39,506\t0/0:32,0:32:75:0,75,946\t0/1:15,0:15:42:0,42,496\t0/1:34,0:34:87:0,87,1077\t0/1:15,13:28:99:324,0,398"	
	#DB14-001 parents have 1/1, 029 is HM, MP14-001 sibling is not HM, 003 is HM, 004 is not HM because mother is 1/1
	vcf_line_with_AR_HM = "1\t877831\t877831\tT\tC\texonic\tSAMD11\tnonsynonymous SNV\tSAMD11:NM_152486:exon10:c.T1027C:p.W343R\tScore=559;Name=lod=249\tNA\trs6672356\tNA\tNA\tNA\t1\t877831\t.\tT\tC \t2813.08\t.\tAC=28;AF=1.00;AN=28;DP=100;Dels=0.00;FS=0.000;HaplotypeScore=0.0702;InbreedingCoeff=-0.0129;MLEAC=28;MLEAF=1.00;MQ=59.81;MQ0=0;QD=28.13\tGT:AD:DP:GQ:PL\t1/1:0,7:7:18:198,18,0\t1/1:0,11:11:33:349,33,0\t1/1:0,10:10:27:285,27,0\t1/1:0,5:5:15:147,15,0\t1/1:0,4:4:9:108,9,0\t0/1:0,7:7:15:185,15,0\t0/1:0,7:7:21:222,21,0\t1/1:0,5:5:15:154,15,0\t0/1:0,6:6:15:176,15,0\t0/1:0,8:8:15:177,15,0\t0/1:0,7:7:15:181,15,0\t1/1:0,7:7:18:202,18,0\t1/1:0,8:8:24:250,24,0\t1/1:0,8:8:18:203,18,0"
	#DB14-001 is HM with sibling, 029 is only 0/1, 003 is only 0/1 and 004 is HM
	vcf_line_with_AR_HM_2 = "1\t877831\t877831\tT\tC\texonic\tSAMD11\tnonsynonymous SNV\tSAMD11:NM_152486:exon10:c.T1027C:p.W343R\tScore=559;Name=lod=249\tNA\trs6672356\tNA\tNA\tNA\t1\t877831\t.\tT\tC \t2813.08\t.\tAC=28;AF=1.00;AN=28;DP=100;Dels=0.00;FS=0.000;HaplotypeScore=0.0702;InbreedingCoeff=-0.0129;MLEAC=28;MLEAF=1.00;MQ=59.81;MQ0=0;QD=28.13\tGT:AD:DP:GQ:PL\t1/1:0,7:7:18:198,18,0\t1/1:0,11:11:33:349,33,0\t0/1:0,10:10:27:285,27,0\t0/1:0,5:5:15:147,15,0\t0/1:0,4:4:9:108,9,0\t0/1:0,7:7:15:185,15,0\t0/1:0,7:7:21:222,21,0\t1/1:0,5:5:15:154,15,0\t0/1:0,6:6:15:176,15,0\t0/1:0,8:8:15:177,15,0\t0/1:0,7:7:15:181,15,0\t0/1:0,7:7:18:202,18,0\t1/1:0,8:8:24:250,24,0\t0/1:0,8:8:18:203,18,0"
	proband_index_QTB  = [24, 27, 30, 33, 36, 39, 42]
	proband_index_June = [24, 28, 31, 35, 36]
	June_Cohort = {
		"DB14-001": {
						"index": 24,
						"parents": [26,27],
						"num_affected": 2,
						"absent": ""
					},
		"DB14-029": {
						"index": 28,
						"parents": [29,30],
						"num_affected": 1,
						"absent": ""
					},
		"MP14-001": {
						"index": 31,
						"parents": [33,34],
						"num_affected": 2,
						"absent": ""
					},
		"MP14-003": {
						"index": 35,
						"parents": [0,0],
						"num_affected": 1,
						"absent": "MF"
					},
		"MP14-004": {
						"index": 36,
						"parents": [0,37],
						"num_affected": 1,
						"absent": "F"
					}
	}
	parent_index_June  = [[26, 27], [29, 30], [33, 34], [0, 0] ,[0, 37]]
	number_affected_QTB = [1, 1, 1, 1, 1, 1, 1]
	number_affected_June = [2, 1, 2, 1, 1]
	absent_June = ["", "", "", "MF", "F"]
	no_absent = ""
	mom_absent = "M"
	dad_absent = "F"
	both_absent = "MF"
	pedigree = ["DN", "AR", "AD", "XL"]
	#to test all people in cohort (need to compute parents for last two to register)
	entire_cohort = 12

	def person_generator(self, person):
		new_person = vcf(self.June_Cohort[person]["index"], self.June_Cohort[person]["num_affected"], self.June_Cohort[person]["absent"], self.snv_file_June, self.indel_file_June, self.pedigree[0], "/home/alex/Documents/Frankie_Analysis/SOLVE_BRAIN_TEST/")
		new_person.computeParents()
		return new_person

	#Test parent parsing
	def test_parse_parents_no_absent(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.no_absent)
		self.assertEqual(vcf_test.parseAbsentParents(), [False, False], "Parents were not recognized as absent.")

	def test_parse_parents_no_mother(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.mom_absent)
		self.assertEqual(vcf_test.parseAbsentParents(), [False, True], "Mother was not recognized as absent and/or father was not recognized as present.")

	def test_parse_parents_no_father(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.dad_absent)
		self.assertEqual(vcf_test.parseAbsentParents(), [True, False], "Father was not recognized as absent and/or mother was not recognized as present.")

	def test_parse_parents_both_absent(self):
		vcf_test = vcf(self.proband_index_QTB[0], self.number_affected_QTB[0], self.both_absent)
		self.assertEqual(vcf_test.parseAbsentParents(), [True, True], "Parents were not recognized as both being absent")

	#Test parent computation
	def test_compute_parents_no_absent(self):
		for index in range(len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.no_absent)
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [self.proband_index_QTB[index] + self.number_affected_QTB[index], self.proband_index_QTB[index] + self.number_affected_QTB[index] + 1])

	def test_compute_parents_no_mother(self):
		for index in range(len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.mom_absent)
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [self.proband_index_QTB[index] + self.number_affected_QTB[index], 0])

	def test_compute_parents_no_father(self):
		for index in range(len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.dad_absent)
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [0, self.proband_index_QTB[index] + self.number_affected_QTB[index]])

	def test_compute_parents_both_absent(self):
		for index in range(len(self.proband_index_QTB)):
			vcf_test = vcf(self.proband_index_QTB[index], self.number_affected_QTB[index], self.both_absent)
			vcf_test.parseAbsentParents()
			self.assertEqual(vcf_test.computeParents(), [0, 0])

	def test_compute_parents_june_cohort(self):
		for proband in self.June_Cohort:
			vcf_test = vcf(self.June_Cohort[proband]["index"], self.June_Cohort[proband]["num_affected"], self.June_Cohort[proband]["absent"])
			self.assertEqual(vcf_test.computeParents(), self.June_Cohort[proband]["parents"], "Parent indecies not computed correctly for June cohort")

	#Map return tests
	def test_map_return_array_length(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		self.assertEqual(len(vcf_test.mapSearch("0/0", self.map_return_all_ONE_ONE.split('\t'))), 38)

	def test_map_return_all_false(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		self.assertFalse(all(vcf_test.mapSearch("0/0", self.map_return_all_ONE_ONE.split('\t'))), "Map Return thought a 0/0 existed when it did not")

	def test_map_return_all_true(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		self.assertTrue(all(vcf_test.mapSearch("1/1", self.map_return_all_ONE_ONE.split('\t'))[24:]), "Map Return thought did not find all to be true searching for 1/1")

	def test_map_return_last_true_only(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		returned_array = vcf_test.mapSearch("0/1", self.map_return_last_true.split('\t'))
		self.assertFalse(all(returned_array[24:len(returned_array) - 1]), "Map Return find a 0/1 in a sea of all 0/0")
		self.assertTrue(returned_array[len(returned_array) - 1:][0], "Map Return did not find the last index to be 0/1")

	#Compute VCF line tests (extension of map return tests, more complex)
	def test_vcf_line_computation_homo(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		returned_array = vcf_test.computeVCFLine(self.vcf_line_all_three_cases)['homo']
		self.assertTrue(all([returned_array[24], returned_array[30]]), "Compute VCF lines did not find the homozygous(1/1) cases correctly")

	def test_vcf_line_computation_hetero(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		returned_array = vcf_test.computeVCFLine(self.vcf_line_all_three_cases)['hetero']
		self.assertTrue(all([returned_array[26], returned_array[27], returned_array[28], returned_array[34], returned_array[35], returned_array[36], returned_array[37]]), "Compute VCF lines did not find the absent(0/0) cases correctly")

	def test_vcf_line_computation_absent(self):
		vcf_test = vcf(self.June_Cohort["DB14-001"]["index"], self.entire_cohort, self.June_Cohort["DB14-001"]["absent"])
		vcf_test.computeParents()
		returned_array = vcf_test.computeVCFLine(self.vcf_line_all_three_cases)['absent']
		self.assertTrue(all([returned_array[25], returned_array[29], returned_array[31], returned_array[32], returned_array[33]]), "Compute VCF lines did not find the heterozygous(0/1) cases correctly")

	#ComputeDN testing, trying all cases
	def test_compute_DN_false_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		self.assertFalse(vcf_test.computeDN(self.vcf_line_with_DN_3), "Compute DN thought first proband had a DN variant. (actually the second proband does)")

	def test_compute_DN_true_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertTrue(vcf_test.computeDN(self.vcf_line_with_DN_2), "Compute DN did not find the second proband to have a DN variant")

	def test_compute_DN_false_multiAffected_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		self.assertFalse(vcf_test.computeDN(self.vcf_line_with_DN_2), "Compute DN thought first proband had a DN variant. (but sibling does not contain variant)")

	def test_compute_DN_true_multiAffected_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		self.assertTrue(vcf_test.computeDN(self.vcf_line_with_DN_4), "Compute DN thought siblings did not both have DN variant")

	def test_compute_DN_false_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertFalse(vcf_test.computeDN(self.vcf_line_with_DN), "Compute DN did not recognize that proband has no variant")

	def test_compute_DN_true_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertTrue(vcf_test.computeDN(self.vcf_line_with_DN_2), "Compute DN did not recognize that proband has 'DN' mutation without parents")

	def test_compute_DN_false_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertFalse(vcf_test.computeDN(self.vcf_line_with_DN_2), "Compute DN did not recognize that probands mother also has variant")

	def test_compute_DN_true_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertTrue(vcf_test.computeDN(self.vcf_line_with_DN_3), "Compute DN did not recognize that probands mother does not have variant")

	#ComputeAD testing
	def test_compute_AD_false_DN_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertFalse(vcf_test.computeAD(self.vcf_line_with_DN_2), "This is actually DN but compute AD came back true")

	def test_compute_AD_true_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertTrue(vcf_test.computeAD(self.vcf_line_with_DN_3), "Compute AD did not see variant as AD when it should (one affected, two parents")

	def test_compute_AD_false_multiAffected_both_parents(self):
		vcf_test = self.person_generator("MP14-001")
		self.assertFalse(vcf_test.computeAD(self.vcf_line_with_DN_2), "The variant is in both parents not one the way AD should be")
		self.assertFalse(vcf_test.computeAD(self.vcf_line_with_DN_4), "The variant is not in the affected sibling")

	def test_compute_AD_true_multiAffected_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		self.assertTrue(vcf_test.computeAD(self.vcf_line_with_DN_3), "Compute AD did not recognize that both affecteds inherited variant from father")

	def test_compute_AD_false_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertFalse(vcf_test.computeAD(self.vcf_line_with_DN), "Compute AD did not recognize that proband has no variant")

	def test_compute_AD_true_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertTrue(vcf_test.computeAD(self.vcf_line_with_DN_3), "Compute AD did not recognize that proband has variant without parents")

	def test_compute_AD_false_DN_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertFalse(vcf_test.computeAD(self.vcf_line_with_DN_3), "Compute AD thought a DN variant was actually AD")

	def test_compute_AD_true_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertTrue(vcf_test.computeAD(self.vcf_line_with_DN_2), "Compute AD did not find variant to be inherited from mother")

	#ComputeXL testing
	def test_compute_XL_not_X_chromo(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertFalse(vcf_test.computeXL(self.vcf_line_not_X_chromo), "Compute XL thought this was the X chromosome (actually 20)")

	def test_compute_XL_false_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertFalse(vcf_test.computeXL(self.vcf_line_with_XL), "Compute XL thought a DN variant was XL")		

	def test_compute_XL_true_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertTrue(vcf_test.computeXL(self.vcf_line_with_XL_2), "Compute XL did not recognize an XL variant")

	def test_compute_XL_false_multiAffected_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		self.assertFalse(vcf_test.computeXL(self.vcf_line_with_XL), "Compute XL did not realize sibling is missing variant")

	def test_compute_XL_false_multiAffected_inherited_from_dad(self):
		vcf_test = self.person_generator("MP14-001")
		self.assertFalse(vcf_test.computeXL(self.vcf_line_with_XL_2), "Compute XL did not realize inheritance was from father")

	def test_compute_XL_true_multiAffected_both_parents(self):
		vcf_test = self.person_generator("MP14-001")
		self.assertTrue(vcf_test.computeXL(self.vcf_line_with_XL), "Compute XL did not work for two sibilings")

	def test_compute_XL_false_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertFalse(vcf_test.computeXL(self.vcf_line_with_XL), "Compute XL did not recognize that proband has no variant")

	def test_compute_XL_true_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertTrue(vcf_test.computeXL(self.vcf_line_with_XL_2), "Compute XL did not recognize that proband has variant")

	def test_compute_XL_false_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertFalse(vcf_test.computeXL(self.vcf_line_with_XL), "Compute XL did not recognize that probands mom has variant variant only")

	def test_compute_XL_true_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertTrue(vcf_test.computeXL(self.vcf_line_with_XL_2), "Compute XL did not recognize that proband has variant from mother")

	def test_compute_XL_false_one_parent_inherited_from_dad(self):
		vcf_test = vcf(self.June_Cohort["MP14-004"]["index"], self.June_Cohort["MP14-004"]["num_affected"], self.mom_absent)
		vcf_test.computeParents()
		self.assertFalse(vcf_test.computeXL(self.vcf_line_with_XL_2), "Compute XL did not recognize that proband has variant from father")

	# ComputeAR testing, homozygous cases...
	def test_compute_AR_HM_false_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertFalse(vcf_test.computeAR(self.vcf_line_with_AR_HM_2), "This found a 0/1 variant to be HM...")

	def test_compute_AR_HM_true_both_parents(self):
		vcf_test = self.person_generator("DB14-029")
		self.assertTrue(vcf_test.computeAR(self.vcf_line_with_AR_HM), "This did not find a single affected child to be AR-HM")

	def test_compute_AR_HM_false_multiAffected_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		vcf_test_2 = self.person_generator("MP14-001")
		self.assertFalse(vcf_test.computeAR(self.vcf_line_with_AR_HM), "Did not realize parents are both 1/1 as well")
		self.assertFalse(vcf_test_2.computeAR(self.vcf_line_with_AR_HM), "Did not realize that sibling does not possess 1/1 as well")

	def test_compute_AR_HM_true_multiAffected_both_parents(self):
		vcf_test = self.person_generator("DB14-001")
		self.assertTrue(vcf_test.computeAR(self.vcf_line_with_AR_HM_2), "Did not find both sibling to have 1/1 inherited from parents")

	def test_compute_AR_HM_false_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertFalse(vcf_test.computeAR(self.vcf_line_with_AR_HM_2), "Did not realize proband is only heterozygous")

	def test_compute_AR_HM_true_no_parents(self):
		vcf_test = self.person_generator("MP14-003")
		self.assertTrue(vcf_test.computeAR(self.vcf_line_with_AR_HM), "Did not find proband to be 1/1 without any parents")

	def test_compute_AR_HM_false_DN_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertFalse(vcf_test.computeAR(self.vcf_line_with_AR_HM), "Probands sinlge parent is also 1/1")

	def test_compute_AR_HM_true_one_parent(self):
		vcf_test = self.person_generator("MP14-004")
		self.assertTrue(vcf_test.computeAR(self.vcf_line_with_AR_HM_2), "Proband and single parent fit for HM")

	# Build gene hash, quick test
	def test_build_gene_hash(self):
		vcf_test = self.person_generator("DB14-001")
		returned_gene_hash = vcf_test.buildGeneHash(self.ch_lines_to_test)
		self.assertEqual(len(returned_gene_hash['RNF223']), 1)
		self.assertEqual(len(returned_gene_hash['TTLL10']), 7)
		self.assertEqual(len(returned_gene_hash['SCNN1D']), 4)

	# Helper method for compound het testing...
	def file_len(self, fname):
	    with open(fname) as f:
	    	i = 0
	        for i, l in enumerate(f):
	            pass
	    if i == 0:
	    	return i
	    else:
	    	return i + 1

	# Some testing for compound het inheritance

	output = input("Please enter a temporary output location: ")

	def test_manual_compound_het_test_db14_001(self):
		# print("\nDB14-001")
		vcf_test = self.person_generator("DB14-001")
		vcf_test.computeCompoundHet(self.ch_lines_to_test, self.output + "DB14-001_test")
		file_length = self.file_len(self.output + "DB14-001_test_CH.vcf")
		os.remove(self.output + "DB14-001_test_CH.vcf")
		self.assertEqual(file_length, 0, "DB14-001 was found to have compound het variants and should not have")

	def test_manual_compound_het_test_mp14_001(self):
		# print("\nMP14-001")
		vcf_test = self.person_generator("MP14-001")
		vcf_test.computeCompoundHet(self.ch_lines_to_test, self.output + "MP14-001_test")
		file_length = self.file_len(self.output + "MP14-001_test_CH.vcf")
		os.remove(self.output + "MP14-001_test_CH.vcf")
		self.assertEqual(file_length, 2, "MP14-001 was found to have more/less than 2 compound het variants and should not have")

	def test_manual_compound_het_test_db14_029(self):
		# print("\nDB14-029")
		vcf_test = self.person_generator("DB14-029")
		vcf_test.computeCompoundHet(self.ch_lines_to_test, self.output + "DB14-029_test")
		file_length = self.file_len(self.output + "DB14-029_test_CH.vcf")
		os.remove(self.output + "DB14-029_test_CH.vcf")
		self.assertEqual(file_length, 3, "MDB14-029 was found to have more/less than 3 compound het variants and should not have")


if __name__ == '__main__':
	unittest.main()