#!/usr/bin/python
#author: Frankie James
#date:   06/17/2015

import sys, getopt, re

def main(argv):
   usage = ("\nUsage: ./rarity_finder.py -F <inputfile> -W <whos_who_file>\n"
            "Long option names also available for convenience:\n"
            "\t-F or --INPUT\n\t-W or --WHO\n")
   output_analysis = '***************\n\tPubmed: \n\tUCSC: \n\tLynx: \n\tAllen: \n\tMGI: \n\tEVS: \n\tExAC: \n***************\n' 
   input_file = ''
   whos_file = ''
   current_family = ''
   families = {}
   proband_indecies = []
   start_of_gene = False
   variants_printed = False
   try:
      opts, args = getopt.getopt(argv,"hF:W:",["INPUT=","WHO="])
   except getopt.GetoptError:
      print usage
      sys.exit(2)
   for opt, arg in opts:
      if opt == '-h':
         print usage
         sys.exit()
      elif opt in ("-F", "--INPUT"):
         input_file = arg
      elif opt in ("-W", "--WHO"):
         whos_file = arg
   if input_file == '' or whos_file == '':
      print 'Error: Both input files not detected.\n', usage
      sys.exit(2)
   elif file_check(input_file) == 0 or file_check(whos_file) == 0:
      print 'Error: One or more Files supplied do not appear to exist.'
      sys.exit(2)

   with open(whos_file, 'r') as who_is_who:
      for line in who_is_who:
         line_components = line.split('\t')
         families[line_components[0]] = [int(line_components[1]), int(line_components[3].split('\n')[0])]
         for i in range(0,int(line_components[3])):
            proband_indecies.append(int(line_components[1]) + i)
   who_is_who.close()

   path = "/".join(input_file.split('/')[:-1]) + "/"
   output_file = path + "rare_only_" + "".join(input_file.split('/')[-1:])
   fileout = open(output_file, 'w')

   with open(input_file, 'r') as filein:
      multiple_variants = 0
      for line in filein:
         need_to_filter = re.search("GT:AD:DP:GQ:PL", line)
         if need_to_filter is None:
            fileout.write(line)
            multiple_variants = 0
            line_components = line.replace('\n', '').split('\t')
            if line_components[0] in families:
               current_family = line_components[0]
            elif line_components[0] == '---------------':
               start_of_gene = True
            elif start_of_gene and variants_printed:
               fileout.write(output_analysis)
               start_of_gene = False
            variants_printed = False
         else:
            variant_from_proband = 0
            multiple_variants += 1
            line_of_interest = line.split('\t')
            start_index = line_of_interest.index("GT:AD:DP:GQ:PL") + 1
            number_of_people_with_variant = 0
            total_people_in_cohort = len(line_of_interest[start_index:])

            if start_index == families[current_family][0]:
               start_index = proband_indecies[proband_indecies.index(families[current_family][0] + families[current_family][1] - 1) + 1]
	       #print(current_family, start_index)

            while start_index < len(line_of_interest) and (start_index < families[current_family][0] or start_index >= proband_indecies[proband_indecies.index(families[current_family][0] + families[current_family][1] - 1) + 1]):
		
	       #print(current_family, start_index)	
               genotype = line_of_interest[start_index].split(':')
               alleles = genotype[0].split('/')     

               if alleles[0] == '1' or alleles[1] == '1':
                  number_of_people_with_variant += 1
                  if start_index in proband_indecies:
                     variant_from_proband += 1

               start_index += 1
               if start_index == families[current_family][0]:
		  if proband_indecies.index(families[current_family][0] + families[current_family][1] - 1) + 1 >= len(proband_indecies):
			start_index = len(line_of_interest)
		  else:
                        start_index = proband_indecies[proband_indecies.index(families[current_family][0] + families[current_family][1] - 1) + 1]
		  #print(current_family, start_index)

            if number_of_people_with_variant == 0:
               fileout.write(line)
               variants_printed = True
            elif number_of_people_with_variant == variant_from_proband:
               fileout.write('+~~>Variant found ONLY in probands!\n')
               fileout.write(line)
               variants_printed = True
            else:
               if multiple_variants == 1:
                  fileout.write('+~~>Not a rare variant, Number of additional cohort members outside of family with variant: ' + \
                                 str(number_of_people_with_variant) + ' out of ' + \
                                 str(total_people_in_cohort) + ' total.\n')
               else:
                  fileout.write('+~~>Additional variant in this gene, also not rare:\t\t\t\t            ' + \
                                 str(number_of_people_with_variant) + ' out of ' + \
                                 str(total_people_in_cohort) + ' total.\n')
      if variants_printed:
         fileout.write("\n" + output_analysis)
   filein.close()
   fileout.close()

def file_check(fn):
    try:
      open(fn, "r")
      return 1
    except IOError:
      return 0

if __name__ == "__main__":
   main(sys.argv[1:])
