# sturgeon_pipeline
Performs Sturgeon calssification and CNV calling of nanopore reads. Takes folders containing pod5 files as input. Uses SLURM on the PALMA-II HPC cluster @ University of Münster.

Bascalling is performed on the gpua100 partition (Nvidia A100), actual Sturgeon classification runs on the requeue partition.
Wall-clock time for 3 GB of pod5 files:

```
Dorado Basecalling = 00:05:29
Sturgeon Classification = 00:01:20
```
