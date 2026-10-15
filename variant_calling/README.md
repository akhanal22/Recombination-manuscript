# Joint variant calling

These SLURM scripts use GATK to call SNPs and indels from individual BAM files and jointly genotype samples against `Salix_purpurea_var_94006.mainGenome-noZ.fasta`.

## Workflow

Run the scripts in this order, waiting for each stage to finish successfully:

| Script | Purpose | Output |
| --- | --- | --- |
| `08-individual_vcf.sh` | Run HaplotypeCaller in GVCF mode for each sample | `<sample>.g.vcf` |
| `09-genodb.sh` | Import the sample GVCFs into GenomicsDB | `genodb/` |
| `10-raw_vcf.sh` | Jointly genotype samples with GenotypeGVCFs | `vcf/genotypes.raw.vcf` |

## Requirements and inputs

- GATK, compatible Java, and SLURM.
- The reference FASTA with its `.fai` index and sequence dictionary.
- Coordinate-sorted, indexed BAMs named `dBAM/<sample>.dedup.bam`.
- `names.list`: one sample prefix per line, without a header, for step 08.
- `all.sample_map`: a tab-separated file containing each sample name and its GVCF path, for step 09.
- `chromosome.list`: reference contig names to include, one per line.

For example, after setting the GVCF output directory in step 08 to `gvcf/`, prepare the sample map and interval list from the working directory:

```bash
mkdir -p gvcf vcf
while read -r sample; do
    printf '%s\tgvcf/%s.g.vcf\n' "$sample" "$sample"
done < names.list > all.sample_map
cut -f1 Salix_purpurea_var_94006.mainGenome-noZ.fasta.fai > chromosome.list
```

GVCFs must have the accompanying indexes required by GATK. All paths in the sample map must resolve from the directory where step 09 runs.
