#!/bin/bash -l

# =============================================================================================== #
# Script to prepare PanSN-formatted assemblies, generate SLURM submission scripts, and option-
# ally submit Minigraph-Cactus, PGGB, and ODGI pangenome graph construction jobs.
# Author: Lee Ackerson {ackers24@msu.edu}
# =============================================================================================== #

set -euo pipefail

# Internal Defaults
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$PWD"
PANGENOME_DIR="pangenome_prep"
REF_NAME="REF_HxYL_ncbi_hap2"
RUN_CACTUS="FALSE"
RUN_PGGB="FALSE"
RUN_ODGI="FALSE"

# 1. Parse Input Arguments
while [[ $# -gt 0 ]]; do
	case "$1" in
		--pipelineDir)  PIPELINE_DIR="$2"; shift 2 ;;
		--projectROOT)  PROJECT_ROOT="$2"; shift 2 ;;
		--pangenomeDir) PANGENOME_DIR="$2"; shift 2 ;;
		--reference)    REF_NAME="$2"; shift 2 ;;
		--run.cactus)   RUN_CACTUS="$2"; shift 2 ;;
		--run.pggb)     RUN_PGGB="$2"; shift 2 ;;
		--run.odgi)     RUN_ODGI="$2"; shift 2 ;;
		*) echo "Error: Unknown option $1"; exit 1 ;;
	esac
done

if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
	source "${PIPELINE_DIR}/env.bashrc"
fi

PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")

