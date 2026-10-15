# Read mapping for sex-determining region analysis

This directory contains five SLURM batch scripts for processing paired-end Illumina sequencing reads for downstream analysis of the sex-determining region (SDR). The workflow converts FASTQ files to unmapped BAM files, aligns reads to a reference genome, restores read metadata, sorts alignments, and marks duplicate reads.

The scripts use the reference `Salix_purpurea_var_94006.mainGenome-noZ.fasta` and assign the read-group identifier `Salix_nivalis_SLR`. They produce genome-wide alignment files.

## Workflow and files

Run the scripts in numerical order for each sample:

| Step | Script | Main operation | Main output |
| --- | --- | --- | --- |
| 1 | `01-ubam_all.sh` | Convert paired FASTQ files to an unmapped BAM with sample and read-group metadata | `uBAM/<sample>.unmapped.bam` |
| 2 | `02-alignedbam.sh` | Convert the unmapped BAM to an interleaved FASTQ stream and align with BWA-MEM | `aBAM/<sample>.aligned.bam` |
| 3 | `03-merge_abam_ubam.sh` | Merge alignments with the original unmapped BAM metadata | `mBAM/<sample>.merged.bam` |
| 4 | `04-sortedbam.sh` | Sort by genomic coordinate and calculate reference-dependent tags | `sBAM/<sample>.sorted.bam` |
| 5 | `05-markduplicatedreads_bam.sh` | Mark duplicate reads and write duplication metrics | `dBAM/<sample>.dedup.bam` |



## Requirements

- A Linux environment with Bash and a SLURM scheduler.
- GATK with the Picard tools used by these scripts: `FastqToSam`, `SamToFastq`, `MergeBamAlignment`, `SortSam`, `SetNmMdAndUqTags`, and `MarkDuplicates`.
- Java compatible with the installed GATK release.
- BWA with the `mem` command.
- SAMtools.
- Paired-end FASTQ files, a sample list, and an indexed reference genome.

The commands `gatk`, `bwa`, and `samtools` must be available on `PATH` in the compute jobs. Load your cluster's modules or activate the appropriate environment before submission, or add the setup commands to each script. Exact software versions are not pinned in this directory. Step 3 records `0.7.17-r1188` as the BWA program version in the BAM header; this is a fixed metadata value and does not verify the installed version.

## Prepare the inputs

### 1. Working directory and sample list

Submit the jobs from a working directory containing the scripts, reference, FASTQ files, and `names.txt`. All paths in the scripts are relative to the job's working directory.

Create `names.txt` with one sample prefix per line, without a header, blank lines, or FASTQ suffixes. For example:

```text
sample01
sample02
sample03
```

Each prefix must match a pair of files named:

```text
<sample>_R1.fastq.gz
<sample>_R2.fastq.gz
```

Each SLURM array task reads the corresponding line of `names.txt`. Task 1 processes the first sample, task 2 processes the second, and so on. Ensure that prefixes are unique so that output files are not overwritten.

### 2. Output directories

The scripts do not create their output directories. Create them before running:

```bash
mkdir -p uBAM aBAM mBAM sBAM dBAM
```

### 3. Reference genome

Place the reference FASTA in the working directory. Prepare the BWA index, FASTA index, and sequence dictionary once:

```bash
bwa index Salix_purpurea_var_94006.mainGenome-noZ.fasta

samtools faidx Salix_purpurea_var_94006.mainGenome-noZ.fasta

gatk CreateSequenceDictionary \
    -R Salix_purpurea_var_94006.mainGenome-noZ.fasta \
    -O Salix_purpurea_var_94006.mainGenome-noZ.dict
```

If using another reference, update its path in steps 2, 3, and 4, including the recorded command-line metadata in step 3. Use the same reference for alignment, merging, and tag calculation.

## What each step does

### Step 1: Create an unmapped BAM

`01-ubam_all.sh` runs `gatk FastqToSam` on the paired FASTQ files. The unmapped BAM preserves the original reads and attaches metadata that can be carried through alignment.

| Metadata field | Value in the script |
| --- | --- |
| Read-group name | `Salix_nivalis_SLR` |
| Sample name | Sample prefix from `names.txt` |
| Library name | `NEBNext-<sample>` |
| Platform unit | `HT23LBBXX.6.1101` |
| Platform | `illumina` |
| Sequencing center | `OMRF` |
| Run date | `2018-03-12T08:55:00+0500` |

These values describe the original dataset. Update them to match any new sequencing dataset, especially when combining multiple libraries or sequencing runs.

### Step 2: Align reads

`02-alignedbam.sh` streams reads from `gatk SamToFastq` into `bwa mem`, then converts the SAM output to BAM with `samtools view`. No intermediate FASTQ or SAM file is written to disk.

The BWA command uses 16 threads (`-t 16`), interleaved paired-end input (`-p`), a fixed input batch size (`-K 100000000`), and soft clipping for supplementary alignments (`-Y`). The resulting alignment BAM is an intermediate file for step 3.

### Step 3: Merge alignments and original metadata

`03-merge_abam_ubam.sh` runs `gatk MergeBamAlignment` using the aligned BAM and the original unmapped BAM. This combines alignment information with the original read and read-group metadata.

The script specifies FR pair orientation, retains unmapped reads, adds mate CIGAR information, disables adapter clipping during this step, and enables contaminant-read handling through `UNMAP_CONTAMINANT_READS=true`. Its output sort order is explicitly `unsorted`; coordinate sorting occurs in step 4.

### Step 4: Sort and calculate alignment tags

`04-sortedbam.sh` pipes `gatk SortSam` into `gatk SetNmMdAndUqTags`. It sorts alignments by reference coordinate and calculates the `NM`, `MD`, and `UQ` tags using the reference sequence.

The output is `sBAM/<sample>.sorted.bam`, together with a BAM index and an MD5 checksum file. These tags describe edit distance, reference mismatches/deletions, and a base-quality-based alignment measure, respectively.

### Step 5: Mark duplicate reads

`05-removeduplicatedreads_bam.sh` runs `gatk MarkDuplicates` on the coordinate-sorted BAM. It writes:

- `dBAM/<sample>.dedup.bam`: the final BAM with duplicate flags.
- `dBAM/<sample>.dedup.metrics`: duplicate metrics.
- A BAM index and an MD5 checksum file.

The optical duplicate pixel distance is set to `2500`. Review this setting for the sequencing instrument used. The `.dedup.bam` suffix is an output naming convention; it does not mean duplicate records have been physically removed.

## Run on SLURM

The supplied scripts define arrays of **132 tasks** (`#SBATCH -a 1-132:1`) and request one node with 16 tasks per node. Step 1 uses partition `nocona`; steps 2–5 use `quanah`. Change these settings for your cluster and sample count.

The following example overrides the array size using `names.txt` and submits the stages with dependencies. It assumes the software environment, partitions, directories, and inputs have already been prepared:
ed by the downstream method and record software versions and reference provenance when reproducing the analysis.
