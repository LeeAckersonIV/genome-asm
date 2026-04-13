#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO     
#SBATCH --output=BUSCO_%j.out
#SBATCH --error=BUSCO_%j.err  

module load BUSCO/5.8.2-foss-2023a # MSU

# paternal haplotype
busco --in $PAT_ASM \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out $BUSCO_OUTDIR/busco.paternal

# maternal haplotype
busco --in $MAT_ASM \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out $BUSCO_OUTDIR/busco.maternal