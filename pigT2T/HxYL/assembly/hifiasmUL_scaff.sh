#!/bin/bash -l

#SBATCH --job-name=hifiasm_UL_Pig
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=16104
#SBATCH --partition=priority-mem
#SBATCH --qos=agil-mem
#SBATCH --chdir=/project/ruminant_t2t/Pig/assembly/hifiasmUL_scaff
#SBATCH --output=hifiasmUL_scaff__%j.std
#SBATCH --error=hifiasmUL_scaff__%j.err


date

conda activate hifiasm_19.7-r598

hifiasm -o Pig_trioUL -t 96 -1 pat.yak -2 mat.yak --ul Pig_ULONT.fastq --dual-scaf *_DC_1.2.fastq.gz

date
