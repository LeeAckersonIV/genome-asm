# env.bashrc
# =============================================================================================== #

# Default Directories
# ----------------------------------------------------------------------------------------------- #
export ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
export HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
export ONT_DIR="NA"
export SNP_DIR="NA"
# ----------------------------------------------------------------------------------------------- #

# Default Software Paths
# ----------------------------------------------------------------------------------------------- #
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
# ----------------------------------------------------------------------------------------------- #

# Default References
# ----------------------------------------------------------------------------------------------- #
export RDNA_REF="${ENV_BASHRC_DIR}/references/pig_rDNA.fasta"
export MTDNA_REF="${ENV_BASHRC_DIR}/references/pig_MT.fasta"
# ----------------------------------------------------------------------------------------------- #

# Workflow Defaults
# ----------------------------------------------------------------------------------------------- #
export ThreeGenMode="YES"
export LOAD_PARAMS_CONFIG="NO"
# ----------------------------------------------------------------------------------------------- #


# Micromamba Environments (install before running pipeline)
# ----------------------------------------------------------------------------------------------- #
# Download micromamba:			"${SHELL}" <(curl -L https://micro.mamba.pm/install.sh)
## 	then initilize ~/.bashrc:	micromamba shell init

# Genomescope2: 		micromamba create -n genomescope2 -c conda-forge -c bioconda genomescope2
# Nanopack (Chopper): 	micromamba create -n nanopack -c conda-forge -c bioconda chopper
# Verkko 2.3.2: 		micromamba create -n verkkov2.3.2 -c conda-forge -c bioconda -c defaults verkko
# HiFiasm: 				micromamba create -n hifiasm -c conda-forge -c bioconda hifiasm
# ----------------------------------------------------------------------------------------------- #


# R & Python Libraries
# ----------------------------------------------------------------------------------------------- #
R_VER=$(R --version | head -n 1 | cut -d " " -f 3 | cut -d "." -f 1,2)
export R_LIBS_USER="${HOME}/R/x86_64-pc-linux-gnu-library/${R_VER}"
mkdir -p "$R_LIBS_USER"

# Check if packages exist. If not, install them using the -e flag.
if ! Rscript -e "library(argparse); library(ggplot2); library(scales)" >/dev/null 2>&1; then
    echo "Dependencies missing. Installing to $R_LIBS_USER..."
    Rscript -e 'install.packages(c("argparse", "ggplot2", "scales"), repos="https://cloud.r-project.org/", lib=Sys.getenv("R_LIBS_USER"))'
fi

pip install pandas matplotlib seaborn
# ----------------------------------------------------------------------------------------------- #
# =============================================================================================== #
