#!/bin/bash -l

# Parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
        --outdir)       HIFIASM_OUTDIR="$2"; shift 2 ;;
        --hifi)         CLEAN_HIFI_DIR="$2"; shift 2 ;;
        --ont)          CLEAN_ONT_DIR="$2"; shift 2 ;;
        --yak.mat)      MAT_HAPMERS="$2"; shift 2 ;;
        --yak.pat)      PAT_HAPMERS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Set environment
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Error: env.bashrc not found in ${PIPELINE_DIR}"
    exit 1
fi

echo "+ ${HIFIASM_SOFTWARE} --version"
"${HIFIASM_SOFTWARE}" --version 2>/dev/null || hifiasm --version

# Discover all cleaned HiFi FASTQ files across libraries
readarray -t HIFI_FILES < <(find -L "${CLEAN_HIFI_DIR}" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \) 2>/dev/null)
if [[ ${#HIFI_FILES[@]} -eq 0 ]]; then
    echo "Error: No cleaned HiFi FASTQ files found in ${CLEAN_HIFI_DIR}"
    exit 1
fi

# Ensure parent directory for output prefix exists
mkdir -p "$(dirname "${HIFIASM_OUTDIR}")"

# Execute HiFiasm pipeline
# ------------------------------------------------------------------------------- #
HIFIASM_CMD=(
    "${HIFIASM_SOFTWARE}"
    --dual-scaf
    --write-ec
    --trio-dual
    --telo-m TTAGGG
    -o "${HIFIASM_OUTDIR}"
    -t "${SLURM_CPUS_PER_TASK:-48}"
    -1 "${MAT_HAPMERS}"
    -2 "${PAT_HAPMERS}"
)

# Add ONT reads only if the directory exists and contains valid files
if [[ -n "$CLEAN_ONT_DIR" && "$CLEAN_ONT_DIR" != "NA" && -d "$CLEAN_ONT_DIR" ]]; then
    readarray -t ONT_FILES < <(find -L "${CLEAN_ONT_DIR}" -type f \( -name "*.fastq.gz" -o -name "*.fq.gz" \) 2>/dev/null)
    if [[ ${#ONT_FILES[@]} -gt 0 ]]; then
        HIFIASM_CMD+=(--ul "${ONT_FILES[@]}")
    fi
fi

# Add discovered HiFi input files to command array
HIFIASM_CMD+=("${HIFI_FILES[@]}")

# Execute command with verbose logging
echo "----------------------------------------------------------------"
echo "Launching HiFiasm Trio Assembly..."
echo "Output Prefix: ${HIFIASM_OUTDIR}"
echo "+ ${HIFIASM_CMD[*]}"
echo "----------------------------------------------------------------"

"${HIFIASM_CMD[@]}"
# ------------------------------------------------------------------------------- #