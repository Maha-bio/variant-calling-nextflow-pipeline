process FASTQC_RAW {

    tag "$sample"

    cpus 1
    memory '1 GB'

    publishDir "${params.outdir}/fastqc/raw", mode: 'copy'

    input:
    tuple val(sample), path(reads)

    output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

    script:
    """
    fastqc \
        --threads ${task.cpus} \
        ${reads} \
        --outdir .
    """
}


process FASTQC_POSTTRIM {

    tag "$sample"

    cpus 1
    memory '1 GB'

    publishDir "${params.outdir}/fastqc/post_trim", mode: 'copy'

    input:
    tuple val(sample), path(reads)

    output:
    path "*_fastqc.html"
    path "*_fastqc.zip"

    script:
    """
    fastqc \
        --threads ${task.cpus} \
        ${reads} \
        --outdir .
    """
}