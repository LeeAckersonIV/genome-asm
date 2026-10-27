#!/bin/bash -l

# =============================================================================================== #
# Script to perform k-mer analysis on input sequence data. Analysis includes k-mer count and 
# multiplicity statistics via Meryl, as well as production of hapmer databases via Merqury.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# kmers.sh \
#	--load.project.params \		# can re-use input parameter config from initialize.sh; default NO
#	--projectROOT \ 			# where initialize.sh built the project directory at.
#	--kmer.length \ 			# kmer length for meryl dbs and kmer analysis; default=31
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
	echo "kmers.sh \ "
	echo "	--load.project.params \		# can re-use input parameter config from initialize.sh; default NO"
	echo "	--projectROOT \ 			# where directory structure will be built, default is working dir"
	echo "	--kmer.length \ 			# kmer length for meryl dbs and kmer analysis; default=31"
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
	echo "kmers.sh \ "
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
KMER_LENGTH="31"

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
		--kmer.length) 		 	KMER_LENGTH="$2"; shift 2 ;;
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

# Compute sanitized tags (fallback if running kmers.sh standalone without params.config)
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
PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")
QC_OUT="${PROJECT_ROOT}/dataQC"
MERYL_DIR="${QC_OUT}/meryl"
MERYL_COMPRESS_DIR="${QC_OUT}/meryl.compressed"
mkdir -p "$MERYL_DIR"
mkdir -p "$MERYL_COMPRESS_DIR"
GS_OUT="${QC_OUT}/genomescope"
mkdir -p "$GS_OUT"
DATA_DIR="${PROJECT_ROOT}/data"
YAK_DIR="${QC_OUT}/yak"
mkdir -p "${YAK_DIR}"

# Define target pedigree roles for loop processing
declare -a TARGET_ROLES=("terminal" "maternal" "paternal")
if [[ "$ThreeGenMode" == "YES" ]]; then
    TARGET_ROLES+=("MGS" "MGD")
fi
# ----------------------------------------------------------------------------------------------- #


# 1. Run Meryl [kmer analysis]
# ----------------------------------------------------------------------------------------------- #
echo "Starting K-mer (k=$KMER_LENGTH) Analysis with Meryl..."

for role in "${TARGET_ROLES[@]}"; do
    case "$role" in
        terminal) tag="$ILLUM_TERM_TAG"; raw="$ILLUM_TERM"; dir="${DATA_DIR}/illumina.terminal" ;;
        maternal) tag="$ILLUM_MAT_TAG";  raw="$ILLUM_MAT";  dir="${DATA_DIR}/illumina.maternal" ;;
        paternal) tag="$ILLUM_PAT_TAG";  raw="$ILLUM_PAT";  dir="${DATA_DIR}/illumina.paternal" ;;
        MGS)      tag="$ILLUM_MGS_TAG";  raw="$ILLUM_MGS";  dir="${DATA_DIR}/illumina.MGS" ;;
        MGD)      tag="$ILLUM_MGD_TAG";  raw="$ILLUM_MGD";  dir="${DATA_DIR}/illumina.MGD" ;;
    esac

    if [[ "$raw" != "NA" && -d "$dir" ]]; then
        readarray -t illum_files < <(find -L "$dir" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \))
        if [[ ${#illum_files[@]} -gt 0 ]]; then
            echo "Counting k-mers for role [$role] (Tag: $tag, ${#illum_files[@]} files found)..."
            
            # Standard Meryl DB
            echo "+ ${MERYL_SOFTWARE}/meryl k=$KMER_LENGTH count threads=16 memory=100G ${illum_files[*]} output ${MERYL_DIR}/${tag}.meryl"
            "${MERYL_SOFTWARE}/meryl" k="$KMER_LENGTH" count threads=16 memory=100G "${illum_files[@]}" output "${MERYL_DIR}/${tag}.meryl"
            
            echo "+ ${MERYL_SOFTWARE}/meryl statistics ${MERYL_DIR}/${tag}.meryl > ${MERYL_DIR}/${tag}.stats"
            "${MERYL_SOFTWARE}/meryl" statistics "${MERYL_DIR}/${tag}.meryl" > "${MERYL_DIR}/${tag}.stats"
            
            echo "+ ${MERYL_SOFTWARE}/meryl histogram ${MERYL_DIR}/${tag}.meryl > ${MERYL_DIR}/${tag}.hist"
            "${MERYL_SOFTWARE}/meryl" histogram "${MERYL_DIR}/${tag}.meryl" > "${MERYL_DIR}/${tag}.hist"
            echo "K-mer profile for $tag complete."
            
            # Compressed Meryl DB
            echo "Counting compressed k-mers for $tag..."
            echo "+ ${MERYL_SOFTWARE}/meryl k=$KMER_LENGTH compress count threads=16 memory=100G ${illum_files[*]} output ${MERYL_COMPRESS_DIR}/${tag}.meryl"
            "${MERYL_SOFTWARE}/meryl" k="$KMER_LENGTH" compress count threads=16 memory=100G "${illum_files[@]}" output "${MERYL_COMPRESS_DIR}/${tag}.meryl"
            echo "Compressed k-mers for $tag complete."
        else
            echo "WARNING: No Illumina files found in $dir for $tag"
        fi
    fi
done
# ----------------------------------------------------------------------------------------------- #


# 2. Run GenomeScope 2.0
# ----------------------------------------------------------------------------------------------- #
echo "Modeling K-mer distributions with GenomeScope 2.0..."

eval "$(micromamba shell hook --shell bash)"
micromamba activate genomescope2

for role in "${TARGET_ROLES[@]}"; do
    case "$role" in
        terminal) tag="$ILLUM_TERM_TAG" ;;
        maternal) tag="$ILLUM_MAT_TAG" ;;
        paternal) tag="$ILLUM_PAT_TAG" ;;
        MGS)      tag="$ILLUM_MGS_TAG" ;;
        MGD)      tag="$ILLUM_MGD_TAG" ;;
    esac

    if [[ "$tag" != "NA" && -f "${MERYL_DIR}/${tag}.hist" ]]; then
        echo "Processing GenomeScope for $tag..."
        mkdir -p "${GS_OUT}/${tag}"
        echo "+ Rscript $GENOMESCOPE2_SOFTWARE -i ${MERYL_DIR}/${tag}.hist -k $KMER_LENGTH -p 2 -o ${GS_OUT}/${tag}"
        Rscript "$GENOMESCOPE2_SOFTWARE" -i "${MERYL_DIR}/${tag}.hist" -k "$KMER_LENGTH" -p 2 -o "${GS_OUT}/${tag}"
    fi
