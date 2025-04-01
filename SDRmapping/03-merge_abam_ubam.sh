#!/bin/bash
#SBATCH -J all_mbam
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

gatk --java-options "-Dsamjdk.compression_level=5 -Xms3000m" MergeBamAlignment \
    --VALIDATION_STRINGENCY SILENT \
    --EXPECTED_ORIENTATIONS FR \
    --ATTRIBUTES_TO_RETAIN X0 \
    --ALIGNED_BAM aBAM/"$prefix".aligned.bam \
    --UNMAPPED_BAM uBAM/"$prefix".unmapped.bam \
     --OUTPUT mBAM/"$prefix".merged.bam \
    --REFERENCE_SEQUENCE Salix_purpurea_var_94006.mainGenome-noZ.fasta \
    --PAIRED_RUN true \
    --SORT_ORDER 'unsorted' \
    --IS_BISULFITE_SEQUENCE false \
    --ALIGNED_READS_ONLY false \
    --CLIP_ADAPTERS false \
    --MAX_RECORDS_IN_RAM 2000000 \
    --ADD_MATE_CIGAR true \
    --MAX_INSERTIONS_OR_DELETIONS -1 \
    --PRIMARY_ALIGNMENT_STRATEGY MostDistant \
    --PROGRAM_RECORD_ID 'bwamem' \
    --PROGRAM_GROUP_VERSION '0.7.17-r1188' \
    --PROGRAM_GROUP_COMMAND_LINE 'bwa mem -K 100000000 -p -v 3 -t 16 -Y Salix_purpurea_var_94006.mainGenome-noZ.fasta /dev/stdin -' \
    --PROGRAM_GROUP_NAME 'bwamem' \
    --UNMAPPED_READ_STRATEGY COPY_TO_TAG \
    --ALIGNER_PROPER_PAIR_FLAGS true \
    --UNMAP_CONTAMINANT_READS true


