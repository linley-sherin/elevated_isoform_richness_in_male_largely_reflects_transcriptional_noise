#!/bin/bash

set -euo pipefail
mkdir -p ./08_transdecoder2

# === Use TD2 utility scripts to try and fix issue with strand mismatches  === #

export PATH=/Library/Frameworks/Python.framework/Versions/3.11/bin/TD2/util:$PATH

# Convert transcriptome to fasta directly from genomic coordinates
./TransDecoder-v5.7.1/util/gtf_genome_to_cdna_fasta.pl ./GTF/02_SQANTI_filtered.gtf ./guppy_genomes/ncbi_female.fa > ./08_transdecoder2/transcripts.fasta
# Convert gtf to gff3 
./TransDecoder-v5.7.1/util/gtf_to_alignment_gff3.pl ./GTF/02_SQANTI_filtered.gtf > ./08_transdecoder2/transcripts.gff3

# === Setup logging ===
LOGFILE="./08_transdecoder2/transdecoder2_$(date +%Y%m%d_%H%M%S).log"
exec > >(tee -i "$LOGFILE")
exec 2>&1

# === Create output directory and enter it ===
mkdir -p ./08_transdecoder2
cd ./08_transdecoder2

# === Inputs and settings ===
FASTA="../08_transdecoder2/transcripts.fasta"
BASENAME=$(basename "$FASTA" .fasta)

echo "Starting TransDecoder analysis at $(date)"
echo "Input FASTA: $FASTA"
echo "Output directory: $(pwd)"
echo "Log file: $LOGFILE"

# === Run TD2.LongOrfs (no --precise this time) ===
if [[ -d "$BASENAME" ]]; then
    echo "TD2.LongOrfs output directory '$BASENAME' already exists. Skipping."
else
    echo "Running TD2.LongOrfs (relaxed)..."
    TD2.LongOrfs -t "$FASTA" \
    			 -v \
    			 -S
fi

# === Run TD2.Predict (less conservative) ===
echo "Running TD2.Predict..."

TD2.Predict -t "$FASTA" \
            -v \
            -O "./$BASENAME" \
            #--all-good \
            -P 0.9

# === Finalize output ===
echo "Moving final output files up one level..."
mv "$BASENAME"/* ./
rmdir "$BASENAME"

# === Use TD2 utility scripts to try and fix issue with strand mismatches  === #
# Create gff3 output with cds regions already annotated

../TransDecoder-v5.7.1/util/cdna_alignment_orf_to_genome_orf.pl \
     ../08_transdecoder2/transcripts.fasta.TD2.gff3 \
     ../08_transdecoder2/transcripts.gff3 \
     ../08_transdecoder2/transcripts.fasta > transcripts_with_cds.gff3

echo "TransDecoder finished at $(date)"
echo "Final files:"
ls -lh ./
