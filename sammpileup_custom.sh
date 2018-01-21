#!/usr/bin/env bash
#SBATCH --job-name sammpileup_c
#SBATCH --time 7-12:0:0
#SBATCH --mem 20000
#SBATCH --ntasks 10
#SBATCH --cpus-per-task 10
#SBATCH --output sammpileup_c_%j.out
#SBATCH --mail-type FAIL


file1=$1
file2=$2
file3=$3
file4=$4
prefix=$5

module load SAMtools

	samtools mpileup -B --ignore-RG \
	--fasta-ref /mnt/bioinf-4/shani/barley_RNASeq/IBSC_2016/barley_pseudomolecules_edited_lineformatted.fasta \
	"${file1} ${file2} ${file3} ${file4}" \
	-o /mnt/bioinf-4/shani/barley_RNASeq/mpileup_snps/"${prefix}".pileup
	echo "Completed mpileup and saved as "${prefix}".pileup";
done 
exit
