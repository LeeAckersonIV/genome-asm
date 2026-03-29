# Make .gfa file for each flanking node to the rDNA tangles
grep utig4-1844 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1844.gfa
grep utig4-59 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-59.gfa
grep utig4-684 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-684.gfa
grep utig4-1964 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-1964.gfa
grep utig4-89 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-89.gfa
grep utig4-1778 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1778.gfa
grep utig4-1626 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-1626.gfa
grep utig4-88 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-88.gfa

# Convert each to .fasta file (needed for minimap2)
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1844.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1844.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-59.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-59.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-684.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-684.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-1964.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-1964.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-89.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-89.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1778.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1778.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-1626.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-1626.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-88.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-88.fa

# Now do minimap2 alignemenets
## basic command (for closely related contigs): minimap2 -ax asm5 ref.fasta query.fasta > aln.sam

cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/

# chr8.hap1
# -----------------------------------------
	########################################
	# attempt 1: base command, against full seq.
	#minimap2 -ax asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa > chr8.hap1.utig4-684.sam
	# attempt 2: base command, against 1 morph.
	#minimap2 -ax asm5 chr8.hap1.utig4-684.fa chr8.hap1.consensus.fa > chr8.hap1.utig4-684vConsensus.sam
	# attempt 3: more lenient mapping, and smaller kmer/window size, 1 morph.
	#minimap2 -x asm10 -k13 -w5 -c chr8.hap1.utig4-684.fa chr8.hap1.consensus.fa > chr8.hap1.utig4-684vConsensus.asm10.paf
	# attempt 4: more lenient mapping, and smaller kmer/window size, full seq.
	#minimap2 -x asm10 -k13 -w5 -c chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa > chr8.hap1.utig4-684.asm10.paf
	# go back to attempt 1, but with .paf file
	#minimap2 -x asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa > chr8.hap1.utig4-684.paf
	########################################

# utig4-684
minimap2 -x asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa > minimap2/chr8.hap1.utig4-684.paf
# utig4-1964
minimap2 -x asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.patch.fa > minimap2/chr8.hap1.utig4-1964.paf

# chr8.hap2
# -----------------------------------------
# utig4-59
minimap2 -x asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.patch.fa > minimap2/chr8.hap2.utig4-59.paf
# utig4-1844
minimap2 -x asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.patch.fa > minimap2/chr8.hap2.utig4-1844.paf



# chr10.hap1
# -----------------------------------------
# utig4-89
minimap2 -x asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.patch.fa > minimap2/chr10.hap1.utig4-89.paf
# utig4-1778
minimap2 -x asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.patch.fa > minimap2/chr10.hap1.utig4-1778.paf



# chr10.hap2
# -----------------------------------------
# utig4-88
minimap2 -x asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.patch.fa > minimap2/chr10.hap2.utig4-88.paf
# utig4-1626
minimap2 -x asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.patch.fa > minimap2/chr10.hap2.utig4-1626.paf


# All mappings tied together into one script:
# -----------------------------------------
# utig4-684
minimap2 -x asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa > minimap2/chr8.hap1.utig4-684.paf #.paf
minimap2 -ax asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa > minimap2/chr8.hap1.utig4-684.sam #.sam
# utig4-1964
minimap2 -x asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.patch.fa > minimap2/chr8.hap1.utig4-1964.paf #.paf
minimap2 -ax asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.patch.fa > minimap2/chr8.hap1.utig4-1964.sam #.sam
# utig4-59
minimap2 -x asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.patch.fa > minimap2/chr8.hap2.utig4-59.paf #.paf
minimap2 -ax asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.patch.fa > minimap2/chr8.hap2.utig4-59.sam #.sam
# utig4-1844
minimap2 -x asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.patch.fa > minimap2/chr8.hap2.utig4-1844.paf #.paf
minimap2 -ax asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.patch.fa > minimap2/chr8.hap2.utig4-1844.sam #.sam
# utig4-89
minimap2 -x asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.patch.fa > minimap2/chr10.hap1.utig4-89.paf #.paf
minimap2 -ax asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.patch.fa > minimap2/chr10.hap1.utig4-89.sam #.sam
# utig4-1778
minimap2 -x asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.patch.fa > minimap2/chr10.hap1.utig4-1778.paf #.paf
minimap2 -ax asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.patch.fa > minimap2/chr10.hap1.utig4-1778.sam #.sam
# utig4-88
minimap2 -x asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.patch.fa > minimap2/chr10.hap2.utig4-88.paf #.paf
minimap2 -ax asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.patch.fa > minimap2/chr10.hap2.utig4-88.sam #.sam
# utig4-1626
minimap2 -x asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.patch.fa > minimap2/chr10.hap2.utig4-1626.paf #.paf
minimap2 -ax asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.patch.fa > minimap2/chr10.hap2.utig4-1626.sam #.sam



