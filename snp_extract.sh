#!/usr/bin/env bash
#SBATCH --job-name HKT_SNPs
#SBATCH --time 7-12:0:0
#SBATCH --mem 200000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --output HKT_SNPs_%j.out
#SBATCH --mail-type FAIL

#directory has to be /mnt/bioinf-4/shani/barley_RNASeq/snps/geno_tissue
#suffix is either calls or counts
module load \
pigz

#directory=$1
#suffix=$2
#HKT_coord='/mnt/bioinf-4/shani/barley_RNASeq/HKTGenes/hkt_coords.txt'
#find "${directory}" -name "*${suffix}*" | while read file; 
		#do 
		file='/mnt/bioinf-4/shani/barley_RNASeq/snps/final2.calls.tab.gz'
		out=${file##*/}; out=${out%%.*};
		while read line;
			do
			hkt=$(awk -F'\t' '{print $1}');
			chrom=$(awk -F'\t' '{print $2}');
			start=$(awk -F'\t' '{print $3}');
			end=$(awk -F'\t' '{print $4}');
			echo -ne "${hkt}\n"
			less "${file}"| awk -F'\t' '$1=="${chrom}" && $2>="${start}" && $2<="${end}"'
			#echo -ne "${result}\n"
		done < '/mnt/bioinf-4/shani/barley_RNASeq/HKTGenes/hkt_coords.txt'> SNPs_"${suffix}"_"${out}"_"${hkt}".tab
#done 