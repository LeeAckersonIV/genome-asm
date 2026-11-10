#!/bin/bash
#SBATCH --job-name=post_cactus_analysis
#SBATCH --output=post_cactus-%j.out
#SBATCH --error=post_cactus-%j.err
#SBATCH --time=08:00:00
#SBATCH --cpus-per-task=64
#SBATCH --mem=128G

set -euo pipefail

WORKDIR="/mnt/gs21/scratch/ackers24/srp-sandbox/SRP.v1/SRP.v1-pangenome/pangenome_build/minigraph_cactus"
CACTUS_SIF="/mnt/research/qgg/software/cactus/cactus_v3.1.4.sif"

cd "${WORKDIR}"

# Helper function for container execution
sing_exec() {
    singularity exec --cleanenv \
        -B /mnt/research,/mnt/gs21,"${WORKDIR}":"${WORKDIR}" \
        "${CACTUS_SIF}" "$@"
}

echo "=========================================================="
echo "Starting Post-Minigraph-Cactus Graph Analysis Pipeline"
echo "Job ID: ${SLURM_JOB_ID:-Manual}"
echo "Start Time: $(date)"
echo "=========================================================="

# ------------------------------------------------------------------------------
# STAGE 1: Convert GFA 1.1 W-lines to GFA 1.0 P-lines using vg convert
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 1: Streaming decompressed GFA into vg convert (W -> P lines)..."
pigz -dc -p "${SLURM_CPUS_PER_TASK}" output/pig_pangenome.gfa.gz | \
    sing_exec vg convert -g - -f -W > output/pig_pangenome.plines.gfa

# ------------------------------------------------------------------------------
# STAGE 2: Build initial ODGI binary graph
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 2: Building ODGI graph representation (.og)..."
sing_exec odgi build -g output/pig_pangenome.plines.gfa -o output/pig_pangenome.og -t "${SLURM_CPUS_PER_TASK}"

# ------------------------------------------------------------------------------
# STAGE 3: Compact and sort node IDs contiguously
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 3: Compact-sorting graph node IDs (-O)..."
sing_exec odgi sort -i output/pig_pangenome.og -o output/pig_pangenome.sorted.og -O -t "${SLURM_CPUS_PER_TASK}"

# ------------------------------------------------------------------------------
# STAGE 4: Extract graph topological summary statistics
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 4: Calculating whole-graph statistics..."
sing_exec odgi stats -i output/pig_pangenome.sorted.og -S -s -t "${SLURM_CPUS_PER_TASK}" > output/graph_stats.txt

# ------------------------------------------------------------------------------
# STAGE 5: Option A — Per-Path / Per-Sample Coverage Depth
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 5: Running Option A (Per-path coverage depth)..."
sing_exec odgi depth -i output/pig_pangenome.sorted.og -t "${SLURM_CPUS_PER_TASK}" > output/path_depth.tsv

# ------------------------------------------------------------------------------
# STAGE 6: Option B — Node-Level Depth Table (Core / Accessory / Private)
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 6: Running Option B (Node-level depth table)..."
sing_exec odgi depth -i output/pig_pangenome.sorted.og -d -t "${SLURM_CPUS_PER_TASK}" > output/node_depth_table.tsv

# ------------------------------------------------------------------------------
# STAGE 7: Reclaim scratch space by removing intermediate uncompressed files
# ------------------------------------------------------------------------------
echo "[$(date)] STAGE 7: Cleaning up intermediate uncompressed/unsorted files..."
rm -f output/pig_pangenome.plines.gfa output/pig_pangenome.og

echo "=========================================================="
echo "Post-Cactus Graph Analysis Pipeline Completed Successfully"
echo "End Time: $(date)"
echo "=========================================================="