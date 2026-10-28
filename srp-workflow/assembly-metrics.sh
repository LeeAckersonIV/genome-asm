#!/bin/bash -l

# =============================================================================================== #
# Script to perform assembly quality control evaluation on output hifiasm and verkko assemblies.
#	QC includes N50, BUSCO, QV, as well as running FCS-GX/Adapt and Flagger.
# Author: Lee Ackerson {ackers24@msu.edu}
# ----------------------------------------------------------------------------------------------- #
# assembly-metrics.sh \
#	--load.project.params \		# can re-use input parameter config from initialize.sh; default NO
#	--projectROOT \ 			# where initialize.sh built the project directory at
#	--ref.rdna \ 				# reference rDNA morph for species to use for filtering/assembly.
#	--ref.mtdna \ 				# reference mtDNA morph for species to use for filtering/assembly.
#	--meryl.hapmers.mat \ 		# path to meryl maternal hapmers database
#	--meryl.hapmers.pat \ 		# path to meryl paternal hapmers database
#	--meryl.hapmers.MGD \ 		# path to meryl maternal grand dam hapmers database
#	--meryl.hapmers.MGS \ 		# path to meryl maternal grand sire hapmers database
#	--yak.hapmers.mat \ 		# path to yak maternal hapmers database
#	--yak.hapmers.pat \ 		# path to yak paternal hapmers database
#	--yak.hapmers.MGD \ 		# path to yak maternal grand dam hapmers database
#	--yak.hapmers.MGS \ 		# path to yak maternal grand sire hapmers database
#	--verkko.outdir \ 			# name of output directory for Verkko run
#	--hifiasm.outdir \ 			# name of output directory for HiFiasm run
#	--illumina.terminal.lib \ 	# library IDs for terminal animal illumina data
#	--illumina.maternal.lib \ 	# library IDs for maternal animal [F1] illumina data
#	--illumina.paternal.lib \ 	# library IDs for paternal animal illumina data
# 	--illumina.MGS.lib \ 		# library IDs for maternal grand sire [MGS] animal illumina data
#	--illumina.MGD.lib \ 		# library IDs for maternal grand dam [MGD] animal illumina data
#	--hifi.terminal.lib \ 		# library IDs for terminal animal hifi data
#	--hifi.maternal.lib \ 		# library IDs for maternal animal [F1] hifi data
#	--ont.terminal.lib \ 		# library IDs for terminal animal ONT data
#	--ont.maternal.lib \ 		# library IDs for maternal animal [F1] ONT data
# 	--illuminaDir \ 			# parent directory containing all the illumina data
#	--hifiDir \ 				# parent directory containing all the hifi data
#	--ontDir \ 					# parent directory containing all the ONT data
# 	--snpDir \					# parent directory containing all the SNP data
#	--ThreeGenMode \			# indicate NO if only maternal, paternal, & F1 given; default YES
#	--help						# print all options and point to github documentation
# =============================================================================================== #
# Example Command Execution
# ----------------------------------------------------------------------------------------------- #
# ./assembly-metrics.sh --projectROOT SRP_1 --illumina.terminal.lib LIB212039 --illumina.maternal.lib LIB212038 --illumina.paternal.lib LIB212041 --illumina.MGS.lib LIB212046 --illumina.MGD.lib LIB212044 --hifi.terminal.lib LIB212031 --hifi.maternal.lib LIB212951

# OR, IF initialize.sh was RUN FIRST:

# ./assembly-metrics.sh --projectROOT SRP_1 --load.project.params YES
# =============================================================================================== #


