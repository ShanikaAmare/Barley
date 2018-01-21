#!/usr/bin/env bash
#SBATCH --job-name samindexing
#SBATCH --time 7-12:0:0
#SBATCH --mem 300000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 30
#SBATCH --output samindexing_%j.out
#SBATCH --mail-type FAIL

SEARCH_DIR=$1
SEARCH_SUFFIX=".bam"

module load SAMtools

find "${SEARCH_DIR}" -name "*${SEARCH_SUFFIX}" | while read file; 
do 
	samtools index -c "${file}";
done
