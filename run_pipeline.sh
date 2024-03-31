#!/bin/bash

dirs=$(find ./pod5 -mindepth 1 -maxdepth 1 -type d -print|sort)

for dir in $dirs; do
	base=`basename $dir`
	echo "submitting job ${base}"
	sbatch --job-name=${base}_basecalling ./scripts/gpu_basecalling.sh $dir
done
