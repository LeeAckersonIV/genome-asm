#!/bin/bash -l

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

if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Error: env.bashrc not found in ${PIPELINE_DIR}"
    exit 1
fi

DOWNLOAD_DIR="${PIPELINE_DIR}/references/busco_downloads"
mkdir -p "${OUTDIR}"

module load BUSCO/5.8.2-foss-2023a

echo "----------------------------------------------------------------"
echo "Launching BUSCO Gene Completeness Analysis..."
echo "Output Directory: ${OUTDIR}"
date

if [[ -f "$ASM1" ]]; then
    echo "+ busco -i ${ASM1} -o hap1 --out_path ${OUTDIR} --download_path ${DOWNLOAD_DIR} --offline -m genome -l ${LINEAGE} -c ${SLURM_CPUS_PER_TASK:-16} --force"
    busco -i "${ASM1}" \
          -o hap1 \
          --out_path "${OUTDIR}" \
          --download_path "${DOWNLOAD_DIR}" \
          --offline \
          -m genome \
          -l "${LINEAGE}" \
          -c "${SLURM_CPUS_PER_TASK:-16}" \
          --force
fi

if [[ -f "$ASM2" ]]; then
    echo "+ busco -i ${ASM2} -o hap2 --out_path ${OUTDIR} --download_path ${DOWNLOAD_DIR} --offline -m genome -l ${LINEAGE} -c ${SLURM_CPUS_PER_TASK:-16} --force"
    busco -i "${ASM2}" \
          -o hap2 \
          --out_path "${OUTDIR}" \
          --download_path "${DOWNLOAD_DIR}" \
          --offline \
          -m genome \
          -l "${LINEAGE}" \
          -c "${SLURM_CPUS_PER_TASK:-16}" \
          --force
fi

date
echo "----------------------------------------------------------------"