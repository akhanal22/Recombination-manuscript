#!/bin/bash
#SBATCH -J sbam_all
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

gatk --java-options "-Dsamjdk.compression_level=5 -Xms4000m" SortSam \
    --INPUT mBAM/"$prefix".merged.bam \
    --OUTPUT /dev/stdout \
    --SORT_ORDER 'coordinate' \
    --CREATE_INDEX false \
    --CREATE_MD5_FILE false \
    | \
    gatk --java-options "-Dsamjdk.compression_level=5 -Xms500m" SetNmMdAndUqTags \
    --INPUT /dev/stdin \
    --OUTPUT sBAM/"$prefix".sorted.bam \
    --CREATE_INDEX true \
    --CREATE_MD5_FILE true \
    --REFERENCE_SEQUENCE Salix_purpurea_var_94006.mainGenome-noZ.fasta
