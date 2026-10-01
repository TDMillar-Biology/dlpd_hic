target="data/references/ISO1_r6.58"
echo "Attempting to access data from flybase ftp server"
echo "Files will be stored in ${target}"

mkdir ${target}

# Download the FASTA
wget -P data/references/ISO1_r6.58/ https://s3ftp.flybase.org/genomes/Drosophila_melanogaster/dmel_r6.58_FB2024_03/fasta/dmel-all-chromosome-r6.58.fasta.gz

# Download the GTF
#wget -P data/references/ISO1_r6.58/ https://s3ftp.flybase.org/genomes/Drosophila_melanogaster/dmel_r6.58_FB2024_03/gtf/dmel-all-r6.58.gtf.gz

gunzip data/references/ISO1_r6.58/*.gz
