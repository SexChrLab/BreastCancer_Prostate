#!/bin/bash
#SBATCH --job-name=QC_Trimmomatic_snakemake # Job name
#SBATCH --mem-per-cpu=16000
#SBATCH -o slurm.%j.out                # STDOUT (%j = JobId)
#SBATCH -e slurm.%j.err                # STDERR (%j = JobId)
#SBATCH --mail-type=END,FAIL           # notifications for job done & fail
#SBATCH --mail-user=ajdeshpa@asu.edu # send-to address
#SBATCH -n 16
#SBATCH -t 96:00:00
#SBATCH -p private

newgrp wilsonsayreslab
cd /mnt/storage/SAYRES/Isoforms_Breast_Prostate/Scripts/QC_Trimmomatic
source activate QC_Trimmomatic

date
export PERL5LIB=/packages/6x/vcftools/0.1.12b/lib/perl5/site_perl
#export JVM_ARGS="-Xms4096m -Xmx4096m"
ulimit -c unlimited
snakemake -j 20 --nolock --keep-target-files --rerun-incomplete --cluster "sbatch -n 16 -t 96:00:00 --mail-type=END,FAIL --mail-user=ajdeshpa@asu.edu"
date
