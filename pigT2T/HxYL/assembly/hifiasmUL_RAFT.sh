#!/bin/bash -l

#SBATCH --job-name=pig_RAFT-hifiasm
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16104
#SBATCH --partition=priority-mem
#SBATCH --qos=agil-mem
#SBATCH --chdir=/project/ruminant_t2t/Pig/assembly/raft_hifiasmUL
#SBATCH --output=pig_raft-hifiasm__%j.std
#SBATCH --error=pig_raft-hifiasm__%j.err


date

conda activate hifiasm-0.19.8-r603

hifiasm -o errorcorrect -t 96 --write-ec *_20k.fastq.gz 2> errorcorrect.log
COVERAGE=$(grep "homozygous" errorcorrect.log | tail -1 | awk '{print $6}')
echo ${COVERAGE}
hifiasm -o getOverlaps -t 96 --dbg-ovec errorcorrect.ec.fa 2> getOverlaps.log
cat getOverlaps.0.ovlp.paf getOverlaps.1.ovlp.paf > overlaps.paf
/project/cattle_genome_assemblies/packages/RAFT/raft -e ${COVERAGE} -o fragmented errorcorrect.ec.fa overlaps.paf
hifiasm -o pig_raft_trioUL -t 96 -r 1 -1 pat.yak -2 mat.yak --ul Pig_ULONT.fastq.gz fragmented.reads.fasta 2> finalasm.log

date
