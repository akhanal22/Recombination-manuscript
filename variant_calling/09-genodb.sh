#!/bin/bash
#SBATCH -J genodb
#SBATCH -N 1
#SBATCH --ntasks-per-node=50
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH -p nocona
#SBATCH -a 1-132:1
#SBATCH --export=ALL

gatk --java-options "-Xmx4g -Xms4g" GenomicsDBImport \
    --sample-name-map all.sample.map \
    --genomicsdb-workspace-path genodb \
    -L chromosome.list
