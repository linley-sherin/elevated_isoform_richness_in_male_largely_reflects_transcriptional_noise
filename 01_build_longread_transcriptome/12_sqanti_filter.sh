#!/bin/bash

####################################################################################
### STEP 7: SQANTI3 FILTER
####################################################################################

conda activate SQANTI3.env 

# Filter based on defaults rules (as defined in filter_default.json)
# 	- Keep all FSM isoform models without evidence of intrapriming (%A downstream of TTS >60, ie. 12/20 bp)
#		(indicates 3' end is potentially unreliable)
#
#	- Keep non FSM isoform models if they meet below criteria:
#		(1) no evidence of intrapriming (see above)
#       (2) no junction labeled RT-switching (RTS) 
#		(3) all junctions canonical OR have short-read cov >10 (-c threshold)
#

python ~/Documents/programs/SQANTI3-5.2.2/sqanti3_filter.py rules ./06_SQANTIqc/output/SQANTI_output_classification.txt `# classification file from sqanti3` \
																--isoforms ./06_SQANTIqc/output/SQANTI_output_corrected.fasta `# fasta file with isoform models to filter` \
																--gtf ./06_SQANTIqc/output/SQANTI_output_corrected.gtf `# gtf file with isoform models to filter` \
																-o SQANTI_filtered \
																-d ./07_SQANTIfilter/ \
																-j ./07_SQANTIfilter/filter_new_filterstruc.json `# json with rules`
