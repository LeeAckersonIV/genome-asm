#!/bin/bash -l

#SBATCH --job-name=align
#SBATCH --cpus-per-task=24
#SBATCH --ntasks=1
#SBATCH --partition=priority
#SBATCH --qos=agil
#SBATCH --mem-per-cpu=3968
#SBATCH --array=1-191
#SBATCH --time=2-00:00:00
#SBATCH --chdir=/project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/8-manualResolution
#SBATCH --output=align__%A_%a.std
#SBATCH --error=align__%A_%a.err

date

micromamba activate verkko-v2.2

for i in `ls split/ont$(printf "%03d" $SLURM_ARRAY_TASK_ID).fasta.gz`; do
id=`basename $i | sed s/.fasta.gz//g`

echo "$i $id.WORKING.gaf"

GraphAligner -t 24 -g ../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa -f $i -a $id.WORKING.gaf \
		--diploid-heuristic 21 31 --diploid-heuristic-cache diploid.index \
		--seeds-mxm-cache-prefix manual \
		--seeds-mxm-windowsize 5000 --seeds-mxm-length 30 \
		--seeds-mem-count 10000 \
		--bandwidth 15 \
		--multimap-score-fraction 0.99 \
		--precise-clipping 0.85 \
		--min-alignment-score 5000 \
		--hpc-collapse-reads \
		--discard-cigar \
		--clip-ambiguous-ends 100 \
		--overlap-incompatible-cutoff 0.15 \
		--max-trace-count 5 \
		--mem-index-no-wavelet-tree \
	&& \
	mv -f $id.WORKING.gaf $id.gaf

done

date
