#!/bin/bash -l

# =============================================================================================== #
# Script: pangenome.sh
# Purpose: Format assemblies to PanSN standards and launch Minigraph-Cactus, PGGB, and ODGI.
# Default Reference Backbone: REF_HxYL_ncbi_hap2 (Maternal YL 2.0)
# =============================================================================================== #

log() {
	echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_BASHRC="${PIPELINE_DIR}/env.bashrc"

# Automatically source env.bashrc if available
if [[ -f "$ENV_BASHRC" ]]; then
	log "Sourcing pipeline environment: ${ENV_BASHRC}"
	source "$ENV_BASHRC"
fi

usage() {
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  --pangenomeDir     Directory containing assemblies prepared by prepangenome.sh (REQUIRED)"
	echo "  --ref.genome       Name of backbone reference sample tag (default: REF_HxYL_ncbi_hap2)"
	echo "  --cactus.sif       Path to Cactus Singularity image (default: \$CACTUS_SOFTWARE or /mnt/research/qgg/software/cactus/cactus_v3.1.4.sif)"
	echo "  --micromamba.env   Micromamba environment name for PGGB/ODGI (default: pggb)"
	echo "  --segment.len      PGGB segment length -s in bp (default: 50000)"
	echo "  --map.pct          PGGB minimum mapping percent identity -p (default: 98)"
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
REF_GENOME="REF_HxYL_ncbi_hap2"
CACTUS_SIF="${CACTUS_SOFTWARE:-/mnt/research/qgg/software/cactus/cactus_v3.1.4.sif}"
MICROMAMBA_ENV="pggb"
SEGMENT_LEN=50000
MAP_PCT=98
RUN_CACTUS="TRUE"
RUN_PGGB="TRUE"
RUN_ODGI="TRUE"
CPUS=64
MEM="500G"
WALLTIME="48:00:00"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--pangenomeDir)   PREP_DIR="$2"; shift 2 ;;
		--ref.genome)     REF_GENOME="$2"; shift 2 ;;
		--cactus.sif)     CACTUS_SIF="$2"; shift 2 ;;
		--micromamba.env) MICROMAMBA_ENV="$2"; shift 2 ;;
		--segment.len)    SEGMENT_LEN="$2"; shift 2 ;;
		--map.pct)        MAP_PCT="$2"; shift 2 ;;
		--run.cactus)      RUN_CACTUS="$2"; shift 2 ;;
		--run.pggb)        RUN_PGGB="$2"; shift 2 ;;
		--run.odgi)        RUN_ODGI="$2"; shift 2 ;;
		--cpus)            CPUS="$2"; shift 2 ;;
		--mem)             MEM="$2"; shift 2 ;;
		--time)            WALLTIME="$2"; shift 2 ;;
		--help)            usage ;;
		*)                 log "Error: Unknown option $1"; usage ;;
	esac
done

is_true() {
	local val="${1^^}"
	[[ "$val" == "TRUE" || "$val" == "YES" || "$val" == "1" ]]
}

if [[ -z "$PREP_DIR" || ! -d "$PREP_DIR" ]]; then
	log "Error: Valid --pangenomeDir is required."
	usage
fi

PREP_DIR=$(readlink -f "$PREP_DIR")
ASSEMBLY_DIR="${PREP_DIR}/assemblies"
PANGENOME_OUT="${PREP_DIR}/pangenome_build"
mkdir -p "${PANGENOME_OUT}"

log "========================================================================"
log "Initiating Pangenome Construction Pipeline..."
log "Assembly Source:       ${ASSEMBLY_DIR}"
log "Backbone Reference:    ${REF_GENOME}"
log "Build Directory:       ${PANGENOME_OUT}"
log "Cactus Container SIF:  ${CACTUS_SIF}"
log "Micromamba Env:        ${MICROMAMBA_ENV}"
log "PGGB Segment Length:   ${SEGMENT_LEN} bp"
log "PGGB Map Identity:     ${MAP_PCT}%"
log "========================================================================"

