#!/bin/bash -l

# =============================================================================================== #
# Script to perform read quality control (QC) analysis on input sequence data. Analysis includes 
# fastQC for long and short reads, as well as plotting of read quality vs read length.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# readQC.sh \
#	--load.project.params \		# can re-use input parameter config from initialize.sh; default NO
#	--projectROOT \ 			# where initialize.sh built the project directory at.
#	--illumina.terminal.lib \ 	# library IDs for terminal animal illumina data
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
# 	--snpDir \					# parent directory containing all the SNP data
#	--ThreeGenMode \			# indicate NO if only maternal, paternal, & F1 given; default YES
#	--help						# print all options and point to github documentation
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
	echo "# ------------------------------ Expected Pedigree Structure ------------------------------- #"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "                Maternal Grand Sire [MGS]        Maternal Grand Dam [MGD]"
	echo "                            │                               │"
	echo "                            └────────────────┬──────────────┘"
	echo "                                             │"
	echo "                    Paternal           Maternal [F1]"
	echo "                        │                    │"
	echo "                        └─────────┬──────────┘"
	echo "                                  │"
	echo "                           Terminal Animal"
	echo ""
	echo "# --------------------------------- Configuration Options ---------------------------------- #"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "readQC.sh \ "
	echo "	--load.project.params \		# can re-use input parameter config from initialize.sh; default NO"
	echo "	--projectROOT \ 			# where directory structure will be built, default is working dir"
	echo "	--illumina.terminal.lib \ 	# REQUIRED; library IDs for terminal animal illumina data"
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
	echo "If initialize.sh has already been run for this project, and no parameters need changed, "
	echo " then simply run this script as follows:"
	echo "readQC.sh \ "
	echo "	--load.project.params YES \		# can re-use input parameter config from initialize.sh; default NO"
	echo "	--projectROOT path/to/project \	# where directory structure will be built, default is working dir"
	echo ""
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	exit 1
}
# ----------------------------------------------------------------------------------------------- #


# Take in, parse, and set input parameters
# ----------------------------------------------------------------------------------------------- #
# initialize non-global variables
ILLUM_MGS="NA"
ILLUM_MGD="NA"
ONT_TERM="NA"
ONT_MAT="NA"
SNP_DIR="NA"

# load env.bashrc, inputs are overwritten first by config.params; and then by command line
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$PWD"

if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    echo "Sourcing configuration from ${PIPELINE_DIR}/env.bashrc"
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Warning: env.bashrc not found. Using internal script defaults."
	ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
	HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
	ONT_DIR="NA"
	SNP_DIR="NA"
	ThreeGenMode="YES"
	FASTQC_SOFTWARE="/mnt/research/qgg/software/fastqc_v0.11.5"
	MULTIQC_SOFTWARE="/mnt/research/qgg/software/multiqc_v1.33/bin"
	SEQKIT_SOFTWARE="/mnt/research/qgg/software/seqkit-2.13.0"
fi

# Load existing project parameters if supplied: i.e. --load.project.params YES
for ((i=1; i<=$#; i++)); do
    case "${!i}" in
        --projectROOT) 
            j=$((i+1)); PROJECT_ROOT="${!j}" ;;
        --load.project.params) 
            j=$((i+1)); LOAD_CONFIG_PARAMS="${!j}" ;;
    esac
done

PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")

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
		--load.project.params) 	LOAD_CONFIG_PARAMS="$2"; shift 2 ;;
        --projectROOT) 		 	PROJECT_ROOT="$2"; shift 2 ;;
		--illumina.terminal.lib) 	ILLUM_TERM="$2"; shift 2 ;;
		--illumina.maternal.lib) 	ILLUM_MAT="$2"; shift 2 ;;
		--illumina.paternal.lib) 	ILLUM_PAT="$2"; shift 2 ;;
		--illumina.MGS.lib) 		ILLUM_MGS="$2"; shift 2 ;;
		--illumina.MGD.lib) 		ILLUM_MGD="$2"; shift 2 ;;
		--hifi.terminal.lib)		HIFI_TERM="$2"; shift 2 ;;
		--hifi.maternal.lib) 		HIFI_MAT="$2"; shift 2 ;;
		--ont.terminal.lib) 		ONT_TERM="$2"; shift 2 ;;
		--ont.maternal.lib) 		ONT_MAT="$2"; shift 2 ;;
        --illuminaDir) 			ILLUM_DIR="$2"; shift 2 ;;
        --hifiDir) 	 			HIFI_DIR="$2"; shift 2 ;;
        --ontDir) 	 			ONT_DIR="$2"; shift 2 ;;
		--snpDir) 	 			SNP_DIR="$2"; shift 2 ;;
		--ThreeGenMode)				ThreeGenMode="$2"; shift 2 ;;
        --help) 	 			usage ;;
        *) 	 	 			echo "Error: Unknown option $1"; usage ;;
    esac
done
# ----------------------------------------------------------------------------------------------- #


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

