#!/usr/bin/env bash
#SBATCH --job-name snp_calling
#SBATCH --time 7-12:0:0
#SBATCH --mem 300000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 30
#SBATCH --output snp_calling_%j.out
#SBATCH --mail-type FAIL

module load Java pigz

in_dir=/mnt/bioinf-4/shani/barley_RNASeq/mpileup_snps/
SUFFIX='.pileup'
out_dir=snps

REFERENCE=/mnt/bioinf-4/shani/barley_RNASeq/IBSC_2016/barley_pseudomolecules_edited_lineformatted.fasta

pigz_compression_threads=1
pigz_decompression_threads=1

sort_threads=7

snp_threads=5
snp_min_coverage_per_allele=5
snp_min_coverage_per_locus=10
snp_min_samples_within_coverage=1
snp_max_percent_error_allele=5
snp_min_samples_called=1
snp_min_snps_to_reference=1
snp_min_calls_het=0

find "${in_dir}" -name "*${SUFFIX}.gz" | while read file; 
do 
	out=${file##*/}; out=${out%%.*}; out=${out}3;
	touch "${out_dir}/${out}.both.tab.gz" "${out_dir}/${out}.calls.tab.gz" "${out_dir}/${out}.counts.tab.gz" "${out_dir}/${out}.both.tab.err"
	java -jar /mnt/bioinf-4/shani/barley_RNASeq/scripts/merutensils-new.jar pmpileup \
	  --sample-names Ales Beecher Comm Fleet Maritime Sloop \
	  --pileup-file "${file}" \
	  --min-snps-to-reference "${snp_min_snps_to_reference}" \
	  --threads "${snp_threads}" \
	  --min-coverage-per-allele "${snp_min_coverage_per_allele}" \
	  --min-samples-within-coverage "${snp_min_samples_within_coverage}" \
	  --max-percent-error-allele "${snp_max_percent_error_allele}" \
	  --in-buffer-size 32768 \
	  --print-user-settings \
	  --stderr-redirect "${out_dir}/${out}.both.tab.err" \
	  | tee >(grep '^CALLS' | cut -f 2- | pigz --best -cp "${pigz_compression_threads}" > "${out_dir}/${out}.calls.tab.gz") \
	  | tee >(grep '^COUNTS' | cut -f 2- | pigz --best -cp "${pigz_compression_threads}" > "${out_dir}/${out}.counts.tab.gz") \
	  | pigz --best -cp "${pigz_compression_threads}" > "${out_dir}/${out}.both.tab.gz" ; done
	  