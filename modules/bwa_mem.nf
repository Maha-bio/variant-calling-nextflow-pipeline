process BWA_MEM {

    tag "$sample"

    cpus 1
    memory '1500 MB'

    publishDir "${params.outdir}/bam", mode: 'copy'

    input:
    tuple val(sample), path(reads)
    path reference
    path bwa_indexes

    output:
    tuple val(sample), path("${sample}.sorted.bam"), emit: bam
    path "${sample}.sorted.bam.bai", emit: bai

    script:
    """
    bwa mem \
        -t ${task.cpus} \
        ${reference} \
        ${reads[0]} \
        ${reads[1]} \
        | samtools sort \
        -@ 1 \
        -o ${sample}.sorted.bam

    samtools index ${sample}.sorted.bam
    """
}