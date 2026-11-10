#!/bin/bash
#SBATCH --job-name=sv_gene_impact
#SBATCH --output=v_gene-%j.out
#SBATCH --error=v_gene-%j.err
#SBATCH --time=4:00:00
#SBATCH --cpus-per-task=16
#SBATCH --mem=50G


WORKDIR="/mnt/gs21/scratch/ackers24/srp-sandbox/SRP.v1/SRP.v1-pangenome/pangenome_build/minigraph_cactus"
CACTUS_SIF="/mnt/research/qgg/software/cactus/cactus_v3.1.4.sif"

cd "${WORKDIR}"

sing_exec() {
    singularity exec --cleanenv \
        -B /mnt/research,/mnt/gs21,"${WORKDIR}":"${WORKDIR}" \
        "${CACTUS_SIF}" "$@"
}

sing_exec bedtools intersect \
    -a output/pangenome_svs_ge50bp.bed \
    -b output/cds_features.bed \
    -wa -wb > output/svs_cds_intersect_detailed.bed