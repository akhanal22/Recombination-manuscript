#!/bin/bash
#SBATCH -J raw_vcf
#SBATCH -N 1
#SBATCH --ntasks-per-node=50
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH -p nocona
#SBATCH --export=ALL

gatk --java-options "-Xmx5g -Xms5g" GenotypeGVCFs \
    -R Salix_purpurea_var_94006.mainGenome-noZ.fasta \
    -O vcf/genotypes.raw.vcf \
    -G StandardAnnotation \
    --use-new-qual-calculator \
    -V gendb://genodb \
    --heterozygosity 0.015 \
    --indel-heterozygosity 0.01 \
    --stand-call-conf 30.0
