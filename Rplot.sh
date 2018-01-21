#!/usr/bin/env bash
#SBATCH --job-name R_plots
#SBATCH --time 0-5:0:0
#SBATCH --mem 130000
#SBATCH --ntasks 1
#SBATCH --cpus-per-task 13
#SBATCH --output Rplots_%j.out
#SBATCH --mail-type FAIL

SEARCH_DIR=$1 #Full path to the file
BAMstats=$2 #file name.

module load \
	R-bundle-Bioconductor-shani

R

library(reshape2)
library(data.table) # fread()
library(ggplot2)
library(dplyr)      # group_by() summarize() 
library(scales)     # 
bamstats <- read.table(${SEARCH_DIR}${BAMstats})
colnames(bamstats) <- c("file", 
						"total", 
						"mapped", 
						"unmapped", 
						"nuclear_rRNA", 
						"nuclear_rRNA_percentage", 
						"total_chloroplast", 
						"chloroplast_percentage", 
						"chloroplast_rRNA", 
						"chloroplast_rRNA_percentage", 
						"total_mitoch", 
						"mitoch_percentage", 
						"mitoch_rRNA", 
						"mitoch_rRNA_percentage")
bamstats.unmapped <- read.table(${SEARCH_DIR}${BAMstats,unmapped})
colnames(bamstats.unmapped) <- c("file", 
						"total", 
						"mapped", 
						"unmapped", 
						"nuclear_rRNA", 
						"nuclear_rRNA_percentage", 
						"total_chloroplast", 
						"chloroplast_percentage", 
						"chloroplast_rRNA", 
						"chloroplast_rRNA_percentage", 
						"total_mitoch", 
						"mitoch_percentage", 
						"mitoch_rRNA", 
						"mitoch_rRNA_percentage")	
bamstats$unmapped        <- bamstats.unmapped$unmapped
bamstats$total           <- bamstats$mapped+bamstats$unmapped						
bamstats$nuclear_nonrRNA <- bamstats$mapped - (bamstats$nuclear_rRNA + bamstats$total_chloroplast +bamstats$total_mitoch)
bamstats$chloro_nonrRNA  <- bamstats$total_chloroplast - bamstats$chloroplast_rRNA
bamstats$mitoch_nonrRNA  <- bamstats$total_mitoch - bamstats$mitoch_rRNA
#bamstats.m <- melt(bamstats[, c('file','unmapped','mapped')], id.vars=1)
bamstats.m <- melt(bamstats[, c('file',
								'nuclear_nonrRNA',
								'nuclear_rRNA',
								'chloroplast_rRNA',
								'chloro_nonrRNA',
								'mitoch_rRNA',
								'mitoch_nonrRNA',
								'unmapped')], id.vars=1)
bamstats.m$file <- sub("(^.*/)(L.*[A-Z])(_.*)","\\2", bamstats.m$file)
setnames(bamstats.m, c("file", "type", "reads"))
metadata <- read.table ("../DEanalysis/Metadata_Barley.txt", header=TRUE)			
bamstats.m$genotype <- metadata$Genotype[match(bamstats.m$file, metadata$ID)]
bamstats.m$tissue  <- metadata$Tissue[match(bamstats.m$file, metadata$ID)]
# Calculate % of reads in each Type
x <- bamstats.m %>%
	 group_by(file) %>%
	 mutate(prop = round(as.numeric(reads) / sum(as.numeric(reads)) * 100, 3))
bamstats.m$Percent <- x$prop
bamstats.m$x <- paste(bamstats.m$file, bamstats.m$genotype, sep="_")
g_bamstats <- ggplot(bamstats.m, 
					 aes(
						x=x, 
						y=reads,#can use reads/Percent as well 
						fill=type))+ 
					geom_bar(
						stat='identity')+
					scale_y_continuous(labels=comma, expand = c(0, 0)) +
					facet_grid(.~tissue, scales='free_x', drop=TRUE)+
					theme(
						text = element_text(size=5), 
						axis.text.x = element_text(
							angle = 90, 
							hjust = 0.95,
							vjust = 0.2),
						axis.title.y = element_text(vjust=1.25),
						axis.title.x = element_text(vjust=-2),
						plot.title   = element_text(vjust=2, hjust=1))+
					ylab("number of reads")+
					xlab("File names")+
					ggtitle("BAM stats for barley data")
pdf("../qc/barley_bamstats_new.pdf", height=11,  width=8.26); g_bamstats; dev.off()
q()
exit




