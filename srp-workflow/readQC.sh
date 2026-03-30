#!/bin/bash -l

# =============================================================================================== #
# Script to perform read quality control (QC) analysis on input sequence data. Analysis includes 
# fastQC for long and short reads, as well as k-mer count and multiplicity statistics via Meryl.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# readQC.sh \
#	--load.project.params \		# can re-use input paramter config from initialize.sh; default NO
#	--projectROOT \ 			# where initialize.sh built the project directory at.
#	--kmer.length \ 			# kmer length for meryl dbs and kmer analysis; default=31
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
# salloc --time=4:00:00 --cpus-per-task=8 --mem=100G
# ./readQC.sh --projectROOT ~/scripts/SRP_1 --illumina.terminal.lib LIB212039 --illumina.maternal.lib LIB212038 --illumina.paternal.lib LIB212041 --illumina.MGS.lib LIB212046 --illumina.MGD.lib LIB212044 --hifi.terminal.lib LIB212031 --hifi.maternal.lib LIB212951

# OR, IF initialize.sh was RUN FIRST:

# salloc --time=4:00:00 --cpus-per-task=8 --mem=100G
# ./readQC.sh --projectROOT ../SRP_1 --load.project.params YES
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
	echo "readQC.sh \ "
	echo "	--load.project.params \		# can re-use input paramter config from initialize.sh; default NO"
	echo "	--projectROOT \ 			# where directory strcuture will be built, default is working dir"
	echo "	--kmer.length \ 			# kmer length for meryl dbs and kmer analysis; default=31"
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
	echo "readQC.sh \ "
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
KMER_LENGTH="31"

# load env.bashrc, inputs are overwritten first by config.params; and then by command line
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
	SNP_DIR="NA"
	RUNFASTQC="YES"
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
		--kmer.length)    		 	KMER_LENGTH="$2"; shift 2 ;;
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



# Run Main Quality Control workflow (FastQC, MultiQC, SeqKit, Meryl)
# ----------------------------------------------------------------------------------------------- #

# variables and directory structure
QC_OUT="${PROJECT_ROOT}/dataQC"
DATA_DIR="${PROJECT_ROOT}/data"
SEQKIT_OUT="${QC_OUT}/per_read_stats"
mkdir -p "$SEQKIT_OUT"
PLOT_DIR="${QC_OUT}/plots"
mkdir -p "$PLOT_DIR"
MERYL_DIR="${QC_OUT}/meryl"
mkdir -p "$MERYL_DIR"
GS_OUT="${QC_OUT}/genomescope"
mkdir -p "$GS_OUT"

# 1. run fastqc
# ----------------------------------------------------------------------------------------------- #
find "${PROJECT_ROOT}/data" -name "*.fastq.gz" | xargs "${FASTQC_SOFTWARE}/fastqc" -o "$QC_OUT" -t 8
echo "FastQC complete. Results are in: ${PROJECT_ROOT}/dataQC"

# 2. run seqkit
# ----------------------------------------------------------------------------------------------- #
for lib_dir in "${PROJECT_ROOT}/data"/*/; do
    lib_name=$(basename "$lib_dir")

	if [[ "$lib_name" == hifi.* ]] || [[ "$lib_name" == ont.* && "$ONT_TERM" != "NA" && "$ONT_MAT" != "NA" ]]; then
		echo "Processing Library: $lib_name"
		${SEQKIT_SOFTWARE}/seqkit fx2tab -l -q -n -H "$lib_dir"/*.fastq.gz > "${SEQKIT_OUT}/${lib_name}_stats.tsv"
    fi
done

# 3. run density_plot.py
# ----------------------------------------------------------------------------------------------- #
echo "Generating Joint Density Plots..."
for stats_file in "${SEQKIT_OUT}"/*_stats.tsv; do
    filename=$(basename "$stats_file")

	if [[ "$filename" == hifi.* ]] || [[ "$filename" == ont.* && "$ONT_TERM" != "NA" && "$ONT_MAT" != "NA" ]]; then	        
		lib_name=$(basename "$stats_file" _stats.tsv)
        python3 "${PIPELINE_DIR}/density_plot.py" "$stats_file" "${PLOT_DIR}/${lib_name}_joint_qc.png" "$lib_name"
    fi
done

# 4. run multiqc
# ----------------------------------------------------------------------------------------------- #
echo "Generating MultiQC Report..."
"${MULTIQC_SOFTWARE}/multiqc" "$QC_OUT" -o "$QC_OUT" --filename "MultiQC_Report"
echo "MultiQC complete. Review your report at: ${PROJECT_ROOT}/dataQC/MultiQC_Report.html"
echo "QC complete. Individual stats are in: $SEQKIT_OUT"


# 5. run Meryl [kmer analysis]
# ----------------------------------------------------------------------------------------------- #
echo "Starting K-mer (k=$KMER_LENGTH) Analysis with Meryl..."

# sort out which animals to include (3GenMode?)
KMER_LIBS=("$ILLUM_TERM" "$ILLUM_MAT" "$ILLUM_PAT")
if [[ "$ThreeGenMode" == "YES" ]]; then
    KMER_LIBS+=("$ILLUM_MGS" "$ILLUM_MGD")
fi

for lib in "${KMER_LIBS[@]}"; do
	# validate files exist
    if [[ "$lib" != "NA" && -n "$lib" ]]; then
		
        INPUT_FILES="${DATA_DIR}/illumina.*/${lib}"*.fastq.gz
		if ls $INPUT_FILES >/dev/null 2>&1; then
            
			echo "Counting k-mers for: $lib"
            "${MERYL_SOFTWARE}/meryl" k="$KMER_LENGTH" count threads=16 memory=100G $INPUT_FILES output "${MERYL_DIR}/${lib}.meryl"
            "${MERYL_SOFTWARE}/meryl" statistics "${MERYL_DIR}/${lib}.meryl" > "${MERYL_DIR}/${lib}.stats"
            "${MERYL_SOFTWARE}/meryl" histogram "${MERYL_DIR}/${lib}.meryl" > "${MERYL_DIR}/${lib}.hist"
            echo "K-mer profile for $lib complete."
			
        else
            echo "WARNING: No files found for $lib in ${DATA_DIR}/illumina.*/"
        fi
    fi
