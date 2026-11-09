#!/bin/bash
#SBATCH --job-name=sv_coding_analysis
#SBATCH --output=sv_coding-%j.out
#SBATCH --error=sv_coding-%j.err
#SBATCH --time=100:00:00
#SBATCH --cpus-per-task=32
#SBATCH --mem=350G

set -euo pipefail

# ------------------------------------------------------------------------------
# PATHS & CONFIGURATION
# ------------------------------------------------------------------------------
WORKDIR="/mnt/gs21/scratch/ackers24/srp-sandbox/SRP.v1/SRP.v1-pangenome/pangenome_build/minigraph_cactus"
GFA_FILE="${WORKDIR}/output/pig_pangenome.gfa"

CACTUS_SIF="/mnt/research/qgg/software/cactus/cactus_v3.1.4.sif"
REF_PATH="REF_HxYL_ncbi_hap2#0" 

# Persistent annotation location shared across pangenome iterations
ANNOTATION_DIR="/mnt/gs21/scratch/ackers24/srp-sandbox/SRP.v1/SRP.v1-pangenome/pangenome_build/minigraph_cactus/annotation"
GFF_FILE="${ANNOTATION_DIR}/GCA_054392235.2_geneset.gff3"
GFF_URL="https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/054/392/235/GCF_054392235.1_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0/GCF_054392235.1_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0_genomic.gff.gz"

cd "${WORKDIR}"
mkdir -p output "${ANNOTATION_DIR}"

sing_exec() {
    singularity exec --cleanenv \
        -B /mnt/research,/mnt/gs21,"${WORKDIR}":"${WORKDIR}" \
        "${CACTUS_SIF}" "$@"
}

echo "=========================================================="
echo "Starting Structural Variant & Coding Overlap Analysis"
echo "Working Directory: ${WORKDIR}"
echo "Input Graph:       ${GFA_FILE}"
echo "=========================================================="

# ------------------------------------------------------------------------------
# STEP 0: Check or download NCBI RefSeq GFF3 annotation
# ------------------------------------------------------------------------------
GFF_GZ="${ANNOTATION_DIR}/GCA_054392235.2_geneset.gff3.gz"

if [[ ! -f "${GFF_FILE}" ]]; then
    echo "[$(date)] STEP 0: Annotation missing. Downloading from NCBI RefSeq..."
    curl -sSL -f "${GFF_URL}" -o "${GFF_GZ}"
    
    if [[ -s "${GFF_GZ}" ]]; then
        echo "[$(date)] Download successful. Decompressing..."
        gunzip -f "${GFF_GZ}"
        echo "[$(date)] Annotation ready at: ${GFF_FILE}"
    else
        echo "ERROR: Downloaded GFF3 file is empty. Verify URL." >&2
        exit 1
    fi
else
    echo "[$(date)] STEP 0: Annotation verified at: ${GFF_FILE}"
fi

# ------------------------------------------------------------------------------
# STEP 1: Deconstruct GFA graph using -P (path prefix) for REF_HxYL_ncbi_hap2#0
# ------------------------------------------------------------------------------
echo "[$(date)] STEP 1: Deconstructing GFA graph to VCF..."

# Decompress if only the .gz file exists
if [[ -f "${GFA_FILE}.gz" && ! -f "${GFA_FILE}" ]]; then
    echo "[$(date)] Decompressing ${GFA_FILE}.gz..."
    gunzip "${GFA_FILE}.gz"
fi

sing_exec vg deconstruct -P "${REF_PATH}" -t "${SLURM_CPUS_PER_TASK}" "${GFA_FILE}" | \
    sing_exec bgzip -c > output/pangenome_raw.vcf.gz

sing_exec tabix -p vcf output/pangenome_raw.vcf.gz

# ------------------------------------------------------------------------------
# STEP 2: Filter SVs (>= 50 bp), generate 0-indexed BED & size stats
# ------------------------------------------------------------------------------
echo "[$(date)] STEP 2: Filtering structural variants (>= 50bp)..."
python3 -c '
import gzip

vcf_in = "output/pangenome_raw.vcf.gz"
bed_out = "output/pangenome_svs_ge50bp.bed"
stats_out = "output/sv_size_distribution.tsv"

sv_counts = {"DEL": 0, "INS": 0, "COMPLEX": 0}
lengths = []

