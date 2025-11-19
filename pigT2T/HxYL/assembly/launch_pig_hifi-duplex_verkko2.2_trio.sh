#!/bin/bash -l

micromamba activate verkko-v2.2

verkko --version
verkko --slurm -d verkko2.2_hifi-duplex_trio --unitig-abundance 4 --red-run 8 40 8 --hifi hifi-duplex/*.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq.gz --screen pig_MT Pig_Mt.fasta --screen pig_rDNA Pig_rDNA.fasta --hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio
# for restart test with --snakeopts "--dry-run"
#verkko --slurm --snakeopts "--dry-run" -d verkko1.4.1_DC1.2_dorado_q12-10-7-5_extrahifi --red-run 4 32 8 --hifi hifi_data/*_DC_1.2.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq --hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio
