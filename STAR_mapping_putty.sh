for R1 in /mnt/bioinf-1/shani/barley_RNASeq/Length_filtered/C8T1NANXX_L2{A,B,C}*_R1_001.fastq.gz;
do
R2=${R1/_R1_001.fastq.gz/_R2_001.fastq.gz}; 
 Rout=${R1##*/};  Rout2=${Rout%%_R1*}; Rout3=${Rout%%L0*};Rout4=${Rout2%%_S*}; Rout5=${Rout4##*_};
 DS=$(grep -F ${Rout5} /mnt/bioinf-1/shani/barley_RNASeq/Raw_data/MattG_samples_Barley.txt |awk '{print $3"_"$4}')
	echo "PROCESSING:${R1} and ${R2}"
/usr/local/Programs/STAR/STAR_2.4.2a_mod/STAR \
--runMode alignReads \
--outWigType bedGraph \
--outFilterIntronMotifs RemoveNoncanonicalUnannotated \
--runThreadN 25 \
--outBAMsortingThreadN 5 \
--genomeDir /mnt/bioinf-1/shani/barley_RNASeq/BarleyGenomeIndex \
--alignIntronMax 5000 --alignMatesGapMax 5000 \
--readFilesCommand 'pigz -dcp2' \
--outFilterMismatchNmax 5 --outFilterMultimapNmax 20 \
--outFilterMatchNminOverLread 1  \
--outSAMunmapped Within \
--readFilesIn ${R1} ${R2} \
--outSAMtype BAM SortedByCoordinate --outFileNamePrefix ${Rout3} \
--outTmpDir /dev/shm/${Rout3}5.STARtmp \
--outSAMattrRGline ID:${Rout2} DS:${DS} PL:Illumina PU:Unknown SM:${Rout5} \
--outSAMstrandField None;
done