# Function to display help menu
# ----------------------------------------------------------------------------------------------- #
usage() {
	echo ""
	echo "This pipeline is intended to run on a 3-generation pedigree (illustrated below), if you do not"
	echo "have grandparental data for the terminal animal - only use the terminal, maternal, and 		"
	echo "paternal related flags for execution. The pipeline will interpret terminal as F1 in such case,"
	echo "just indicate that the expected pedigree structure was not used by setting --ThreeGenMode to NO."
	echo ""
	echo "# ------------------------------ Expected Pedigree Structure ------------------------------- #"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "                Maternal Grand Sire [MGS]        Maternal Grand Dam [MGD]"
	echo "                            │                               │"
	echo "                            └────────────────┬──────────────┘"
	echo "                                             │"
	echo "                    Paternal           Maternal [F1]"
	echo "                        │                    │"
	echo "                        └─────────┬──────────┘"
	echo "                                  │"
	echo "                           Terminal Animal"
	echo ""
	echo "# --------------------------------- Configuration Options ---------------------------------- #"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "Usage: $0 [OPTIONS]"
	echo ""
	echo "assembly-metrics.sh \ "
	echo "	--load.project.params \		# can re-use input parameter config from initialize.sh; default NO"
	echo "	--projectROOT \ 			# where directory structure will be built, default is working dir"
	echo "	--ref.rdna \ 				# reference rDNA morph for species to use for filtering/assembly."
	echo "	--ref.mtdna \ 				# reference mtDNA morph for species to use for filtering/assembly."
	echo "	--meryl.hapmers.mat \ 		# name of meryl maternal hapmers database"
	echo "	--meryl.hapmers.pat \ 		# name of meryl paternal hapmers database"
	echo "	--meryl.hapmers.MGD \ 		# name of meryl maternal grand dam hapmers database"
	echo "	--meryl.hapmers.MGS \ 		# name of meryl maternal grand sire hapmers database"
	echo "	--yak.hapmers.mat \ 		# name of yak maternal hapmers database"
	echo "	--yak.hapmers.pat \ 		# name of yak paternal hapmers database"
	echo "	--yak.hapmers.MGD \ 		# name of yak maternal grand dam hapmers database"
	echo "	--yak.hapmers.MGS \ 		# name of yak maternal grand sire hapmers database"
	echo "	--verkko.outdir.name \ 		# name of output directory for Verkko run (terminal and maternal)"
	echo "	--hifiasm.outdir.name \ 	# name of output directory for HiFiasm run (terminal and maternal)"
	echo "	--illumina.terminal.lib \ 	# REQUIRED; library IDs for terminal animal illumina data"
	echo "	--illumina.maternal.lib \ 	# REQUIRED; library IDs for maternal animal [F1] illumina data"
	echo "	--illumina.paternal.lib \ 	# REQUIRED; library IDs for paternal animal illumina data"
	echo "	--illumina.MGS.lib \ 		# library IDs for maternal grand sire [MGS] animal illumina data"
	echo "	--illumina.MGD.lib \ 		# library IDs for maternal grand dam [MGD] animal illumina data"
	echo "	--hifi.terminal.lib \ 		# REQUIRED; library IDs for terminal animal hifi data"
	echo "	--hifi.maternal.lib \ 		# library IDs for maternal animal [F1] hifi data"
	echo "	--ont.terminal.lib \ 		# library IDs for terminal animal ONT data"
	echo "	--ont.maternal.lib \ 		# library IDs for maternal animal [F1] ONT data"
	echo "	--illuminaDir \ 			# parent directory containing all the illumina data"
	echo "	--hifiDir \ 				# parent directory containing all the hifi data"
	echo "	--ontDir \ 					# parent directory containing all the ONT data"
	echo "	--snpDir 					# parent directory containing all the SNP data"
	echo "	--ThreeGenMode \			# indicate NO if only maternal, paternal, and F1 given; default is YES"
	echo "	--help						# print all options and point to github documentation"
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	echo "If initialize.sh has already been run for this project, and no parameters need changed, "
	echo " then simply run this script as follows:"
	echo "assembly-metrics.sh \ "
	echo "	--load.project.params YES \		# can re-use input parameter config from initialize.sh; default NO"
	echo "	--projectROOT path/to/project \	# where directory structure will be built, default is working dir"
	echo ""
	echo "# ------------------------------------------------------------------------------------------ #"
	echo ""
	exit 1
}
# ----------------------------------------------------------------------------------------------- #


# Take in, parse, and set input parameters
# ----------------------------------------------------------------------------------------------- #

# initialize non-global variables
ILLUM_MGS="NA"
ILLUM_MGD="NA"
ONT_TERM="NA"
ONT_MAT="NA"

# defaults if using outputs from earlier scripts in workflow
PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")
VERKKO_OUTDIR="verkko2.3.2_trio"
HIFIASM_OUTDIR="hifiasm_trio"

# load env.bashrc, inputs are overwritten first by config.params; and then by command line
PIPELINE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$PWD"

if [[ -f "${PIPELINE_DIR}/env.bashrc" ]]; then
    echo "Sourcing configuration from ${PIPELINE_DIR}/env.bashrc"
    source "${PIPELINE_DIR}/env.bashrc"
