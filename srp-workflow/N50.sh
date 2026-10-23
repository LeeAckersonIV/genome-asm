#!/bin/bash -l

# parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
		--outdir)  		OUTDIR="$2"; shift 2 ;;
        --assembly1)    ASM1="$2"; shift 2 ;;
		--assembly2)    ASM2="$2"; shift 2 ;;
        --reference)	REF="$2"; shift 2 ;;
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

# execute QUAST command
# ------------------------------------------------------------------------------- #
date
module load QUAST/5.2.0 #MSU

mkdir -p "${OUTDIR}"
quast -o "${OUTDIR}" -r "${REF}" "${ASM1}" "${ASM2}"

date
# ------------------------------------------------------------------------------- #
