# Bioinformatic pipeline for the SRP workflow

### 1. initialize.sh
### 2. readQC.sh
### 3. kmers.sh
### 4. filter.sh

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
    --hifi.terminal.lib LIB212031 \
    --hifi.maternal.lib LIB212951

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP_1 --load.project.params YES"
tail -f readQC.log

# Run kmers.sh
sbatch --time=10:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP_1 --load.project.params YES"
tail -f kmers.log

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP_1 --load.project.params YES"
tail -f filter.log

```