else
    echo "Warning: env.bashrc not found. Using internal script defaults."
	ILLUM_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_Illumina"
	HIFI_DIR="/mnt/gs21/scratch/huangw53/upload/USMARC_HiFi"
	ONT_DIR="NA"
	SNP_DIR="NA"
	ThreeGenMode="YES"
	FASTQC_SOFTWARE="/mnt/research/qgg/software/fastqc_v0.11.5"
	MULTIQC_SOFTWARE="/mnt/research/qgg/software/multiqc_v1.33/bin"
	SEQKIT_SOFTWARE="/mnt/research/qgg/software/seqkit-2.13.0"
fi

# Load existing project parameters if supplied: i.e. --load.project.params YES
for ((i=1; i<=$#; i++)); do
    case "${!i}" in
        --projectROOT) 
            j=$((i+1)); PROJECT_ROOT="${!j}" ;;
        --load.project.params) 
            j=$((i+1)); LOAD_CONFIG_PARAMS="${!j}" ;;
    esac
done

PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")

if [[ "$LOAD_CONFIG_PARAMS" == "YES" ]]; then
    if [[ -f "${PROJECT_ROOT}/params.config" ]]; then
        source "${PROJECT_ROOT}/params.config"
        echo "Successfully loaded parameters from ${PROJECT_ROOT}/params.config"
    else
        echo "Error: --load.project.params YES was set, but ${PROJECT_ROOT}/params.config not found."
        exit 1
    fi
fi

# Parse and load any input parameters; even if they override some in the existing config
while [[ $# -gt 0 ]]; do
    case "$1" in
		--load.project.params) 	LOAD_CONFIG_PARAMS="$2"; shift 2 ;;
        --projectROOT) 		 	PROJECT_ROOT="$2"; shift 2 ;;
		--ref.rdna)				RDNA_REF="$2"; shift 2 ;;
		--ref.mtdna)			MTDNA_REF="$2"; shift 2 ;;
		--meryl.hapmers.mat)	MERYL_HAP_MAT="$2"; shift 2 ;;
		--meryl.hapmers.pat)	MERYL_HAP_PAT="$2"; shift 2 ;;
		--meryl.hapmers.MGS)	MERYL_HAP_MGS="$2"; shift 2 ;;
		--meryl.hapmers.MGD)	MERYL_HAP_MGD="$2"; shift 2 ;;
		--yak.hapmers.mat)		YAK_HAP_MAT="$2"; shift 2 ;;
		--yak.hapmers.pat)		YAK_HAP_PAT="$2"; shift 2 ;;
		--yak.hapmers.MGS)		YAK_HAP_MGS="$2"; shift 2 ;;
		--yak.hapmers.MGD)		YAK_HAP_MGD="$2"; shift 2 ;;
		--verkko.outdir.name)	VERKKO_OUTDIR="$2"; shift 2 ;;
		--hifiasm.outdir.name)	HIFIASM_OUTDIR="$2"; shift 2 ;;
		--illumina.terminal.lib) ILLUM_TERM="$2"; shift 2 ;;
		--illumina.maternal.lib) ILLUM_MAT="$2"; shift 2 ;;
		--illumina.paternal.lib) ILLUM_PAT="$2"; shift 2 ;;
		--illumina.MGS.lib) 	ILLUM_MGS="$2"; shift 2 ;;
		--illumina.MGD.lib) 	ILLUM_MGD="$2"; shift 2 ;;
		--hifi.terminal.lib)	HIFI_TERM="$2"; shift 2 ;;
		--hifi.maternal.lib) 	HIFI_MAT="$2"; shift 2 ;;
		--ont.terminal.lib) 	ONT_TERM="$2"; shift 2 ;;
		--ont.maternal.lib) 	ONT_MAT="$2"; shift 2 ;;
        --illuminaDir) 			ILLUM_DIR="$2"; shift 2 ;;
        --hifiDir) 	 			HIFI_DIR="$2"; shift 2 ;;
        --ontDir) 	 			ONT_DIR="$2"; shift 2 ;;
		--snpDir) 	 			SNP_DIR="$2"; shift 2 ;;
		--ThreeGenMode)			ThreeGenMode="$2"; shift 2 ;;
        --help) 	 			usage ;;
        *) 	 	 			echo "Error: Unknown option $1"; usage ;;
    esac
done


# Validate that all required inputs are supplied
# ----------------------------------------------------------------------------------------------- #
if [[ "$ThreeGenMode" == "YES" ]]; then
	REQUIRED_VARS=("ILLUM_TERM" "ILLUM_MAT" "ILLUM_PAT" "HIFI_TERM" "ILLUM_MGS" "ILLUM_MGD" "HIFI_MAT")
