# For terminal animal LIB212039 #
# ============================= #

# meryl count
/mnt/research/qgg/software/meryl-1.4.1/bin/meryl k=21 count threads=16 memory=100G /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/data/illumina.terminal/LIB212039*.fastq.gz output /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.meryl

# meryl stats
/mnt/research/qgg/software/meryl-1.4.1/bin/meryl statistics /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.meryl > /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.stats

# meryl histo
/mnt/research/qgg/software/meryl-1.4.1/bin/meryl histogram /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.meryl > /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.hist

# genomescope
micromamba activate genomescope2
Rscript /mnt/research/qgg/software/genomescope2.0/genomescope.R -i /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.hist -k 21 -p 2 -o /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/genomescope/LIB212039

# merqury
## run parental meryls first
/mnt/research/qgg/software/meryl-1.4.1/bin/meryl k=21 count threads=16 memory=100G /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/data/illumina.maternal/LIB212038*.fastq.gz output /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212038.meryl
/mnt/research/qgg/software/meryl-1.4.1/bin/meryl k=21 count threads=16 memory=100G /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/data/illumina.paternal/LIB212041*.fastq.gz output /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212041.meryl

## run trio hapmers
mkdir -p /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/merqury_trio_terminal && cd /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/merqury_trio_terminal
export MERQURY="/mnt/research/qgg/software/merqury"
export MERYL="/mnt/research/qgg/software/meryl-1.4.1/bin"
export PATH="$MERYL:$PATH"

micromamba activate verkko

bash /mnt/research/qgg/software/merqury/trio/hapmers.sh \
    /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212038.meryl \
	/mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212041.meryl \
    /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.meryl

## run merqury 
bash /mnt/research/qgg/software/merqury/merqury.sh \
    /mnt/gs21/scratch/ackers24/srp-sandbox/SRP_1/dataQC/meryl/LIB212039.meryl \
    "mat.hapmer.meryl" \
    "pat.hapmer.meryl" \
    LIB212039_terminal_trio


# merqury plots
cd /mnt/gs21/scratch/ackers24/srp-sandbox
rm -rf dataQC/merqury_trio_terminal/*
cd dataQC/merqury_trio_terminal/


export PATH="/mnt/research/qgg/software/meryl-1.4.1/bin:$PATH"
export MERQURY="/mnt/research/qgg/software/merqury"
export PATH="$MERQURY:$MERQURY/build:$PATH"

bash $MERQURY/trio/hapmers.sh \
../../dataQC/meryl/LIB212038.meryl \
../../dataQC/meryl/LIB212041.meryl \
../../dataQC/meryl/LIB212039.meryl