# Determine absolute path for PANGENOME_DIR
if [[ "$PANGENOME_DIR" = /* ]]; then
	PREP_DIR="$PANGENOME_DIR"
else
	PREP_DIR="${PROJECT_ROOT}/${PANGENOME_DIR}"
fi

ASM_DIR="${PREP_DIR}/assemblies"
PUBLIC_REF_DIR="${PREP_DIR}/public_refs"
BUILD_DIR="${PREP_DIR}/pangenome_build"
PANSN_DIR="${BUILD_DIR}/pansn_genomes"
CACTUS_DIR="${BUILD_DIR}/minigraph_cactus"
PGGB_DIR="${BUILD_DIR}/pggb"

mkdir -p "${PANSN_DIR}" "${CACTUS_DIR}" "${PGGB_DIR}"

echo "----------------------------------------------------------------"
echo "Starting Pangenome Preparation Workflow..."
echo "Project Root:    ${PROJECT_ROOT}"
echo "Prep Directory:  ${PREP_DIR}"
echo "Build Directory: ${BUILD_DIR}"
echo "Reference Tag:   ${REF_NAME}"
date
echo "----------------------------------------------------------------"

# 2. Format PanSN Headers & Concatenate Assemblies
COMBINED_FASTA="${BUILD_DIR}/all_assemblies.pansn.fa"
SEQFILE="${CACTUS_DIR}/pangenome.seqfile"

> "${COMBINED_FASTA}"
> "${SEQFILE}"

echo "Formatting FASTA headers to PanSN spec..."

shopt -s nullglob
assembly_files=("${ASM_DIR}"/*.fasta "${ASM_DIR}"/*.fa "${PUBLIC_REF_DIR}"/*.fasta "${PUBLIC_REF_DIR}"/*.fa "${PUBLIC_REF_DIR}"/*.fna)
shopt -u nullglob

if [[ ${#assembly_files[@]} -eq 0 ]]; then
	echo "Error: No FASTA files found in ${ASM_DIR} or ${PUBLIC_REF_DIR}"
	exit 1
fi

for asm_path in "${assembly_files[@]}"; do
	filename=$(basename "$asm_path")
	sample_tag="${filename%.*}"
	clean_tag="${sample_tag//./_}"
	pansn_out="${PANSN_DIR}/${sample_tag}.pansn.fa"

	echo "  -> Processing: ${filename} as sample ID: ${clean_tag}"

	awk -v sample="${clean_tag}" '/^>/{print ">" sample "#" ++i; next} {print}' "$asm_path" > "$pansn_out"
	cat "$pansn_out" >> "${COMBINED_FASTA}"
	echo -e "${clean_tag}\t${pansn_out}" >> "${SEQFILE}"
done

echo "Combined PanSN FASTA: ${COMBINED_FASTA}"
echo "Cactus Seqfile:       ${SEQFILE}"


# 3. Write Minigraph-Cactus SLURM Script
cat << 'EOF' > "${CACTUS_DIR}/run_cactus.sb"
#!/bin/bash -l
#SBATCH --job-name=cactus_pangenome
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=1000G
#SBATCH --time=167:00:00
#SBATCH --output=cactus-%j.out
#SBATCH --error=cactus-%j.err

set -euo pipefail

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting Minigraph-Cactus run on $(hostname)..."

CACTUS_DIR="${SLURM_SUBMIT_DIR:-$PWD}"
PIPELINE_DIR="$(cd "${CACTUS_DIR}/../../.." && pwd)"

if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
	source "${PIPELINE_DIR}/env.bashrc"
fi

WORK_DIR="${SLURM_TMPDIR:-/mnt/gs21/scratch/ackers24/tmp}/cactus_${SLURM_JOB_ID}"
JOBSTORE_PATH="${WORK_DIR}/jobstore"

mkdir -p "${WORK_DIR}"
trap 'rm -rf "${WORK_DIR}"' EXIT

SEQFILE="${CACTUS_DIR}/pangenome.seqfile"
OUT_DIR="${CACTUS_DIR}/output"
mkdir -p "${OUT_DIR}"

REF_SAMPLE="REF_HxYL_ncbi_hap2"

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Executing Cactus-Pangenome Container..."

singularity exec --cleanenv \
	-B /mnt/research,/mnt/gs21,"${WORK_DIR}":"${WORK_DIR}","${CACTUS_DIR}":"${CACTUS_DIR}" \
	"${CACTUS_SOFTWARE:-/mnt/research/qgg/software/cactus/cactus_v3.1.4.sif}" \
	cactus-pangenome \
		"${JOBSTORE_PATH}" \
		"${SEQFILE}" \
		--outDir "${OUT_DIR}" \
		--outName pig_pangenome \
		--reference "${REF_SAMPLE}" \
		--batchSystem single_machine \
		--binariesMode local \
		--consCores "${SLURM_CPUS_PER_TASK:-64}" \
		--chrom-og full

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Minigraph-Cactus complete!"
EOF

chmod +x "${CACTUS_DIR}/run_cactus.sb"


# 4. Write PGGB SLURM Script
cat << 'EOF' > "${PGGB_DIR}/run_pggb.sb"
#!/bin/bash -l
#SBATCH --job-name=pggb_pangenome
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=64
#SBATCH --mem=1000G
#SBATCH --time=167:00:00
#SBATCH --output=pggb-%j.out
#SBATCH --error=pggb-%j.err

set -euo pipefail

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Starting PGGB run on $(hostname)..."

PGGB_BUILD_DIR="${SLURM_SUBMIT_DIR:-$PWD}"
BUILD_DIR="$(cd "${PGGB_BUILD_DIR}/.." && pwd)"
COMBINED_FASTA="${BUILD_DIR}/all_assemblies.pansn.fa"
OUT_DIR="${PGGB_BUILD_DIR}/output"
mkdir -p "${OUT_DIR}"

if command -v micromamba &>/dev/null; then
	eval "$(micromamba shell hook --shell bash)"
	micromamba activate pggb
fi

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Indexing combined PanSN FASTA..."
if [[ ! -f "${COMBINED_FASTA}.fai" ]]; then
	samtools faidx "${COMBINED_FASTA}"
fi

pggb \
	-i "${COMBINED_FASTA}" \
	-o "${OUT_DIR}" \
	-t "${SLURM_CPUS_PER_TASK:-64}" \
	-p 98 \
	-s 5000 \
	-n 13 \
	-V 'REF_HxYL_ncbi_hap2:#:'

echo "[$(date '+%Y-%m-%d %H:%M:%S')] PGGB run complete!"
EOF

chmod +x "${PGGB_DIR}/run_pggb.sb"


# 5. Conditionally Dispatch SLURM Jobs
RUN_CACTUS_UPPER=$(echo "$RUN_CACTUS" | tr '[:lower:]' '[:upper:]')
RUN_PGGB_UPPER=$(echo "$RUN_PGGB" | tr '[:lower:]' '[:upper:]')

if [[ "$RUN_CACTUS_UPPER" == "TRUE" || "$RUN_CACTUS_UPPER" == "YES" ]]; then
	echo "Submitting Minigraph-Cactus SLURM job..."
	(cd "${CACTUS_DIR}" && sbatch run_cactus.sb)
fi

if [[ "$RUN_PGGB_UPPER" == "TRUE" || "$RUN_PGGB_UPPER" == "YES" ]]; then
	echo "Submitting PGGB SLURM job..."
	(cd "${PGGB_DIR}" && sbatch run_pggb.sb)
fi

echo "----------------------------------------------------------------"
echo "Pangenome execution pipeline complete!"
date
echo "----------------------------------------------------------------"