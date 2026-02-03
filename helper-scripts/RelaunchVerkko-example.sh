# Example of how to re-launch the PigT2T assembly with rDNA and tangle patches.
# Author: Lee Ackerson [ackers24@msu.edu]
###############################################################################

# generate or copy in necessary inputs
# =============================================================================
# Make assembly-patch directory
mkdir verkko2.2_hifi-duplex_trio.patch1
cd verkko2.2_hifi-duplex_trio.patch1

# Translate the detangled hapmers to proper format; script in github:helper-scripts
asm-path-translate.py <every-detangled-hapmer>

# Generate rDNA patch ("ONT Reads")
mkdir rDNA-patches
cd rDNA-patches
rDNA-morph2patch.py input.fasta output.fasta CNV # this just glosses over me generating the rDNA array patches for the assembly; script is in github, reach out to me for more info.
cd ..

# Insert custom sequence into rDNA gaps
# insert_aln_gaps.py ../assembly.homopolymer-compressed.gfa \ # graph file
	# subset.gaf \ # aligned gaf file
	# 1 \ # min gap coverage
	# # 50000 \ # 
	# patch.nogap.gaf \ # Output file for non-gap alignments
	# patch.gaf \ # Output file for gap alignments
	# gapmanual \ # file prefix
	# y # allow no tips \
	# > patch.gfa # output graph file
	
/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2/lib/verkko/scripts/insert_aln_gaps.py /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.homopolymer-compressed.gfa /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/flank-utigs/minimap2.patchSeq.hpc/minimap2.patchSeq.hpc.gaf/rDNApatchAligns.gaf 1 50000 patch.nogap.gaf patch.gaf gapmanual y > /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/patch.gfa # adjust 50,000 to higher number of needed. I had to go to 100,000 for 1 of the rDNA arrays.


# Set up verkko_final_asm folder
mkdir relaunch-verkko2.2-patch-phase
cd relaunch-verkko2.2-patch-phase
salloc -p priority -q agil -c 96 --mem-per-cpu=3968 --time=4-00:00:00
micromamba activate verkko-v2.2

# copy in align + patch gaf files
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-alignments.gaf ./
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/patch.gaf ./
cat patch.gaf >> combined-alignments.gaf

# copy in edges and paatch gfa files
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-edges.gfa ./
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/patch.gfa ./
cat patch.gfa | grep '^L' |grep gap >> combined-edges.gfa

# get nodemap and nodelens, append patch.gfa
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-nodemap.txt
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/nodelens.txt ./
cat patch.gfa | grep gap | awk 'BEGIN { FS="[ \t]+"; OFS="\t"; } ($1 == "S") && ($3 != "*") { print $2, length($3); }' >> nodelens.txt

# copy in consensus ONT reads, as well as full patch sequences (treated as ONT reads)
# add rDNA patches as ONT reads for verkko to use
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/7-consensus/ont_subset.fasta.gz ./
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/rDNA-patches/*fullpatch.fa ./ # these are my patch files, generated prior to this script.
cat chr8.hap1.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr8.hap2.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr10.hap1.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr10.hap2.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id

# Manually (semi-automatic with below script) edit patch files
#cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1
#perl ~/scripts/addPatch.pl --gaf manual.paths.gaf --patch HxYL-Assembly-CollatedPatches.tsv > new.paths.gaf
#cd /90daydata/ruminant_t2t/Pig/assembly/relaunch.patch1.verkko2.2_hifi-duplex_trio
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio.patch1/new.paths.gaf ./

# Confirm new assembly layout & paths are valid; & generate layout and scfmap with new paths using get_layout_from_mbg.py
/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2/lib/verkko/scripts/get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf new.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap


# set up directory structure for final launch of verkko
# =============================================================================
# Set up verkko_final_asm folder
mkdir verkko_final_asm
cd verkko_final_asm

# link in dirs 1-5 of tangled assembly
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/1-buildGraph/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/2-processGraph/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/3-align
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/3-alignTips/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/4-processONT/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/5-untip/

# make new 6-layoutContigs folder, link in necessary files (make sure to include output from get_layout_from_mbg.py)
mkdir 6-layoutContigs
cd 6-layoutContigs
ln -s ../../combined-nodemap.txt
ln -s ../../combined-edges.gfa
ln -s ../../combined-alignments.gaf
ln -s ../../nodelens.txt
ln -s ../../unitig-popped.layout.scfmap
ln -s ../../unitig-popped.layout

# make new 6-rukki folder, link in necessary files (make sure to include label1 & label2 if phasing information supplied)
cd ..
mkdir 6-rukki
cd 6-rukki
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv
ln -s ../../new.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf
ln -s ../../new.paths.gaf unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/label1
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/label2


# make new 7-consensus folder, link in necessary files
cd ../
mkdir 7-consensus
cd 7-consensus
ln -s ../../ont_subset.id
ln -s ../../ont_subset.fasta.gz

# link in input data to parent directory for launching verkkko (sequencc reads, reference fastas, etc.)
cd ../../
ln -s /project/ruminant_t2t/Pig/assembly/hifi-duplex
ln -s /project/ruminant_t2t/Pig/assembly/oxnan_data
ln -s /project/ruminant_t2t/existing_NCBI_references/Pig/Pig_MT.fasta
ln -s /project/ruminant_t2t/Pig/assembly/verkko1.4.1_hifi_trio/pig_rDNA.fasta
ln -s /project/ruminant_t2t/Pig/illumina_data


# Rerun Verkko w/ patches
# =============================================================================
# snakemake touch - make sure verkko will do what you want it to do
# verkko --slurm /
# 	--snakeopts "--touch" /
# 	-d verkko_final_asm /
# 	--unitig-abundance 4 /
# 	--red-run 8 40 8 /
# 	--hifi hifi-duplex/*.fastq.gz /
# 	--nano oxnan_data/*q12-10-7-5*.fastq.gz /
# 	--screen pig_MT Pig_MT.fasta /
# 	--screen pig_rDNA pig_rDNA.fasta /
# 	--hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio /
# 	> /dev/null 2>&1

# snakemake dryrun - make sure verkko will do what you want it to do
# verkko --slurm /
# 	--snakeopts "--dry-run"/
# 	 -d verkko_final_asm /
# 	 --unitig-abundance 4 /
# 	 --red-run 8 40 8 /
# 	 --hifi hifi-duplex/*.fastq.gz /
# 	 --nano oxnan_data/*q12-10-7-5*.fastq.gz /
# 	 --screen pig_MT Pig_MT.fasta /
# 	 --screen pig_rDNA pig_rDNA.fasta /
# 	 --hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl 	illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio

# actually submit the job to SLURM for execution
sbatch --parsable --cpus-per-task=2 --mem 50g --output verkko_final_asm.out launch_verkko_final_asm.sh

	# ./launch_verkko_final_asm.sh
	# ----------------------------
	#!/bin/bash -l
	# micromamba activate verkko-v2.2
# 	verkko --version
# 	verkko --slurm /
# 		-d verkko_final_asm /
# 		--unitig-abundance 4 /
# 		--red-run 8 40 8 /
# 		--hifi hifi-duplex/*.fastq.gz /
# 		--nano oxnan_data/*q12-10-7-5*.fastq.gz /
# 		--screen pig_MT Pig_MT.fasta /
# 		--screen pig_rDNA pig_rDNA.fasta /
# 		--hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio
	# -----------------------------
