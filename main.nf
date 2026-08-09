/*
 * Germline Variant Calling Pipeline
 * WES Paired-End
 *
 * Steps:
 * 1. Raw read QC
 * 2. Read trimming
 * 3. Post-trimming QC
 * 4. Alignment with BWA-MEM
 * 5. BAM sorting and indexing
 */

nextflow.enable.dsl=2

params.samplesheet = "data/samplesheet.csv"
params.outdir     = "results"
params.reference  = "data/reference/GRCh38.fa"


/*
 * Modules
 */

include { FASTQC_RAW; FASTQC_POSTTRIM } from './modules/fastqc.nf'
include { FASTP } from './modules/fastp.nf'
include { BWA_MEM } from './modules/bwa_mem.nf'


workflow {

    /*
     * Read sample information
     */

    samples = Channel
        .fromPath(params.samplesheet)
        .splitCsv(header: true)


    /*
     * Paired-end FASTQ channel
     */

    reads = samples.map { row ->

        tuple(
            row.sample,
            [
                file(row.fastq_1),
                file(row.fastq_2)
            ]
        )
    }


    /*
     * 1. Raw FASTQC
     */

    FASTQC_RAW(reads)


    /*
     * 2. Adapter trimming and quality filtering
     */

    trimmed_reads = FASTP(reads)


    /*
     * 3. Post-trimming FASTQC
     */

    post_trim_reads = trimmed_reads.trimmed.map { sample, r1, r2 ->

        tuple(
            sample,
            [r1, r2]
        )
    }

    FASTQC_POSTTRIM(post_trim_reads)


      /*
     * 4. Alignment with BWA-MEM
     */

    reference = Channel.fromPath(
        "${params.reference}",
        checkIfExists: true
    )

    bwa_indexes = Channel.fromPath(
     "${params.reference}.amb",
        checkIfExists: true
    )
    .mix(
        Channel.fromPath("${params.reference}.ann", checkIfExists: true)
    )
    .mix(
        Channel.fromPath("${params.reference}.bwt", checkIfExists: true)
    )
    .mix(
        Channel.fromPath("${params.reference}.pac", checkIfExists: true)
    )
    .mix(
        Channel.fromPath("${params.reference}.sa", checkIfExists: true)
    )
    .collect()

    BWA_MEM(
        post_trim_reads,
        reference,
        bwa_indexes
    )
}