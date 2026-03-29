# Bioinformatic pipeline for the SRP workflow

### 1. initialize.sh
### 2. readQC.sh

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

# Build dependency environment
pip install pandas matplotlib seaborn
```

# Workflow Execution

```bash
# Run initialize.sh
./initialize.sh --projectROOT ../SRP_1 --illumina.terminal.lib LIB212039 --illumina.maternal.lib LIB212038 --illumina.paternal.lib LIB212041 --illumina.MGS.lib LIB212046 --illumina.MGD.lib LIB212044 --hifi.terminal.lib LIB212031 --hifi.maternal.lib LIB212951

# Run readQC.sh
salloc --time=24:00:00 --cpus-per-task=16 --mem=250G
nohup ./readQC.sh --projectROOT ../SRP_1 --load.project.params YES > readQC.log 2>&1 &
tail -f readQC.log


```
**Note:** Adjust the `env.bashrc` to work on your system before running workflow