else
	REQUIRED_VARS=("ILLUM_TERM" "ILLUM_MAT" "ILLUM_PAT" "HIFI_TERM")
fi
	
MISSING=0
for var in "${REQUIRED_VARS[@]}"; do
    if [[ -z "${!var}" ]]; then
        echo "Error: The required argument for $var is missing."
        MISSING=1
    fi
done

if [[ $MISSING -eq 1 ]]; then
    usage
fi
# ----------------------------------------------------------------------------------------------- #


# Compute sanitized tags (fallback if running assembly-metrics.sh standalone without params.config)
# ----------------------------------------------------------------------------------------------- #
ILLUM_TERM_TAG="${ILLUM_TERM_TAG:-${ILLUM_TERM//,/_}}"
ILLUM_MAT_TAG="${ILLUM_MAT_TAG:-${ILLUM_MAT//,/_}}"
ILLUM_PAT_TAG="${ILLUM_PAT_TAG:-${ILLUM_PAT//,/_}}"
ILLUM_MGS_TAG="${ILLUM_MGS_TAG:-${ILLUM_MGS//,/_}}"
ILLUM_MGD_TAG="${ILLUM_MGD_TAG:-${ILLUM_MGD//,/_}}"

HIFI_TERM_TAG="${HIFI_TERM_TAG:-${HIFI_TERM//,/_}}"
HIFI_MAT_TAG="${HIFI_MAT_TAG:-${HIFI_MAT//,/_}}"
ONT_TERM_TAG="${ONT_TERM_TAG:-${ONT_TERM//,/_}}"
ONT_MAT_TAG="${ONT_MAT_TAG:-${ONT_MAT//,/_}}"
# ----------------------------------------------------------------------------------------------- #


# 0. Initialize variables & directory paths 
# ----------------------------------------------------------------------------------------------- #
PROJECT_ROOT=$(readlink -f "$PROJECT_ROOT")
MERQURY_TERM_DIR="${PROJECT_ROOT}/dataQC/merqury_trio_terminal.compressed" 
MERQURY_MAT_DIR="${PROJECT_ROOT}/dataQC/merqury_trio_maternal.compressed" 

YAK_DIR="${PROJECT_ROOT}/dataQC/yak"
VERKKO_TERM_DIR="${PROJECT_ROOT}/verkko.terminal"
VERKKO_MAT_DIR="${PROJECT_ROOT}/verkko.maternal"
HIFIASM_TERM_DIR="${PROJECT_ROOT}/hifiasm.terminal"
HIFIASM_MAT_DIR="${PROJECT_ROOT}/hifiasm.maternal"
CLEAN_DATA="${PROJECT_ROOT}/data-cleaned"

YAK_HAP_MAT="${YAK_HAP_MAT:-${YAK_DIR}/${ILLUM_MAT_TAG}.yak}"
YAK_HAP_PAT="${YAK_HAP_PAT:-${YAK_DIR}/${ILLUM_PAT_TAG}.yak}"
YAK_HAP_MGS="${YAK_HAP_MGS:-${YAK_DIR}/${ILLUM_MGS_TAG}.yak}"
YAK_HAP_MGD="${YAK_HAP_MGD:-${YAK_DIR}/${ILLUM_MGD_TAG}.yak}"

MERYL_HAP_MAT="${MERYL_HAP_MAT:-${MERQURY_TERM_DIR}/${ILLUM_MAT_TAG}.hapmer.meryl}"
MERYL_HAP_PAT="${MERYL_HAP_PAT:-${MERQURY_TERM_DIR}/${ILLUM_PAT_TAG}.hapmer.meryl}"
MERYL_HAP_MGS="${MERYL_HAP_MGS:-${MERQURY_MAT_DIR}/${ILLUM_MGS_TAG}.hapmer.meryl}"
MERYL_HAP_MGD="${MERYL_HAP_MGD:-${MERQURY_MAT_DIR}/${ILLUM_MGD_TAG}.hapmer.meryl}"

# Assembly QC Output Subdirectories
ASMQC_DIR="${PROJECT_ROOT}/assemblyQC" 
N50_DIR="${ASMQC_DIR}/N50"
BUSCO_DIR="${ASMQC_DIR}/BUSCO"
QV_DIR="${ASMQC_DIR}/QV"
FCS_DIR="${ASMQC_DIR}/FCS"
FLAGGER_DIR="${ASMQC_DIR}/FLAGGER"

