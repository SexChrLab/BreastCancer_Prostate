#!/bin/bash
#SBATCH --job-name=Salmon_snakemake # Job name
#SBATCH -o slurm.%j.out                # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err                # STDERR (%j = JobId)
#SBATCH --mail-type=END,FAIL           # notifications for job done & fail
#SBATCH --mail-user=ajdeshpa@asu.edu # send-to address
#SBATCH -n 1
#SBATCH -t 96:00:00
#SBATCH -p private

newgrp combinedlab
cd /mnt/storage/SAYRES/Isoforms_Breast_Prostate/Scripts/Salmon
source activate Salmon

date
snakemake -j 20 --nolock --keep-target-files --rerun-incomplete --cluster "sbatch -n 16 -t 96:00:00 --mem 24000 --mail-type=END,FAIL --mail-user=ajdeshpa@asu.edu"
date
