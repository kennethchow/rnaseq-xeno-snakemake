#!/bin/bash
#SBATCH --nodes 1
#SBATCH --cpus-per-task=16
#SBATCH --mem=70G
#SBATCH --output logs/50-50_%j.out
#SBATCH --error logs/50-50_%j.err

singularity run --bind $(pwd):/work-dir/ --bind /data3/:/data3/ --bind /data/:/data/ /data3/kchow/singularity-images/bulkrna_preproc.sif bash -c "snakemake --cores 16 --retries 3 --rerun-incomplete --jobs 5"
