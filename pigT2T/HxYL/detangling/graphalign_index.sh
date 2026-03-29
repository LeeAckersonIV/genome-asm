#!/bin/bash -l

#SBATCH --job-name=index
#SBATCH --cpus-per-task=4
#SBATCH --ntasks=1
#SBATCH --partition=priority
#SBATCH --qos=agil
#SBATCH --mem-per-cpu=18027
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/8-manualResolution
#SBATCH --output=index__%j.std
#SBATCH --error=index__%j.err

date

micromamba activate verkko-v2.2

GraphAligner -t 4 -g ../5-untip/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.gfa -f empty.fasta -a empty.gaf \
       --diploid-heuristic 21 31 --diploid-heuristic-cache diploid.index \
       --seeds-mxm-cache-prefix manual \
       --bandwidth 15 \
       --seeds-mxm-length 30 \
       --mem-index-no-wavelet-tree \
       --seeds-mem-count 10000 && touch graph.index

date
