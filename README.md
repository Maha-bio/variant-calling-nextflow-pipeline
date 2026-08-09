# Germline Variant Calling Pipeline with Nextflow

## Project Overview

This repository contains a **reproducible germline variant calling workflow for human Whole Exome Sequencing (WES) data**, developed using **Nextflow DSL2**.

The objective of this project is to build a modular and reproducible bioinformatics pipeline for the identification of **germline single-nucleotide variants (SNVs) and small insertions/deletions (indels)** from Illumina whole-exome sequencing data.

The workflow is designed to reproduce a typical analysis strategy used in genomics and molecular genetics laboratories, from raw sequencing reads to annotated germline variants.

The pipeline is being developed and tested locally using a personal computer.

---

# Workflow

```text
Paired-end WES FASTQ files
            |
            v
       FastQC
   Raw read QC
            |
            v
          fastp
   Adapter trimming
   Quality filtering
            |
            v
       FastQC
 Post-trimming QC
            |
            v
       BWA-MEM2
     Read alignment
            |
            v
     SAMtools
 Sort and index BAM
            |
            v
  GATK MarkDuplicates
            |
            v
        GATK BQSR
 Base Quality Score
    Recalibration
            |
            v
   GATK HaplotypeCaller
     Germline calling
            |
            v
        Germline VCF
            |
            v
 Variant annotation
      VEP / SnpEff
            |
            v
 Biological interpretation
```

---

# Biological Dataset

## Dataset

The pipeline is being tested using publicly available **human whole-exome sequencing data** from the NCBI Sequence Read Archive (SRA).

### Study

**Expanding whole exome resequencing into non-human primates**

Study accession:

```text
SRP007211
```

Experiment:

```text
SRX077395
```

Run:

```text
SRR303351
```

### Sample

```text
Human Mbuti pygmy (NA10495)
```

Organism:

```text
Homo sapiens
```

### Sequencing characteristics

| Property      | Description                  |
| ------------- | ---------------------------- |
| Experiment    | Whole Exome Resequencing     |
| Organism      | *Homo sapiens*               |
| Source        | Genomic DNA                  |
| Strategy      | Whole Exome Sequencing (WXS) |
| Selection     | Hybrid Selection             |
| Platform      | Illumina Genome Analyzer II  |
| Layout        | Paired-end                   |
| Spots         | ~23.9 million                |
| Bases         | ~3.8 Gb                      |
| Download size | ~2.1 Gb                      |

The dataset is suitable for demonstrating a **germline variant calling workflow from WES data**.

---

# Project Objectives

The main objectives are:

* Perform quality control of raw sequencing reads
* Remove sequencing adapters and low-quality bases
* Perform post-trimming quality control
* Align reads to the human reference genome
* Generate sorted and indexed BAM files
* Mark PCR duplicates
* Perform base quality score recalibration
* Call germline variants
* Generate a VCF file
* Annotate detected variants
* Produce a reproducible and modular workflow

---

# Technologies

## Workflow Management

| Tool     | Purpose                               |
| -------- | ------------------------------------- |
| Nextflow | Workflow orchestration                |
| Conda    | Environment and dependency management |

## Quality Control

| Tool   | Purpose                                |
| ------ | -------------------------------------- |
| FastQC | Sequencing read quality assessment     |
| fastp  | Adapter trimming and quality filtering |

## Alignment

| Tool     | Purpose                           |
| -------- | --------------------------------- |
| BWA-MEM2 | Alignment to the reference genome |

## BAM Processing

| Tool                | Purpose                          |
| ------------------- | -------------------------------- |
| SAMtools            | BAM sorting and indexing         |
| GATK MarkDuplicates | PCR duplicate identification     |
| GATK BQSR           | Base quality score recalibration |

## Variant Calling

| Tool                 | Purpose                        |
| -------------------- | ------------------------------ |
| GATK HaplotypeCaller | Germline SNV and indel calling |

## Variant Annotation

Planned annotation tools include:

* Ensembl VEP
* SnpEff

---

# Reference Genome

The pipeline is designed for the human reference genome:

```text
GRCh38 / hg38
```

Reference files are stored locally under:

```text
data/reference/
```

The reference genome and required indexes are **not included in the GitHub repository** because of their large size.

---

# Repository Structure

```text
variant-calling-nextflow-pipeline/

├── main.nf
├── nextflow.config
├── environment.yml
├── README.md
│
├── modules/
│   ├── fastqc.nf
│   ├── fastp.nf
│   ├── bwa_mem2.nf
│   ├── samtools.nf
│   └── gatk.nf
│
├── data/
│   ├── raw/
│   │   └── *.fastq.gz
│   │
│   └── reference/
│       └── GRCh38 reference files
│
├── results/
│   ├── fastqc/
│   ├── fastp/
│   ├── alignment/
│   ├── bam/
│   ├── variants/
│   └── annotation/
│
├── logs/
│
└── work/
```

Large sequencing files, reference genomes, BAM files and intermediate files should **not be committed to GitHub**.

---

# Installation

## Clone the repository

```bash
git clone https://github.com/Maha-bio/variant-calling-nextflow-pipeline.git

cd variant-calling-nextflow-pipeline
```

## Create the Conda environment

```bash
conda env create -f environment.yml
```

Activate the environment:

```bash
conda activate variantcalling
```

## Verify Nextflow

```bash
nextflow -version
```

## Verify Java

