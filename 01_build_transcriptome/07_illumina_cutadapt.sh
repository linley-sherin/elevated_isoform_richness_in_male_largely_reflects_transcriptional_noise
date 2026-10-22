#!/bin/bash

## Last modified by Linley Sherin 2024-10-09

# conda activate cutadapt

#Start!
echo "Cutadapt is removing poly G reads :)"
date

find ./00_rawreads -name '*_R1.fastq.gz' | sed 's|.*/||; s/_R1.fastq.gz//' > forwardreads.txt
find ./00_rawreads -name '*_R2.fastq.gz' | sed 's|.*/||; s/_R2.fastq.gz//' > reversereads.txt

#Checking the reads provided
NOFR="$(wc -l < forwardreads.txt )"
echo Number of forward reads: "${NOFR}"

NORR="$(wc -l < reversereads.txt )"
echo Number of reverse reads: "${NORR}"

if [[ $NOFR == $NORR ]] 
	then
	echo 
	else
	echo ERROR: The number of forward reads does not match the number of reverse reads. Please double check this.; date; exit 1; 
	
	fi

#Making file of base names for the reads
sed 's/_R[12]$//' forwardreads.txt > basenamereads.txt

#Cutadapt 

mkdir -p 01_cutadapt
echo Starting Cutadapt...
date

# Loop through each base name in basenamereads.txt
while IFS= read -r line; do
    echo "Processing: $line"
    
    # Run Cutadapt for both forward and reverse reads
    # Set minimum-length to 25 so that reads that are entirely removed by nextseq-trim
    # are filtered out
    cutadapt --nextseq-trim=20 \
    -o ./01_cutadapt/"$line"_R1.fastq.gz \
    -p ./01_cutadapt/"$line"_R2.fastq.gz \
    ./00_rawreads/"$line"_R1.fastq.gz ./00_rawreads/"$line"_R2.fastq.gz \
    --minimum-length 25
    
    # Check if Cutadapt was successful
    if [ $? -eq 0 ]; then
        echo "Cutadapt completed successfully for $line."
    else
        echo "Cutadapt encountered an error for $line."
    fi
done < basenamereads.txt
	
echo Completed Cutadapt 
date

# FastQC
mkdir -p ./01_cutadapt/fastqc
for i in ./01_cutadapt/*.fastq; do
    echo "Running FastQC on $i..."
    
    if fastqc "$i" -o ./01_cutadapt/fastqc; then
        echo "FastQC completed successfully for $i."
    else
        echo "ERROR: FastQC encountered an error for $i." >&2
    fi
done

conda deactivate

#MultiQC
conda activate multiqc_env
multiqc ./01_cutadapt/fastqc/
conda deactivate
cd .. 

# echo All done! Thank you, please come again. 
# date