# convert morphs to hpc space
# ----------------------------
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches

seqtk hpc /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/CONKORD/feature/chr8.hap1.consensus/chr8.hap1.consensus.fa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr8.hap1.morph.fa.hpc
seqtk hpc /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/CONKORD/feature/chr8.hap2.consensus/chr8.hap2.consensus.fa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr8.hap2.morph.fa.hpc
seqtk hpc /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/CONKORD/feature/chr10.hap1.consensus/chr10.hap1.consensus.fa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr10.hap1.morph.fa.hpc
seqtk hpc /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/CONKORD/feature/chr10.hap2.consensus/chr10.hap2.consensus.fa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr10.hap2.morph.fa.hpc


# Re-run alignments in HPC space
# -------------------------------
# utig4-684
minimap2 -x asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-684.hpc.paf #.paf
minimap2 -ax asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-684.hpc.sam #.sam
# utig4-1964
minimap2 -x asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-1964.hpc.paf #.paf
minimap2 -ax asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-1964.hpc.sam #.sam
# utig4-59
minimap2 -x asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-59.hpc.paf #.paf
minimap2 -ax asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-59.hpc.sam #.sam
# utig4-1844
minimap2 -x asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-1844.hpc.paf #.paf
minimap2 -ax asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-1844.hpc.sam #.sam
# utig4-89
minimap2 -x asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-89.hpc.paf #.paf
minimap2 -ax asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-89.hpc.sam #.sam
# utig4-1778
minimap2 -x asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-1778.hpc.paf #.paf
minimap2 -ax asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-1778.hpc.sam #.sam
# utig4-88
minimap2 -x asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-88.hpc.paf #.paf
minimap2 -ax asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-88.hpc.sam #.sam
# utig4-1626
minimap2 -x asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-1626.hpc.paf #.paf
minimap2 -ax asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-1626.hpc.sam #.sam


# add the -cx to get cigar string
# -------------------------------
# utig4-684
minimap2 -cx asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-684.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-684.cax.hpc.sam #.sam
# utig4-1964
minimap2 -cx asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-1964.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.morph.fa.hpc > minimap2.hpc/chr8.hap1.utig4-1964.cax.hpc.sam #.sam
# utig4-59
minimap2 -cx asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-59.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-59.cax.hpc.sam #.sam
# utig4-1844
minimap2 -cx asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-1844.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.morph.fa.hpc > minimap2.hpc/chr8.hap2.utig4-1844.cax.hpc.sam #.sam
# utig4-89
minimap2 -cx asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-89.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-89.cax.hpc.sam #.sam
# utig4-1778
minimap2 -cx asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-1778.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.morph.fa.hpc > minimap2.hpc/chr10.hap1.utig4-1778.cax.hpc.sam #.sam
# utig4-88
minimap2 -cx asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-88.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-88.cax.hpc.sam #.sam
# utig4-1626
minimap2 -cx asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-1626.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.morph.fa.hpc > minimap2.hpc/chr10.hap2.utig4-1626.cax.hpc.sam #.sam

# check the winnowmap map-ont, get better/worse results
# -------------------------------------------------------
# example from 3-alignTips:
# winnowmap -I40G -t 24 -cx map-ont tips.fasta ../3-alignTips/split/ont005.fasta.gz |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > ../3-alignTips/aligned005.WORKING.gaf && mv -f ../3-alignTips/aligned005.WORKING.gaf ../3-alignTips/aligned005.gaf

# winnowmap -> .gaf
# -----------------
# utig4-684
winnowmap -I40G -t 24 -cx map-ont chr8.hap1.utig4-684.fa ../chr8.hap1.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr8.hap1.utig4-684.hpc.gaf
# utig4-1964
winnowmap -I40G -t 24 -cx map-ont chr8.hap1.utig4-1964.fa ../chr8.hap1.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr8.hap1.utig4-1964.hpc.gaf
# utig4-59
winnowmap -I40G -t 24 -cx map-ont chr8.hap2.utig4-59.fa ../chr8.hap2.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr8.hap2.utig4-59.hpc.gaf
# utig4-1844
winnowmap -I40G -t 24 -cx map-ont chr8.hap2.utig4-1844.fa ../chr8.hap2.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr8.hap2.utig4-1844.hpc.gaf
# utig4-89
winnowmap -I40G -t 24 -cx map-ont chr10.hap1.utig4-89.fa ../chr10.hap1.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr10.hap1.utig4-89.hpc.gaf
# utig4-1778
winnowmap -I40G -t 24 -cx map-ont chr10.hap1.utig4-1778.fa ../chr10.hap1.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr10.hap1.utig4-1778.hpc.gaf
# utig4-88
winnowmap -I40G -t 24 -cx map-ont chr10.hap2.utig4-88.fa ../chr10.hap2.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr10.hap2.utig4-88.hpc.gaf
# utig4-1626
winnowmap -I40G -t 24 -cx map-ont chr10.hap2.utig4-1626.fa ../chr10.hap2.morph.fa.hpc |sed s/de:f://g |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > winnowmap.hpc.gfa/chr10.hap2.utig4-1626.hpc.gaf


