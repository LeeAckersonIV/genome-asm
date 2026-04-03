#!/bin/bash -l

# =============================================================================================== #
# Script to perform trio based genome assembly on input hybrid animals using input sequence data.
#	Verkko and HiFiasm are both launched in trio mode for each hybrid animal.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# assembly.sh \
#	--load.project.params \		# can re-use input paramter config from initialize.sh; default NO
#	--projectROOT \ 			# where initialize.sh built the project directory at
#	--ref.rdna \ 				# reference rDNA moprh for species to use for filtering/assembly.
#	--ref.mtdna \ 				# reference mtDNA moprh for species to use for filtering/assembly.
#	--meryl.hapmers.mat \ 		# path to meryl maternal hapmers database
#	--meryl.hapmers.pat \ 		# path to meryl paternal hapmers database
#	--meryl.hapmers.MGD \ 		# path to meryl maternal grand dam hapmers database
#	--meryl.hapmers.MGS \ 		# path to meryl maternal grand sire hapmers database
#	--yak.hapmers.mat \ 		# path to yak maternal hapmers database
#	--yak.hapmers.pat \ 		# path to yak paternal hapmers database
#	--yak.hapmers.MGD \ 		# path to yak maternal grand dam hapmers database
#	--yak.hapmers.MGS \ 		# path to yak maternal grand sire hapmers database
#	--verkko.outdir \ 			# name of output directory for Verkko run
#	--hifiasm.outdir \ 			# name of output directory for HiFiasm run

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
# =============================================================================================== #
# Example Command Execution
# ----------------------------------------------------------------------------------------------- #
# ./assembly.sh --projectROOT SRP_1 --illumina.terminal.lib LIB212039 --illumina.maternal.lib LIB212038 --illumina.paternal.lib LIB212041 --illumina.MGS.lib LIB212046 --illumina.MGD.lib LIB212044 --hifi.terminal.lib LIB212031 --hifi.maternal.lib LIB212951

# OR, IF initialize.sh was RUN FIRST:

# ./assembly.sh --projectROOT SRP_1 --load.project.params YES
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
	echo "assembly.sh \ "
	echo "	--load.project.params \		# can re-use input paramter config from initialize.sh; default NO"
	echo "	--projectROOT \ 			# where directory strcuture will be built, default is working dir"
	
	echo "	--ref.rdna \ 				# reference rDNA moprh for species to use for filtering/assembly."
	echo "	--ref.mtdna \ 				# reference mtDNA moprh for species to use for filtering/assembly."
	echo "	--meryl.hapmers.mat \ 		# name of meryl maternal hapmers database"
	echo "	--meryl.hapmers.pat \ 		# name of meryl paternal hapmers database"
	echo "	--meryl.hapmers.MGD \ 		# name of meryl maternal grand dam hapmers database"
	echo "	--meryl.hapmers.MGS \ 		# name of meryl maternal grand sire hapmers database"
	echo "	--yak.hapmers.mat \ 		# name of yak maternal hapmers database"
	echo "	--yak.hapmers.pat \ 		# name of yak paternal hapmers database"
	echo "	--yak.hapmers.MGD \ 		# name of yak maternal grand dam hapmers database"
	echo "	--yak.hapmers.MGS \ 		# name of yak maternal grand sire hapmers database"
	echo "	--verkko.outdir \ 			# name of output directory for Verkko run (terminal and maternal)"
	echo "	--hifiasm.outdir \ 			# name of output directory for HiFiasm run (terminal and maternal)"
	
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
	echo ""
	echo "If initialize.sh has already been run for this project, and no parameters need changed, "
	echo " then simply run this script as follows:"
	echo "assembly.sh \ "
	echo "	--load.project.params YES \		# can re-use input paramter config from initialize.sh; default NO"
	echo "	--projectROOT path/to/project \	# where directory strcuture will be built, default is working dir"
	echo ""
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	exit 1
}
# ----------------------------------------------------------------------------------------------- #


# take in, parse, and set input paramters
# ----------------------------------------------------------------------------------------------- #

# initialize non-global variables
ILLUM_MGS="NA"
ILLUM_MGD="NA"
ONT_TERM="NA"
ONT_MAT="NA"

# defaults if using outputs from earlier scripts in workflow
PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")