done

micromamba deactivate
# ----------------------------------------------------------------------------------------------- #


# 3. Run Merqury Hapmer (Compressed and Non-Compressed) Databases & Trio Plotting
# ----------------------------------------------------------------------------------------------- #
echo "Initiating Merqury Trio Analysis..."
export PATH="$MERYL_SOFTWARE:$MERQURY_SOFTWARE:$MERQURY_SOFTWARE/build:$PATH"

# --- TRIO 1: The Terminal Animal (Always Run) ---
if [[ -d "${MERYL_DIR}/${ILLUM_TERM_TAG}.meryl" && -d "${MERYL_DIR}/${ILLUM_MAT_TAG}.meryl" && -d "${MERYL_DIR}/${ILLUM_PAT_TAG}.meryl" ]]; then
    echo "Processing Terminal Trio: ${ILLUM_TERM_TAG} (Offspring) + ${ILLUM_MAT_TAG} (Mat) + ${ILLUM_PAT_TAG} (Pat)"
    
    TERM_TRIO_DIR="${QC_OUT}/merqury_trio_terminal"
    mkdir -p "$TERM_TRIO_DIR" && cd "$TERM_TRIO_DIR"

    echo "Generating hapmers for Terminal Trio..."
    echo "+ ${MERQURY_SOFTWARE}/trio/hapmers.sh ${MERYL_DIR}/${ILLUM_MAT_TAG}.meryl ${MERYL_DIR}/${ILLUM_PAT_TAG}.meryl ${MERYL_DIR}/${ILLUM_TERM_TAG}.meryl"
    "${MERQURY_SOFTWARE}/trio/hapmers.sh" \
        "${MERYL_DIR}/${ILLUM_MAT_TAG}.meryl" \
        "${MERYL_DIR}/${ILLUM_PAT_TAG}.meryl" \
        "${MERYL_DIR}/${ILLUM_TERM_TAG}.meryl"
    
    cd "$PROJECT_ROOT"
    TERM_TRIO_COMPRESS_DIR="${QC_OUT}/merqury_trio_terminal.compressed"
    mkdir -p "$TERM_TRIO_COMPRESS_DIR" && cd "$TERM_TRIO_COMPRESS_DIR"
    
    echo "Generating compressed hapmers for Terminal Trio..."
    echo "+ ${MERQURY_SOFTWARE}/trio/hapmers.sh ${MERYL_COMPRESS_DIR}/${ILLUM_MAT_TAG}.meryl ${MERYL_COMPRESS_DIR}/${ILLUM_PAT_TAG}.meryl ${MERYL_COMPRESS_DIR}/${ILLUM_TERM_TAG}.meryl"
    "${MERQURY_SOFTWARE}/trio/hapmers.sh" \
        "${MERYL_COMPRESS_DIR}/${ILLUM_MAT_TAG}.meryl" \
        "${MERYL_COMPRESS_DIR}/${ILLUM_PAT_TAG}.meryl" \
        "${MERYL_COMPRESS_DIR}/${ILLUM_TERM_TAG}.meryl"
    
    cd "$PROJECT_ROOT"
else
    echo "SKIP: Terminal Trio missing required Meryl databases."
fi


