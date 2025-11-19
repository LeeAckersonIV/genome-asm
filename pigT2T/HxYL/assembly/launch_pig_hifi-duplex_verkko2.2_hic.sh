#!/bin/bash -l

micromamba activate verkko-v2.2.1

verkko --version
verkko --slurm -d verkko2.2_hifi-duplex_hic --unitig-abundance 4 --ovb-run 8 32 32 --red-run 8 40 8 --hifi hifi-duplex/*.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq.gz --screen pig_MT Pig_Mt.fasta --screen pig_rDNA Pig_rDNA.fasta --hic1 Omni-C/240903_A00291_0583_BHJ2GYDRX5_1_31671AA0001L02_1.fastq.gz --hic2 Omni-C/240903_A00291_0583_BHJ2GYDRX5_1_31671AA0001L02_2.fastq.gz
#verkko --slurm --snakeopts "--dry-run" -d verkko2.2_hifi-duplex_hic --unitig-abundance 4 --ovb-run 8 32 32 --red-run 8 40 8 --hifi hifi-duplex/*.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq.gz --screen pig_MT Pig_Mt.fasta --screen pig_rDNA Pig_rDNA.fasta --hic1 Omni-C/240903_A00291_0583_BHJ2GYDRX5_1_31671AA0001L02_1.fastq.gz --hic2 Omni-C/240903_A00291_0583_BHJ2GYDRX5_1_31671AA0001L02_2.fastq.gz
#verkko --slurm -d verkko2.2_hifi-duplex_hic --snakeopts "--dry-run" --unitig-abundance 4 --ovb-run 8 32 32 --red-run 8 40 8 --hifi hifi-duplex/*.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq.gz --screen pig_MT Pig_Mt.fasta --screen pig_rDNA Pig_rDNA.fasta --hic1 Omni-C/*.fastq.gz --hic2 Omni-C/*.fastq.gz
# for restart test with --snakeopts "--dry-run" if that looks wrong, run --snakeopts "--touch" and try again.
