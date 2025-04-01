#!/bin/bash
#SBATCH -J individual_vcf
#SBATCH -N 1
#SBATCH --ntasks-per-node=16
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH -p nocona
#SBATCH -a 1-132:1
#SBATCH --export=ALL

prefixNum="$SLURM_ARRAY_TASK_ID"
prefixNumP="$prefixNum"p
prefix=`sed -n "$prefixNumP" names.list`

gatk HaplotypeCaller \
    -R Salix_purpurea_var_94006.mainGenome-noZ.fasta \
    -L "$prefix" \
    -I dBAM/"$prefix".dedup.bam \
    -ERC GVCF \
    --heterozygosity 0.015 \
    --indel-heterozygosity 0.01 \
    -O /lustre/scratch/askhanal/snigra/gvcf/"$prefix".g.vcf

