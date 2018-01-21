#!/usr/bin/env bash
#SBATCH --job-name samsorting
#SBATCH --time 7-12:0:0
#SBATCH --mem 300000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 30
#SBATCH --output samsorting_%j.out
#SBATCH --mail-type FAIL

SEARCH_DIR=$1
BAM_SUFFIX='.sortedByCoord.out.bam'

module load SAMtools

find "${SEARCH_DIR}" -name "*${BAM_SUFFIX}" | while read file; 
do 
	Rout=${file##*/}; Rout2=${Rout%%_Aligned*};
	echo "processing "${Rout2}""
	samtools sort "${file}" > ../BAMs_sorted/"${Rout2}"_sorted.bam
	echo ""${Rout2}" completed and saved as "${Rout2}"_sorted.bam";
done 
exit
