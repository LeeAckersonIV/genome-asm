#!/bin/bash -l

# =============================================================================================== #
# Script to initialize, automate, and formalize SRP worflow: 1) establish and organize directory 
# structure based on data inputs, and 2) symlink in genomic data for indicated animals/family.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# initialize.sh \
#	--projectROOT \ 			# where directory strcuture will be built, default is working dir
#	--illumina.terminal.lib \  	# library IDs for terminal animal illumina data
#	--illumina.maternal.lib \ 	# library IDs for maternal animal [F1] illumina data
#	--illumina.paternal.lib \ 	# library IDs for paternal animal illumina data
# 	--illumina.MGS.lib \ 		# library IDs for maternal grand sire [MGS] animal illumina data
#	--illumina.MGD.lib \ 		# library IDs for maternal grand dam [MGD] animal illumina data
#	--hifi.terminal.lib \ 		# library IDs for terminal animal hifi data
#	--hifi.maternal.lib \ 		# library IDs for maternal animal [F1] hifi data
#	--ont.terminal.lib \ 		# library IDs for terminal animal ONT data
#	--ont.maternal.lib \ 		# library IDs for maternal animal [F1] ONT data
# 	--illuminaDir \ 			# parent directory containing all the illumina data
#	--hifiDir \ 				# parent directory containing all the hifi data
#	--ontDir \ 					# parent directory containing all the ONT data
# 	--snpDIR \					# parent directory containing all the SNP data
#	--ThreeGenMode \			# indicate NO if only maternal, paternal, & F1 given; default YES
#	--help						# print all options and point to github documentation

# Example Command Execution
# ----------------------------------------------------------------------------------------------- #
# ./initialize.sh --projectROOT ~/SRP_1 --illumina.terminal.lib LIB212039 --illumina.maternal.lib LIB212038 --illumina.paternal.lib LIB212041 --illumina.MGS.lib LIB212046 --illumina.MGD.lib LIB212044 --hifi.terminal.lib LIB212031 --hifi.maternal.lib LIB212951
# =============================================================================================== #


# Function to display help menu
# ----------------------------------------------------------------------------------------------- #
usage() {
	echo ""
	echo "This pipeline is intended to run on a 3-generation pedigree (illustrated below), if you do not"
	echo "have grandparental data for the terminal animal - only use the terminal, maternal, and 		"
	echo "paternal related flags for execution. The pipeline will interpret terminal as F1 in such case,"
	echo "just indicate that the expected pedigree structure was not used by setting --ThreeGenMode to NO."
	echo ""
	echo ""
	echo ""
	echo ""
	echo "# ------------------------------ Expected Pedigree Structure ------------------------------- #"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "                Maternal Grand Sire [MGS]        Maternal Grand Dam [MGD]"
	echo "                            │                                │"
	echo "                            └────────────────┬───────────────┘"
	echo "                                             │"
	echo "                    Paternal           Maternal [F1]"
	echo "                        │                    │"
	echo "                        └─────────┬──────────┘"
	echo "                                  │"
	echo "                           Terminal Animal"
	echo ""
	echo ""
	echo ""
	echo "# --------------------------------- Configuration Options ---------------------------------- #"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "initialize.sh \ "
	echo "	--projectROOT \ 			# where directory strcuture will be built, default is working dir"
	echo "	--illumina.terminal.lib \  	# REQUIRED; library IDs for terminal animal illumina data"
	echo "	--illumina.maternal.lib \ 	# REQUIRED; library IDs for maternal animal [F1] illumina data"
	echo "	--illumina.paternal.lib \ 	# REQUIRED; library IDs for paternal animal illumina data"
	echo "	--illumina.MGS.lib \ 		# library IDs for maternal grand sire [MGS] animal illumina data"
	echo "	--illumina.MGD.lib \ 		# library IDs for maternal grand dam [MGD] animal illumina data"
	echo "	--hifi.terminal.lib \ 		# REQUIRED; library IDs for terminal animal hifi data"
	echo "	--hifi.maternal.lib \ 		# library IDs for maternal animal [F1] hifi data"
	echo "	--ont.terminal.lib \ 		# library IDs for terminal animal ONT data"
	echo "	--ont.maternal.lib \ 		# library IDs for maternal animal [F1] ONT data"
	echo "	--illuminaDir \ 			# parent directory containing all the illumina data"
	echo "	--hifiDir \ 				# parent directory containing all the hifi data"
	echo "	--ontDir \ 					# parent directory containing all the ONT data"
	echo "	--snpDir 					# parent directory containing all the SNP data"
	echo "	--ThreeGenMode \			# indicate NO if only maternal, paternal, and F1 given; default is YES"
	echo "	--help						# print all options and point to github documentation"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	exit 1
}
# ----------------------------------------------------------------------------------------------- #


