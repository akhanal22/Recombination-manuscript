#!/bin/bash
#SBATCH -J dbam_pur
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


gatk --java-options "-Dsamjdk.compression_level=5 -Xms4000m" MarkDuplicates \
    --INPUT sBAM/"$prefix".sorted.bam \
    --OUTPUT dBAM/"$prefix".dedup.bam \
    --METRICS_FILE dBAM/"$prefix".dedup.metrics \
    --VALIDATION_STRINGENCY SILENT \
    --OPTICAL_DUPLICATE_PIXEL_DISTANCE 2500 \
    --ASSUME_SORT_ORDER 'coordinate' \
    --CREATE_INDEX true \
    --CREATE_MD5_FILE true