with gzip.open(vcf_in, "rt") as infile, open(bed_out, "w") as bed, open(stats_out, "w") as stats:
    stats.write("CHROM\tPOS\tSV_TYPE\tSV_LEN\n")
    for line in infile:
        if line.startswith("#"):
            continue
        fields = line.strip().split("\t")
        chrom_raw, pos, ref, alt = fields[0], int(fields[1]), fields[3], fields[4]
        
        chrom = chrom_raw.split("#")[-1].replace("chr", "")
        
        alt_first = alt.split(",")[0]
        len_ref, len_alt = len(ref), len(alt_first)
        sv_len = abs(len_alt - len_ref)
        
        if sv_len >= 50:
            if len_ref > len_alt:
                sv_type = "DEL"
            elif len_alt > len_ref:
                sv_type = "INS"
            else:
                sv_type = "COMPLEX"
                
            sv_counts[sv_type] += 1
            lengths.append(sv_len)
            
            start_pos = pos - 1
            end_pos = start_pos + max(1, len_ref)
            
            bed.write(f"{chrom}\t{start_pos}\t{end_pos}\t{sv_type}\t{sv_len}\n")
            stats.write(f"{chrom}\t{pos}\t{sv_type}\t{sv_len}\n")

print("\n--- SV Class Counts (>= 50bp) ---")
for k, v in sv_counts.items():
    print(f"{k}: {v}")

if lengths:
    lengths.sort()
    n = len(lengths)
    median_len = lengths[n // 2]
    min_len, max_len = lengths[0], lengths[-1]
    
    b_50_500 = sum(1 for x in lengths if 50 <= x < 500)
    b_500_1k = sum(1 for x in lengths if 500 <= x < 1000)
    b_1k_10k = sum(1 for x in lengths if 1000 <= x < 10000)
    b_10k_plus = sum(1 for x in lengths if x >= 10000)
    
    print("\n--- SV Size Distribution Summary ---")
    print(f"Min Size: {min_len} bp | Median Size: {median_len} bp | Max Size: {max_len} bp")
    print(f"50 bp - 500 bp : {b_50_500}")
    print(f"500 bp - 1 kb  : {b_500_1k}")
    print(f"1 kb - 10 kb   : {b_1k_10k}")
    print(f">= 10 kb       : {b_10k_plus}\n")
'

# ------------------------------------------------------------------------------
# STEP 3: Map RefSeq accessions to chromosome IDs & run bedtools overlap
# ------------------------------------------------------------------------------
echo "[$(date)] STEP 3: Extracting CDS features and overlapping SVs..."

python3 -c "
gff_in = \"${GFF_FILE}\"
bed_out = \"output/cds_features.bed\"

acc_to_chrom = {}

with open(gff_in, 'r') as f:
    for line in f:
        if line.startswith('#'):
            continue
        parts = line.strip().split('\t')
        if len(parts) > 8 and parts[2] == 'region':
            acc = parts[0]
            for attr in parts[8].split(';'):
                if attr.startswith('chromosome='):
                    acc_to_chrom[acc] = attr.split('=')[1]

with open(gff_in, 'r') as f, open(bed_out, 'w') as out:
    for line in f:
        if line.startswith('#'):
            continue
        parts = line.strip().split('\t')
        if len(parts) > 8 and parts[2] == 'CDS':
            acc = parts[0]
            chrom = acc_to_chrom.get(acc, acc)
            start = int(parts[3]) - 1
            end = parts[4]
            info = parts[8]
            out.write(f'{chrom}\t{start}\t{end}\t{info}\n')
"

sing_exec bedtools intersect -a output/pangenome_svs_ge50bp.bed -b output/cds_features.bed -u > output/svs_overlapping_cds.bed

TOTAL_SVS=$(wc -l < output/pangenome_svs_ge50bp.bed)
CODING_SVS=$(wc -l < output/svs_overlapping_cds.bed)

echo "=========================================================="
echo "ANALYSIS SUMMARY:"
echo "Total Structural Variants (>=50bp): ${TOTAL_SVS}"
echo "SVs Overlapping Coding Regions (CDS): ${CODING_SVS}"
if [ "${TOTAL_SVS}" -gt 0 ]; then
    PCT=$(python3 -c "print(round((${CODING_SVS}/${TOTAL_SVS})*100, 2))")
    echo "Percentage of SVs in Coding Regions: ${PCT}%"
fi
echo "=========================================================="