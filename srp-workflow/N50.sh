#!/bin/bash -l

# Parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir) PIPELINE_DIR="$2"; shift 2 ;;
        --outdir)      OUTDIR="$2"; shift 2 ;;
        --assembly1)   ASM1="$2"; shift 2 ;;
        --assembly2)   ASM2="$2"; shift 2 ;;
        --reference)   REF="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# Source environment settings
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Error: env.bashrc not found in ${PIPELINE_DIR}"
    exit 1
fi

# Ensure output directory exists
mkdir -p "${OUTDIR}"

# set env
module load QUAST/5.2.0 #MSU

# Build QUAST command array
QUAST_CMD=(
    quast.py
    -t "${SLURM_CPUS_PER_TASK:-8}"
    -o "${OUTDIR}"
    -r "${REF}"
    --large
    "${ASM1}"
    "${ASM2}"
)

# Execute command with verbose logging
echo "----------------------------------------------------------------"
echo "Launching QUAST Contiguity & N50 Analysis..."
echo "Output Directory: ${OUTDIR}"
echo "+ ${QUAST_CMD[*]}"
echo "----------------------------------------------------------------"
date
"${QUAST_CMD[@]}"
date