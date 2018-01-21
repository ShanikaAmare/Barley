#!/usr/bin/env bash
#SBATCH --job-name STAR_mapping
#SBATCH --time 7-12:0:0
#SBATCH --mem 200000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 10
#SBATCH --output STAR_mapping_%j.out
#SBATCH --mail-type FAIL

module load \
pigz STAR FASTX-Toolkit

SEARCH_DIR=$1
COMMON_EXT=$2

for R1 in ${SEARCH_DIR}/${COMMON_EXT};
do
R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}; 
 Rout=${R1##*/};  Rout2=${Rout%%_R1*}; Rout3=${Rout%%L0*};Rout4=${Rout2%%_S*}; Rout5=${Rout4##*_};
 DS=$(grep -F ${Rout5} ~/barley_RNASeq/Raw_data/MattG_samples_Barley.txt |awk '{print $3"_"$4}')
	echo "PROCESSING:${R1} and ${R2}"
STAR \
	--runMode alignReads \
	--outWigType bedGraph \
	--outFilterIntronMotifs RemoveNoncanonicalUnannotated \
	--runThreadN 25 \
	--outBAMsortingThreadN 5 \
	--genomeDir ~/barley_RNASeq/BarleyGenomeIndex \
	--alignIntronMax 5000 --alignMatesGapMax 5000 \
	--readFilesCommand 'pigz -dcp2' \
	--outFilterMismatchNmax 5 --outFilterMultimapNmax 20 \
	--outSAMunmapped Within \
	--readFilesIn ${R1} ${R2} \
	--outSAMtype BAM SortedByCoordinate --outFileNamePrefix ${Rout3} \
	--outTmpDir /dev/shm/${Rout3}14.STARtmp \
	--outSAMattrRGline ID:${Rout2} DS:${DS} PL:Illumina PU:Unknown SM:${Rout5} \
	--outSAMstrandField None;
done
exit
