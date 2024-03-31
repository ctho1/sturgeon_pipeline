#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=18
#SBATCH --partition requeue
#SBATCH --time=0:30:00
#SBATCH --mem=16G
#SBATCH --job-name=sturgeon
#SBATCH --mail-type=ALL
#SBATCH --error ./logs/%x_%j.err.txt
#SBATCH --output ./logs/%x_%j.out.txt

basedir="."
base=`basename ${basedir}/$1`
sturgeon_model=/scratch/tmp/thomachr/software/sturgeon/include/models/general.zip

# CNV calling
ml palma/2020b GCC/10.2.0 OpenMPI/4.0.5 R/4.0.3
Rscript ${basedir}/scripts/cnv_plot.R ${basedir}/tmp/${base}/hg38/ ${basedir}/results/${base}/cnv

# Sturgeon
module unload
ml palma/2021b GCC/11.2.0 OpenMPI/4.1.1 sturgeon/0.4.3
sturgeon inputtobed -i ${basedir}/tmp/${base}/ -o ${basedir}/tmp/${base}/ -s modkit

sturgeon predict \
-i ${basedir}/tmp/${base} \
-o ${basedir}/results/${base} \
--model-files $sturgeon_model \
--plot-results
