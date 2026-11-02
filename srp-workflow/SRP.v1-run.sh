# ==================================================== Stage 1 for SRP 1,2,3,4,5,6,9,11 ==================================================== #
# This example has several LibraryIDs for individuals, as well as several files within a single LibraryID.

# Move to scratch space with plenty of storage space
mkdir -p /mnt/gs21/scratch/ackers24/srp-sandbox/SRP.v1
cd /mnt/gs21/scratch/ackers24/srp-sandbox/SRP.v1

# Run SRP1
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP1 \
    --illumina.terminal.lib LIB212039 \
    --illumina.maternal.lib LIB212038 \
    --illumina.paternal.lib LIB212041 \
    --illumina.MGS.lib LIB212046 \
    --illumina.MGD.lib LIB212044 \
    --hifi.terminal.lib "LIB212031,LIB215030" \
    --hifi.maternal.lib "LIB212951,LIB215570" &> ${PWD}/SRP1-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP1/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP1 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP1/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP1 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP1/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP1 --load.project.params YES"

# Run SRP2
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP2 \
    --illumina.terminal.lib LIB212040 \
    --illumina.maternal.lib LIB212037 \
    --illumina.paternal.lib LIB212042 \
    --illumina.MGS.lib LIB212045 \
    --illumina.MGD.lib LIB212043 \
    --hifi.terminal.lib "LIB212032,LIB215031" \
    --hifi.maternal.lib "LIB212950,LIB215002" &> ${PWD}/SRP2-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP2/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP2 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP2/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP2 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP2/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP2 --load.project.params YES"

# Run SRP3
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP3 \
    --illumina.terminal.lib LIB219050 \
    --illumina.maternal.lib LIB219054 \
    --illumina.paternal.lib LIB216357 \
    --illumina.MGS.lib LIB216351 \
    --illumina.MGD.lib LIB216347 \
    --hifi.terminal.lib LIB218782 \
    --hifi.maternal.lib LIB219057 &> ${PWD}/SRP3-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP3/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP3 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP3/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP3 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP3/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP3 --load.project.params YES"

# Run SRP4
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP4 \
    --illumina.terminal.lib LIB219049 \
    --illumina.maternal.lib LIB219053 \
    --illumina.paternal.lib LIB216358 \
    --illumina.MGS.lib LIB216352 \
    --illumina.MGD.lib LIB216346 \
    --hifi.terminal.lib LIB218781 \
    --hifi.maternal.lib LIB219056 &> ${PWD}/SRP4-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP4/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP4 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP4/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP4 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP4/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP4 --load.project.params YES"

# Run SRP5
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP5 \
    --illumina.terminal.lib LIB219052 \
    --illumina.maternal.lib LIB216350 \
    --illumina.paternal.lib LIB216355 \
    --illumina.MGS.lib LIB216353 \
    --illumina.MGD.lib LIB216349 \
    --hifi.terminal.lib LIB218784 \
    --hifi.maternal.lib LIB216388 &> ${PWD}/SRP5-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP5/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP5 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP5/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP5 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP5/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP5 --load.project.params YES"

# Run SRP6
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP6 \
    --illumina.terminal.lib LIB219051 \
    --illumina.maternal.lib LIB219055 \
    --illumina.paternal.lib LIB216356 \
    --illumina.MGS.lib LIB216354 \
    --illumina.MGD.lib LIB216348 \
    --hifi.terminal.lib LIB218783 \
    --hifi.maternal.lib LIB218785 &> ${PWD}/SRP6-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP6/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP6 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP6/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP6 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP6/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP6 --load.project.params YES"

# Run SRP9
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP9 \
    --illumina.terminal.lib LIB223149 \
    --illumina.maternal.lib LIB223143 \
    --illumina.paternal.lib LIB223138 \
    --illumina.MGS.lib LIB223132 \
    --illumina.MGD.lib LIB223129 \
    --hifi.terminal.lib LIB224204 \
    --hifi.maternal.lib LIB223157 &> ${PWD}/SRP9-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP9/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP9 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP9/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP9 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP9/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP9 --load.project.params YES"

# Run SRP11
"${SRP_WORKFLOW}/initialize.sh" --projectROOT ${PWD}/SRP11 \
    --illumina.terminal.lib LIB223150 \
    --illumina.maternal.lib LIB223145 \
    --illumina.paternal.lib LIB223137 \
    --illumina.MGS.lib LIB223135 \
    --illumina.MGD.lib LIB223131 \
    --hifi.terminal.lib LIB224205 \
    --hifi.maternal.lib LIB224200 &> ${PWD}/SRP11-initialize.log

sbatch --time=8:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=readQC --output=${PWD}/SRP11/readQC.log \
    --wrap="${SRP_WORKFLOW}/readQC.sh --projectROOT ${PWD}/SRP11 --load.project.params YES"

sbatch --time=24:00:00 --cpus-per-task=16 --mem=250G \
    --job-name=kmers --output=${PWD}/SRP11/kmers.log \
    --wrap="${SRP_WORKFLOW}/kmers.sh --projectROOT ${PWD}/SRP11 --load.project.params YES"

sbatch --time=2-00:00:00 --cpus-per-task=48 --mem=400G \
    --job-name=filter --output=${PWD}/SRP11/filter.log \
    --wrap="${SRP_WORKFLOW}/filter.sh --projectROOT ${PWD}/SRP11 --load.project.params YES"

# ==================================================== Stage 2 for SRP 1,2,3,4,5,6,9,11 ==================================================== #

# Run SRP1
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP1 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP1/assembly.log

# Run SRP2
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP2 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP2/assembly.log

# Run SRP3
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP3 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP3/assembly.log

# Run SRP4
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP4 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP4/assembly.log

# Run SRP5
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP5 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP5/assembly.log

# Run SRP6
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP6 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP6/assembly.log

# Run SRP9
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP9 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP9/assembly.log

# Run SRP11
${SRP_WORKFLOW}/assembly.sh --projectROOT ${PWD}/SRP11 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --run.verkko FALSE &> ${PWD}/SRP11/assembly.log


# ==================================================== Stage 3 for SRP 1,2,3,4,5,6,9,11 ==================================================== #

# Run SRP1
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP1 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP1/assembly-metrics.log

# Run SRP2
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP2 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP2/assembly-metrics.log

# Run SRP3
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP3 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP3/assembly-metrics.log

# Run SRP4
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP4 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP4/assembly-metrics.log

# Run SRP5
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP5 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP5/assembly-metrics.log

# Run SRP6
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP6 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP6/assembly-metrics.log

# Run SRP9
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP9 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP9/assembly-metrics.log

# Run SRP11
${SRP_WORKFLOW}/assembly-metrics.sh --projectROOT ${PWD}/SRP11 --load.project.params YES --hifiasm.outdir.name hifiasm_trio --eval.verkko FALSE &> ${PWD}/SRP11/assembly-metrics.log

















