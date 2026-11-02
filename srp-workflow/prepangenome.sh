#!/bin/bash -l

# =============================================================================================== #
# Script: prepangenome.sh
# Purpose: Consolidate genome assemblies from multiple SRP project directories into a single 
#          pangenome preparation folder with PanSN-compatible syntax, and compile a master QC TSV.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# Usage Example:
#   ./prepangenome.sh --srpDirs "SRP1,SRP2" --outdir pangenome_prep
# =============================================================================================== #

usage() {
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "Options:"
	echo "  --srpDirs      Comma-separated list of SRP project directory paths (e.g. SRP1,SRP2)"
	echo "  --outdir       Output directory for consolidated pangenome prep (default: pangenome_prep)"
	echo "  --help         Display this help message"
	echo ""
	exit 1
}

# Parse options
SRP_DIRS_RAW=""
OUTDIR="pangenome_prep"

while [[ $# -gt 0 ]]; do
	case "$1" in
		--srpDirs)  SRP_DIRS_RAW="$2"; shift 2 ;;
		--outdir)   OUTDIR="$2"; shift 2 ;;
		--help)     usage ;;
		*)          echo "Error: Unknown option $1"; usage ;;
	esac
done

if [[ -z "$SRP_DIRS_RAW" ]]; then
	echo "Error: --srpDirs is required."
	usage
fi

PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTDIR=$(readlink -f "$OUTDIR")
ASSEMBLY_DIR="${OUTDIR}/assemblies"
mkdir -p "${ASSEMBLY_DIR}"

IFS=',' read -ra SRP_ARRAY <<< "$SRP_DIRS_RAW"

echo "========================================================================"
echo "Initiating Pangenome Assembly Preparation..."
echo "Output Directory: ${OUTDIR}"
echo "========================================================================"

# Prepare Master Summary TSV
SUMMARY_TSV="${OUTDIR}/pangenome_assembly_qc_summary.tsv"
echo -e "Project\tSample\tAssembler\tHaplotype\tAssembly_File\tTotal_Length_bp\tContig_N50_bp\tBUSCO_Complete_pct\tBUSCO_Single_pct\tBUSCO_Dup_pct\tMerqury_QV\tT2T_Contigs" > "${SUMMARY_TSV}"

# Map directory lookups
declare -A ASM_MAP=(
	["terminal.hifiasm.hap1"]="hifiasm.terminal/hifiasm_trio.dip.hap1.p_ctg.fasta"
	["terminal.hifiasm.hap2"]="hifiasm.terminal/hifiasm_trio.dip.hap2.p_ctg.fasta"
	["maternal.hifiasm.hap1"]="hifiasm.maternal/hifiasm_trio.dip.hap1.p_ctg.fasta"
	["maternal.hifiasm.hap2"]="hifiasm.maternal/hifiasm_trio.dip.hap2.p_ctg.fasta"
	["terminal.verkko.hap1"]="verkko.terminal/verkko2.3.2_trio/assembly.haplotype1.fasta"
	["terminal.verkko.hap2"]="verkko.terminal/verkko2.3.2_trio/assembly.haplotype2.fasta"
	["maternal.verkko.hap1"]="verkko.maternal/verkko2.3.2_trio/assembly.haplotype1.fasta"
	["maternal.verkko.hap2"]="verkko.maternal/verkko2.3.2_trio/assembly.haplotype2.fasta"
)

