#!/bin/bash -l

# Parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
        --outdir)       VERKKO_ASM_OUTDIR="$2"; shift 2 ;;
        --hifi)         CLEAN_HIFI_DIR="$2"; shift 2 ;;
        --ont)          CLEAN_ONT_DIR="$2"; shift 2 ;;
        --mtDNA)        MTDNA_REF="$2"; shift 2 ;;
        --rDNA)         RDNA_REF="$2"; shift 2 ;;
        --meryl.mat)    MAT_HAPMERS="$2"; shift 2 ;;
        --meryl.pat)    PAT_HAPMERS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Set env
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Error: env.bashrc not found in ${PIPELINE_DIR}"
    exit 1
fi

echo "+ ${VERKKO_SOFTWARE} --version"
"${VERKKO_SOFTWARE}" --version

# Discover all cleaned HiFi FASTQ files across libraries
readarray -t HIFI_FILES < <(find -L "${CLEAN_HIFI_DIR}" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \) 2>/dev/null)
if [[ ${#HIFI_FILES[@]} -eq 0 ]]; then
    echo "Error: No cleaned HiFi FASTQ files found in ${CLEAN_HIFI_DIR}"
    exit 1
fi

# Build Verkko command array
# ------------------------------------------------------------------------------- #
VERKKO_CMD=(
    "${VERKKO_SOFTWARE}" --slurm 
    -d "${VERKKO_ASM_OUTDIR}"
    --unitig-abundance 4
    --hifi "${HIFI_FILES[@]}"
)

# Add optional mtDNA and rDNA screening refs if files exist
if [[ -n "$MTDNA_REF" && "$MTDNA_REF" != "NA" && -f "$MTDNA_REF" ]]; then
    VERKKO_CMD+=(--screen mtDNA "${MTDNA_REF}")
fi

if [[ -n "$RDNA_REF" && "$RDNA_REF" != "NA" && -f "$RDNA_REF" ]]; then
    VERKKO_CMD+=(--screen rDNA "${RDNA_REF}")
fi

# Add ONT reads if the directory exists and contains valid files
if [[ -n "$CLEAN_ONT_DIR" && "$CLEAN_ONT_DIR" != "NA" && -d "$CLEAN_ONT_DIR" ]]; then
    readarray -t ONT_FILES < <(find -L "${CLEAN_ONT_DIR}" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \) 2>/dev/null)
    if [[ ${#ONT_FILES[@]} -gt 0 ]]; then
        VERKKO_CMD+=(--nano "${ONT_FILES[@]}")
    fi
fi

# Add kmers and trio to end of command
VERKKO_CMD+=(--hap-kmers "${MAT_HAPMERS}" "${PAT_HAPMERS}" trio)

# Verbose execution logging
echo "----------------------------------------------------------------"
echo "Launching Verkko Trio Assembly..."
echo "Output Directory: ${VERKKO_ASM_OUTDIR}"
echo "+ PYTHONNOUSERSITE=1 ${VERKKO_CMD[*]}"
echo "----------------------------------------------------------------"

PYTHONNOUSERSITE=1 "${VERKKO_CMD[@]}"
# ------------------------------------------------------------------------------- #