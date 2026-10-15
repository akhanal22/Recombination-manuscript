Before running this file, all.sample.map file is created which is basically first column with sample name and second with its location : while read -r i; 
    do printf "$i\tgvcf/$i.g.vcf\n"; done < names.txt > all.sample_map. chromosome.list is the file listing all the chromosomes in reference genome which i generated using grep command and removed the ">" sign using sed command.

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
    --sample-name-map all.sample_map \
    --genomicsdb-workspace-path genodb \
    -L chromosome.list