ASSEMBLIES=(${ASSEMBLY_DIR}/*.fasta)
if [[ ${#ASSEMBLIES[@]} -eq 0 || ! -f "${ASSEMBLIES[0]}" ]]; then
	log "Error: No FASTA assemblies found in ${ASSEMBLY_DIR}"
	exit 1
fi

NUM_ASMS=${#ASSEMBLIES[@]}
log "Total input assemblies detected: ${NUM_ASMS}"

# ----------------------------------------------------------------------------------------------- #
# Step 1: PanSN FASTA Header Formatting
# ----------------------------------------------------------------------------------------------- #
PANSN_DIR="${PANGENOME_OUT}/pansn_genomes"
mkdir -p "${PANSN_DIR}"

log "Formatting FASTA headers to PanSN specifications (Sample#1#Contig)..."
PANSN_FASTAS=()

for fa in "${ASSEMBLIES[@]}"; do
	base=$(basename "$fa" .fasta)
	sample_name="${base//./_}"
	
	pansn_fa="${PANSN_DIR}/${base}.pansn.fa"
	log "  [PanSN Format] ${base} -> ${sample_name}#1#..."
	
	awk -v prefix="${sample_name}#1#" '/^>/{print ">" prefix substr($1,2); next} {print}' "$fa" > "$pansn_fa"
	PANSN_FASTAS+=("$pansn_fa")
done

COMBINED_FA="${PANGENOME_OUT}/all_assemblies.pansn.fa"
log "Concatenating all PanSN sequences into ${COMBINED_FA}..."
cat "${PANSN_FASTAS[@]}" > "$COMBINED_FA"

if ! grep -q ">${REF_GENOME}#1#" "$COMBINED_FA"; then
	log "Error: Reference tag '${REF_GENOME}' was not found in formatted PanSN sequences."
	log "Available sample tags:"
	grep -oP '^>[^#]+' "$COMBINED_FA" | sort -u | tr -d '>'
	exit 1
fi

# ----------------------------------------------------------------------------------------------- #
# Step 2: Minigraph-Cactus Pangenome Pipeline (Singularity Container)
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
	log "Writing Minigraph-Cactus SLURM script to ${CACTUS_SB}..."
	
	cat <<EOT > "$CACTUS_SB"
#!/bin/bash --login
#SBATCH --job-name=cactus-pangenome
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=${MEM}
#SBATCH --time=${WALLTIME}
#SBATCH --output=${CACTUS_DIR}/cactus-%j.out

set -e
set -x

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Starting Minigraph-Cactus run on \$(hostname)..."
cd ${CACTUS_DIR}

if [[ -f "${ENV_BASHRC}" ]]; then
	source "${ENV_BASHRC}"
fi

SCRATCH_DIR="/mnt/gs21/scratch/\${USER}/tmp_cactus_\${SLURM_JOB_ID}"
JOBSTORE_PATH="\${SCRATCH_DIR}/jobstore"
mkdir -p "\$SCRATCH_DIR" "\$JOBSTORE_PATH"

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Executing Cactus-Pangenome Singularity Container..."
singularity exec --cleanenv -B /mnt/research,/mnt/gs21,"\${SCRATCH_DIR}" "${CACTUS_SIF}" \\
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

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Cleaning scratch jobstore space..."
rm -rf "\$SCRATCH_DIR"

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Minigraph-Cactus execution completed successfully."
EOT

	log "Submitting Minigraph-Cactus SLURM job..."
	sbatch "$CACTUS_SB"
fi

# ----------------------------------------------------------------------------------------------- #
# Step 3: PGGB Pangenome Pipeline (Micromamba Environment)
# ----------------------------------------------------------------------------------------------- #
if is_true "$RUN_PGGB"; then
	PGGB_DIR="${PANGENOME_OUT}/pggb"
	mkdir -p "${PGGB_DIR}"

	PGGB_SB="${PGGB_DIR}/run_pggb.sb"
	log "Writing PGGB SLURM script to ${PGGB_SB}..."
	
	cat <<EOT > "$PGGB_SB"
#!/bin/bash --login
#SBATCH --job-name=pggb-pangenome
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=${MEM}
#SBATCH --time=${WALLTIME}
#SBATCH --output=${PGGB_DIR}/pggb-%j.out

set -e
set -x

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Starting PGGB run on \$(hostname)..."
cd ${PGGB_DIR}

if [[ -f "${ENV_BASHRC}" ]]; then
	source "${ENV_BASHRC}"
fi

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Activating Micromamba environment: ${MICROMAMBA_ENV}..."
eval "\$(micromamba shell hook --shell bash)"
micromamba activate ${MICROMAMBA_ENV}

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Indexing combined PanSN FASTA..."
samtools faidx ${COMBINED_FA}

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Executing PGGB graph builder..."
pggb -i ${COMBINED_FA} \\
	-s ${SEGMENT_LEN} \\
	-p ${MAP_PCT} \\
	-n ${NUM_ASMS} \\
	-t ${CPUS} \\
	-V '${REF_GENOME}:0' \\
	-o ${PGGB_DIR}/output

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] PGGB execution completed successfully."
EOT

	log "Submitting PGGB SLURM job..."
	sbatch "$PGGB_SB"
fi

# ----------------------------------------------------------------------------------------------- #
# Step 4: ODGI Visualizations (Micromamba Environment)
# ----------------------------------------------------------------------------------------------- #
if is_true "$RUN_ODGI"; then
	VIZ_DIR="${PANGENOME_OUT}/odgi_visualizations"
	mkdir -p "${VIZ_DIR}"

	ODGI_SB="${VIZ_DIR}/run_odgi_viz.sb"
	log "Writing ODGI visualization SLURM script to ${ODGI_SB}..."
	
	cat <<EOT > "$ODGI_SB"
#!/bin/bash --login
#SBATCH --job-name=odgi-viz
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=${CPUS}
#SBATCH --mem=250G
#SBATCH --time=24:00:00
#SBATCH --output=${VIZ_DIR}/odgi-viz-%j.out

set -e
set -x

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Starting ODGI Visualizations on \$(hostname)..."
cd ${VIZ_DIR}

if [[ -f "${ENV_BASHRC}" ]]; then
	source "${ENV_BASHRC}"
fi

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Activating Micromamba environment: ${MICROMAMBA_ENV}..."
eval "\$(micromamba shell hook --shell bash)"
micromamba activate ${MICROMAMBA_ENV}

CHROM_DIR="${PANGENOME_OUT}/minigraph_cactus/output/pig_pangenome.chroms"

if [[ -d "\$CHROM_DIR" ]]; then
	for og in \${CHROM_DIR}/*.og; do
		base=\$(basename "\$og" .og)
		
		echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Rendering 1D Scan for \${base}..."
		odgi viz -i "\$og" -o "\${base}_1D_scan.png" -z -P -x 5000 -y 1000

		echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Sorting graph \${base}..."
		odgi sort -i "\$og" -o "\${base}_sorted.og" -O -p b

		echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Calculating 2D Layout for \${base}..."
		odgi layout -i "\${base}_sorted.og" -o "\${base}.lay" -t ${CPUS}

		echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Drawing 2D Layout PNG for \${base}..."
		odgi draw -i "\${base}_sorted.og" -c "\${base}.lay" -p "\${base}_2D_layout.png" -C -b 1000 -w 30 -S 1
	done
else
	echo "[\$(date '+%Y-%m-%d %H:%M:%S')] Warning: Cactus chromosome directory \${CHROM_DIR} not found yet."
fi

echo "[\$(date '+%Y-%m-%d %H:%M:%S')] ODGI Visualizations completed successfully."
EOT

	log "Submitting ODGI visualization SLURM job..."
	sbatch "$ODGI_SB"
fi

log "========================================================================"
log "All pangenome construction jobs successfully dispatched."
log "========================================================================"