mkdir -p "${ASMQC_DIR}" "${N50_DIR}" "${BUSCO_DIR}" "${QV_DIR}" "${FCS_DIR}" "${FLAGGER_DIR}"

# Download reference genomes
mkdir -p "${PIPELINE_DIR}/references"

REF_SS11="${PIPELINE_DIR}/references/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz"
REF_HXYL="${PIPELINE_DIR}/references/GCA_054392235.2_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0_genomic.fna.gz"

if [[ ! -f "$REF_SS11" ]]; then
    echo "+ wget -O ${REF_SS11} ftp://ftp.ensembl.org/pub/release-110/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz"
    wget -O "$REF_SS11" ftp://ftp.ensembl.org/pub/release-110/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
fi

if [[ ! -f "$REF_HXYL" ]]; then
    echo "+ wget -O ${REF_HXYL} https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/054/392/235/GCA_054392235.2_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0/GCA_054392235.2_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0_genomic.fna.gz"
    wget -O "$REF_HXYL" https://ftp.ncbi.nlm.nih.gov/genomes/all/GCA/054/392/235/GCA_054392235.2_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0/GCA_054392235.2_Sscrofa_HxYL_maternal_Yorkshire_Landrace_v2.0_genomic.fna.gz
fi
# ----------------------------------------------------------------------------------------------- #


# 1. Contiguity: N50 (QUAST)
# ----------------------------------------------------------------------------------------------- #
echo "Initiating Contiguity & N50 (QUAST) Evaluation..."

# Hifiasm GFA to FASTA conversion
if [[ -f "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.gfa" ]]; then
    echo "+ awk '/^S/{print \">\"\$2\"\n\"\$3}' ${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.gfa > ${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta"
    awk '/^S/{print ">"$2"\n"$3}' "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.gfa" > "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta"
fi

if [[ -f "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.gfa" ]]; then
    echo "+ awk '/^S/{print \">\"\$2\"\n\"\$3}' ${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.gfa > ${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
    awk '/^S/{print ">"$2"\n"$3}' "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.gfa" > "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
fi

if [[ "$ThreeGenMode" == "YES" ]]; then
    if [[ -f "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.gfa" ]]; then
        echo "+ awk '/^S/{print \">\"\$2\"\n\"\$3}' ${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.gfa > ${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta"
        awk '/^S/{print ">"$2"\n"$3}' "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.gfa" > "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta"
    fi

    if [[ -f "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.gfa" ]]; then
        echo "+ awk '/^S/{print \">\"\$2\"\n\"\$3}' ${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.gfa > ${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
        awk '/^S/{print ">"$2"\n"$3}' "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.gfa" > "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
    fi
fi

# Launch QUAST for Hifiasm
echo "+ sbatch --job-name=term-hifiasm-quast --cpus-per-task=8 --mem=250G --time=2:00:00 --output=\"${N50_DIR}/terminal.hifiasm.quast.log\" \"${PIPELINE_DIR}/N50.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${N50_DIR}/terminal.hifiasm.quast\" --assembly1 \"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta\" --assembly2 \"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta\" --reference \"${REF_HXYL}\""
sbatch --job-name=term-hifiasm-quast --cpus-per-task=8 --mem=250G --time=2:00:00 \
	--output="${N50_DIR}/terminal.hifiasm.quast.log" "${PIPELINE_DIR}/N50.sh" \
	--pipelineDir "${PIPELINE_DIR}" \
	--outdir "${N50_DIR}/terminal.hifiasm.quast" \
	--assembly1 "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta" \
	--assembly2 "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta" \
	--reference "${REF_HXYL}"

if [[ "$ThreeGenMode" == "YES" ]]; then
    echo "+ sbatch --job-name=mat-hifiasm-quast --cpus-per-task=8 --mem=250G --time=2:00:00 --output=\"${N50_DIR}/maternal.hifiasm.quast.log\" \"${PIPELINE_DIR}/N50.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${N50_DIR}/maternal.hifiasm.quast\" --assembly1 \"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta\" --assembly2 \"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta\" --reference \"${REF_HXYL}\""
    sbatch --job-name=mat-hifiasm-quast --cpus-per-task=8 --mem=250G --time=2:00:00 \
    	--output="${N50_DIR}/maternal.hifiasm.quast.log" "${PIPELINE_DIR}/N50.sh" \
    	--pipelineDir "${PIPELINE_DIR}" \
    	--outdir "${N50_DIR}/maternal.hifiasm.quast" \
    	--assembly1 "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta" \
    	--assembly2 "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta" \
    	--reference "${REF_HXYL}"
