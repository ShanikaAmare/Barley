#!/usr/bin/env bash
#SBATCH --job-name bam_trimming
#SBATCH --time 7-12:0:0
#SBATCH --mem 500000
#SBATCH --ntasks 5
#SBATCH --cpus-per-task 10
#SBATCH --output bam_trimming_%j.out
#SBATCH --mail-type FAIL

# Extract regions from a set of BAM files, modifying co-ordinates, to that within the region
#####

REFERENCE='/mnt/bioinf-4/shani/barley_RNASeq/IBSC_2016/barley_pseudomolecules_edited_lineformatted.fasta'
BAM_FILES=( $(find /mnt/bioinf-4/shani/barley_RNASeq/merged_BAMs/genotypes/ -name "*.bam") )
REGIONS=(
	#chr7H:520198211-520201915
	#chr3H:8165119-8185220
	#chr4H:238472323-238482764
	#chr5H:421877807-421880417
	#chr7H:173367734-173374639
	#chr1H:79212696-79218619
	#chr2H:59025611-59030288
	#chr7H:148709554-148713307
	#chr5H:535545853-535553664
	chr3H:8165119-8185220 #SOS1 HORVU3Hr1G003150
)

module load \
  SAMtools/1.4-foss-2015b \
  Sambamba/0.6.5-x86-64

for LOCUS in "${REGIONS[@]}"; do
  CHR="${LOCUS%:*}"
  FROM="${LOCUS%%-*}"
  FROM="${FROM##*:}"
  TO="${LOCUS##*-}"
  FROM="$((FROM-2000))"
  TO="$((TO+2000))"
  
  samtools faidx \
    "${REFERENCE}" \
    "${CHR}:${FROM}-${TO}" |\
    sed -re '/^>/ s/:.+?//' > "tmp/${CHR}:${FROM}-${TO}.fasta"
  
  for BAM_FILE in "${BAM_FILES[@]}"; do
    OUT_BAM="${BAM_FILE/.bam/_${CHR}:${FROM}-${TO}.bam}"
    OUT_BAM="tmp/${OUT_BAM##*/}"
    
    samtools view -h \
      "${BAM_FILE}" "${CHR}:${FROM}-${TO}" \
      | perl -ne 'if (/^\@SQ/) {if (/SN:'${CHR}'/){s/LN:\d+/LN:'$((TO-FROM+1))'/;print}}elsif(! /^\@/){@cols=split "\t"; $cols[3]-='$((FROM-1))'; $cols[7]-='$((FROM-1))'; local $" = "\t";print "@cols"}else{print}' \
      | samtools view -b -1 \
        --reference "tmp/${CHR}:${FROM}-${TO}.fasta" \
      > "${OUT_BAM}"
    samtools index -b "${OUT_BAM}"
  done
done

find /mnt/bioinf-4/shani/barley_RNASeq/tmp/ -name "*.fasta" | while read file; do  samtools faidx "${file}" ; done
