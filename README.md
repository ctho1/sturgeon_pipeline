# sturgeon_pipeline
Performs Sturgeon calssification and CNV calling of nanopore reads. Takes folders containing pod5 files as input. Uses SLURM on the PALMA-II HPC cluster @ University of Münster.

Bascalling is performed on the gpua100 or gpu2080 partition (Nvidia A100 or GeForce RTX 2080 Ti), actual Sturgeon classification runs on the requeue partition.
Wall-clock time for 3 GB of pod5 files @gpua100:

```
Dorado Basecalling = 00:05:29
Sturgeon Classification = 00:01:20
```
