#!/bin/bash
#SBATCH -J all_ubam
#SBATCH -N 1
#SBATCH --ntasks-per-node=16
#SBATCH -o %x.%j.out
#SBATCH -e %x.%j.err
#SBATCH -p nocona
#SBATCH -a 1-132:1
#SBATCH --export=ALL

prefixNum="$SLURM_ARRAY_TASK_ID"
prefixNumP="$prefixNum"p
prefix=`sed -n "$prefixNumP" names.txt`

gatk FastqToSam --java-options "-Xmx8G" \
    --FASTQ "$prefix"_R1.fastq.gz \
    --FASTQ2 "$prefix"_R2.fastq.gz \
    --OUTPUT uBAM/"$prefix".unmapped.bam \
    --READ_GROUP_NAME Salix_nivalis_SLR \
    --SAMPLE_NAME "$prefix" \
    --LIBRARY_NAME NEBNext-"$prefix" \
    --PLATFORM_UNIT HT23LBBXX.6.1101 \
    --PLATFORM illumina \
    --SEQUENCING_CENTER OMRF \
    --RUN_DATE 2018-03-12T08:55:00+0500