fi
			
# Launch QUAST for Verkko
echo "+ sbatch --job-name=term-verkko-quast --cpus-per-task=8 --mem=250G --time=2:00:00 --output=\"${N50_DIR}/terminal.verkko.quast.log\" \"${PIPELINE_DIR}/N50.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${N50_DIR}/terminal.verkko.quast\" --assembly1 \"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta\" --assembly2 \"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta\" --reference \"${REF_HXYL}\""
sbatch --job-name=term-verkko-quast --cpus-per-task=8 --mem=250G --time=2:00:00 \
	--output="${N50_DIR}/terminal.verkko.quast.log" "${PIPELINE_DIR}/N50.sh" \
	--pipelineDir "${PIPELINE_DIR}" \
	--outdir "${N50_DIR}/terminal.verkko.quast" \
	--assembly1 "${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta" \
	--assembly2 "${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta" \
	--reference "${REF_HXYL}"

if [[ "$ThreeGenMode" == "YES" ]]; then
    echo "+ sbatch --job-name=mat-verkko-quast --cpus-per-task=8 --mem=250G --time=2:00:00 --output=\"${N50_DIR}/maternal.verkko.quast.log\" \"${PIPELINE_DIR}/N50.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${N50_DIR}/maternal.verkko.quast\" --assembly1 \"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta\" --assembly2 \"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta\" --reference \"${REF_HXYL}\""
    sbatch --job-name=mat-verkko-quast --cpus-per-task=8 --mem=250G --time=2:00:00 \
    	--output="${N50_DIR}/maternal.verkko.quast.log" "${PIPELINE_DIR}/N50.sh" \
    	--pipelineDir "${PIPELINE_DIR}" \
    	--outdir "${N50_DIR}/maternal.verkko.quast" \
    	--assembly1 "${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta" \
    	--assembly2 "${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta" \
    	--reference "${REF_HXYL}"
fi
# ----------------------------------------------------------------------------------------------- #


# 2. Completeness: BUSCO
# ----------------------------------------------------------------------------------------------- #
echo "Initiating Gene Completeness (BUSCO) Evaluation..."

# Hifiasm BUSCO
echo "+ sbatch --job-name=term-hifiasm-busco --cpus-per-task=16 --mem=350G --time=8:00:00 --output=\"${BUSCO_DIR}/terminal.hifiasm.busco.log\" \"${PIPELINE_DIR}/BUSCO.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${BUSCO_DIR}/terminal.hifiasm.busco\" --assembly1 \"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta\" --assembly2 \"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta\""
sbatch --job-name=term-hifiasm-busco --cpus-per-task=16 --mem=350G --time=8:00:00 \
	--output="${BUSCO_DIR}/terminal.hifiasm.busco.log" "${PIPELINE_DIR}/BUSCO.sh" \
	--pipelineDir "${PIPELINE_DIR}" \
	--outdir "${BUSCO_DIR}/terminal.hifiasm.busco" \
	--assembly1 "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta" \
	--assembly2 "${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"

if [[ "$ThreeGenMode" == "YES" ]]; then
    echo "+ sbatch --job-name=mat-hifiasm-busco --cpus-per-task=16 --mem=350G --time=8:00:00 --output=\"${BUSCO_DIR}/maternal.hifiasm.busco.log\" \"${PIPELINE_DIR}/BUSCO.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${BUSCO_DIR}/maternal.hifiasm.busco\" --assembly1 \"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta\" --assembly2 \"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta\""
    sbatch --job-name=mat-hifiasm-busco --cpus-per-task=16 --mem=350G --time=8:00:00 \
    	--output="${BUSCO_DIR}/maternal.hifiasm.busco.log" "${PIPELINE_DIR}/BUSCO.sh" \
    	--pipelineDir "${PIPELINE_DIR}" \
    	--outdir "${BUSCO_DIR}/maternal.hifiasm.busco" \
    	--assembly1 "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta" \
    	--assembly2 "${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
fi

