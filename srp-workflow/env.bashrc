# env.bashrc
# ----------------------------------------------------------------------------------------------- #
# Default Directories
export ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
export HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
export ONT_DIR="NA"
export SNP_DIR="NA"

# Default Software Paths
export ENV_BASHRC_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export FASTQC_SOFTWARE="/mnt/research/qgg/software/fastqc_v0.11.5"
export MULTIQC_SOFTWARE="/mnt/research/qgg/software/multiqc_v1.33/bin"
export SEQKIT_SOFTWARE="/mnt/research/qgg/software/seqkit-2.13.0"
export MERYL_SOFTWARE="/mnt/research/qgg/software/meryl-1.4.1/bin"
export GENOMESCOPE2_SOFTWARE="/mnt/research/qgg/software/genomescope2.0/genomescope.R"
export MERQURY_SOFTWARE="/mnt/research/qgg/software/merqury"
export MERQURY="$MERQURY_SOFTWARE"
export MERYL="/mnt/research/qgg/software/meryl-1.4.1/bin"
export HIFIASM="/mnt/research/qgg/software/hifiasm/hifiasm"
export YAK_SOFTWARE="/mnt/research/qgg/software/yak-0.1-r69/yak"
export PATH="$MERYL:$PATH"
export PATH="$MERYL_SOFTWARE:$PATH"
export PATH="$MERQURY_SOFTWARE:$MERQURY_SOFTWARE/build:$PATH"

# Default References
export RDNA_REF="${ENV_BASHRC_DIR}/references/pig_rDNA.fasta"
export MTDNA_REF="${ENV_BASHRC_DIR}/references/pig_MT.fasta"

# Workflow Defaults
export RUNFASTQC="YES"
export ThreeGenMode="YES"
export LOAD_PARAMS_CONFIG="NO"
export RUN_DC="YES"
export BC_ONT="NO"



# Environments
# need micromamba genomescope2 env available for readQC.sh
# need micromamba nanopack env available for filter.sh # micromamba create -n nanopack -c conda-forge -c bioconda chopper



# 4. LANGUAGE ENVIRONMENTS (R)
# ----------------------------------------------------------------------------------------------- #
R_VER=$(R --version | head -n 1 | cut -d " " -f 3 | cut -d "." -f 1,2)
export R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/${R_VER}"
mkdir -p "$R_LIBS_USER"

# Check if packages exist. If not, install them using the -e flag.
if ! Rscript -e "library(argparse); library(ggplot2); library(scales)" >/dev/null 2>&1; then
    echo "Dependencies missing. Installing to $R_LIBS_USER..."
    Rscript -e 'install.packages(c("argparse", "ggplot2", "scales"), repos="https://cloud.r-project.org/", lib=Sys.getenv("R_LIBS_USER"))'
fi
# ----------------------------------------------------------------------------------------------- #