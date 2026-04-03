#!/bin/bash -l

# parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
		--outdir)  		HIFIASM_OUTDIR="$2"; shift 2 ;;
        --hifi)     	CLEAN_HIFI_DIR="$2"; shift 2 ;;
        --ont)			CLEAN_ONT_DIR="$2"; shift 2 ;;
        --yak.mat) 		MAT_HAPMERS="$2"; shift 2 ;;
		--yak.pat)  	PAT_HAPMERS="$2"; shift 2 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

# set env
hifiasm --version
if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Error: env.bashrc not found in ${PIPELINE_DIR}"
    exit 1
fi

# execute HiFiasm pipeline
# ------------------------------------------------------------------------------- #
# set default command flags
HIFIASM_CMD=(
    "${HIFIASM_SOFTWARE}"
	--dual-scaf
	--telo-m TTAGGG
    -o "${HIFIASM_OUTDIR}"
    -t "${SLURM_CPUS_PER_TASK:-48}"
    -1 "${MAT_HAPMERS}"
    -2 "${PAT_HAPMERS}"
)

# add ONT reads only if the directory exists and has files
if [[ -n "$CLEAN_ONT_DIR" && "$CLEAN_ONT_DIR" != "NA" ]]; then
	if ls "${CLEAN_ONT_DIR}"/*.fastq.gz >/dev/null 2>&1; then
		HIFIASM_CMD+=(--ul "${CLEAN_ONT_DIR}"/*.fastq.gz)
	fi
fi

# add HiFi input
HIFIASM_CMD+=("${CLEAN_HIFI_DIR}"/*.fastq.gz)

# execute command
echo "----------------------------------------------------------------"
echo "Launching HiFiasm Trio Assembly..."
echo "Output Prefix: ${HIFIASM_OUTDIR}"
echo "Full Command: ${HIFIASM_CMD[@]}"
echo "----------------------------------------------------------------"

"${HIFIASM_CMD[@]}"
# ------------------------------------------------------------------------------- #


