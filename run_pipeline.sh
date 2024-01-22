#!/bin/bash

dirs=$(find ./pod5 -mindepth 1 -maxdepth 1 -type d -print|sort)

for dir in $dirs; do
	base=`basename $dir`
	echo "submitting job ${base}"
	sbatch ./scripts/slurm_script_pipeline.sh $dir
done
