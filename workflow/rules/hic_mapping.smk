rule index_reference:
    input:
        assembly = config["ref_genome"]["fasta"]
    output:
        fai = config["ref_genome"]["faidx"],
        bwt = config["ref_genome"]["bwa_index_marker"]
    conda:
        "../envs/hic_mapping.yaml"
    threads: 4
    shell:
        """
        samtools faidx {input.assembly}
        bwa-mem2 index {input.assembly}
        """

rule hic_map_bwa2:
    input:
        assembly = config["ref_genome"]["fasta"],
        bwt = config["ref_genome"]["bwa_index_marker"],
        r1 = lambda wildcards: samples_df.loc[wildcards.sample, "hic_r1"],
        r2 = lambda wildcards: samples_df.loc[wildcards.sample, "hic_r2"]
    output:
        raw_bam = "results/{sample}/raw_unsorted_hic.bam" # wrap in 'temp()' after debugging to remove in production
    conda:
        "../envs/hic_mapping.yaml"
    threads: config["max_threads"]
    shell:
        """
        # Compress BWA-MEM2 output directly to BAM without coordinate sorting - pairtools will handle sorting
        bwa-mem2 mem -5SP -T0 -t {threads} {input.assembly} {input.r1} {input.r2} | \
        samtools view -b -@ {threads} -o {output.raw_bam}
        """