# minimap .paf -> .gaf
# --------------------
cd minimap2.hpc
# utig4-684
sed s/de:f://g minimap2.hpc/chr8.hap1.utig4-684.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap1.utig4-684.hpc.gaf
# utig4-1964
sed s/de:f://g minimap2.hpc/chr8.hap1.utig4-1964.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap1.utig4-1964.hpc.gaf
# utig4-59
sed s/de:f://g minimap2.hpc/chr8.hap2.utig4-59.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap2.utig4-59.hpc.gaf
# utig4-1844
sed s/de:f://g minimap2.hpc/chr8.hap2.utig4-1844.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap2.utig4-1844.hpc.gaf
# utig4-89
sed s/de:f://g minimap2.hpc/chr10.hap1.utig4-89.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap1.utig4-89.hpc.gaf
# utig4-1778
sed s/de:f://g minimap2.hpc/chr10.hap1.utig4-1778.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap1.utig4-1778.hpc.gaf
# utig4-88
sed s/de:f://g minimap2.hpc/chr10.hap2.utig4-88.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap2.utig4-88.hpc.gaf
# utig4-1626
sed s/de:f://g minimap2.hpc/chr10.hap2.utig4-1626.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap2.utig4-1626.hpc.gaf

# we are losing some alings - empty files! 
# fix the awk script to remedy this:
	#Currently: if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9)
		#MAPQ>20, BP>5000, Divergence>90%
	#get rid of all of them:

# utig4-684
sed s/de:f://g minimap2.hpc/chr8.hap1.utig4-684.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap1.utig4-684.hpc.gaf
# utig4-1964
sed s/de:f://g minimap2.hpc/chr8.hap1.utig4-1964.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap1.utig4-1964.hpc.gaf
# utig4-59
sed s/de:f://g minimap2.hpc/chr8.hap2.utig4-59.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap2.utig4-59.hpc.gaf
# utig4-1844
sed s/de:f://g minimap2.hpc/chr8.hap2.utig4-1844.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr8.hap2.utig4-1844.hpc.gaf
# utig4-89
sed s/de:f://g minimap2.hpc/chr10.hap1.utig4-89.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap1.utig4-89.hpc.gaf
# utig4-1778
sed s/de:f://g minimap2.hpc/chr10.hap1.utig4-1778.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap1.utig4-1778.hpc.gaf
# utig4-88
sed s/de:f://g minimap2.hpc/chr10.hap2.utig4-88.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap2.utig4-88.hpc.gaf
# utig4-1626
sed s/de:f://g minimap2.hpc/chr10.hap2.utig4-1626.cax.hpc.paf |awk -F "\t" '{ if ($12 >= 20 && $4-$3 > 5000 && 1-$21 >= 0.9) { if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }}' > minimap2.hpc.gaf/chr10.hap2.utig4-1626.hpc.gaf







# Updated workflow: Take2
# ======================================

# Make .gfa file for each flanking node to the rDNA tangles
# ---------------------------------------------------------
grep utig4-1844 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1844.gfa
grep utig4-59 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-59.gfa
grep utig4-684 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-684.gfa
grep utig4-1964 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-1964.gfa
grep utig4-89 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-89.gfa
grep utig4-1778 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1778.gfa
grep utig4-1626 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-1626.gfa
grep utig4-88 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-88.gfa

# Convert each to .fasta file (needed for minimap2)
# -------------------------------------------------
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1844.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1844.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-59.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-59.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-684.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-684.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-1964.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-1964.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-89.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-89.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1778.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1778.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-1626.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-1626.fa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-88.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-88.fa


# convert morphs*CNV to hpc space
# -------------------------------
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches

seqtk hpc chr8.hap1.patch.fa > chr8.hap1.patch.fa.hpc
seqtk hpc chr8.hap2.patch.fa > chr8.hap2.patch.fa.hpc
seqtk hpc chr10.hap1.patch.fa > chr10.hap1.patch.fa.hpc
seqtk hpc chr10.hap2.patch.fa > chr10.hap2.patch.fa.hpc