# Compute sanitized tags (fallback if running readQC standalone without params.config)
# ----------------------------------------------------------------------------------------------- #
ILLUM_TERM_TAG="${ILLUM_TERM_TAG:-${ILLUM_TERM//,/_}}"
ILLUM_MAT_TAG="${ILLUM_MAT_TAG:-${ILLUM_MAT//,/_}}"
ILLUM_PAT_TAG="${ILLUM_PAT_TAG:-${ILLUM_PAT//,/_}}"
ILLUM_MGS_TAG="${ILLUM_MGS_TAG:-${ILLUM_MGS//,/_}}"
ILLUM_MGD_TAG="${ILLUM_MGD_TAG:-${ILLUM_MGD//,/_}}"

HIFI_TERM_TAG="${HIFI_TERM_TAG:-${HIFI_TERM//,/_}}"
HIFI_MAT_TAG="${HIFI_MAT_TAG:-${HIFI_MAT//,/_}}"
ONT_TERM_TAG="${ONT_TERM_TAG:-${ONT_TERM//,/_}}"
ONT_MAT_TAG="${ONT_MAT_TAG:-${ONT_MAT//,/_}}"
# ----------------------------------------------------------------------------------------------- #


# 0. Initialize variables and directory structure
# ----------------------------------------------------------------------------------------------- #
QC_OUT="${PROJECT_ROOT}/dataQC"
FASTQC_OUT="${QC_OUT}/fastqc_outputs"
mkdir -p "$FASTQC_OUT"
DATA_DIR="${PROJECT_ROOT}/data"
SEQKIT_OUT="${QC_OUT}/per_read_stats"
mkdir -p "$SEQKIT_OUT"
PLOT_DIR="${QC_OUT}/plots"
mkdir -p "$PLOT_DIR"
# ----------------------------------------------------------------------------------------------- #


# 1. Run FastQC
# ----------------------------------------------------------------------------------------------- #
echo "Running FastQC across symlinked dataset..."
echo "+ find -L \"${PROJECT_ROOT}/data\" -type f \( -name \"*.fastq.gz\" -o -name \"*.fq.gz\" \) | xargs -r \"${FASTQC_SOFTWARE}/fastqc\" -o \"$FASTQC_OUT\" -t 8"
find -L "${PROJECT_ROOT}/data" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \) | xargs -r "${FASTQC_SOFTWARE}/fastqc" -o "$FASTQC_OUT" -t 8
echo "FastQC complete. Results are in: $FASTQC_OUT"
# ----------------------------------------------------------------------------------------------- #


# 2. Run SeqKit on Long Read Libraries
# ----------------------------------------------------------------------------------------------- #
echo "Calculating long-read per-read quality stats with SeqKit..."
for lib_dir in "${PROJECT_ROOT}/data"/*/; do
    [[ -d "$lib_dir" ]] || continue
    lib_name=$(basename "$lib_dir")

    if [[ "$lib_name" == hifi.* ]] || [[ "$lib_name" == ont.* ]]; then
        readarray -t read_files < <(find -L "$lib_dir" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \))
        if [[ ${#read_files[@]} -gt 0 ]]; then		
            echo "Processing Library Directory: $lib_name (${#read_files[@]} files found)"
            echo "+ ${SEQKIT_SOFTWARE}/seqkit fx2tab -l -q -n -H ${read_files[*]} > ${SEQKIT_OUT}/${lib_name}_stats.tsv"
            "${SEQKIT_SOFTWARE}/seqkit" fx2tab -l -q -n -H "${read_files[@]}" > "${SEQKIT_OUT}/${lib_name}_stats.tsv"
        fi
    fi
done
# ----------------------------------------------------------------------------------------------- #


# 3. Run density_plot.py
# ----------------------------------------------------------------------------------------------- #
echo "Generating Joint Density Plots..."
for stats_file in "${SEQKIT_OUT}"/*_stats.tsv; do
    [[ -f "$stats_file" ]] || continue
    lib_name=$(basename "$stats_file" _stats.tsv)

    if [[ "$lib_name" == hifi.* ]] || [[ "$lib_name" == ont.* ]]; then
        echo "Plotting: $lib_name"
        echo "+ python3 ${PIPELINE_DIR}/density_plot.py $stats_file ${PLOT_DIR}/${lib_name}_joint_qc.png $lib_name"
        python3 "${PIPELINE_DIR}/density_plot.py" \
            "$stats_file" \
            "${PLOT_DIR}/${lib_name}_joint_qc.png" \
            "$lib_name"
    fi
done
# ----------------------------------------------------------------------------------------------- #


# 4. Run MultiQC
# ----------------------------------------------------------------------------------------------- #
echo "Generating MultiQC Report..."
echo "+ ${MULTIQC_SOFTWARE}/multiqc $FASTQC_OUT -o $QC_OUT --filename MultiQC_Report"
"${MULTIQC_SOFTWARE}/multiqc" "$FASTQC_OUT" -o "$QC_OUT" --filename "MultiQC_Report"
echo "MultiQC complete. Review your report at: ${PROJECT_ROOT}/dataQC/MultiQC_Report.html"
echo "QC complete. Individual stats are in: $SEQKIT_OUT"
# ----------------------------------------------------------------------------------------------- #

echo "readQC.sh complete!"