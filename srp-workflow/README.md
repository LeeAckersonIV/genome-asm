# Bioinformatic pipeline for the SRP workflow

## 🔄 Data Flow & Pipeline Architecture

```mermaid
flowchart TD
    %% Define Styles
    classDef script fill:#d4edda,stroke:#28a745,stroke-width:2px,color:#155724;
    classDef slurm fill:#c3e6cb,stroke:#1e7e34,stroke-width:2px,stroke-dasharray: 5 5,color:#155724;
    classDef data fill:#d1ecf1,stroke:#17a2b8,stroke-width:2px,color:#0c5460;
    classDef config fill:#fff3cd,stroke:#ffc107,stroke-width:2px,color:#856404;
    classDef output fill:#e2e3e5,stroke:#6c757d,stroke-width:2px,color:#383d41;

    %% Stage 1: Initialization
    subgraph STAGE1 ["1. Project Initialization & Workspace Setup"]
        INPUT_RAW[("Raw Sequence Data\n• Illumina (5 Animals)\n• PacBio HiFi (Terminal & Mat)")]:::data
        INPUT_CFG["CLI Args & env.bashrc\n• Library IDs\n• Software Paths"]:::config
        INIT["initialize.sh"]:::script
        PARAMS["params.config &\nDirectory Structure"]:::config

        INPUT_RAW --> INIT
        INPUT_CFG --> INIT
        INIT --> PARAMS
    end

    %% Stage 2: Parallel Preprocessing & Profiling
    subgraph STAGE2 ["2. Data Preprocessing & K-mer Phasing (Parallel Execution)"]
        READ_QC["readQC.sh\n(FastQC & density_plot.py)"]:::script
        FILTER["filter.sh (SLURM)\n(chopper read filtering)"]:::slurm
        KMERS["kmers.sh\n(Meryl, Yak, GenomeScope2, Merqury)"]:::script

        REPORT_QC[("dataQC/fastqc_outputs &\nJoint Density Plots")]:::output
        CLEAN_HIFI[("Clean HiFi Long Reads\n(data-cleaned/hifi.*/)")]:::data
        PHASE_DBS[("Phased K-mer Databases\n• .yak DBs (4 files)\n• .hapmer.meryl DBs (4 files)")]:::data

        PARAMS --> READ_QC
        PARAMS --> FILTER
        PARAMS --> KMERS

        INPUT_RAW --> READ_QC --> REPORT_QC
        INPUT_RAW --> FILTER --> CLEAN_HIFI
        INPUT_RAW --> KMERS --> PHASE_DBS
    end

    %% Stage 3: Trio Assembly Orchestration
    subgraph STAGE3 ["3. Parallel Trio Genome Assembly (assembly.sh)"]
        ASM_MAIN["assembly.sh\n(Orchestrator)"]:::script
        
        LAUNCH_HIFIASM["launch_hifiasm_trio.sh"]:::script
        LAUNCH_VERKKO["launch_verkko_trio.sh"]:::script

        JOB_HIFIASM_TERM["hifiasm_term (SLURM)\n• Terminal HiFi\n• Mat/Pat .yak DBs"]:::slurm
        JOB_HIFIASM_MAT["hifiasm_mat (SLURM)\n• Maternal HiFi\n• MGD/MGS .yak DBs"]:::slurm
        JOB_VERKKO_TERM["verkko_term (SLURM)\n• Terminal HiFi\n• Mat/Pat .hapmer.meryl"]:::slurm
        JOB_VERKKO_MAT["verkko_mat (SLURM)\n• Maternal HiFi\n• MGD/MGS .hapmer.meryl"]:::slurm

        ASM_GFA[("HiFiasm Contig Graphs\n(.hap1.p_ctg.gfa / .hap2)")]:::data
        ASM_FASTA[("Verkko Haplotype FASTAs\n(assembly.haplotype1/2.fasta)")]:::data

        CLEAN_HIFI --> ASM_MAIN
        PHASE_DBS --> ASM_MAIN

        ASM_MAIN --> LAUNCH_HIFIASM
        ASM_MAIN --> LAUNCH_VERKKO

        LAUNCH_HIFIASM --> JOB_HIFIASM_TERM --> ASM_GFA
        LAUNCH_HIFIASM --> JOB_HIFIASM_MAT --> ASM_GFA
        LAUNCH_VERKKO --> JOB_VERKKO_TERM --> ASM_FASTA
        LAUNCH_VERKKO --> JOB_VERKKO_MAT --> ASM_FASTA
    end

    %% Stage 4: Assembly QC Evaluation
    subgraph STAGE4 ["4. Downstream Quality Evaluation (assembly-metrics.sh)"]
        METRICS_MAIN["assembly-metrics.sh\n(Orchestrator)"]:::script
        REF_GENOMES[("Ref Genomes\n• Sscrofa11.1\n• HxYL v2.0")]:::data

        GFA_CONV["GFA to FASTA Conversion\n(awk extraction)"]:::script

        JOB_QUAST["N50.sh (QUAST SLURM)\n• Contiguity, N50/L50"]:::slurm
        JOB_BUSCO["BUSCO.sh (SLURM)\n• Lineage Gene Completeness"]:::slurm
        JOB_MERQURY["run_merqury_qv (SLURM)\n• Consensus QV & Phasing"]:::slurm
        JOB_T2T["t2t-stats (SLURM)\n• Telomere Repeat Identification"]:::slurm

        QC_FINAL[("assemblyQC/ Final Reports\n• N50 & BUSCO Summaries\n• Merqury QV Plots\n• t2t_summary.tsv")]:::output

        ASM_GFA --> METRICS_MAIN
        ASM_FASTA --> METRICS_MAIN
        REF_GENOMES --> METRICS_MAIN

        METRICS_MAIN --> GFA_CONV
        GFA_CONV --> JOB_QUAST
        GFA_CONV --> JOB_BUSCO
        GFA_CONV --> JOB_MERQURY
        GFA_CONV --> JOB_T2T

        ASM_FASTA --> JOB_QUAST
        ASM_FASTA --> JOB_BUSCO
        ASM_FASTA --> JOB_MERQURY
        ASM_FASTA --> JOB_T2T

        JOB_QUAST --> QC_FINAL
        JOB_BUSCO --> QC_FINAL
        JOB_MERQURY --> QC_FINAL
        JOB_T2T --> QC_FINAL
    end


### 1. initialize.sh
### 2. readQC.sh
### 3. kmers.sh
### 4. filter.sh
### 5. assembly.sh
### 6. assembly-metrics.sh

---

## 📁 Repository Structure

```text
srp-workflow/
├── env.bashrc                 # Global environment configurations & tool paths
├── initialize.sh              # Project workspace initializer & params.config builder
├── readQC.sh                  # Raw/cleaned data FastQC, SeqKit stats, and MultiQC
├── density_plot.py            # Python script for read length/quality joint density plots
├── filter.sh                  # Trimming & quality filtering (Chopper) for HiFi reads
├── kmers.sh                   # K-mer counting (Meryl & Yak), GenomeScope2, & Merqury hapmers
├── assembly.sh                # Trio assembly orchestrator (HiFiasm & Verkko)
├── launch_hifiasm_trio.sh     # SLURM launcher wrapper for HiFiasm Trio
├── launch_verkko_trio.sh      # SLURM launcher wrapper for Verkko Trio
├── assembly-metrics.sh        # Post-assembly evaluation orchestrator
├── N50.sh                     # QUAST contiguity & N50 analysis wrapper
└── BUSCO.sh                   # Lineage gene completeness wrapper
```
---

# Software Installation

```bash
# Download the repository archive
wget https://github.com/LeeAckersonIV/genome-asm/archive/refs/heads/main.zip

# Unzip only the specific workflow folder
unzip main.zip 'genome-asm-main/srp-workflow/*'
mv ./genome-asm-main/srp-workflow .
rm -rf main.zip genome-asm-main
cd srp-workflow/
export SRP_WORKFLOW="$PWD"

# Build dependency environment
pip install pandas matplotlib seaborn
```
---


# Workflow Execution


**Note:** Adjust the `env.bashrc` to work on your system before running workflow

```bash

# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP_1 \
    --illumina.terminal.lib LIB212039 \
    --illumina.maternal.lib LIB212038 \
    --illumina.paternal.lib LIB212041 \
    --illumina.MGS.lib LIB212046 \
    --illumina.MGD.lib LIB212044 \
    --hifi.terminal.lib "LIB212031,LIB215030" \
    --hifi.maternal.lib "LIB212951,LIB215570"

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP_1 --load.project.params YES"
tail -f readQC.log

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP_1 --load.project.params YES"
tail -f kmers.log

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP_1 --load.project.params YES"
tail -f filter.log

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP_1 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> assembly.log

# Run assemblyQC.sh
${SRP_WORKFLOW}/assemblyQC.sh --projectROOT SRP_1 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> assemblyQC.log

```
---

