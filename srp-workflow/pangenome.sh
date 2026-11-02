#!/bin/bash -l

# =============================================================================================== #
# Script: pangenome.sh
# Purpose: Build Minigraph-Cactus and/or PGGB pangenome graphs from harvested assemblies,
#          including automated PanSN header formatting and ODGI graph visualizations.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# Usage Example:
#   ./pangenome.sh \
#     --pangenomeDir pangenome_prep \
#     --ref.genome SRP1_maternal_hifiasm_hap1 \
#     --run.cactus TRUE \
#     --run.pggb TRUE \
#     --run.odgi TRUE
# =============================================================================================== #

usage() {
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  --pangenomeDir     Directory containing assemblies prepared by prepangenome.sh (REQUIRED)"
	echo "  --ref.genome       Name of backbone reference genome tag (REQUIRED; e.g. SRP1_maternal_hifiasm_hap1)"
	echo "  --ref.fasta        Path to external reference FASTA file (optional)"
	echo "  --cactus.sif       Path to Cactus Singularity image (default: /mnt/research/qgg/software/cactus/cactus_v3.1.4.sif)"
	echo "  --run.cactus       Run Minigraph-Cactus pangenome construction (TRUE/FALSE; default: TRUE)"
	echo "  --run.pggb         Run PGGB pangenome construction (TRUE/FALSE; default: TRUE)"
	echo "  --run.odgi         Generate ODGI 1D/2D visualization plots (TRUE/FALSE; default: TRUE)"
	echo "  --cpus             CPUs per SLURM job (default: 64)"
	echo "  --mem              Memory per SLURM job (default: 500G)"
	echo "  --time             Walltime per SLURM job (default: 48:00:00)"
	echo "  --help             Display this help message"
	echo ""
	exit 1
}

# Default parameters
PREP_DIR=""
REF_GENOME=""
REF_FASTA=""
CACTUS_SIF="/mnt/research/qgg/software/cactus/cactus_v3.1.4.sif"
RUN_CACTUS="TRUE"
RUN_PGGB="TRUE"
RUN_ODGI="TRUE"
CPUS=64
MEM="500G"
WALLTIME="48:00:00"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--pangenomeDir) PREP_DIR="$2"; shift 2 ;;
		--ref.genome)   REF_GENOME="$2"; shift 2 ;;
		--ref.fasta)    REF_FASTA="$2"; shift 2 ;;
		--cactus.sif)   CACTUS_SIF="$2"; shift 2 ;;
		--run.cactus)   RUN_CACTUS="$2"; shift 2 ;;
		--run.pggb)     RUN_PGGB="$2"; shift 2 ;;
		--run.odgi)     RUN_ODGI="$2"; shift 2 ;;
		--cpus)         CPUS="$2"; shift 2 ;;
		--mem)          MEM="$2"; shift 2 ;;
		--time)         WALLTIME="$2"; shift 2 ;;
		--help)         usage ;;
		*)              echo "Error: Unknown option $1"; usage ;;
	esac
done

is_true() {
	local val="${1^^}"
	[[ "$val" == "TRUE" || "$val" == "YES" || "$val" == "1" ]]
}

if [[ -z "$PREP_DIR" || ! -d "$PREP_DIR" ]]; then
	echo "Error: Valid --pangenomeDir is required."
	usage
fi

if [[ -z "$REF_GENOME" ]]; then
	echo "Error: --ref.genome tag is required (must match a harvested sample name or external reference tag)."
	usage
fi

PREP_DIR=$(readlink -f "$PREP_DIR")
ASSEMBLY_DIR="${PREP_DIR}/assemblies"
PANGENOME_OUT="${PREP_DIR}/pangenome_build"
mkdir -p "${PANGENOME_OUT}"

PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================================================"
echo "Initiating Pangenome Construction Pipeline..."
echo "Assembly Source: ${ASSEMBLY_DIR}"
echo "Reference Tag:   ${REF_GENOME}"
echo "Build Directory: ${PANGENOME_OUT}"
echo "========================================================================"