done


# 6. run GenomeScope 2.0
# ----------------------------------------------------------------------------------------------- #
echo "Modeling K-mer distributions with GenomeScope 2.0..."

eval "$(micromamba shell hook --shell bash)"
micromamba activate genomescope2

for lib in "${KMER_LIBS[@]}"; do
    if [[ "$lib" != "NA" && -f "${MERYL_DIR}/${lib}.hist" ]]; then
		
        echo "Processing $lib..."
        mkdir -p "${GS_OUT}/${lib}"
		Rscript "$GENOMESCOPE2_SOFTWARE" -i "${MERYL_DIR}/${lib}.hist" -k "$KMER_LENGTH" -p 2 -o "${GS_OUT}/${lib}"
    
	fi
done

micromamba deactivate

# 7. run Merqury Trio Plotting
# ----------------------------------------------------------------------------------------------- #
echo "Initiating Merqury Trio Analysis..."

# --- TRIO 1: The Terminal Animal (Always Run) ---
# Inputs: Terminal Animal | Mother: MAT | Father: PAT
if [[ "$ILLUM_TERM" != "NA" && "$ILLUM_MAT" != "NA" && "$ILLUM_PAT" != "NA" ]]; then
    echo "Processing Terminal Trio: ${ILLUM_TERM} (Offspring) + ${ILLUM_MAT} (Mat) + ${ILLUM_PAT} (Pat)"
    
	TERM_TRIO_DIR="${QC_OUT}/merqury_trio_terminal"
	mkdir -p "$TERM_TRIO_DIR" && cd "$TERM_TRIO_DIR"

    # Generate inherited hapmers
    echo "Generating hapmers for Terminal Trio..."
    "${MERQURY_SOFTWARE}/trio/hapmers.sh" \
        "${MERYL_DIR}/${ILLUM_MAT}.meryl" \
        "${MERYL_DIR}/${ILLUM_PAT}.meryl" \
        "${MERYL_DIR}/${ILLUM_TERM}.meryl"
	
	cd "$PROJECT_ROOT"
else
    echo "SKIP: Terminal Trio missing required Meryl databases."
fi


# --- TRIO 2: The Maternal F1 (Optional 3-Gen Mode) ---
# Inputs: MAT | Mother: MGD (Grand-Dam) | Father: MGS (Grand-Sire)
if [[ "$ThreeGenMode" == "YES" ]]; then
    if [[ "$ILLUM_MAT" != "NA" && "$ILLUM_MGS" != "NA" && "$ILLUM_MGD" != "NA" ]]; then
        echo "Processing Maternal F1 Trio: ${ILLUM_MAT} (F1) + ${ILLUM_MGD} (MGD) + ${ILLUM_MGS} (MGS)"
        
		MAT_TRIO_DIR="${QC_OUT}/merqury_trio_maternal"
		mkdir -p "$MAT_TRIO_DIR" && cd "$MAT_TRIO_DIR"

        echo "Generating hapmers for Maternal F1 Trio..."
        bash "${MERQURY_SOFTWARE}/trio/hapmers.sh" \
            "${MERYL_DIR}/${ILLUM_MGD}.meryl" \
            "${MERYL_DIR}/${ILLUM_MGS}.meryl" \
            "${MERYL_DIR}/${ILLUM_MAT}.meryl"

    else
        echo "WARNING: ThreeGenMode is YES but Grandparent IDs (MGS/MGD) are missing."
    fi
fi

# Return to root directory for any subsequent steps
cd "$PROJECT_ROOT"
echo "Step 7: Merqury Trio Plotting complete."
# ----------------------------------------------------------------------------------------------- #
