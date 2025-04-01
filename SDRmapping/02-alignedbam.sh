#!/bin/bash
#SBATCH -J all_abam
#SBATCH -N 1
#SBATCH --ntasks-per-node=16
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH -p quanah
#SBATCH -a 1-132:1
#SBATCH --export=ALL

prefixNum="$SLURM_ARRAY_TASK_ID"
prefixNumP="$prefixNum"p
prefix=`sed -n "$prefixNumP" names.txt`

gatk --java-options "-Dsamjdk.compression_level=5 -Xms3000m" SamToFastq \
    --INPUT uBAM/"$prefix".unmapped.bam \
    --FASTQ /dev/stdout \
    --INTERLEAVE true \
    --NON_PF true \
    | \
    bwa mem -K 100000000 -p -v 3 -t 16 \
    -Y Salix_purpurea_var_94006.mainGenome-noZ.fasta \
    /dev/stdin - \
    | \
    samtools view -1 - > aBAM/"$prefix".aligned.bam