for srp_path in "${SRP_ARRAY[@]}"; do
	srp_abs=$(readlink -f "$srp_path")
	srp_id=$(basename "$srp_abs")

	echo -e "\nProcessing project directory: ${srp_id} (${srp_abs})"

	for key in "${!ASM_MAP[@]}"; do
		IFS='.' read -r sample tool hap <<< "$key"
		rel_path="${ASM_MAP[$key]}"
		src_fasta="${srp_abs}/${rel_path}"

		# Fallback: Convert GFA to FASTA if FASTA is missing
		if [[ ! -f "$src_fasta" ]]; then
			gfa_src="${src_fasta%.fasta}.gfa"
			if [[ -f "$gfa_src" ]]; then
				echo "  [CONVERTING] ${gfa_src} -> ${src_fasta}"
				awk '/^S/{print ">"$2"\n"$3}' "$gfa_src" > "$src_fasta"
			fi
		fi

		target_name="${srp_id}.${sample}.${tool}.${hap}.fasta"
		dest_fasta="${ASSEMBLY_DIR}/${target_name}"

		if [[ -f "$src_fasta" ]]; then
			echo "  [FOUND] ${key} -> Copying to ${target_name}"
			cp -f "$src_fasta" "$dest_fasta"

			# ------------------------------------------------------------------ #
			# Gather Metrics
			# ------------------------------------------------------------------ #
			
			# 1. N50 & Total Length (Dynamic QUAST Header Parsing)
			total_len="NA"
			n50_val="NA"
			quast_report="${srp_abs}/assemblyQC/N50/${sample}.${tool}.quast/transposed_report.tsv"
			if [[ -f "$quast_report" ]]; then
				read total_len n50_val <<< $(awk -F'\t' -v hap="$hap" '
					NR==1 {
						for (i=1; i<=NF; i++) {
							if ($i == "Total length") total_col = i;
							if ($i == "N50") n50_col = i;
						}
					}
					NR>1 {
						hap_num = substr(hap, 4);
						if (($1 ~ hap) || ($1 ~ ("haplotype" hap_num)) || ($1 ~ ("hap" hap_num))) {
							if (total_col) t_val = $total_col;
							if (n50_col) n_val = $n50_col;
						}
					}
					END {
						print (t_val ? t_val : "NA"), (n_val ? n_val : "NA");
					}
				' "$quast_report")
			fi

			# 2. BUSCO Metrics (Recursive File Search)
			busco_comp="NA"; busco_single="NA"; busco_dup="NA"
			busco_dir="${srp_abs}/assemblyQC/BUSCO/${sample}.${tool}.busco"
			if [[ -d "$busco_dir" ]]; then
				busco_summary=$(find "$busco_dir" -type f -name "short_summary*.txt" | grep -i "$hap" | head -n 1)
				if [[ -z "$busco_summary" ]]; then
					busco_summary=$(find "$busco_dir" -type f -name "short_summary*.txt" | head -n 1)
				fi

				if [[ -f "$busco_summary" ]]; then
					busco_comp=$(grep -oP 'C:\K[0-9.]+' "$busco_summary" || grep -m1 "Complete BUSCOs" "$busco_summary" | awk '{print $1}' | tr -d '%')
					busco_single=$(grep -oP 'S:\K[0-9.]+' "$busco_summary" || grep -m1 "Complete and single-copy" "$busco_summary" | awk '{print $1}' | tr -d '%')
					busco_dup=$(grep -oP 'D:\K[0-9.]+' "$busco_summary" || grep -m1 "Complete and duplicated" "$busco_summary" | awk '{print $1}' | tr -d '%')
					
					[[ -z "$busco_comp" ]] && busco_comp="NA"
					[[ -z "$busco_single" ]] && busco_single="NA"
					[[ -z "$busco_dup" ]] && busco_dup="NA"
				fi
			fi

			# 3. Merqury QV
			qv_val="NA"
			qv_file="${srp_abs}/assemblyQC/QV/${tool}.${sample}/${tool}.${sample}.qv"
			if [[ -f "$qv_file" ]]; then
				qv_val=$(awk -v h="$hap" '$1==h || $1~("^"h) {print $4}' "$qv_file" | head -n 1)
				if [[ -z "$qv_val" || "$qv_val" == "NA" ]]; then
					qv_val=$(awk '$1=="Both" {print $4}' "$qv_file")
				fi
				[[ -z "$qv_val" ]] && qv_val="NA"
			fi

			# 4. T2T Contigs (Matches explicit sample.tool.hap tag)
			t2t_cnt="NA"
			t2t_file="${srp_abs}/assemblyQC/T2T/t2t_summary.tsv"
			if [[ -f "$t2t_file" ]]; then
				tag="${sample}.${tool}.${hap}"
				src_base=$(basename "$src_fasta")
				t2t_cnt=$(awk -v tag="$tag" -v f="$src_base" -v target="$target_name" '
					($1 == tag) || ($1 == f) || ($1 == target) || ($1 ~ tag) { print $3 }
				' "$t2t_file" | head -n 1)
				[[ -z "$t2t_cnt" ]] && t2t_cnt="NA"
			fi

			echo -e "${srp_id}\t${sample}\t${tool}\t${hap}\t${target_name}\t${total_len}\t${n50_val}\t${busco_comp}\t${busco_single}\t${busco_dup}\t${qv_val}\t${t2t_cnt}" >> "${SUMMARY_TSV}"
		else
			echo "  [MISSING] ${src_fasta} (Skipping)"
		fi
	done
done

echo -e "\n========================================================================"
echo "Preparation complete."
echo "Harvested assemblies stored in: ${ASSEMBLY_DIR}"
echo "Master QC summary written to:   ${SUMMARY_TSV}"
echo "========================================================================"