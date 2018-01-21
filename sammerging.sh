#!/usr/bin/env bash
#SBATCH --job-name sammerge
#SBATCH --time 7-12:0:0
#SBATCH --mem 300000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 30
#SBATCH --output sammerge_%j.out
#SBATCH --mail-type FAIL

SEARCH_DIR=$1

module load SAMtools

for i in B C D E F;
do
	samtools merge "${i}".bam <(find "${SEARCH_DIR}" -name "*${i}_accepted_hits.bam")
	echo "Processing completed and saved as "${i}".bam"
done
exit
