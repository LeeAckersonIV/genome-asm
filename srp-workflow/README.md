# Bioinformatic pipeline for the SRP workflow

## 🔄 Data Flow & Pipeline Architecture

![SRP Workflow Architecture](./dataFlowDiagram.jpg)
---

## 📁 Repository & Procedure Structure

```text
srp-workflow/
├── env.bashrc                             # Global environment configurations & executable software paths (adjust to your user & system)
├── references/                            # Reference genomes & sequence sets (larger files fetched dynamically downstream)
│   ├── pig_MT.fasta                       # Porcine mitochondrial genome reference for filtering
│   └── pig_rDNA.fasta                     # Porcine ribosomal DNA unit reference for repeat masking
├── initialize.sh                          # Step 1:	Project workspace initializer & params.config builder
├── readQC.sh                              # Step 2a:	Raw/cleaned data FastQC, SeqKit stats, and MultiQC
│   └── density_plot.py                    # Python script for read length/quality joint density plots
├── filter.sh                              # Step 2b:	Trimming & quality filtering (Chopper) for HiFi & ONT reads
├── kmers.sh                               # Step 2c:	K-mer counting (Meryl & Yak), GenomeScope2, & Merqury hapmers
├── assembly.sh                            # Step 3:	Trio assembly orchestrator (HiFiasm & Verkko)
│   ├── launch_hifiasm_trio.sh             # SLURM launcher wrapper for HiFiasm Trio
│   └── launch_verkko_trio.sh              # SLURM launcher wrapper for Verkko Trio
├── assembly-metrics.sh                    # Step 4:	Post-assembly evaluation orchestrator (QV, BUSCO, N50, T2T stats)
│   ├── N50.sh                             # QUAST contiguity & N50 analysis wrapper
│   └── BUSCO.sh                           # Lineage gene completeness wrapper
├── prepangenome.sh                        # Step 5:	Haplotype FASTA formatting, header renaming, & prepangenome environment configuration
├── pangenome.sh                           # Step 6:	Pangenome graph construction (Minigraph-Cactus / PGGB), fetch pig public T2T genomes
└── tool-scripts/                          # Directory housing tool scripts & post-pangenome analysis examples
    ├── plot_variant_histo.py              # Python script for plotting SV length/size frequency distributions
    ├── post_cactus_analysis.sh            # Pipeline for VCF decomposition, SV annotation, and graph queries
    ├── run_MSTN_pipeline.sb               # SLURM batch job script for ODGI subgraph extraction & 1D visual rendering
    ├── sv_coding_analysis.sh              # Intersects structural variants against exon/CDS coordinate features
    └── sv_gene_impact.sh                  # Evaluates gene disruption categories and functional impact scores
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
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP1 \
    --illumina.terminal.lib LIB212039 \
    --illumina.maternal.lib LIB212038 \
    --illumina.paternal.lib LIB212041 \
    --illumina.MGS.lib LIB212046 \
    --illumina.MGD.lib LIB212044 \
    --hifi.terminal.lib "LIB212031,LIB215030" \
    --hifi.maternal.lib "LIB212951,LIB215570" &> ${PWD}/SRP1-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP1/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP1 --load.project.params YES"
tail -f readQC.log

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP1/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP1 --load.project.params YES"
tail -f kmers.log

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP1/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP1 --load.project.params YES"
tail -f filter.log

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP1 --load.project.params YES \
    --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP1/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP1 --load.project.params YES \
    --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP1/assembly-metrics.log

# Run prepangenome.sh
${SRP_WORKFLOW}/prepangenome.sh --srpDirs "SRP1" --outdir ${PWD}/SRP.v1-pangenome

# Run pangenome.sh
${SRP_WORKFLOW}/pangenome.sh --pangenomeDir ${PWD}/SRP.v1-pangenome --run.cactus TRUE \
    --run.pggb FALSE --run.odgi FALSE &> ${PWD}/pangenome.log



```
---

