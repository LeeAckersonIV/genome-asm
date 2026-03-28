# env.bashrc
# ----------------------------------------------------------------------------------------------- #
# Default Directories
export ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
export HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
export ONT_DIR="NA"
export SNP_DIR="NA"

# Default Software Paths
export FASTQC_SOFTWARE="/mnt/research/qgg/software/fastqc_v0.11.5"
export MULTIQC_SOFTWARE="/mnt/research/qgg/software/multiqc_v1.33/bin"
export SEQKIT_SOFTWARE="/mnt/research/qgg/software/seqkit-2.13.0"
export MERYL_SOFTWARE="/mnt/research/qgg/software/meryl-1.4.1/bin"
export GENOMESCOPE2_SOFTWARE="/mnt/research/qgg/software/genomescope2.0/genomescope.R"
export MERQURY_SOFTWARE="/mnt/research/qgg/software/merqury"

# Workflow Defaults
export RUNFASTQC="YES"
export ThreeGenMode="YES"
export LOAD_PARAMS_CONFIG="NO"

# Environments
eval "$(micromamba shell hook --shell bash)"

micromamba activate genomescope2

# ----------------------------------------------------------------------------------------------- #
