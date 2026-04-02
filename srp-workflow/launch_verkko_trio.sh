#!/bin/bash -l

# parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
        --outdir)  		VERKKO_ASM_OUTDIR="$2"; shift 2 ;;
        --hifi)     	CLEAN_HIFI_DIR="$2"; shift 2 ;;
        --ont)			CLEAN_ONT_DIR="$2"; shift 2 ;;
        --mtDNA) 		MTDNA_REF="$2"; shift 2 ;;
        --rDNA) 		RDNA_REF="$2"; shift 2 ;;
        --meryl.mat) 	MAT_HAPMERS="$2"; shift 2 ;;
		--meryl.pat)  	PAT_HAPMERS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# set env
micromamba activate verkkov2.3.2
verkko --version
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Error: env.bashrc not found in ${PIPELINE_DIR}"
    exit 1
fi

# execute verkko pipeline
# ------------------------------------------------------------------------------- #
# set default flags minus kmers/trio
VERKKO_CMD=(
    verkko --slurm 
    -d "${VERKKO_ASM_OUTDIR}"
    --unitig-abundance 4
    --hifi "${CLEAN_HIFI_DIR}"/*.fastq.gz
    --screen mtDNA "${MTDNA_REF}"
    --screen rDNA "${RDNA_REF}"
)

# add ONT reads only if the directory exists and has files
if [[ -n "$CLEAN_ONT_DIR" && "$CLEAN_ONT_DIR" != "NA" ]]; then
    if ls "${CLEAN_ONT_DIR}"/*.fastq.gz >/dev/null 2>&1; then
        VERKKO_CMD+=(--nano "${CLEAN_ONT_DIR}"/*.fastq.gz)
    fi
fi

# add kmers and trio to end of command
VERKKO_CMD+=(--hap-kmers "${MAT_HAPMERS}" "${PAT_HAPMERS}" trio)

# execute command
echo "----------------------------------------------------------------"
echo "Lauching Verkko Trio Assembly..."
echo "Output Directory: ${VERKKO_ASM_OUTDIR}"
echo "Full Command: ${VERKKO_CMD[@]}"
echo "----------------------------------------------------------------"

"${VERKKO_CMD[@]}"
# ------------------------------------------------------------------------------- #