# Set base default values and source configuration
# ----------------------------------------------------------------------------------------------- #
# initialize non-global variables
ILLUM_MGS="NA"
ILLUM_MGD="NA"
ONT_TERM="NA"
ONT_MAT="NA"

# global variables
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$PWD"
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    echo "Sourcing configuration from ${PIPELINE_DIR}/env.bashrc"
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Warning: env.bashrc not found. Using internal script defaults."
    # backup defaults if env.bashrc missing:
	ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
	HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
	ONT_DIR="NA"

	ThreeGenMode="YES"
	FASTQC_SOFTWARE="/mnt/research/qgg/software/fastqc_v0.11.5"
	MULTIQC_SOFTWARE="/mnt/research/qgg/software/multiqc_v1.33/bin"
	SEQKIT_SOFTWARE="/mnt/research/qgg/software/seqkit-2.13.0"
	MERYL_SOFTWARE="/mnt/research/qgg/software/meryl-1.4.1/bin"
fi

# ----------------------------------------------------------------------------------------------- #


# Parse input arguments
# ----------------------------------------------------------------------------------------------- #
while [[ $# -gt 0 ]]; do
    case "$1" in
        --projectROOT)     		 	PROJECT_ROOT="$2"; shift 2 ;;
		--illumina.terminal.lib) 	ILLUM_TERM="$2"; shift 2 ;;
		--illumina.maternal.lib) 	ILLUM_MAT="$2"; shift 2 ;;
		--illumina.paternal.lib) 	ILLUM_PAT="$2"; shift 2 ;;
		--illumina.MGS.lib) 		ILLUM_MGS="$2"; shift 2 ;;
		--illumina.MGD.lib) 		ILLUM_MGD="$2"; shift 2 ;;
		--hifi.terminal.lib)		HIFI_TERM="$2"; shift 2 ;;
		--hifi.maternal.lib) 		HIFI_MAT="$2"; shift 2 ;;
		--ont.terminal.lib) 		ONT_TERM="$2"; shift 2 ;;
		--ont.maternal.lib) 		ONT_MAT="$2"; shift 2 ;;
        --illuminaDir)     			ILLUM_DIR="$2"; shift 2 ;;
        --hifiDir)         			HIFI_DIR="$2"; shift 2 ;;
        --ontDir)          			ONT_DIR="$2"; shift 2 ;;
		--snpDir)          			SNP_DIR="$2"; shift 2 ;;
		--ThreeGenMode)				ThreeGenMode="$2"; shift 2 ;;
        --help)            			usage ;;
        *)              			echo "Error: Unknown option $1"; usage ;;
    esac
done
# ----------------------------------------------------------------------------------------------- #


# Validate that all required inputs are supplied
# ----------------------------------------------------------------------------------------------- #
if [[ "$ThreeGenMode" == "YES" ]]; then
	REQUIRED_VARS=("ILLUM_TERM" "ILLUM_MAT" "ILLUM_PAT" "HIFI_TERM" "ILLUM_MGS" "ILLUM_MGD")

else
	REQUIRED_VARS=("ILLUM_TERM" "ILLUM_MAT" "ILLUM_PAT" "HIFI_TERM")
fi
	
MISSING=0
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "Error: The required argument for $var is missing."
        MISSING=1
    fi
done

if [[ $MISSING -eq 1 ]]; then
    usage
fi
# ----------------------------------------------------------------------------------------------- #


