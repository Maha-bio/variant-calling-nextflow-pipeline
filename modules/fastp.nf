process FASTP {

    tag "$sample"

    cpus 1
    memory '1 GB'

    publishDir "${params.outdir}/fastp", mode: 'copy'

    input:
    tuple val(sample), path(reads)

    output:
    tuple val(sample), path("${sample}_R1.trimmed.fastq.gz"), path("${sample}_R2.trimmed.fastq.gz"), emit: trimmed
    path "${sample}_fastp.html"
    path "${sample}_fastp.json"

    script:
    def read1 = reads[0]
    def read2 = reads[1]

    """
    fastp \
        --in1 ${read1} \
        --in2 ${read2} \
        --out1 ${sample}_R1.trimmed.fastq.gz \
        --out2 ${sample}_R2.trimmed.fastq.gz \
        --html ${sample}_fastp.html \
        --json ${sample}_fastp.json \
        --thread ${task.cpus}
    """
}