Nextflow requires a compatible Java installation.

```bash
java -version
```

---

# Input Data

The pipeline uses paired-end FASTQ files.

Expected structure:

```text
data/raw/

├── SRR303351_1.fastq.gz
└── SRR303351_2.fastq.gz
```

Sample information is provided through:

```text
data/samplesheet.csv
```

Example:

```csv
sample,fastq_1,fastq_2
SRR303351,data/raw/SRR303351_1.fastq.gz,data/raw/SRR303351_2.fastq.gz
```

---

# Workflow Execution

The complete workflow is automated using **Nextflow DSL2**.

## Preview the workflow

Before execution:

```bash
nextflow run main.nf -preview
```

## Run the pipeline

```bash
nextflow run main.nf
```

## Resume an interrupted workflow

Nextflow allows previously completed processes to be reused:

```bash
nextflow run main.nf -resume
```

## Specify the number of CPUs

For a local computer:

```bash
nextflow run main.nf --cores 2
```

Resource allocation is adapted to the available local hardware.

---

# Analysis Steps

## 1. Raw Read Quality Control

FastQC evaluates:

* Per-base sequence quality
* Sequence quality scores
* GC content
* Sequence duplication
* Adapter contamination
* Overrepresented sequences

Results:

```text
results/fastqc/
```

---

## 2. Read Preprocessing

`fastp` performs:

* Adapter removal
* Quality filtering
* Low-quality base trimming
* Read statistics generation

Outputs include:

```text
results/fastp/

├── *.trimmed.fastq.gz
├── *_fastp.html
└── *_fastp.json
```

---

## 3. Post-trimming Quality Control

FastQC is run again on the cleaned reads to verify that:

* Adapter contamination has been reduced
* Read quality has improved
* Low-quality bases have been removed
* The resulting reads remain suitable for alignment

Results:

```text
results/fastqc/
```

---

## 4. Read Alignment

Cleaned reads are aligned against **GRCh38** using BWA-MEM2.

The output is a BAM file containing genomic alignments.

Conceptually:

```text
FASTQ
  |
  v
BWA-MEM2
  |
  v
SAM
  |
  v
BAM
```

---

## 5. BAM Processing

SAMtools is used to:

* Convert SAM to BAM
* Sort alignments
* Index BAM files
* Generate alignment statistics

Expected outputs include:

```text
sample.sorted.bam
sample.sorted.bam.bai
```

---

## 6. Duplicate Marking

GATK MarkDuplicates identifies reads originating from potential PCR duplication.

Duplicate marking is important for WES because PCR amplification can introduce duplicated reads that should not be interpreted as independent observations.

---

## 7. Base Quality Score Recalibration

GATK BQSR is planned to recalibrate base quality scores using known variant resources.

This step aims to reduce systematic sequencing errors before variant calling.

---

## 8. Germline Variant Calling

GATK HaplotypeCaller will be used to identify candidate germline:

* SNVs
* Small insertions
* Small deletions

The expected output is a VCF file:

```text
results/variants/
└── SRR303351.g.vcf.gz
```

---

# Variant Annotation

After variant calling, variants will be annotated using a tool such as **Ensembl Variant Effect Predictor (VEP)** or **SnpEff**.

Annotation will provide information such as:

* Gene
* Transcript
* Variant consequence
* Coding effect
* Amino acid change
* dbSNP identifiers
* Population allele frequencies

Example consequences include:

```text
missense_variant
synonymous_variant
stop_gained
splice_region_variant
frameshift_variant
```

---

# Reproducibility

This project follows reproducible bioinformatics practices:

* Nextflow DSL2 workflow management
* Modular process design
* Conda-based environment management
* Version-controlled source code
* Structured input and output directories
* Reproducible workflow execution
* Separation of raw data, intermediate files and final results

The pipeline is designed so that each analysis step can be executed independently and resumed when necessary.

---

# Local Development

The pipeline is developed and tested on a **personal computer running WSL2/Linux**, without relying on an high-performance computing cluster.

For production-scale datasets, HPC or cloud resources would be recommended.

---

# Current Development Status

### Completed

* [x] Nextflow project structure
* [x] Nextflow DSL2 workflow
* [x] Raw FASTQ input
* [x] Raw read FastQC
* [x] fastp preprocessing
* [x] Post-trimming FastQC
* [x] Local execution and testing

### In development

* [ ] GRCh38 reference integration
* [ ] BWA-MEM2 alignment
* [ ] SAMtools BAM processing
* [ ] GATK MarkDuplicates
* [ ] GATK BQSR
* [ ] GATK HaplotypeCaller
* [ ] VCF filtering
* [ ] Variant annotation
* [ ] Final variant report

---

# Future Improvements

Planned improvements include:

* Automated reference genome preparation
* Automated GATK resource management
* Variant quality filtering
* VEP/SnpEff annotation
* MultiQC reporting
* Automated summary reports
* Containerization with Docker or Singularity
* Support for multiple WES samples
* Joint germline variant calling
* Integration with HPC environments
* Workflow testing with Nextflow Tower / Seqera Platform

---

# Author

**Maha Abbaci**

Bioinformatics | Genomics | Computational Biology | AI for Healthcare

GitHub:

https://github.com/Maha-bio

---

# License

This project is intended for **academic, research and educational purposes**.

The sequencing data used in this project are publicly available through the NCBI Sequence Read Archive.
