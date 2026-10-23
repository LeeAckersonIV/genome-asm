#!/bin/bash -l

# parse command line args
while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
		--outdir)  		OUTDIR="$2"; shift 2 ;;
        --assembly1)    ASM1="$2"; shift 2 ;;
		--assembly2)    ASM2="$2"; shift 2 ;;
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

# execute BUSCO commands
# ------------------------------------------------------------------------------- #
date
module load BUSCO/5.8.2-foss-2023a # MSU

mkdir -p "${OUTDIR}"

# first haplotype
busco --in "${ASM1}" \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out "${OUTDIR}/busco.hap1"

date

# second haplotype
busco --in "${ASM2}" \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out "${OUTDIR}/busco.hap2"

date