# load env.bashrc, inputs are overwritten first by config.params; and then by command line
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$PWD"
PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    echo "Sourcing configuration from ${PIPELINE_DIR}/env.bashrc"
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Warning: env.bashrc not found. Using internal script defaults."
    # backup defaults if env.bashrc missing:
	ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
	HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
	ONT_DIR="NA"
	SNP_DIR="NA"
	ThreeGenMode="YES"
	FASTQC_SOFTWARE="/mnt/research/qgg/software/fastqc_v0.11.5"
	MULTIQC_SOFTWARE="/mnt/research/qgg/software/multiqc_v1.33/bin"
	SEQKIT_SOFTWARE="/mnt/research/qgg/software/seqkit-2.13.0"
fi

# Load existing project paramters if supplied: i.e. --load.project.params YES
for ((i=1; i<=$#; i++)); do
    case "${!i}" in
        --projectROOT) 
            j=$((i+1)); PROJECT_ROOT="${!j}" ;;
        --load.project.params) 
            j=$((i+1)); LOAD_CONFIG_PARAMS="${!j}" ;;
    esac
done

if [[ "$LOAD_CONFIG_PARAMS" == "YES" ]]; then
    if [[ -f "${PROJECT_ROOT}/params.config" ]]; then
        source "${PROJECT_ROOT}/params.config"
        echo "Successfully loaded parameters from ${PROJECT_ROOT}/params.config"
    else
        echo "Error: --load.project.params YES was set, but ${PROJECT_ROOT}/params.config not found."
        exit 1
    fi
fi

# Parse and load any input parameters; even if they override some in the existing config
while [[ $# -gt 0 ]]; do
    case "$1" in
		--load.project.params)     	LOAD_CONFIG_PARAMS="$2"; shift 2 ;;
        --projectROOT)     		 	PROJECT_ROOT="$2"; shift 2 ;;

		--ref.rdna)					RDNA_REF="$2"; shift 2 ;;
		--ref.mtdna)				MTDNA_REF="$2"; shift 2 ;;
		--meryl.hapmers.mat)		MERYL_HAP_MAT="$2"; shift 2 ;;
		--meryl.hapmers.pat)		MERYL_HAP_PAT="$2"; shift 2 ;;
		--meryl.hapmers.MGS)		MERYL_HAP_MGS="$2"; shift 2 ;;
		--meryl.hapmers.MGD)		MERYL_HAP_MGD="$2"; shift 2 ;;
		--yak.hapmers.mat)			YAK_HAP_MAT="$2"; shift 2 ;;
		--yak.hapmers.pat)			YAK_HAP_PAT="$2"; shift 2 ;;
		--yak.hapmers.MGS)			YAK_HAP_MGS="$2"; shift 2 ;;
		--yak.hapmers.MGD)			YAK_HAP_MGD="$2"; shift 2 ;;
		--verkko.outdir.name)		VERKKO_OUTDIR="$2"; shift 2 ;;
		--hifiasm.outdir.name)		HIFIASM_OUTDIR="$2"; shift 2 ;;
		
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
		--ThreeGenMode)				ThreeGenMode="$2"; shift 2 ;;
        --help)            			usage ;;
        *)              			echo "Error: Unknown option $1"; usage ;;
    esac
done



# Validate that all required inputs are supplied
# ----------------------------------------------------------------------------------------------- #
if [[ "$ThreeGenMode" == "YES" ]]; then
	REQUIRED_VARS=("ILLUM_TERM" "ILLUM_MAT" "ILLUM_PAT" "HIFI_TERM" "ILLUM_MGS" "ILLUM_MGD" "HIFI_MAT")

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


# 0. Initialize variables & directory paths 
# ------------------------------------------------------------------------------- #
PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")
MERQURY_TERM_DIR="${PROJECT_ROOT}/dataQC/merqury_trio_terminal.compressed" 
MERQURY_MAT_DIR="${PROJECT_ROOT}/dataQC/merqury_trio_maternal.compressed" 

YAK_DIR="${PROJECT_ROOT}/dataQC/yak"
VERKKO_TERM_DIR="${PROJECT_ROOT}/verkko.terminal"
VERKKO_MAT_DIR="${PROJECT_ROOT}/verkko.maternal"
HIFIASM_TERM_DIR="${PROJECT_ROOT}/hifiasm.terminal"
HIFIASM_MAT_DIR="${PROJECT_ROOT}/hifiasm.maternal"
CLEAN_DATA="${PROJECT_ROOT}/data-cleaned"