# Verkko BUSCO
echo "+ sbatch --job-name=term-verkko-busco --cpus-per-task=16 --mem=350G --time=8:00:00 --output=\"${BUSCO_DIR}/terminal.verkko.busco.log\" \"${PIPELINE_DIR}/BUSCO.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${BUSCO_DIR}/terminal.verkko.busco\" --assembly1 \"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta\" --assembly2 \"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta\""
sbatch --job-name=term-verkko-busco --cpus-per-task=16 --mem=350G --time=8:00:00 \
	--output="${BUSCO_DIR}/terminal.verkko.busco.log" "${PIPELINE_DIR}/BUSCO.sh" \
	--pipelineDir "${PIPELINE_DIR}" \
	--outdir "${BUSCO_DIR}/terminal.verkko.busco" \
	--assembly1 "${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta" \
	--assembly2 "${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta"

if [[ "$ThreeGenMode" == "YES" ]]; then
    echo "+ sbatch --job-name=mat-verkko-busco --cpus-per-task=16 --mem=350G --time=8:00:00 --output=\"${BUSCO_DIR}/maternal.verkko.busco.log\" \"${PIPELINE_DIR}/BUSCO.sh\" --pipelineDir \"${PIPELINE_DIR}\" --outdir \"${BUSCO_DIR}/maternal.verkko.busco\" --assembly1 \"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta\" --assembly2 \"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta\""
    sbatch --job-name=mat-verkko-busco --cpus-per-task=16 --mem=350G --time=8:00:00 \
    	--output="${BUSCO_DIR}/maternal.verkko.busco.log" "${PIPELINE_DIR}/BUSCO.sh" \
    	--pipelineDir "${PIPELINE_DIR}" \
    	--outdir "${BUSCO_DIR}/maternal.verkko.busco" \
    	--assembly1 "${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta" \
    	--assembly2 "${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta"
fi
# ----------------------------------------------------------------------------------------------- #


# 3. Correctness: QV (Meryl/Merqury)
# ----------------------------------------------------------------------------------------------- #
echo "Initiating Merqury QV Analysis..."
export PATH="$MERYL_SOFTWARE:$MERQURY_SOFTWARE:$MERQURY_SOFTWARE/build:$PATH"

run_merqury_qv() {
	local meryl_read="$1"
	local meryl_mat="$2"
	local meryl_pat="$3"
	local hap1_fasta="$4"
	local hap2_fasta="$5"
	local out_prefix="$6"
	local out_dir="${QV_DIR}/${out_prefix}"

	mkdir -p "$out_dir"

	echo "+ sbatch --job-name=qv-${out_prefix} --chdir=${out_dir} --cpus-per-task=16 --mem=64G --time=6:00:00 --output=${out_dir}/merqury.log"
	sbatch --job-name="qv-${out_prefix}" \
		--chdir="$out_dir" \
		--cpus-per-task=16 \
		--mem=64G \
		--time=6:00:00 \
		--output="${out_dir}/merqury.log" \
		--wrap="
			unset SLURM_SUBMIT_DIR
			cd ${out_dir}
			ln -sf ${meryl_read} illumina.meryl
			ln -sf ${meryl_mat} mat.meryl
			ln -sf ${meryl_pat} pat.meryl
			ln -sf ${hap1_fasta} hap1.fasta
			ln -sf ${hap2_fasta} hap2.fasta
			${MERQURY_SOFTWARE}/merqury.sh illumina.meryl mat.meryl pat.meryl hap1.fasta hap2.fasta ${out_prefix}
		"
}

# Terminal Assemblies
run_merqury_qv \
	"${MERQURY_TERM_DIR}/${ILLUM_TERM_TAG}.meryl" \
	"${MERYL_HAP_MAT}" \
	"${MERYL_HAP_PAT}" \
	"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta" \
	"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta" \
	"hifiasm.terminal"

run_merqury_qv \
	"${MERQURY_TERM_DIR}/${ILLUM_TERM_TAG}.meryl" \
	"${MERYL_HAP_MAT}" \
	"${MERYL_HAP_PAT}" \
	"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta" \
	"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta" \
	"verkko.terminal"

# Maternal Assemblies (If 3-Generation Mode)
if [[ "$ThreeGenMode" == "YES" ]]; then
	run_merqury_qv \
		"${MERQURY_MAT_DIR}/${ILLUM_MAT_TAG}.meryl" \
		"${MERYL_HAP_MGD}" \
		"${MERYL_HAP_MGS}" \
		"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta" \
		"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta" \
		"hifiasm.maternal"

	run_merqury_qv \
		"${MERQURY_MAT_DIR}/${ILLUM_MAT_TAG}.meryl" \
		"${MERYL_HAP_MGD}" \
		"${MERYL_HAP_MGS}" \
		"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta" \
		"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta" \
		"verkko.maternal"
