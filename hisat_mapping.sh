#!/usr/bin/env bash
#SBATCH --job-name L1*hisat2_mapping
#SBATCH --time 14-12:0:0
#SBATCH --mem 200000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 20
#SBATCH --output L1*hisat_mapping_%j.out
#SBATCH --mail-type FAIL

module load \
HISAT2/2.0.5-foss-2015b \
SAMtools/1.3-foss-2015b

for R1 in ~/barley_RNASeq/Length_filtered/*L1[A-F]*_R1_001.fastq.gz;
do
	R2=${R1/R1_001.fastq.gz/R2_001.fastq.gz};
	Rout=${R1##*/};  Rout2=${Rout%%_R1*}; Rout3=${Rout%%L0*};Rout4=${Rout2%%_S*}; prefix=${Rout4##*_};
	echo "Processing ${R1} and ${R2}"
	hisat2 \
		--no-softclip \
		--rna-strandness FR \
		--mp 5,0 \
		-k 20 \
		--max-seeds 126 \
		--max-intronlen 5000 \
		--met-file "${prefix}".met \
		--met-stderr "${prefix}".stderr \
		--met 5 \
		-x hisat2_index/barley \
		-1 "${R1}" -2 "${R2}" \
	|samtools view -bS >"${prefix}".bam
	echo "Completed${R1}and${R2}";
done


#startedaround11.26am18/12