# Inform the user on loaded parameters
# ----------------------------------------------------------------------------------------------- #
echo ""
echo ""
echo "========================================================================="
echo "==================  Configuration Loaded for Project  ==================="
echo "========================================================================="
echo ""
echo "Input Project & Data Directories:"
echo "------------------------------------------------------------------"
printf "%-25s %s\n" "Project Directory:" "$PROJECT_ROOT"
printf "%-25s %s\n" "Illumina Directory:" "$ILLUM_DIR"
printf "%-25s %s\n" "HiFi Directory:" "$HIFI_DIR"
printf "%-25s %s\n" "ONT Directory:" "$ONT_DIR"
printf "%-25s %s\n" "SNP Directory:" "$SNP_DIR"
echo ""
echo "Input Library IDs:"
echo "------------------------------------------------------------------"
printf "%-25s %s\n" "Terminal Illumina Library ID:" "$ILLUM_TERM"
printf "%-25s %s\n" "Maternal Illumina Library ID:" "$ILLUM_MAT"
printf "%-25s %s\n" "Paternal Illumina Library ID:" "$ILLUM_PAT"
printf "%-25s %s\n" "Maternal Grand Dam  [MGD] Illumina Library ID:" "$ILLUM_MGD"
printf "%-25s %s\n" "Maternal Grand Sire [MGS] Illumina Library ID:" "$ILLUM_MGS"
printf "%-25s %s\n" "Termimal HiFi Library ID:" "$HIFI_TERM"
printf "%-25s %s\n" "Maternal HiFi Library ID:" "$HIFI_MAT"
printf "%-25s %s\n" "Terminal ONT Library ID:" "$ONT_TERM"
printf "%-25s %s\n" "Maternal ONT Library ID:" "$ONT_MAT"
echo ""
if [[ "$ThreeGenMode" == "YES" ]]; then
	echo "Project Pedigree Structure:"
	echo "------------------------------------------------------------------"
	echo ""
	echo "      Maternal Grand Sire [MGS]        Maternal Grand Dam [MGD]"
	echo "                  │                                │"
	echo "                  └────────────────┬───────────────┘"
	echo "                                   │"
	echo "          Paternal           Maternal [F1]"
	echo "              │                    │"
	echo "              └─────────┬──────────┘"
	echo "                        │"
	echo "                 Terminal Animal"
	echo ""
else 
	echo "Project Pedigree Structure:"
	echo "------------------------------------------------------------------"
	echo ""
	echo "          Paternal             Maternal"
	echo "              │                    │"
	echo "              └─────────┬──────────┘"
	echo "                        │"
	echo "               Terminal F1 Animal"
	echo ""
fi

echo "Workflow Execution:"
echo "------------------------------------------------------------------"
echo "Three Generation Mode? [YES/NO]:	$ThreeGenMode"	
echo ""
echo "========================================================================="
echo ""
# ----------------------------------------------------------------------------------------------- #


# build standardized directory structure in Project Root directory 
# ----------------------------------------------------------------------------------------------- #
mkdir -p $PROJECT_ROOT
cd $PROJECT_ROOT || { echo "Error: Could not enter $PROJECT_ROOT"; exit 1; }
echo "Current working directory: $(pwd)"

mkdir -p "${PROJECT_ROOT}/data"
mkdir -p "${PROJECT_ROOT}/data/illumina.paternal"
mkdir -p "${PROJECT_ROOT}/data/illumina.maternal"
mkdir -p "${PROJECT_ROOT}/data/illumina.terminal"
mkdir -p "${PROJECT_ROOT}/data/hifi.terminal"
mkdir -p "${PROJECT_ROOT}/data/ont.terminal"
mkdir -p "${PROJECT_ROOT}/data/snp.chip"

mkdir -p "${PROJECT_ROOT}/dataQC"
mkdir -p "${PROJECT_ROOT}/verkko.terminal"
mkdir -p "${PROJECT_ROOT}/hifiasm.terminal"

