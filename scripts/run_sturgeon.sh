#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=12
#SBATCH --partition normal
#SBATCH --time=0:30:00
#SBATCH --mem=16G
#SBATCH --job-name=sturgeon
#SBATCH --mail-type=ALL
#SBATCH --error ./logs/%x_%j.err.txt
#SBATCH --output ./logs/%x_%j.out.txt

export PATH=/scratch/tmp/thomachr/software/miniconda3/bin:$PATH
sturgeon_model=/scratch/tmp/thomachr/software/sturgeon/include/models/general.zip
basedir="."
base=`basename ${basedir}/$1`

# Sturgeon
module unload
ml palma/2021b GCC/11.2.0 OpenMPI/4.1.1 sturgeon/0.4.3
sturgeon inputtobed -i ${basedir}/tmp/${base}/ -o ${basedir}/tmp/${base}/ -s modkit

sturgeon predict \
-i ${basedir}/tmp/${base} \
-o ${basedir}/results/${base} \
--model-files $sturgeon_model \
--plot-results

# CNV analysis
ml palma/2020b GCC/10.2.0 OpenMPI/4.0.5 R/4.0.3
Rscript ${basedir}/scripts/cnv_plot.R ${basedir}/tmp/${base}/hg19/ ${basedir}/results/${base}/cnv
mv ${basedir}/results/${base}/cnv/cnv_plot_1000kbp.pdf ${basedir}/results/${base}

# QC hg19
NanoPlot -t 8 -c blue --N50 --bam ${basedir}/tmp/${base}/hg19/${base}_hg19_alignment_sorted.bam \
	 -o ${basedir}/results/${base}/qc_hg19

# QC chm13v2
NanoPlot -t 8 -c blue --N50 --bam ${basedir}/tmp/${base}/chm13v2/${base}_chm13v2_alignment_sorted.bam \
	 -o ${basedir}/results/${base}/qc_chm13v2