# minimap2 aligns { .sam, .paf }
# -------------------------------
cd flank-utigs
mkdir minimap2.patchSeq.hpc

# utig4-684
minimap2 -cx asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap1.utig4-684.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap1.utig4-684.fa ../chr8.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap1.utig4-684.cax.hpc.sam #.sam
# utig4-1964
minimap2 -cx asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap1.utig4-1964.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap1.utig4-1964.fa ../chr8.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap1.utig4-1964.cax.hpc.sam #.sam
# utig4-59
minimap2 -cx asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap2.utig4-59.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap2.utig4-59.fa ../chr8.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap2.utig4-59.cax.hpc.sam #.sam
# utig4-1844
minimap2 -cx asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap2.utig4-1844.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap2.utig4-1844.fa ../chr8.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap2.utig4-1844.cax.hpc.sam #.sam
# utig4-89
minimap2 -cx asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap1.utig4-89.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap1.utig4-89.fa ../chr10.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap1.utig4-89.cax.hpc.sam #.sam
# utig4-1778
minimap2 -cx asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap1.utig4-1778.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap1.utig4-1778.fa ../chr10.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap1.utig4-1778.cax.hpc.sam #.sam
# utig4-88
minimap2 -cx asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-88.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap2.utig4-88.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-88.cax.hpc.sam #.sam
# utig4-1626
minimap2 -cx asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-1626.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap2.utig4-1626.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-1626.cax.hpc.sam #.sam

# Generate .gaf files {from .paf}
# -------------------------------
# !!! MANUALLY FILTER TO ONLY HAVE LAST ALIGNMENTS BEFORE MOVING ON TO THIS STEP !!!
cd minimap2.patchSeq.hpc
mkdir minimap2.patchSeq.hpc.gaf

# utig4-684
sed s/de:f://g chr8.hap1.utig4-684.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr8.hap1.utig4-684.hpc.gaf
# utig4-1964
sed s/de:f://g chr8.hap1.utig4-1964.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr8.hap1.utig4-1964.hpc.gaf
# utig4-59
sed s/de:f://g chr8.hap2.utig4-59.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr8.hap2.utig4-59.hpc.gaf
# utig4-1844
sed s/de:f://g chr8.hap2.utig4-1844.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr8.hap2.utig4-1844.hpc.gaf
# utig4-89
sed s/de:f://g chr10.hap1.utig4-89.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap1.utig4-89.hpc.gaf
# utig4-1778
sed s/de:f://g chr10.hap1.utig4-1778.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap1.utig4-1778.hpc.gaf
# utig4-88
sed s/de:f://g chr10.hap2.utig4-88.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap2.utig4-88.hpc.gaf
# utig4-1626
sed s/de:f://g chr10.hap2.utig4-1626.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap2.utig4-1626.hpc.gaf



# need to check aligns for utig4-58 (as opposed to utig4-1964; 15kb), and utig4-1795 (as opposed to utig4-1778; 13kb)
# this is because the rDNA morph is actually larger than the length of these two nodes -> so, there is a chance we can bypass these utigs to larger utigs as anchor points

# utig4-58
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/
grep utig4-58 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-58.gfa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-58.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap1.utig4-58.fa
minimap2 -cx asm5 chr8.hap1.utig4-58.fa ../chr8.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap1.utig4-58.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap1.utig4-58.fa ../chr8.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap1.utig4-58.cax.hpc.sam #.sam
cd minimap2.patchSeq.hpc
sed s/de:f://g chr8.hap1.utig4-58.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr8.hap1.utig4-58.hpc.gaf

# utig4-1795
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/
grep utig4-1795 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1795.gfa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1795.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap1.utig4-1795.fa
minimap2 -cx asm5 chr10.hap1.utig4-1795.fa ../chr10.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap1.utig4-1795.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap1.utig4-1795.fa ../chr10.hap1.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap1.utig4-1795.cax.hpc.sam #.sam
cd minimap2.patchSeq.hpc
sed s/de:f://g chr10.hap1.utig4-1795.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap1.utig4-1795.hpc.gaf

