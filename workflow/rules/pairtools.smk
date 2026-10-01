rule hic_process_pairs:
    input:
        raw_bam = "results/{sample}/raw_unsorted_hic.bam",
        fai = config["ref_genome"]["faidx"]
    output:
        final_bam = "results/{sample}/hic_mapped.bam",
        bai = "results/{sample}/hic_mapped.bam.bai",
        stats = "results/{sample}/hic_stats.txt",
        pairs = "results/{sample}/hic.pairs"
    params:
        min_mapq = config["pairtools"]["min_mapq"],
        walks_policy = config["pairtools"]["walks_policy"],
        max_inter_align_gap = config["pairtools"]["max_inter_align_gap"]
    conda:
        "../envs/pairtools.yaml"
    threads: config["max_threads"]
    resources:
        tmpdir = "tmp/"
    shell:
        """
        mkdir -p {resources.tmpdir}

        # Stream the raw BAM with headers into pairtools
        samtools view -h -@ {threads} {input.raw_bam} | \
        pairtools parse --min-mapq {params.min_mapq} \
            --walks-policy {params.walks_policy} \
            --max-inter-align-gap {params.max_inter_align_gap} \
            --nproc-in {threads} --nproc-out {threads} \
            --chroms-path {input.fai} | \
        pairtools sort --tmpdir {resources.tmpdir} --nproc {threads} | \
        pairtools dedup --nproc-in {threads} --nproc-out {threads} \
            --mark-dups --output-stats {output.stats} | \
        pairtools split --nproc-in {threads} --nproc-out {threads} \
            --output-pairs {output.pairs} --output-sam - | \
        samtools view -bS -@ {threads} | \
        samtools sort -@ {threads} -o {output.final_bam}

        samtools index {output.final_bam}
        """