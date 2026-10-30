#!/bin/bash -l

# Parse command line args
LINEAGE="cetartiodactyla_odb10"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --pipelineDir) PIPELINE_DIR="$2"; shift 2 ;;
        --outdir)      OUTDIR="$2"; shift 2 ;;
        --assembly1)   ASM1="$2"; shift 2 ;;
        --assembly2)   ASM2="$2"; shift 2 ;;
        --lineage)     LINEAGE="$2"; shift 2 ;;
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

# Create target output paths
mkdir -p "${OUTDIR}"

# set env
module load BUSCO/5.8.2-foss-2023a # MSU

echo "----------------------------------------------------------------"
echo "Launching BUSCO Gene Completeness Analysis..."
echo "Output Directory: ${OUTDIR}"
date
# Evaluate Haplotype 1
if [[ -f "$ASM1" ]]; then
    echo "+ busco -i ${ASM1} -o hap1 --out_path ${OUTDIR} -m genome -l ${LINEAGE} -c ${SLURM_CPUS_PER_TASK:-16} --force"
    busco -i "${ASM1}" -o hap1 --out_path "${OUTDIR}" -m genome -l "${LINEAGE}" -c "${SLURM_CPUS_PER_TASK:-16}" --force
fi

# Evaluate Haplotype 2
if [[ -f "$ASM2" ]]; then
    echo "+ busco -i ${ASM2} -o hap2 --out_path ${OUTDIR} -m genome -l ${LINEAGE} -c ${SLURM_CPUS_PER_TASK:-16} --force"
    busco -i "${ASM2}" -o hap2 --out_path "${OUTDIR}" -m genome -l "${LINEAGE}" -c "${SLURM_CPUS_PER_TASK:-16}" --force
fi
date
echo "----------------------------------------------------------------"