# utig4-1843 # replaced 1844; even tho 200kb away - might resolve tangle and find more rDNA here.
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/
grep utig4-1843 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1843.gfa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1843.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr8.hap2.utig4-1843.fa
minimap2 -cx asm5 chr8.hap2.utig4-1843.fa ../chr8.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap2.utig4-1843.cax.hpc.paf #.paf
minimap2 -cax asm5 chr8.hap2.utig4-1843.fa ../chr8.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr8.hap2.utig4-1843.cax.hpc.sam #.sam
cd minimap2.patchSeq.hpc
sed s/de:f://g chr8.hap2.utig4-1843.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr8.hap2.utig4-1843.hpc.gaf

# !!! Each contig has aligns, with MAPQ=60 -> should use these uigs moving forward (as opposed to their neighboring smaller utigs)

# utig4-13; even tho 200kb away - might resolve tangle and find more rDNA here.
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/
grep utig4-13 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa | head -n 1 > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-13.gfa
awk '$1 == "S" {print ">" $2 "\n" $3}' /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-13.gfa > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/chr10.hap2.utig4-13.fa
minimap2 -cx asm5 chr10.hap2.utig4-13.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-13.cax.hpc.paf #.paf
minimap2 -cax asm5 chr10.hap2.utig4-13.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-13.cax.hpc.sam #.sam
cd minimap2.patchSeq.hpc
sed s/de:f://g chr10.hap2.utig4-13.cax.hpc.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap2.utig4-13.hpc.gaf



# Manually determine which alignments to keep within the .gfa files to feed back to verkko.
# Wen and I determined that we want to identify the two alignments furthest from the tangles as the overlap fed to verkko.

	# Chr8.hap1 [utig58 & utig684]
	sort -k4,4nr chr8.hap1.utig4-684.hpc.gaf | head -n 1  > chr8.hap1.patchAlign.gaf # take top align
	tail -n 1 chr8.hap1.utig4-58.hpc.gaf >> chr8.hap1.patchAlign.gaf # take bottom align from zero

	# Chr8.hap2 [utig59 & utig1843]
	sort -k4,4nr chr8.hap2.utig4-1843.hpc.gaf | head -n 1 > chr8.hap2.patchAlign.gaf
	tail -n 1 chr8.hap2.utig4-59.hpc.gaf >> chr8.hap2.patchAlign.gaf

	# Chr10.hap1 [utig89 & 1795]
	sort -k4,4nr chr10.hap1.utig4-89.hpc.gaf | head -n 1 > chr10.hap1.patchAlign.gaf
	sort -k4,4nr chr10.hap1.utig4-1795.hpc.gaf | tail -n 1 >> chr10.hap1.patchAlign.gaf
	
	# Chr10.hap2 [utig88 & utig13]
	sort -k4,4nr  chr10.hap2.utig4-13.hpc.gaf | head -n 1 > chr10.hap2.patchAlign.gaf
	sort -k4,4nr  chr10.hap2.utig4-88.hpc.gaf | tail -n 1 >> chr10.hap2.patchAlign.gaf
	
	# collate into one file 
	cat *patchAlign* > rDNApatchAligns.gaf

# Ben had indicated that it may be better to take the alignment closer to the gap; so we may want to generate an assembly that way too.

# update patch file so two lines - check that aligns dont change...
python rDNA-morph2patch.py /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr8.hap1.consensus.fa chr8.hap1.fullpatch.fa 108
python rDNA-morph2patch.py /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr8.hap2.consensus.fa chr8.hap2.fullpatch.fa 109
python rDNA-morph2patch.py /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr10.hap1.consensus.fa chr10.hap1.fullpatch.fa 110
python rDNA-morph2patch.py /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/chr10.hap2.consensus.fa chr10.hap2.fullpatch.fa 116

# cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/
# seqtk hpc chr10.hap2.fullpatch.fa > chr10.hap2.fullpatch.test.fa.hpc
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/
minimap2 -cx asm5 chr10.hap2.utig4-13.fa ../chr10.hap2.patch.fa.hpc > minimap2.patchSeq.hpc/chr10.hap2.utig4-13.cax.hpc.test.paf #.paf
cd minimap2.patchSeq.hpc
sed s/de:f://g chr10.hap2.utig4-13.cax.hpc.test.paf |awk -F "\t" '{ if (match($5, "-")) print $1"\t"$2"\t"$3"\t"$4"\t+\t<"$6"\t"$7"\t"$7-$9"\t"$7-$8"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21; else print $1"\t"$2"\t"$3"\t"$4"\t"$5"\t>"$6"\t"$7"\t"$8"\t"$9"\t"$10"\t"$11"\t"$12"\t"$13"\t"$15"\tdv:f:"$21"\tid:f:"1-$21 }' > minimap2.patchSeq.hpc.gaf/chr10.hap2.utig4-13.hpc.test.gaf
# !!! Identical, we dont need to rerun alignments!