fi
echo "Finishing Merqury QV Submissions..."
# ----------------------------------------------------------------------------------------------- #


# 4. T2T Stats
# ----------------------------------------------------------------------------------------------- #
echo "Calculating T2T Metrics & Summarizing Assemblies..."
T2T_DIR="${ASMQC_DIR}/T2T"
mkdir -p "$T2T_DIR"

# Identify & collate assemblies
TARGET_FASTAS=(
	"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta"
	"${HIFIASM_TERM_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
	"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta"
	"${VERKKO_TERM_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta"
)

if [[ "$ThreeGenMode" == "YES" ]]; then
	TARGET_FASTAS+=(
		"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap1.p_ctg.fasta"
		"${HIFIASM_MAT_DIR}/${HIFIASM_OUTDIR}.dip.hap2.p_ctg.fasta"
		"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype1.fasta"
		"${VERKKO_MAT_DIR}/${VERKKO_OUTDIR}/assembly.haplotype2.fasta"
	)
fi

# Verify assemblies exist
VALID_FASTAS=()
for fasta in "${TARGET_FASTAS[@]}"; do
	if [[ -f "$fasta" ]]; then
		VALID_FASTAS+=("$fasta")
	fi
done

if [[ ${#VALID_FASTAS[@]} -eq 0 ]]; then
	echo "Error: No valid assembly FASTA files found for T2T analysis."
	exit 1
fi

# Launch T2T evaluation job
echo "+ sbatch --job-name=t2t-stats --cpus-per-task=8 --mem=50G --time=4:00:00 --output=${T2T_DIR}/t2t_stats.log"
sbatch --job-name="t2t-stats" --cpus-per-task=8 --mem=50G --time=4:00:00 \
	--output="${T2T_DIR}/t2t_stats.log" \
	--wrap="
		module load SAMtools
		# General seqkit summary stats
		${SEQKIT_SOFTWARE}/seqkit stats -j 8 -a ${VALID_FASTAS[*]} > ${T2T_DIR}/summary_assembly_stats.tsv

		# Header for final summary table
		echo -e 'Assembly\tTotal_Contigs\tT2T_Contigs' > ${T2T_DIR}/t2t_summary.tsv

		# Threshold distance from contig ends (50 kb)
		THRESHOLD=50000

		for fasta in ${VALID_FASTAS[*]}; do
			asm_name=\$(basename \"\$fasta\")
			fai_file=\"\${fasta}.fai\"
			loc_file=\"${T2T_DIR}/\${asm_name}.telomeres.bed\"

			# A. Generate .fai index if missing
			if [[ ! -f \"\$fai_file\" ]]; then
				samtools faidx \"\$fasta\"
			fi

			# B. Search both forward and reverse telomeres in one pass (-b outputs BED format)
			${SEQKIT_SOFTWARE}/seqkit locate -j 8 -i -b -p 'TTAGGG' -p 'CCCTAA' \"\$fasta\" > \"\$loc_file\"

			# C. AWK script: cross-reference BED matches with .fai sequence lengths
			read tot_cnt t2t_cnt <<< \$(awk -v thresh=\"\$THRESHOLD\" '
				# Pass 1: Read .fai file to store contig lengths
				NR==FNR {
					len[\$1] = \$2;
					next;
				}
				# Pass 2: Process telomere BED file matches
				\$1 !~ /^#/ && \$1 !~ /^seqid/ {
					seqid = \$1; start = \$2; end = \$3;
					if (seqid in len) {
						if (start <= thresh)                 has_5p[seqid] = 1;
						if (end >= (len[seqid] - thresh))     has_3p[seqid] = 1;
					}
				}
				# End: Count true T2T contigs (having both 5p and 3p telomeres)
				END {
					tot = 0; t2t = 0;
					for (s in len) {
						tot++;
						if (has_5p[s] && has_3p[s]) t2t++;
					}
					print tot, t2t;
				}
			' \"\$fai_file\" \"\$loc_file\")

			echo -e \"\${asm_name}\t\${tot_cnt}\t\${t2t_cnt}\" >> ${T2T_DIR}/t2t_summary.tsv
		done
	"
# ----------------------------------------------------------------------------------------------- #

echo "assembly-metrics.sh submission complete!"