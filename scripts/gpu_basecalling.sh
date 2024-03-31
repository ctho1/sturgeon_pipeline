#!/bin/bash
#SBATCH --partition=gpua100
#SBATCH --nodes=1
#SBATCH --mem=30G
#SBATCH --ntasks-per-node=6
#SBATCH --gres=gpu:1
#SBATCH --time=0-01:00:00
#SBATCH --job-name=gpu_basecalling
#SBATCH --mail-type=ALL
#SBATCH --error ./logs/%x_%j.err.txt
#SBATCH --output ./logs/%x_%j.out.txt

ml palma/2022a
ml CUDA/11.7.0

basedir="."
base=`basename ${basedir}/$1`

mkdir -p ${basedir}/results
mkdir -p ${basedir}/tmp

dorado=/scratch/tmp/thomachr/software/dorado-0.5.3-linux-x64/bin
modkit=/scratch/tmp/thomachr/software/modkit

dorado_model=/scratch/tmp/thomachr/software/dorado-0.5.3-linux-x64/bin/dna_r10.4.1_e8.2_400bps_hac@v4.3.0
dorado_modification=/scratch/tmp/thomachr/software/dorado-0.5.3-linux-x64/bin/dna_r10.4.1_e8.2_400bps_hac@v4.3.0_5mCG_5hmCG@v1

mkdir -p ${basedir}/tmp/${base}
mkdir -p ${basedir}/tmp/${base}/hg38
mkdir -p ${basedir}/tmp/${base}/chm13v2
mkdir -p ${basedir}/results/${base}
mkdir -p ${basedir}/results/${base}/cnv

# Dorado Basecalling
$dorado/dorado basecaller --modified-bases-models $dorado_modification \
	$dorado_model ${basedir}/$1 > ${basedir}/tmp/${base}/${base}_calls.bam

# Dorado Alignment chm13v2
$dorado/dorado aligner /scratch/tmp/thomachr/references/T2T/chm13v2.0.fa \
	${basedir}/tmp/${base}/${base}_calls.bam > ${basedir}/tmp/${base}/chm13v2/${base}_chm13v2_alignment.bam
	
# Dorado Alignment hg38
$dorado/dorado aligner /scratch/tmp/thomachr/references/GRCh38/GCA_000001405.15_GRCh38_no_alt_analysis_set.fa \
	${basedir}/tmp/${base}/${base}_calls.bam > ${basedir}/tmp/${base}/hg38/${base}_hg38_alignment.bam

# Modkit
$modkit/modkit adjust-mods --convert h m ${basedir}/tmp/${base}/chm13v2/${base}_chm13v2_alignment.bam ${basedir}/tmp/${base}/${base}_calls_modkit.bam
$modkit/modkit extract ${basedir}/tmp/${base}/${base}_calls_modkit.bam ${basedir}/tmp/${base}/${base}_calls_modkit.txt

sbatch --job-name=${base}_sturgeon ${basedir}/scripts/run_sturgeon.sh $1
