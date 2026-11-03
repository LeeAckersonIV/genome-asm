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

# Set up node-local scratch space to prevent network filesystem inode quota exhaustion
SCRATCH_BUSCO="${SLURM_TMPDIR:-/tmp}/busco_${SLURM_JOB_ID:-$$}"
mkdir -p "${SCRATCH_BUSCO}"

# Guarantee local scratch directory cleanup when job exits or terminates
trap 'rm -rf "${SCRATCH_BUSCO}"' EXIT

cd "${SCRATCH_BUSCO}"

echo "----------------------------------------------------------------"
echo "Launching BUSCO Gene Completeness Analysis (Scratch Mode)..."
echo "Local Node Scratch: ${SCRATCH_BUSCO}"
echo "Final Output Directory: ${OUTDIR}"
date

run_busco_hap() {
	local asm="$1"
	local hap="$2"

	echo "+ busco -i ${asm} -o ${hap} --out_path ${SCRATCH_BUSCO} --download_path ${DOWNLOAD_DIR} --offline -m genome -l ${LINEAGE} -c ${SLURM_CPUS_PER_TASK:-16} --force"
	
	busco -i "${asm}" \
		  -o "${hap}" \
		  --out_path "${SCRATCH_BUSCO}" \
		  --download_path "${DOWNLOAD_DIR}" \
		  --offline \
		  -m genome \
		  -l "${LINEAGE}" \
		  -c "${SLURM_CPUS_PER_TASK:-16}" \
		  --force

	# Purge intermediate sequence/blast/hmmer subdirectories on local scratch before transferring output
	echo "Purging temporary alignment chunks for ${hap}..."
	find "${SCRATCH_BUSCO}/${hap}" -type d \( -name "busco_sequences" -o -name "blast_output" -o -name "hmmer_output" -o -name "translated_proteins" -o -name "gbk" -o -name "gff" \) -exec rm -rf {} + 2>/dev/null || true

	# Transfer remaining summary reports, tables, JSONs, and log trees to network scratch
	echo "Transferring summary deliverables for ${hap} to ${OUTDIR}..."
	mkdir -p "${OUTDIR}/${hap}"
	cp -r "${SCRATCH_BUSCO}/${hap}/"* "${OUTDIR}/${hap}/"
}

if [[ -f "$ASM1" ]]; then
	run_busco_hap "$ASM1" "hap1"
fi

if [[ -f "$ASM2" ]]; then
	run_busco_hap "$ASM2" "hap2"
fi

# Copy top-level BUSCO execution log files to final output directory
cp "${SCRATCH_BUSCO}"/busco_*.log "${OUTDIR}/" 2>/dev/null || true

date
echo "----------------------------------------------------------------"