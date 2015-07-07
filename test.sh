#!/bin/bash
python filter_vcf.py --NUM_AFFECTED=$num_affected --PROBAND=$proband_index --SNV=$active_snv_vcf --INDEL=$active_snv_vcf --PEDIGREE=$pedigree --OUTPUT=$output_base