YAK_HAP_MAT="${YAK_DIR}/${ILLUM_MAT}.yak"
YAK_HAP_PAT="${YAK_DIR}/${ILLUM_PAT}.yak"
YAK_HAP_MGS="${YAK_DIR}/${ILLUM_MGS}.yak"
YAK_HAP_MGD="${YAK_DIR}/${ILLUM_MGD}.yak"
MERYL_HAP_MAT="${MERQURY_TERM_DIR}/${ILLUM_MAT}.hapmer.meryl"
MERYL_HAP_PAT="${MERQURY_TERM_DIR}/${ILLUM_PAT}.hapmer.meryl"
MERYL_HAP_MGS="${MERQURY_MAT_DIR}/${ILLUM_MGS}.hapmer.meryl"
MERYL_HAP_MGD="${MERQURY_MAT_DIR}/${ILLUM_MGD}.hapmer.meryl"

# 1. Terminal Animal Assemblies (Offspring: Term | Parents: Mat + Pat)
# ------------------------------------------------------------------------------- #
echo "Submitting Terminal Animal Trio Assemblies..."

# HiFiasm Terminal
sbatch --job-name=hifiasm_term --cpus-per-task=64 --mem=400G --time=4-00:00:00 \
    --output="${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.terminal.log" "${PIPELINE_DIR}/launch_hifiasm_trio.sh" \
	--pipelineDir "${PIPELINE_DIR}" \
    --outdir "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}" \
    --hifi "${CLEAN_DATA}/hifi.terminal" \
	--ont "${CLEAN_DATA}/ont.terminal" \
    --yak.mat "${YAK_HAP_MAT}" \
    --yak.pat "${YAK_HAP_PAT}"

# Verkko Terminal
sbatch --job-name=verkko_term --cpus-per-task=4 --mem=64G --time=6-00:00:00 \
    --output="${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}.terminal.log" "${PIPELINE_DIR}/launch_verkko_trio.sh" \
	--pipelineDir "${PIPELINE_DIR}" \
    --outdir "${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}" \
    --hifi "${CLEAN_DATA}/hifi.terminal" \
    --ont "${CLEAN_DATA}/ont.terminal" \
	--mtDNA "${MTDNA_REF}" \
	--rDNA "${RDNA_REF}" \
    --meryl.mat "${MERYL_HAP_MAT}" \
    --meryl.pat "${MERYL_HAP_PAT}"

# ------------------------------------------------------------------------------- #


# 2. Maternal F1 Assemblies (Offspring: Mat | Parents: MGD + MGS)
# ------------------------------------------------------------------------------- #
if [[ "$ThreeGenMode" == "YES" ]]; then
    echo "Submitting Maternal F1 Animal Trio Assemblies..."

    # HiFiasm Maternal F1
    sbatch --job-name=hifiasm_mat --cpus-per-task=64 --mem=400G --time=4-00:00:00 \
        --output="${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.maternal.log" "${PIPELINE_DIR}/launch_hifiasm_trio.sh" \
		--pipelineDir "${PIPELINE_DIR}" \
        --outdir "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}" \
		--hifi "${CLEAN_DATA}/hifi.maternal" \
		--ont "${CLEAN_DATA}/ont.maternal" \
		--yak.mat "${YAK_HAP_MGD}" \
		--yak.pat "${YAK_HAP_MGS}"

    # Verkko Maternal F1
    sbatch --job-name=verkko_mat --cpus-per-task=4 --mem=64G --time=6-00:00:00 \
        --output="${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}.maternal.log" "${PIPELINE_DIR}/launch_verkko_trio.sh" \
		--pipelineDir "${PIPELINE_DIR}" \
        --outdir "${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}" \
		--hifi "${CLEAN_DATA}/hifi.maternal" \
		--ont "${CLEAN_DATA}/ont.maternal" \
		--mtDNA "${MTDNA_REF}" \
		--rDNA "${RDNA_REF}" \
		--meryl.mat "${MERYL_HAP_MGD}" \
		--meryl.pat "${MERYL_HAP_MGS}"
fi

# ------------------------------------------------------------------------------- #
