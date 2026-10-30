Test-Case Workflow Runs

# ==================================================== SRP 1 ==================================================== #
# This example has several LibraryIDs for individuals, as well as several files within a single LibraryID.

# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh {paternal has seveal illumina runs within one library ID; terminal HiFi has several LIBIDs }
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP1 \
    --illumina.terminal.lib LIB212039 \
    --illumina.maternal.lib LIB212038 \
    --illumina.paternal.lib LIB212041 \
    --illumina.MGS.lib LIB212046 \
    --illumina.MGD.lib LIB212044 \
    --hifi.terminal.lib "LIB212031,LIB215030" \
    --hifi.maternal.lib "LIB212951,LIB215570" &> SRP1-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP1/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP1 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP1/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP1 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP1/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP1 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP1 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP1/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP1 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP1/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP 2 ==================================================== #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP2 \
    --illumina.terminal.lib LIB212040 \
    --illumina.maternal.lib LIB212037 \
    --illumina.paternal.lib LIB212042 \
    --illumina.MGS.lib LIB212045 \
    --illumina.MGD.lib LIB212043 \
    --hifi.terminal.lib "LIB212032,LIB215031" \
    --hifi.maternal.lib "LIB212950,LIB215002" &> SRP2-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP2/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP2 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP2/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP2 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP2/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP2 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP2 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP2/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP2 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP2/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP 3 ==================================================== #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP3 \
    --illumina.terminal.lib LIB219050 \
    --illumina.maternal.lib LIB219054 \
    --illumina.paternal.lib LIB216357 \
    --illumina.MGS.lib LIB216351 \
    --illumina.MGD.lib LIB216347 \
    --hifi.terminal.lib LIB218782 \
    --hifi.maternal.lib LIB219057 &> SRP3-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP3/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP3 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP3/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP3 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP3/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP3 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP3 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP3/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP3 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP3/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP 4 ==================================================== #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP4 \
    --illumina.terminal.lib LIB219049 \
    --illumina.maternal.lib LIB219053 \
    --illumina.paternal.lib LIB216358 \
    --illumina.MGS.lib LIB216352 \
    --illumina.MGD.lib LIB216346 \
    --hifi.terminal.lib LIB218781 \
    --hifi.maternal.lib LIB219056 &> SRP4-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP4/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP4 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP4/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP4 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP4/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP4 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP4 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP4/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP4 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP4/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP 5 ==================================================== #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP5 \
    --illumina.terminal.lib LIB219052 \
    --illumina.maternal.lib LIB216350 \
    --illumina.paternal.lib LIB216355 \
    --illumina.MGS.lib LIB216353 \
    --illumina.MGD.lib LIB216349 \
    --hifi.terminal.lib LIB218784 \
    --hifi.maternal.lib LIB216388 &> SRP5-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP5/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP5 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP5/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP5 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP5/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP5 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP5 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP5/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP5 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP5/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP 6 ==================================================== #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP6 \
    --illumina.terminal.lib LIB219051 \
    --illumina.maternal.lib LIB219055 \
    --illumina.paternal.lib LIB216356 \
    --illumina.MGS.lib LIB216354 \
    --illumina.MGD.lib LIB216348 \
    --hifi.terminal.lib LIB218783 \
    --hifi.maternal.lib LIB218785 &> SRP6-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP6/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP6 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP6/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP6 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP6/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP6 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP6 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP6/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP6 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP6/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP 7 ==================================================== #
# #################################### SKIP: Library Incomplete 29 OCT 2026 ##################################### #

# ====================================================  END  ==================================================== #


# ==================================================== SRP 8 ==================================================== #
# #################################### SKIP: Library Incomplete 29 OCT 2026 ##################################### #

# ====================================================  END  ==================================================== #


# ==================================================== SRP 9 ==================================================== #
# #################################### NOTE: Suspicious Library 29 OCT 2026 ##################################### #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP9 \
    --illumina.terminal.lib LIB223149 \
    --illumina.maternal.lib LIB223143 \
    --illumina.paternal.lib LIB223138 \
    --illumina.MGS.lib LIB223132 \
    --illumina.MGD.lib LIB223129 \
    --hifi.terminal.lib LIB224204 \
    --hifi.maternal.lib LIB223157 &> SRP9-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP9/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP9 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP9/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP9 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP9/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP9 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP9 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP9/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP9 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP9/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP10 ==================================================== #
# #################################### SKIP: Library Incomplete 29 OCT 2026 ##################################### #

# ====================================================  END  ==================================================== #


# ==================================================== SRP11 ==================================================== #
# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP11 \
    --illumina.terminal.lib LIB223150 \
    --illumina.maternal.lib LIB223145 \
    --illumina.paternal.lib LIB223137 \
    --illumina.MGS.lib LIB223135 \
    --illumina.MGD.lib LIB223131 \
    --hifi.terminal.lib LIB224205 \
    --hifi.maternal.lib LIB224200 &> SRP11-initialize.log

# Run readQC.sh
sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=SRP11/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT SRP11 --load.project.params YES"

# Run kmers.sh
sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=SRP11/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT SRP11 --load.project.params YES"

# Run filter.sh
sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=SRP11/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT SRP11 --load.project.params YES"

# Run assembly.sh
${SRP_WORKFLOW}/assembly.sh --projectROOT SRP11 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP11/assembly.log

# Run assembly-metrics.sh
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT SRP11 --load.project.params YES --verkko.outdir.name verkko2.3.2_trio --hifiasm.outdir.name hifiasm_trio &> SRP11/assembly-metrics.log

# ====================================================  END  ==================================================== #


# ==================================================== SRP12 ==================================================== #
# ====================================================  END  ==================================================== #


# ==================================================== SRP13 ==================================================== #
# ====================================================  END  ==================================================== #


# ==================================================== SRP14 ==================================================== #
# ====================================================  END  ==================================================== #


# ==================================================== SRP15 ==================================================== #
# ====================================================  END  ==================================================== #