# --- TRIO 2: The Maternal F1 (Optional 3-Gen Mode) ---
if [[ "$ThreeGenMode" == "YES" ]]; then
    if [[ -d "${MERYL_DIR}/${ILLUM_MAT_TAG}.meryl" && -d "${MERYL_DIR}/${ILLUM_MGS_TAG}.meryl" && -d "${MERYL_DIR}/${ILLUM_MGD_TAG}.meryl" ]]; then
        echo "Processing Maternal F1 Trio: ${ILLUM_MAT_TAG} (F1) + ${ILLUM_MGD_TAG} (MGD) + ${ILLUM_MGS_TAG} (MGS)"
        
        MAT_TRIO_DIR="${QC_OUT}/merqury_trio_maternal"
        mkdir -p "$MAT_TRIO_DIR" && cd "$MAT_TRIO_DIR"

        echo "Generating hapmers for Maternal F1 Trio..."
        echo "+ ${MERQURY_SOFTWARE}/trio/hapmers.sh ${MERYL_DIR}/${ILLUM_MGD_TAG}.meryl ${MERYL_DIR}/${ILLUM_MGS_TAG}.meryl ${MERYL_DIR}/${ILLUM_MAT_TAG}.meryl"
        "${MERQURY_SOFTWARE}/trio/hapmers.sh" \
            "${MERYL_DIR}/${ILLUM_MGD_TAG}.meryl" \
            "${MERYL_DIR}/${ILLUM_MGS_TAG}.meryl" \
            "${MERYL_DIR}/${ILLUM_MAT_TAG}.meryl"
        
        cd "$PROJECT_ROOT"
        MAT_TRIO_COMPRESS_DIR="${QC_OUT}/merqury_trio_maternal.compressed"
        mkdir -p "$MAT_TRIO_COMPRESS_DIR" && cd "$MAT_TRIO_COMPRESS_DIR"

        echo "Generating compressed hapmers for Maternal F1 Trio..."
        echo "+ ${MERQURY_SOFTWARE}/trio/hapmers.sh ${MERYL_COMPRESS_DIR}/${ILLUM_MGD_TAG}.meryl ${MERYL_COMPRESS_DIR}/${ILLUM_MGS_TAG}.meryl ${MERYL_COMPRESS_DIR}/${ILLUM_MAT_TAG}.meryl"
        "${MERQURY_SOFTWARE}/trio/hapmers.sh" \
            "${MERYL_COMPRESS_DIR}/${ILLUM_MGD_TAG}.meryl" \
            "${MERYL_COMPRESS_DIR}/${ILLUM_MGS_TAG}.meryl" \
            "${MERYL_COMPRESS_DIR}/${ILLUM_MAT_TAG}.meryl"
        
        cd "$PROJECT_ROOT"
    else
        echo "WARNING: ThreeGenMode is YES but Grandparent Meryl DBs (MGS/MGD) are missing."
    fi
fi

cd "$PROJECT_ROOT"
echo "Merqury Trio Plotting complete."
# ----------------------------------------------------------------------------------------------- #


# 4. Run YAK for k-mer databases (needed for Hifiasm)
# ----------------------------------------------------------------------------------------------- #
echo "Generating Yak hashes for HiFi binning..."

for role in "${TARGET_ROLES[@]}"; do
    case "$role" in
        terminal) tag="$ILLUM_TERM_TAG"; raw="$ILLUM_TERM"; dir="${DATA_DIR}/illumina.terminal" ;;
        maternal) tag="$ILLUM_MAT_TAG";  raw="$ILLUM_MAT";  dir="${DATA_DIR}/illumina.maternal" ;;
        paternal) tag="$ILLUM_PAT_TAG";  raw="$ILLUM_PAT";  dir="${DATA_DIR}/illumina.paternal" ;;
        MGS)      tag="$ILLUM_MGS_TAG";  raw="$ILLUM_MGS";  dir="${DATA_DIR}/illumina.MGS" ;;
        MGD)      tag="$ILLUM_MGD_TAG";  raw="$ILLUM_MGD";  dir="${DATA_DIR}/illumina.MGD" ;;
    esac

    if [[ "$raw" != "NA" && -d "$dir" ]]; then
        readarray -t illum_files < <(find -L "$dir" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \))
        if [[ ${#illum_files[@]} -gt 0 ]]; then
            echo "Generating Yak hash for role [$role] (Tag: $tag)..."
            echo "+ ${YAK_SOFTWARE} count -k31 -t16 -b37 -o ${YAK_DIR}/${tag}.yak <(zcat ${illum_files[*]})"
            "${YAK_SOFTWARE}" count -k31 -t16 -b37 -o "${YAK_DIR}/${tag}.yak" <(zcat "${illum_files[@]}")
        else
            echo "WARNING: No Illumina files found in $dir for Yak hash ($tag)"
        fi
    fi
done
# ----------------------------------------------------------------------------------------------- #

echo "kmers.sh complete!"