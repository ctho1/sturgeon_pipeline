#!/bin/bash
#SBATCH --nodes=1
#SBATCH --cpus-per-task=36
#SBATCH --partition requeue
#SBATCH --time=3:00:00
#SBATCH --mem=140G
#SBATCH --job-name=sturgeon_pipeline
#SBATCH --error ./logs/%x_%j.err.txt
#SBATCH --output ./logs/%x_%j.out.txt

export PATH="/scratch/tmp/thomachr/software/dorado-0.4.2-linux-x64/bin:$PATH"
export PATH="/home/t/thomachr/.local/bin:$PATH"

basedir="."
mkdir -p ${basedir}/dorado_output
mkdir -p ${basedir}/modkit_output
mkdir -p ${basedir}/results
mkdir -p ${basedir}/tmp

sturgeon_model=/scratch/tmp/thomachr/software/sturgeon/include/models/general.zip
dorado_model=/scratch/tmp/thomachr/software/dorado-0.4.2-linux-x64/models/dna_r10.4.1_e8.2_400bps_hac@v4.2.0

base=`basename ${basedir}/$1`
mkdir -p ${basedir}/tmp/${base}
mkdir -p ${basedir}/tmp/${base}/hg38
mkdir -p ${basedir}/tmp/${base}/chm13v2
mkdir -p ${basedir}/results/${base}
mkdir -p ${basedir}/results/${base}/cnv

# Dorado Basecalling
dorado basecaller --modified-bases 5mCG_5hmCG -x cpu \
	$dorado_model ${basedir}/$1 > ${basedir}/tmp/${base}/${base}_calls.bam

# Dorado Alignment chm13v2
dorado aligner /scratch/tmp/thomachr/references/T2T/chm13v2.0.fa -t 36 \
	${basedir}/tmp/${base}/${base}_calls.bam > ${basedir}/tmp/${base}/chm13v2/${base}_chm13v2_alignment.bam
	
# Dorado Alignment hg38
dorado aligner /scratch/tmp/thomachr/references/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
	-t 36 ${basedir}/tmp/${base}/${base}_calls.bam > ${basedir}/tmp/${base}/hg38/${base}_hg38_alignment.bam

module unload
ml palma/2020b GCC/10.2.0 OpenMPI/4.0.5 R/4.0.3

Rscript cnv_plot.R ${basedir}/tmp/${base}/hg38/ ${basedir}/results/${base}/cnv

# Modkit
modkit adjust-mods --convert h m ${basedir}/tmp/${base}/chm13v2/${base}_chm13v2_alignment.bam ${basedir}/tmp/${base}/${base}_calls_modkit.bam
modkit extract ${basedir}/tmp/${base}/${base}_calls_modkit.bam ${basedir}/tmp/${base}/${base}_calls_modkit.txt

# Sturgeon
module unload
ml palma/2021a  GCC/10.3.0  OpenMPI/4.1.1 ONNX-Runtime/1.10.0
sturgeon inputtobed -i ${basedir}/tmp/${base}/ -o ${basedir}/tmp/${base}/ -s modkit

sturgeon predict \
-i ${basedir}/tmp/${base} \
-o ${basedir}/results/${base} \
--model-files $sturgeon_model \
--plot-results