ASSEMBLIES=(${ASSEMBLY_DIR}/*.fasta)
if [[ ${#ASSEMBLIES[@]} -eq 0 || ! -f "${ASSEMBLIES[0]}" ]]; then
	echo "Error: No FASTA assemblies found in ${ASSEMBLY_DIR}"
	exit 1
fi

# ----------------------------------------------------------------------------------------------- #
# Step 1: PanSN FASTA Header Formatting
# PanSN Format: Sample#Haplotype#ContigID
# ----------------------------------------------------------------------------------------------- #
PANSN_DIR="${PANGENOME_OUT}/pansn_genomes"
mkdir -p "${PANSN_DIR}"

echo -e "\nFormatting FASTA headers to PanSN specifications..."
PANSN_FASTAS=()

for fa in "${ASSEMBLIES[@]}"; do
	base=$(basename "$fa" .fasta)
	sample_name="${base//./_}" # Converts SRP1.maternal.hifiasm.hap1 -> SRP1_maternal_hifiasm_hap1
	
	pansn_fa="${PANSN_DIR}/${base}.pansn.fa"
	echo "  Formatting ${base} -> ${sample_name}#1#..."
	
	awk -v prefix="${sample_name}#1#" '/^>/{print ">" prefix substr($1,2); next} {print}' "$fa" > "$pansn_fa"
	PANSN_FASTAS+=("$pansn_fa")
done

# Optional: Format external reference FASTA if supplied
if [[ -n "$REF_FASTA" && -f "$REF_FASTA" ]]; then
	echo "  Formatting external reference ${REF_GENOME}..."
	pansn_ref="${PANSN_DIR}/${REF_GENOME}.pansn.fa"
	awk -v prefix="${REF_GENOME}#1#" '/^>/{print ">" prefix substr($1,2); next} {print}' "$REF_FASTA" > "$pansn_ref"
	PANSN_FASTAS+=("$pansn_ref")
fi

# Concatenate all PanSN FASTAs into a single multi-FASTA for PGGB
COMBINED_FA="${PANGENOME_OUT}/all_assemblies.pansn.fa"
cat "${PANSN_FASTAS[@]}" > "$COMBINED_FA"

# ----------------------------------------------------------------------------------------------- #
# Step 2: Minigraph-Cactus Pangenome Pipeline
# ----------------------------------------------------------------------------------------------- #
if is_true "$RUN_CACTUS"; then
	CACTUS_DIR="${PANGENOME_OUT}/minigraph_cactus"
	mkdir -p "${CACTUS_DIR}"
	
	SEQFILE="${CACTUS_DIR}/pangenome.seqfile"
	rm -f "$SEQFILE"
	
	for fa in "${PANSN_FASTAS[@]}"; do
		base=$(basename "$fa" .pansn.fa)
		sample_name="${base//./_}"
		echo -e "${sample_name}\t${fa}" >> "$SEQFILE"
	done

	CACTUS_SB="${CACTUS_DIR}/run_cactus.sb"
	cat <<EOT > "$CACTUS_SB"
#!/bin/bash --login
#SBATCH --job-name=cactus-pangenome
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=${MEM}
#SBATCH --time=${WALLTIME}
#SBATCH --output=${CACTUS_DIR}/cactus-%j.out

cd ${CACTUS_DIR}

SCRATCH_DIR="/mnt/gs21/scratch/\${USER}/tmp_cactus_\${SLURM_JOB_ID}"
JOBSTORE_PATH="\${SCRATCH_DIR}/jobstore"
mkdir -p "\$SCRATCH_DIR" "\$JOBSTORE_PATH"

singularity exec --cleanenv -B /mnt/research,/mnt/gs21 "${CACTUS_SIF}" \\
    cactus-pangenome \\
    "\$JOBSTORE_PATH" \\
    ${SEQFILE} \\
    --outDir ${CACTUS_DIR}/output \\
    --outName pig_pangenome \\
    --reference ${REF_GENOME} \\
    --batchSystem single_machine \\
    --binariesMode local \\
    --consCores \${SLURM_CPUS_PER_TASK} \\
    --chrom-og full

rm -rf "\$SCRATCH_DIR"
EOT

	echo "Submitting Minigraph-Cactus SLURM job..."
	sbatch "$CACTUS_SB"
fi

# ----------------------------------------------------------------------------------------------- #
# Step 3: PGGB Pangenome Pipeline
# ----------------------------------------------------------------------------------------------- #
if is_true "$RUN_PGGB"; then
	PGGB_DIR="${PANGENOME_OUT}/pggb"
	mkdir -p "${PGGB_DIR}"

	PGGB_SB="${PGGB_DIR}/run_pggb.sb"
	cat <<EOT > "$PGGB_SB"
#!/bin/bash --login
#SBATCH --job-name=pggb-pangenome
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=${MEM}
#SBATCH --time=${WALLTIME}
#SBATCH --output=${PGGB_DIR}/pggb-%j.out

cd ${PGGB_DIR}

if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
	source "${PIPELINE_DIR}/env.bashrc"
fi

module load SAMtools

samtools faidx ${COMBINED_FA}

pggb -i ${COMBINED_FA} \\
	-s 10000 \\
	-p 98 \\
	-n 5 \\
	-t ${CPUS} \\
	-V '${REF_GENOME}:0' \\
	-o ${PGGB_DIR}/output
EOT

	echo "Submitting PGGB SLURM job..."
	sbatch "$PGGB_SB"
fi

# ----------------------------------------------------------------------------------------------- #
# Step 4: ODGI Visualizations (1D Scans & 2D Layouts)
# ----------------------------------------------------------------------------------------------- #
if is_true "$RUN_ODGI" && is_true "$RUN_CACTUS"; then
	VIZ_DIR="${CACTUS_DIR}/odgi_visualizations"
	mkdir -p "${VIZ_DIR}"

	ODGI_SB="${VIZ_DIR}/run_odgi_viz.sb"
	cat <<EOT > "$ODGI_SB"
#!/bin/bash --login
#SBATCH --job-name=odgi-viz
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=250G
#SBATCH --time=24:00:00
#SBATCH --output=${VIZ_DIR}/odgi-viz-%j.out

cd ${VIZ_DIR}

CHROM_DIR="${CACTUS_DIR}/output/pig_pangenome.chroms"

if [[ -d "\$CHROM_DIR" ]]; then
	for og in \${CHROM_DIR}/*.og; do
		base=\$(basename "\$og" .og)
		
		# 1D Linear Depth Scan
		singularity exec --cleanenv -B /mnt/research,/mnt/gs21 "${CACTUS_SIF}" \\
			odgi viz -i "\$og" -o "\${base}_1D_scan.png" -z -P -x 5000 -y 1000

		# 2D Graph Layout Sorting and Rendering
		singularity exec --cleanenv -B /mnt/research,/mnt/gs21 "${CACTUS_SIF}" \\
			odgi sort -i "\$og" -o "\${base}_sorted.og" -O -p b

		singularity exec --cleanenv -B /mnt/research,/mnt/gs21 "${CACTUS_SIF}" \\
			odgi layout -i "\${base}_sorted.og" -o "\${base}.lay" -t ${CPUS}

		singularity exec --cleanenv -B /mnt/research,/mnt/gs21 "${CACTUS_SIF}" \\
			odgi draw -i "\${base}_sorted.og" -c "\${base}.lay" -p "\${base}_2D_layout.png" -C -b 1000 -w 30 -S 1
	done
fi
EOT

	echo "Submitting ODGI visualization SLURM job..."
	sbatch "$ODGI_SB"
fi

echo -e "\nPangenome construction tasks successfully dispatched."