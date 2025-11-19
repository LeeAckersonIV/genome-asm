#! /bin/bash -l

#SBATCH --job-name=PAS09592-filt
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --partition=priority
#SBATCH --qos=msn
#SBATCH --mem-per-cpu=3968
#SBATCH --time=2-00:00:00
#SBATCH --chdir=/project/ruminant_t2t/Pig/oxnan_data
#SBATCH --output=PAS09592_nanofilt__%j.std
#SBATCH --error=PAS09592_nanofilt__%j.err

date

conda activate nanopack

zcat PAS09592/fastq_fail/*.fastq.gz PAS09592/fastq_pass/*.fastq.gz | tee >(chopper -t 24 -q 12 --minlength 20000 --maxlength 39999  > PAS09592_dorado_q12-10-7-5_q12_40k.fastq) >(chopper -t 24 -q 10 --minlength 40000 --maxlength 69999 > PAS09592_dorado_q12-10-7-5_q10_70k.fastq) >/dev/null &

zcat PAS09592/fastq_fail/*.fastq.gz PAS09592/fastq_pass/*.fastq.gz | tee >(chopper -t 24 -q 7 --minlength 70000 --maxlength 99999 > PAS09592_dorado_q12-10-7-5_q7_100k.fastq) >(chopper -t 24 -q 5 --minlength 100000 > PAS09592_dorado_q12-10-7-5_q5_100k.fastq) >/dev/null

date
