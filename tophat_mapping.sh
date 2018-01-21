#!/usr/bin/env bash
#SBATCH --job-name tophat_mapping
#SBATCH --time 10-12:0:0
#SBATCH --mem 160000
#SBATCH --cpus-per-task 16
#SBATCH --output tophat_mapping_%j.out
#SBATCH --mail-type FAIL

FILE_NAMES=$1

module load \
  TopHat/2.1.1-foss-2015b \
  Bowtie2/2.2.6-foss-2015b \
  SAMtools/1.3-foss-2015b \
  pigz/2.3.3-foss-2015b

for R1 in ${FILE_NAMES};
do
	R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz};
	Rout=${R1##*/};  
	Rout2=${Rout%%_R1*}; Rout3=${Rout%%L0*};Rout4=${Rout2%%_S*}; prefix=${Rout4##*_};	
	#prefix=${Rout%%_R1*};
	#R1_uz<(pigz -dcp2 "${R1}"); R2_uz<(pigz -dcp2 "${R2}");
	echo "Processing ${R1} and ${R2}"
	tophat2 \
		--zpacker pigz \
		--num-threads ${SLURM_CPUS_PER_TASK} \
 		--max-multihits 1 \
 		--read-mismatches 2 \
		--read-edit-dist 5 \
		--read-gap-length 5 \
		--max-intron-length 5000 \
		--mate-inner-dist 200 \
		--raw-juncs /mnt/bioinf-5/shani/barley_RNASeq/tophat_mapping/IBSC2016.juncs \
 		--no-novel-juncs \
 		--library-type "fr-firststrand" \
		--transcriptome-index /mnt/bioinf-5/shani/barley_RNASeq/tophat_mapping/IBSC2016.transcriptome \
 		--output-dir ./output_${prefix} \
 		/mnt/bioinf-5/shani/barley_RNASeq/tophat_mapping/bowtieindex/bowtieindex \
 	"${R1}" "${R2}"
done
