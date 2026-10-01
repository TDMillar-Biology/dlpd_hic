rule cooler_cload:
    input:
        pairs = "results/{sample}/hic.pairs",
        fai = config["ref_genome"]["faidx"]
    output:
        cool = "results/{sample}/hic_10kb.cool",
        chrom_sizes = "results/{sample}/chrom.sizes"
    conda:
        "../envs/cooler.yaml"
    threads: config["max_threads"]
    shell:
        """
        # Create a chrom.sizes file from the FASTA index
        cut -f 1,2 {input.fai} > {output.chrom_sizes}

        # Bin the pairs into a 10kb contact matrix
        # Pairtools output format typically has chrom1, pos1, chrom2, pos2 in columns 2, 3, 4, 5
        cooler cload pairs -c1 2 -p1 3 -c2 4 -p2 5 \
            {output.chrom_sizes}:10000 \
            {input.pairs} {output.cool}
        """

rule cooler_zoomify_ice:
    input:
        cool = "results/{sample}/hic_10kb.cool"
    output:
        mcool = "results/{sample}/hic.mcool"
    conda:
        "../envs/cooler.yaml"
    threads: config["max_threads"]
    shell:
        """
        # Perform ICE normalization on the base 10kb matrix
        cooler balance -p {threads} {input.cool}

        # Generate the multi-resolution mcool file and balance the new resolutions
        cooler zoomify --balance -p {threads} \
            --resolutions 10000,50000,100000,500000,1000000 \
            -o {output.mcool} {input.cool}
        """

MAIN_CHROMS = ["2L", "2R", "3L", "3R", "4", "X", "Y"]

rule plot_hicexplorer_chromosome:
    input:
        mcool = "results/{sample}/hic.mcool"
    output:
        pdf = "results/{sample}/hic_heatmap_{chrom}.pdf",
        png = "results/{sample}/hic_heatmap_{chrom}.png"
    conda:
        "../envs/hicexplorer.yaml"
    threads: 1 # Plotting individual isolated matrices is very lightweight
    params:
        plot_res = "10000",
        cmap = "viridis",
        vmax = "10000" # Absolute threshold
    shell:
        """;
        # Plot PDF
        hicPlotMatrix -m {input.mcool}::/resolutions/{params.plot_res} \
            -o {output.pdf} \
            --region {wildcards.chrom} \
            --log1p --clearMaskedBins \
            --colorMap {params.cmap} \
            --vMax {params.vmax} \
            --title "Hi-C Contact Map: {wildcards.sample} - Region {wildcards.chrom}"
            
        # Plot PNG
        hicPlotMatrix -m {input.mcool}::/resolutions/{params.plot_res} \
            -o {output.png} \
            --region {wildcards.chrom} \
            --log1p --clearMaskedBins \
            --colorMap {params.cmap} \
            --vMax {params.vmax} \
            --title "Hi-C Contact Map: {wildcards.sample} - Region {wildcards.chrom}"
        """