if [[ "$ThreeGenMode" == "YES" ]]; then
	mkdir -p "${PROJECT_ROOT}/data/illumina.MGS"		# only needed if grandparental data given
	mkdir -p "${PROJECT_ROOT}/data/illumina.MGD"		# only needed if grandparental data given
	mkdir -p "${PROJECT_ROOT}/data/hifi.maternal" 		# only needed if grandparental data given
	mkdir -p "${PROJECT_ROOT}/verkko.maternal" 			# only needed if grandparental data given
	mkdir -p "${PROJECT_ROOT}/hifiasm.maternal" 		# only needed if grandparental data given
fi

if [[ "$ONT_TERM" != "NA" || "$ONT_MAT" != "NA" ]]; then
	mkdir -p "${PROJECT_ROOT}/data/ont.maternal" 		# only needed if grandparental data given
	mkdir -p "${PROJECT_ROOT}/data/ont.terminal"		# only needed if grandparental data given
fi
# ----------------------------------------------------------------------------------------------- #


# Find and Symlink input fastq files into "data" directory
# ----------------------------------------------------------------------------------------------- #
# illumina fastq files
Term_Illumina_Reads=($(find "$ILLUM_DIR" -name "*${ILLUM_TERM}*" | sort))
ln -sf "${Term_Illumina_Reads[0]}" "${PROJECT_ROOT}/data/illumina.terminal/"
ln -sf "${Term_Illumina_Reads[1]}" "${PROJECT_ROOT}/data/illumina.terminal/"

Mat_Illumina_Reads=($(find "$ILLUM_DIR" -name "*${ILLUM_MAT}*" | sort))
ln -sf "${Mat_Illumina_Reads[0]}" "${PROJECT_ROOT}/data/illumina.maternal/"
ln -sf "${Mat_Illumina_Reads[1]}" "${PROJECT_ROOT}/data/illumina.maternal/"

Pat_Illumina_Reads=($(find "$ILLUM_DIR" -name "*${ILLUM_PAT}*" | sort))
ln -sf "${Pat_Illumina_Reads[0]}" "${PROJECT_ROOT}/data/illumina.paternal/"
ln -sf "${Pat_Illumina_Reads[1]}" "${PROJECT_ROOT}/data/illumina.paternal/"

if [[ "$ILLUM_MGD" != "NA" || "$ILLUM_MGS" != "NA" ]]; then # only if supplied
	MGD_Illumina_Reads=($(find "$ILLUM_DIR" -name "*${ILLUM_MGD}*" | sort))
	ln -sf "${MGD_Illumina_Reads[0]}" "${PROJECT_ROOT}/data/illumina.MGD/"
	ln -sf "${MGD_Illumina_Reads[1]}" "${PROJECT_ROOT}/data/illumina.MGD/"

	MGS_Illumina_Reads=($(find "$ILLUM_DIR" -name "*${ILLUM_MGS}*" | sort))
	ln -sf "${MGS_Illumina_Reads[0]}" "${PROJECT_ROOT}/data/illumina.MGS/"
	ln -sf "${MGS_Illumina_Reads[1]}" "${PROJECT_ROOT}/data/illumina.MGS/"
else
	echo "Grandparent sequence data was not supplied; skipping related symlinking."
fi

echo ""
echo "Identified and symlinked the following illumina fastq files:"
echo "Terminal_R1 is: ${Term_Illumina_Reads[0]}"
echo "Terminal_R2 is: ${Term_Illumina_Reads[1]}"
echo "Maternal_R1 is: ${Mat_Illumina_Reads[0]}"
echo "Maternal_R2 is: ${Mat_Illumina_Reads[1]}"
echo "Paternal_R1 is: ${Pat_Illumina_Reads[0]}"
echo "Paternal_R2 is: ${Pat_Illumina_Reads[1]}"

if [[ "$ThreeGenMode" == "YES" ]]; then
echo "MGS_R1 is: ${MGS_Illumina_Reads[0]}" #if supplied
echo "MGS_R2 is: ${MGS_Illumina_Reads[1]}" #if supplied
echo "MGD_R1 is: ${MGD_Illumina_Reads[0]}" #if supplied
echo "MGD_R2 is: ${MGD_Illumina_Reads[1]}" #if supplied
fi
echo ""

