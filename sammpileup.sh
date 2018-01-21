#!/usr/bin/env bash
#SBATCH --job-name sammpileup
#SBATCH --time 7-12:0:0
#SBATCH --mem 300000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 30
#SBATCH --output sammpileup_%j.out
#SBATCH --mail-type FAIL

SEARCH_DIR=$1
BAM_SUFFIX=$2

module load SAMtools

find "${SEARCH_DIR}" -name "*${BAM_SUFFIX}" | while read file; 
do 
	Rout=${file##*/};
	echo "processing "${file}""
	samtools mpileup -B --ignore-RG \
	--fasta-ref /mnt/bioinf-4/shani/barley_RNASeq/IBSC_2016/barley_pseudomolecules_edited_lineformatted.fasta \
	"${file}" \
	-o /mnt/bioinf-4/shani/barley_RNASeq/mpileup_snps/"${Rout}".pileup
	echo ""${Rout}" completed and saved as "${Rout}".pileup";
done 
exit
