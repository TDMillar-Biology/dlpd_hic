snakemake --dag > dag.tmp
cat dag.tmp | dot -Tpng > dag.png