# hifi fastq files
HIFI_TERM_Reads=($(find "$HIFI_DIR" -name "*${HIFI_TERM}*"))
ln -sf "${HIFI_TERM_Reads[0]}" "${PROJECT_ROOT}/data/hifi.terminal/"

if [[ "$HIFI_MAT" != "NA" ]]; then
	HIFI_MAT_Reads=($(find "$HIFI_DIR" -name "*${HIFI_MAT}*"))
	ln -sf "${HIFI_MAT_Reads[0]}" "${PROJECT_ROOT}/data/hifi.maternal/"
else
	HIFI_MAT_Reads="Not Supplied"
fi

echo ""
echo "Identified and symlinked the following HiFi fastq files:"
echo "HIFI_TERM is: ${HIFI_TERM_Reads}"
echo "HIFI_MAT is:	${HIFI_MAT_Reads}"
echo ""

# ont fastq files [IF SUPPLIED]
if [[ "$ONT_TERM" != "NA" || "$ONT_MAT" != "NA" ]]; then
    
    # terminal ONT [IF SUPPLIED]
    if [[ "$ONT_TERM" != "NA" ]]; then
        ONT_TERM_Reads=($(find "$ONT_DIR" -name "*${ONT_TERM}*"))
        ln -sf "${ONT_TERM_Reads}" "${PROJECT_ROOT}/data/ont.terminal/"
    fi

    # maternal ONT [IF SUPPLIED]
    if [[ "$ONT_MAT" != "NA" ]]; then
        ONT_MAT_Reads=($(find "$ONT_DIR" -name "*${ONT_MAT}*"))
        ln -sf "${ONT_MAT_Reads}" "${PROJECT_ROOT}/data/ont.maternal/"
    fi

else 
    echo "ONT sequence data was not supplied; skipping ONT symlinking."
fi
# ----------------------------------------------------------------------------------------------- #


# !!add support for snp chip files here similiar to ONT!!
# ----------------------------------------------------------------------------------------------- #
# ont fastq files [IF SUPPLIED]
if [[ "$SNP_DIR" != "NA" ]]; then
	echo "SNP Data supplied, pipeline not capable of utilizing yet - stay tuned!"
else 
    echo "SNP data was not supplied; skipping SNP symlinking."
fi
# ----------------------------------------------------------------------------------------------- #


# Write config file with run-specific parameters for downstream scripts
# ----------------------------------------------------------------------------------------------- #
PARAMS_CONFIG="${PROJECT_ROOT}/params.config"

cat <<EOF > "$PARAMS_CONFIG"
# SRP Workflow Parameters - Generated on $(date)
# Project: $(basename "$PROJECT_ROOT")
# ----------------------------------------------------------------------------------------------- #
# Directories
PIPELINE_DIR="$PIPELINE_DIR"
PROJECT_ROOT="$PROJECT_ROOT"
ILLUM_DIR="$ILLUM_DIR"
HIFI_DIR="$HIFI_DIR"
ONT_DIR="$ONT_DIR"
SNP_DIR="$SNP_DIR"

# Library IDs
ILLUM_TERM="$ILLUM_TERM"
ILLUM_MAT="$ILLUM_MAT"
ILLUM_PAT="$ILLUM_PAT"
ILLUM_MGS="$ILLUM_MGS"
ILLUM_MGD="$ILLUM_MGD"
HIFI_TERM="$HIFI_TERM"
HIFI_MAT="$HIFI_MAT"
ONT_TERM="$ONT_TERM"
ONT_MAT="$ONT_MAT"

# Software & Settings
ThreeGenMode="$ThreeGenMode"
RUNFASTQC="$RUNFASTQC"
FASTQC_SOFTWARE="$FASTQC_SOFTWARE"
MULTIQC_SOFTWARE="$MULTIQC_SOFTWARE"
SEQKIT_SOFTWARE="$SEQKIT_SOFTWARE"
MERYL_SOFTWARE="$MERYL_SOFTWARE"
# ----------------------------------------------------------------------------------------------- #
EOF

echo "Configuration saved to: $PARAMS_CONFIG"
# ----------------------------------------------------------------------------------------------- #


