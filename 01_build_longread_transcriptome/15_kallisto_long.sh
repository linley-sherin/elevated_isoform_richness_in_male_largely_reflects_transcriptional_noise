#!/bin/bash

####################################################################################
### STEP 10B: REQUANTIFY WITH KALLISTO (LONG-READS)
####################################################################################

## HERE I USE THE KB_PYTHON WRAPPER INSTEAD TO MAKE
## THE SHORT-READ AND LONG-READ PIPELINES MATCH AS CLOSELY AS POSSIBLE

## NOTE, MUST SPECIFY THE CORRECT KALLISTO BUILD FOR 64 KMER SIZE
## kallisto_LongKmer_NoOpt-v0.51.1.tar.gz

# Before running: make sure to run (these run automatically as part of STEP11a)
# (1) interleaved_2_noninterleaved.sh on filter output
# (2) t2g.sh on noninterleaved output
# (3) convert all bam files to fastq files for kallisto input

#for bamfile in /Volumes/mankbank_new/linley/ch2_splicing_reticulata/data/reticulata_isoseq_nojuv/03_updatebam/*.bam; do
#    # Define the output name by stripping .bam and adding .fastq.gz
#    outname="${bamfile%.bam}.fastq.gz"
#    
#    echo "Converting $bamfile to $outname..."
#    
#    # Convert BAM to compressed FASTQ to save space
#    samtools fastq "$bamfile" | gzip > "$outname"
#done

#echo "Conversion complete!"

# Define files
interleaved_fasta="./07_SQANTIfilter/nonredundant_transcripts.fasta"
t2g_file="./07_SQANTIfilter/t2g.txt"

# Define the path to the Kallisto index
kallisto_index="./09_kallisto/kallisto_index_long.idx"

# Check if the Kallisto index exists
if [ ! -f "$kallisto_index" ]; then
    echo "Index not found. Creating Kallisto index..."
    kb ref "$interleaved_fasta" \
    	   -i "$kallisto_index" \
    	   --make-unique \
    	   --workflow=custom \
    	   -k 63 \
    	   --kallisto ./kallisto/kallisto_mac-v0.51.1_kmer64 \
    	   --tmp ./tmp_long
else
    echo "Kallisto index already exists. Skipping index creation."
fi

# Read each sample name
while IFS= read -r line; do
    # Define the output directory for this sample
    output_dir="./09_kallisto/kallisto_long/$line"

    # Make sure the output directory exists
    mkdir -p "$output_dir"

    # Define the path to the fastq files
    fastq_long="/Volumes/mankbank_new/linley/ch2_splicing_reticulata/data/reticulata_isoseq_nojuv/03_updatebam/${line}"

    # Check if the fastq files exist
    if [ ! -f "$fastq_long" ]; then
        echo "Error: Fastq file for $line not found. Skipping this sample."
        continue
    fi

    # Perform Kallisto quantification
    # For long-reads we will computer 100 bootstraps in order to calculate uncertainty later
    echo "Running Kallisto quantification for $line..."
    kb count -x bulk \
             -i "$kallisto_index" \
             -o "$output_dir" \
             -g "$t2g_file" \
             --parity=single \
             --strand=unstranded \
             --tcc \
             --matrix-to-directories \
             --long \
             --platform PacBio \
             "$fastq_long" \
             --kallisto ./kallisto/kallisto_mac-v0.51.1_kmer64 \
             --bootstraps 100 \
             -t 40 \
             --tmp ./tmp_long

#done < ./03_updatebam/flnc_fastq.fofn
done < /Volumes/mankbank_new/linley/ch2_splicing_reticulata/data/reticulata_isoseq_nojuv/03_updatebam/flnc.fofn

