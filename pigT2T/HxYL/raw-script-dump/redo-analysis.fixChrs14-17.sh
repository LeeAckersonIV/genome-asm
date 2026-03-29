# What would have to be done in order to fix both chromsome 14 and 17 in the HxYL assembly?


# Procedure + Timeline
# ------------------------------------------------------------------------------------------#
# 1. Fix the paths file to include utig4-693 in chr14_H.									#
# 2. DETERMINE BEST COURSE OF ACTION FOR chr17_H.											#
#	# a. likely will be anchoring in patch sequence similiar to that of the rDNA			#
#	# b. perhaps since both assemblies are verkko, we can just adjust utig paths			#
#	# c. subbing in entire chromosome sequence into final assembly could work since 		#
#	# 	it is T2T contig in Hi-C (requires unused sequence removal from trio assembly)		#
# 3. Relaunch verkko assembly with fixed paths files (patch-commands.sh)					#
# 4. Clean-up assembly: run RepeatMasker and remove mtDNA, rDNA, and misc small repeats.	#
# 5. Add in mtDNA contig to assembly														#
# 6. Screen for contaminants: FCS-GX & FCS-Adaptor (FCS-GX.sh & FCS-Adaptor.sh)				#
#	# no need to re-run FCS-GX, but need to run FCS-Adaptor!								#
# 7. Remove the adaptor found in the middle of contig dam_3									#
# 8. Validate assembly is stucturally correct 												#
# 9. Perform canu-binning & polishing with DeepVariant (iterative, Illumina then HiFi)		#
# 10. Rename final contigs																	#
# 11. Re-orient all the chromosomes such that they match Sscrofa11.1						#
# 12. Generate final partitioned assemblies													#
# 13. Upload to google drive																#
# 13. Perform QC analysis on assemblies (N50, BUSCO, QV, and novel seq)						#
# ------------------------------------------------------------------------------------------#



# Commands to execute
# ========================================================================================= #

# 1. Fix path for chr14_H
# -----------------------------------------------------------------------------------------#
# check the two missing sire contigs with CENP-A signals:

grep sire_compressed.k31.hapmer-0000365 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.scfmap
# > path sire_compressed.k31.hapmer-0000365 sire_compressed.k31.hapmer_unused_utig4-693
grep sire_compressed.k31.hapmer_unused_utig4-693 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > sire_compressed.k31.hapmer_unused_utig4-693	>utig4-693	SIRE_COMPRESSED.K31.HAPMER
# check pre-detangle assembly
grep utig4-693 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/assembly.paths.tsv
# > sire_compressed.k31.hapmer_from_utig4-972	utig4-966+,utig4-972+,utig4-1715+,utig4-1716+,utig4-1735+,utig4-694-,[N195892N:tangle],utig4-693+	SIRE_COMPRESSED.K31.HAPMER
# Notes: utig4-693 (sire_365) is a simple addition, already was in the old path before detanling and was accidentally cleaved off


# old path:
# > utig4-667-,utig4-663-,utig4-664+,utig4-1520-,utig4-1325-,utig4-1323+,utig4-1327+,utig4-1978+,utig4-1422-,utig4-1420-,utig4-1184-,utig4-1180-,utig4-1182+,utig4-1614-,utig4-1569-,utig4-1568+,utig4-716-,utig4-714+,utig4-717+,utig4-1123-,utig4-971-,utig4-966+,[N5000N:ambig_path],utig4-972+,utig4-1715+,utig4-1716+,utig4-1735+,utig4-694-,utig4-691-,utig4-692+,utig4-691-			
# new path (added utig4-693):		
# > utig4-667-,utig4-663-,utig4-664+,utig4-1520-,utig4-1325-,utig4-1323+,utig4-1327+,utig4-1978+,utig4-1422-,utig4-1420-,utig4-1184-,utig4-1180-,utig4-1182+,utig4-1614-,utig4-1569-,utig4-1568+,utig4-716-,utig4-714+,utig4-717+,utig4-1123-,utig4-971-,utig4-966+,[N5000N:ambig_path],utig4-972+,utig4-1715+,utig4-1716+,utig4-1735+,utig4-694-,utig4-691-,utig4-692+,utig4-691-,utig4-693+			
# new path -> proper formatting:
# > <utig4-667<utig4-663>utig4-664<utig4-1520<utig4-1325>utig4-1323>utig4-1327>utig4-1978<utig4-1422<utig4-1420<utig4-1184<utig4-1180>utig4-1182<utig4-1614<utig4-1569>utig4-1568<utig4-716>utig4-714>utig4-717<utig4-1123<utig4-971>utig4-966[N5000N:ambig_path]>utig4-972>utig4-1715>utig4-1716>utig4-1735<utig4-694<utig4-691>utig4-692<utig4-691>utig4-693

			
# 2. Fix path for chr17_H
# -----------------------------------------------------------------------------------------#	

# determine path associted with chr17_H in the HiC assembly
grep haplotype1-0000014 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_hic/assembly.scfmap 
# > path haplotype1-0000014 haplotype1_from_utig4-558
			
# grab HiC utig4 path
grep haplotype1_from_utig4-558 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_hic/assembly.paths.tsv
# > haplotype1_from_utig4-558	utig4-263-,utig4-264+,utig4-1815-,utig4-1753-,utig4-1751-,utig4-1187-,utig4-1185+,utig4-1188+,utig4-1760+,utig4-930-,utig4-928+,utig4-932+,utig4-1419-,utig4-561-,utig4-557-,utig4-558+,utig4-1248-,utig4-649-,utig4-647+,utig4-651+,utig4-1635+,utig4-1155-,utig4-1153+	HAPLOTYPE1
			
# compare with trio utig4 path
grep utig4-1153 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > dam_compressed.k31.hapmer_from_utig4-559	>utig4-325<utig4-1815<utig4-1752<utig4-1751<utig4-1187>utig4-1185>utig4-1189>utig4-1760<utig4-929>utig4-928>utig4-931<utig4-1419<utig4-560<utig4-557>utig4-559<utig4-1248<utig4-648>utig4-647>utig4-650>utig4-1635<utig4-1154>utig4-1153	DAM_COMPRESSED.K31.HAPMER
# > sire_compressed.k31.hapmer_from_utig4-558	<utig4-1419<utig4-561<utig4-557>utig4-558<utig4-1248<utig4-649>utig4-647>utig4-651>utig4-1635<utig4-1155>utig4-1153	SIRE_COMPRESSED.K31.HAPMER
# here we only care about sire, not the dam - and we can see that the trio contig only runs from 1419 to 1153;
# whereas, the hic contig, ran from 263 to 1153!

# find where the next used utig is after 1419 in the sire assembly
grep utig4-932 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
grep utig4-928 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
grep utig4-930 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
grep utig4-1760 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
grep utig4-1188 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > sire_compressed.k31.hapmer_from_utig4-264	>utig4-264<utig4-1815<utig4-1753<utig4-1751<utig4-1186>utig4-1185>utig4-1188	SIRE_COMPRESSED.K31.HAPMER
# Note: utig4-1760+,utig4-930-,utig4-928+,utig4-932 are unused in the trio (used in the hi-c)
# So, there are two contigs here for chr17_H that can be tied together by those 4 contigs.
# However, sire_compressed.k31.hapmer_from_utig4-264 starts at utig4-264 and not utig4-263 like the HiC!

# lets confirm that we can use the path utig4-1760+,utig4-930-,utig4-928+,utig4-932 to tie together these contigs:
# are the alternatives to the heterozygous regions used in the dam already (1760 and 928 are homozygous)?
grep utig4-929 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > dam_compressed.k31.hapmer_from_utig4-559	>utig4-325<utig4-1815<utig4-1752<utig4-1751<utig4-1187>utig4-1185>utig4-1189>utig4-1760<utig4-929>utig4-928>utig4-931<utig4-1419<utig4-560<utig4-557>utig4-559<utig4-1248<utig4-648>utig4-647>utig4-650>utig4-1635<utig4-1154>utig4-1153	DAM_COMPRESSED.K31.HAPMER
# YES! They are used, which means we can grab the same path from the Hi-C and insert here to tie together contisg.
# However, sire_compressed.k31.hapmer_from_utig4-264 starts at utig4-264 and not utig4-263 like the HiC!

# lets find utig4-263
grep utig4-263 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > utig4-263 is used in a different contig (sire_compressed.k31.hapmer_from_utig4-622) in the trio assembly! 
# where is sire_compressed.k31.hapmer_from_utig4-622 and utig4-263 in the hi-c assembly?
grep utig4-263 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_hic/assembly.paths.tsv
grep haplotype2_from_utig4-622 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_hic/assembly.scfmap 
# its connected to chr1_YL as well as chr17_H

# Notes: chr17_H needs utigs to connect contigs sire_compressed.k31.hapmer_from_utig4-558 and sire_compressed.k31.hapmer_from_utig4-264
# Notes: also need to consider adding utig4-263 to the end. CENP-A signal is found on sire_311, 
# and thats without including the entire telomere (utig4-263) which the hic assembly uses for both chr1_YL and chr17_H

# sire_311 has CENP-A signal and is last unplaced for paternal assembly - explore
grep sire_compressed.k31.hapmer-0000311 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.scfmap
# > path sire_compressed.k31.hapmer-0000311 sire_compressed.k31.hapmer_from_utig4-264
grep sire_compressed.k31.hapmer_from_utig4-264 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > sire_compressed.k31.hapmer_from_utig4-264	>utig4-264<utig4-1815<utig4-1753<utig4-1751<utig4-1186>utig4-1185>utig4-1188	SIRE_COMPRESSED.K31.HAPMER

############################################################################################################
# Question: Do we need to add utig4-263 to sire_311 (sire_compressed.k31.hapmer_from_utig4-264 aka chr17_H)?
# Hi-C says to use 263 for both chr1_YL and chr17_H, are we okay with this?
############################################################################################################

# The trio already has 263 for chr1_YL
grep utig4-263 /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/assembly.paths.tsv
# > sire_compressed.k31.hapmer_from_utig4-622	<utig4-1668<utig4-1374>utig4-1373>utig4-1375<utig4-1618<utig4-1467<utig4-1463>utig4-1465<utig4-1658>utig4-1659<utig4-1863<utig4-1179<utig4-1177<utig4-620>utig4-619>utig4-622>utig4-1724<utig4-250<utig4-247>utig4-248<utig4-604>utig4-605>utig4-1070>utig4-1072<utig4-1367<utig4-1041>utig4-1040<utig4-477>utig4-476>utig4-479<utig4-1365<utig4-962>utig4-961>utig4-964>utig4-1506<utig4-421>utig4-420>utig4-424>utig4-1580>utig4-1582>utig4-1754<utig4-690>utig4-688<utig4-452>utig4-451>utig4-455>utig4-534>utig4-536<utig4-1983<utig4-233>utig4-232>utig4-236>utig4-1701<utig4-1131>utig4-1130>utig4-1134<utig4-1741<utig4-1194>utig4-1193<utig4-844>utig4-842>utig4-846>utig4-1808<utig4-777<utig4-774>utig4-775<utig4-1592<utig4-1257>utig4-1255<utig4-1128<utig4-1125>utig4-1127<utig4-1664<utig4-1014<utig4-1011>utig4-1012<utig4-1468<utig4-356>utig4-354>utig4-357>utig4-1755<utig4-807<utig4-803>utig4-804>utig4-915<utig4-24<utig4-20>utig4-21>utig4-1510<utig4-1218<utig4-1216<utig4-1045>utig4-1043>utig4-1047<utig4-1565>utig4-1566<utig4-1634<utig4-166<utig4-163>utig4-164>utig4-1714<utig4-1425<utig4-1423<utig4-265>utig4-263	SIRE_COMPRESSED.K31.HAPMER

# for the time being, I am going to add utig4-263 to sire_311 and connect to chr17_H.
# NEED TO CHECK IN WITH BEN AND WEN ON THIS



# 3. Relaunch verkko w/ fixed paths
# -----------------------------------------------------------------------------------------#	
# Final chr14_H reformatted path:
# > sire_compressed.k31.hapmer_from_utig4-972 <utig4-667<utig4-663>utig4-664<utig4-1520<utig4-1325>utig4-1323>utig4-1327>utig4-1978<utig4-1422<utig4-1420<utig4-1184<utig4-1180>utig4-1182<utig4-1614<utig4-1569>utig4-1568<utig4-716>utig4-714>utig4-717<utig4-1123<utig4-971>utig4-966[N5000N:ambig_path]>utig4-972>utig4-1715>utig4-1716>utig4-1735<utig4-694<utig4-691>utig4-692<utig4-691>utig4-693

# Final chr17_H reformatted path:
# > new contig combining (sire_compressed.k31.hapmer_from_utig4-558 and sire_compressed.k31.hapmer_from_utig4-264) <utig4-263>utig4-264<utig4-1815<utig4-1753<utig4-1751<utig4-1187>utig4-1185>utig4-1188>utig4-1760<utig4-930>utig4-928>utig4-932<utig4-1419<utig4-561<utig4-557>utig4-558<utig4-1248<utig4-649>utig4-647>utig4-651>utig4-1635<utig4-1155>utig4-1153

# Set up relaunch folder
cd /90daydata/ruminant_t2t/Pig/assembly
mkdir verkko2.2_fixChr14-17 && cd verkko2.2_fixChr14-17

# set up environment
salloc -p priority -q agil -c 96 --mem-per-cpu=3968 --time=4-00:00:00 --account=cattle_genome_assemblies
micromamba activate verkko-v2.2

# copy in align + patch gaf files
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-alignments.gaf ./
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/patch.gaf ./
cat patch.gaf >> combined-alignments.gaf

# copy in edges and paatch gfa files
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-edges.gfa ./
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/patch.gfa ./
cat patch.gfa | grep '^L' |grep gap >> combined-edges.gfa

# get nodemap and nodelens, append patch.gfa
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-nodemap.txt
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/nodelens.txt ./
cat patch.gfa | grep gap | awk 'BEGIN { FS="[ \t]+"; OFS="\t"; } ($1 == "S") && ($3 != "*") { print $2, length($3); }' >> nodelens.txt

# copy in consensus ONT reads, as well as full patch sequences (treated as ONT reads)
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/7-consensus/ont_subset.fasta.gz ./
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/*fullpatch.fa ./
cat chr8.hap1.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr8.hap2.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr10.hap1.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr10.hap2.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id

# copy in final manual.paths file
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/new.paths.gaf ./

# fix paths file for chr14 and chr17
https://github.com/LeeAckersonIV/genome-asm/blob/main/helper-scripts/addPatch.pl
chmod +x addPatch.pl

echo -e "sire_compressed.k31.hapmer_from_utig4-972\t<utig4-667<utig4-663>utig4-664<utig4-1520<utig4-1325>utig4-1323>utig4-1327>utig4-1978<utig4-1422<utig4-1420<utig4-1184<utig4-1180>utig4-1182<utig4-1614<utig4-1569>utig4-1568<utig4-716>utig4-714>utig4-717<utig4-1123<utig4-971>utig4-966[N5000N:ambig_path]>utig4-972>utig4-1715>utig4-1716>utig4-1735<utig4-694<utig4-691>utig4-692<utig4-691>utig4-693" >> chr14-17_newPaths.tsv
echo -e "sire_compressed.k31.hapmer_from_utig4-558;sire_compressed.k31.hapmer_from_utig4-264\t<utig4-263>utig4-264<utig4-1815<utig4-1753<utig4-1751<utig4-1187>utig4-1185>utig4-1188>utig4-1760<utig4-930>utig4-928>utig4-932<utig4-1419<utig4-561<utig4-557>utig4-558<utig4-1248<utig4-649>utig4-647>utig4-651>utig4-1635<utig4-1155>utig4-1153" >> chr14-17_newPaths.tsv

module load perl
perl addPatch.pl --gaf new.paths.gaf --patch chr14-17_newPaths.tsv > new14-17.paths.gaf 

# generate layout and scfmap with new paths using get_layout_from_mbg.py
/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2/lib/verkko/scripts/get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf new14-17.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap

# Set up verkko_final_asm folder
mkdir verkko_final_asm && cd verkko_final_asm

# link in dirs 1-5 of tangled assembly
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/1-buildGraph/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/2-processGraph/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/3-align
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/3-alignTips/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/4-processONT/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/5-untip/

# make new 6-layoutContigs folder, link in necessary files (make sure to include output from get_layout_from_mbg.py)
mkdir 6-layoutContigs && cd 6-layoutContigs
ln -s ../../combined-nodemap.txt
ln -s ../../combined-edges.gfa
ln -s ../../combined-alignments.gaf
ln -s ../../nodelens.txt
ln -s ../../unitig-popped.layout.scfmap
ln -s ../../unitig-popped.layout

# make new 6-rukki folder, link in necessary files (make sure to include label1 & label2 if phasing information supplied)
cd ..
mkdir 6-rukki && cd 6-rukki
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv
ln -s ../../new14-17.paths.gaf  unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf
ln -s ../../new14-17.paths.gaf  unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/label1
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/label2

# make new 7-consensus folder, link in necessary files
cd ../
mkdir 7-consensus && cd 7-consensus
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
# ------------------------

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
sbatch --parsable --cpus-per-task=2 --mem 50g --account=cattle_genome_assemblies --time=6-00:00:00 --output verkko_final_asm.out launch_verkko_final_asm.sh

# ./launch_verkko_final_asm.sh
# ----------------------------
#!/bin/bash -l
micromamba activate verkko-v2.2
verkko --version
verkko --slurm -d verkko_final_asm --unitig-abundance 4 --red-run 8 40 8 --hifi hifi-duplex/*.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq.gz --screen pig_MT Pig_MT.fasta --screen pig_rDNA pig_rDNA.fasta --hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio
	# -----------------------------

# confirm new T2T statistics 
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17/verkko_final_asm
/project/cattle_genome_assemblies/packages/verkkoPostASMScripts/getT2T.sh assembly.fasta

/project/cattle_genome_assemblies/packages/verkkoPostASMScripts/getChrNames.sh /90daydata/ruminant_t2t/Pig/assembly/orient/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa

mkdir reorient && cd reorient
wget ftp://ftp.ensembl.org/pub/release-110/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
gunzip Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
sbatch launch_mummer.chr.orient.sb

# < launch_mummer.chr.orient.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=3:00:00             
#SBATCH --cpus-per-task=164
#SBATCH --mem-per-cpu=8G   
#SBATCH --job-name chr.orient
#SBATCH --output=mummer_%j.out
#SBATCH --error=mummer_%j.err     
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17/verkko_final_asm/reorient/
#SBATCH --account=cattle_genome_assemblies

date

module load mummer/4.0.0rc1

nucmer -l 100 -c 500 -p ref_vs_asm Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa ../assembly.fasta

delta-filter -i 90 -l 100000 ref_vs_asm.delta > ref_vs_asm.filtered.delta

mummerplot --png --large -p ref_vs_asm ref_vs_asm.filtered.delta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

######################################################
# THERE IS AN ISSUE WITH LOSING CHROMSOME, REDO STEP 3
######################################################

# Set up relaunch folder
cd /90daydata/ruminant_t2t/Pig/assembly
mkdir verkko2.2_fixChr14-17.v2 && cd verkko2.2_fixChr14-17.v2

# set up environment
salloc -p priority -q agil -c 96 --mem-per-cpu=3968 --time=4-00:00:00 --account=cattle_genome_assemblies
micromamba activate verkko-v2.2

# copy in align + patch gaf files
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-alignments.gaf ./
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/patch.gaf ./
cat patch.gaf >> combined-alignments.gaf

# copy in edges and paatch gfa files
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-edges.gfa ./
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/patch.gfa ./
cat patch.gfa | grep '^L' |grep gap >> combined-edges.gfa

# get nodemap and nodelens, append patch.gfa
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/combined-nodemap.txt
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-layoutContigs/nodelens.txt ./
cat patch.gfa | grep gap | awk 'BEGIN { FS="[ \t]+"; OFS="\t"; } ($1 == "S") && ($3 != "*") { print $2, length($3); }' >> nodelens.txt

# copy in consensus ONT reads, as well as full patch sequences (treated as ONT reads)
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/7-consensus/ont_subset.fasta.gz ./
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/*fullpatch.fa ./
cat chr8.hap1.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr8.hap2.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr10.hap1.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
cat chr10.hap2.fullpatch.fa | gzip -c >> ont_subset.fasta.gz
seqtk gc ont_subset.fasta.gz |awk '{print $1}'|sort |uniq > ont_subset.id

# copy in final manual.paths file
cp /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf ./original.paths.gaf

# fix paths file for chr14 and chr17
# I downloaded CollatedPatches file from my google-drive
# scp HxYL-collated-patches14.17.tsv lee.ackerson@ceres.scinet.usda.gov:/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2module load perl
module load perl
perl ~/scripts/addPatch.pl --gaf original.paths.gaf --patch HxYL-collated-patches14.17.tsv > manual.paths.gaf

# generate layout and scfmap with new paths using get_layout_from_mbg.py
/project/cattle_genome_assemblies/packages/micromamba/envs/verkko-v2.2/lib/verkko/scripts/get_layout_from_mbg.py combined-nodemap.txt combined-edges.gfa combined-alignments.gaf manual.paths.gaf nodelens.txt unitig-popped.layout unitig-popped.layout.scfmap

# Set up verkko_final_asm folder
mkdir verkko_final_asm && cd verkko_final_asm

# link in dirs 1-5 of tangled assembly
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/1-buildGraph/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/2-processGraph/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/3-align
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/3-alignTips/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/4-processONT/
ln -s  /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/5-untip/

# make new 6-layoutContigs folder, link in necessary files (make sure to include output from get_layout_from_mbg.py)
mkdir 6-layoutContigs && cd 6-layoutContigs
ln -s ../../combined-nodemap.txt
ln -s ../../combined-edges.gfa
ln -s ../../combined-alignments.gaf
ln -s ../../nodelens.txt
ln -s ../../unitig-popped.layout.scfmap
ln -s ../../unitig-popped.layout

# make new 6-rukki folder, link in necessary files (make sure to include label1 & label2 if phasing information supplied)
cd ..
mkdir 6-rukki && cd 6-rukki
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.noseq.gfa
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.colors.csv
ln -s ../../manual.paths.gaf  unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf
ln -s ../../manual.paths.gaf  unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.tsv
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/label1
ln -s /project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/6-rukki/label2

# make new 7-consensus folder, link in necessary files
cd ../
mkdir 7-consensus && cd 7-consensus
ln -s ../../ont_subset.id
ln -s ../../ont_subset.fasta.gz

# link in input data to parent directory for launching verkkko (sequencc reads, reference fastas, etc.)
cd ../../
ln -s /project/ruminant_t2t/Pig/assembly/hifi-duplex
ln -s /project/ruminant_t2t/Pig/assembly/oxnan_data
ln -s /project/ruminant_t2t/existing_NCBI_references/Pig/Pig_MT.fasta
ln -s /project/ruminant_t2t/Pig/assembly/verkko1.4.1_hifi_trio/pig_rDNA.fasta
ln -s /project/ruminant_t2t/Pig/illumina_data

# sanity check before launch
while read -r line; do
    if grep -q "$line" manual.paths.gaf; then
        echo -e "$line\tFOUND"
    else
        echo -e "$line\tNOT FOUND"
    fi
done < from_utigs.includePath.sanityCheck.lst

# < from_utigs.includePath.sanityCheck.lst > 
dam_compressed.k31.hapmer_from_utig4-1124
dam_compressed.k31.hapmer_from_utig4-1148
dam_compressed.k31.hapmer_from_utig4-1288
dam_compressed.k31.hapmer_from_utig4-1358
dam_compressed.k31.hapmer_from_utig4-1449
dam_compressed.k31.hapmer_from_utig4-1473
dam_compressed.k31.hapmer_from_utig4-1479
dam_compressed.k31.hapmer_from_utig4-1647
dam_compressed.k31.hapmer_from_utig4-1672
dam_compressed.k31.hapmer_from_utig4-174
dam_compressed.k31.hapmer_from_utig4-1795
dam_compressed.k31.hapmer_from_utig4-388
dam_compressed.k31.hapmer_from_utig4-559
dam_compressed.k31.hapmer_from_utig4-573
dam_compressed.k31.hapmer_from_utig4-623
dam_compressed.k31.hapmer_from_utig4-726
dam_compressed.k31.hapmer_from_utig4-912
sire_compressed.k31.hapmer_from_utig4-1149
sire_compressed.k31.hapmer_from_utig4-1287
sire_compressed.k31.hapmer_from_utig4-13
sire_compressed.k31.hapmer_from_utig4-1359
sire_compressed.k31.hapmer_from_utig4-1448
sire_compressed.k31.hapmer_from_utig4-1474
sire_compressed.k31.hapmer_from_utig4-1646
sire_compressed.k31.hapmer_from_utig4-1671
sire_compressed.k31.hapmer_from_utig4-1696
sire_compressed.k31.hapmer_from_utig4-175
sire_compressed.k31.hapmer_from_utig4-389
sire_compressed.k31.hapmer_from_utig4-572
sire_compressed.k31.hapmer_from_utig4-622
sire_compressed.k31.hapmer_from_utig4-725
sire_compressed.k31.hapmer_from_utig4-911
dam_compressed.k31.hapmer_from_utig4-1277
dam_compressed.k31.hapmer_from_utig4-1370
sire_compressed.k31.hapmer_from_utig4-1276
sire_compressed.k31.hapmer_from_utig4-1369
sire_compressed.k31.hapmer_from_utig4-972
sire_compressed.k31.hapmer_from_utig4-558

# Rerun Verkko w/ patches
# ------------------------

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
sbatch --parsable --cpus-per-task=2 --mem 50g --account=cattle_genome_assemblies --time=6-00:00:00 --output verkko_final_asm.out launch_verkko_final_asm.sh

# ./launch_verkko_final_asm.sh
# ----------------------------
#!/bin/bash -l
micromamba activate verkko-v2.2
verkko --version
verkko --slurm -d verkko_final_asm --unitig-abundance 4 --red-run 8 40 8 --hifi hifi-duplex/*.fastq.gz --nano oxnan_data/*q12-10-7-5*.fastq.gz --screen pig_MT Pig_MT.fasta --screen pig_rDNA pig_rDNA.fasta --hap-kmers illumina_data/hapmers_compressed_force_sire_gt6/dam_compressed.k31.hapmer.meryl illumina_data/hapmers_compressed_force_sire_gt6/sire_compressed.k31.hapmer.meryl trio
# -----------------------------

# confirm new T2T statistics 
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm
/project/cattle_genome_assemblies/packages/verkkoPostASMScripts/getT2T.sh assembly.fasta
while read -r line; do
    grep "$line" assembly.scfmap | awk '{print $3}'
done < assembly.t2t_scfs > utig.paths.scfs

/project/cattle_genome_assemblies/packages/verkkoPostASMScripts/getChrNames.sh /90daydata/ruminant_t2t/Pig/assembly/orient/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa
sort -k2,2 -V translation_hap1 > translation_hap1.sorted
sort -k2,2 -V translation_hap2 > translation_hap2.sorted



mkdir reorient && cd reorient
wget ftp://ftp.ensembl.org/pub/release-110/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
gunzip Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
sbatch launch_mummer.chr.orient.sb

# < launch_mummer.chr.orient.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=3:00:00             
#SBATCH --cpus-per-task=164
#SBATCH --mem-per-cpu=8G   
#SBATCH --job-name chr.orient
#SBATCH --output=mummer_%j.out
#SBATCH --error=mummer_%j.err     
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/reorient/
#SBATCH --account=cattle_genome_assemblies

date

module load mummer/4.0.0rc1

nucmer -l 100 -c 500 -p ref_vs_asm Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa ../assembly.fasta

delta-filter -i 90 -l 100000 ref_vs_asm.delta > ref_vs_asm.filtered.delta

mummerplot --png --large -p ref_vs_asm ref_vs_asm.filtered.delta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# 4. Clean-up assembly: run RepeatMasker and remove mtDNA, rDNA, and misc small repeats.
# -----------------------------------------------------------------------------------------#	

# MT contigs (evaluate verkko MT output)
# --------------------------------------
# check verkko screened contigs
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm
grep '^>' assembly.pig_MT.fasta
# > dam_compressed.k31.hapmer-0000028
# > dam_compressed.k31.hapmer-0000030
# > dam_compressed.k31.hapmer-0000031
# > dam_compressed.k31.hapmer-0000032
# > dam_compressed.k31.hapmer-0000033
# > dam_compressed.k31.hapmer-0000034
# > dam_compressed.k31.hapmer-0000035

# none exist in the current assembly
grep '^>' assembly.pig_MT.fasta | sed 's/^>//' | while read -r line; do
  if grep -q "$line" assembly.fasta.fai; then
    echo "FOUND"
  else
    echo "NOT FOUND"
  fi
done

# will need to add assembly.pig_MT.exemplar.fasta back to the assembly
grep '^>' assembly.pig_MT.exemplar.fasta 
# >dam_compressed.k31.hapmer-0000032
grep dam_compressed.k31.hapmer-0000032 assembly.fasta.fai 
# MISSING from assembly



# rDNA contigs (run RepeatMasker)
# --------------------------------------
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm
mkdir RepeatMasker && cd RepeatMasker

ln -s ../assembly.haplotype1.fasta
ln -s ../assembly.haplotype2.fasta

sbatch repeatmasker_hap1.sh
sbatch repeatmasker_hap2.sh

# repeatmasker_hap1.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash
#SBATCH --job-name=RMhap1
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --qos=memlimit
#SBATCH --mem-per-cpu=3968
#SBATCH --time=4-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/RepeatMasker
#SBATCH --output=RM_hap1__%j.std
#SBATCH --error=RM_hap1__%j.err
#SBATCH --account=cattle_genome_assemblies

date

module load repeatmasker/4.1.0

RepeatMasker -species "pig" -libdir /project/cattle_genome_assemblies/config_files_scripts/RepeatMasker_4.0.6_lib -no_is -pa 96 -gff -s -dir RM_hap1 assembly.haplotype1.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# repeatmasker_hap2.sh
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash
#SBATCH --job-name=RMhap2
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --qos=memlimit
#SBATCH --mem-per-cpu=3968
#SBATCH --time=4-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/RepeatMasker
#SBATCH --output=RM_hap2__%j.std
#SBATCH --error=RM_hap2__%j.err
#SBATCH --account=cattle_genome_assemblies

date

module load repeatmasker/4.1.0

RepeatMasker -species "pig" -libdir /project/cattle_genome_assemblies/config_files_scripts/RepeatMasker_4.0.6_lib -no_is -pa 96 -gff -s -dir RM_hap2 assembly.haplotype2.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# checkout rDNA annotations from RepeatMasker
# cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/RepeatMasker
cd RM_Hap1
grep rRNA assembly.haplotype1.fasta.out > assembly.haplotype1.fasta.out.rRNA 
awk ' { if ($10=="LSU-rRNA_Hsa" && $2<9) {print $0} else if ($10=="SSU-rRNA_Hsa" && $2<1) {print $0}} ' assembly.haplotype1.fasta.out.rRNA > assembly.haplotype1.fasta.out.rRNA.filtered
cd ../RM_Hap2 
grep rRNA assembly.haplotype2.fasta.out > assembly.haplotype2.fasta.out.rRNA
awk ' { if ($10=="LSU-rRNA_Hsa" && $2<9) {print $0} else if ($10=="SSU-rRNA_Hsa" && $2<1) {print $0}} ' assembly.haplotype2.fasta.out.rRNA > assembly.haplotype2.fasta.out.rRNA.filtered
# after .filtered is made; need to manually remove contigs which only have LSU and no SSU
# hap1 contigs to keep:
dam_compressed.k31.hapmer-0000007
dam_compressed.k31.hapmer-0000013
dam_compressed.k31.hapmer-0000050
dam_compressed.k31.hapmer-0000199

grep -e 'dam_compressed.k31.hapmer-0000007' -e 'dam_compressed.k31.hapmer-0000013' -e 'dam_compressed.k31.hapmer-0000050' -e 'dam_compressed.k31.hapmer-0000199' assembly.haplotype1.fasta.out.rRNA.filtered > assembly.haplotype1.fasta.out.rRNA.filtered.manual


# hap2 contigs to keep:
sire_compressed.k31.hapmer-0000298
sire_compressed.k31.hapmer-0000300 
sire_compressed.k31.hapmer-0000303

grep -e 'sire_compressed.k31.hapmer-0000298' -e 'sire_compressed.k31.hapmer-0000300' -e 'sire_compressed.k31.hapmer-0000303' assembly.haplotype2.fasta.out.rRNA.filtered > assembly.haplotype2.fasta.out.rRNA.filtered.manual

# which rDNA annotations dont have chr annotations?
# hap1 {filtered rDNA annotations to SSU and LSU}
# less RM_hap1/assembly.haplotype1.fasta.out.rRNA.filtered.manual
dam_compressed.k31.hapmer-0000007	chr8_YL
dam_compressed.k31.hapmer-0000013	chr10_YL
dam_compressed.k31.hapmer-0000050	NO_CHR
dam_compressed.k31.hapmer-0000199	NO_CHR

# hap1 {unfiltered; including 5S rDNA annotations, etc.}
# awk '{print $5}' RM_hap1/assembly.haplotype1.fasta.out.rRNA | sort | uniq | less
dam_compressed.k31.hapmer-0000001	chr14_YL
dam_compressed.k31.hapmer-0000002	chr7_YL
dam_compressed.k31.hapmer-0000003	chr16_YL
dam_compressed.k31.hapmer-0000004	chr2_YL
dam_compressed.k31.hapmer-0000005	chr12_YL
dam_compressed.k31.hapmer-0000006	chr15_YL
dam_compressed.k31.hapmer-0000007	chr8_YL
dam_compressed.k31.hapmer-0000008	chr11_YL
dam_compressed.k31.hapmer-0000009	chrX_YL
dam_compressed.k31.hapmer-0000010	chr18_YL
dam_compressed.k31.hapmer-0000011	chr13_YL
dam_compressed.k31.hapmer-0000012	chr9_YL
dam_compressed.k31.hapmer-0000013	chr10_YL
dam_compressed.k31.hapmer-0000014	chr6_YL
dam_compressed.k31.hapmer-0000015	chr17_YL
dam_compressed.k31.hapmer-0000016	chr4_YL
dam_compressed.k31.hapmer-0000017	chr1_YL
dam_compressed.k31.hapmer-0000018	chr5_YL
dam_compressed.k31.hapmer-0000019	chr3_YL
dam_compressed.k31.hapmer-0000020	NO_CHR
dam_compressed.k31.hapmer-0000050	NO_CHR
dam_compressed.k31.hapmer-0000180	NO_CHR
dam_compressed.k31.hapmer-0000198	NO_CHR
dam_compressed.k31.hapmer-0000199	NO_CHR


# hap2 {filtered rDNA annotations to SSU and LSU}
# less RM_hap2/assembly.haplotype2.fasta.out.rRNA.filtered.manual
sire_compressed.k31.hapmer-0000298	chr16_H
sire_compressed.k31.hapmer-0000300	chr10_H
sire_compressed.k31.hapmer-0000303	chr8_H

# hap2 {unfiltered; including 5S rDNA annotations, etc.}
# awk '{print $5}' RM_hap2/assembly.haplotype2.fasta.out.rRNA | sort | uniq | less 
sire_compressed.k31.hapmer-0000297	chr7_H
sire_compressed.k31.hapmer-0000298	chr16_H
sire_compressed.k31.hapmer-0000299	chr2_H
sire_compressed.k31.hapmer-0000300	chr10_H
sire_compressed.k31.hapmer-0000301	chr12_H
sire_compressed.k31.hapmer-0000302	chr15_H
sire_compressed.k31.hapmer-0000303	chr8_H
sire_compressed.k31.hapmer-0000304	chr11_H
sire_compressed.k31.hapmer-0000305	chr18_H
sire_compressed.k31.hapmer-0000306	chr13_H
sire_compressed.k31.hapmer-0000307	chrY_H
sire_compressed.k31.hapmer-0000308	chr9_H
sire_compressed.k31.hapmer-0000309	chr6_H
sire_compressed.k31.hapmer-0000310	chr17_H
sire_compressed.k31.hapmer-0000311	chr4_H
sire_compressed.k31.hapmer-0000312	chr1_H
sire_compressed.k31.hapmer-0000313	chr5_H
sire_compressed.k31.hapmer-0000314	chr3_H
sire_compressed.k31.hapmer-0000315	chr14_H

# there are no sire contigs with residual non chromosomal annotations

# here are the hapmers with rDNA annotation but no CHR assignement
dam_compressed.k31.hapmer-0000050
dam_compressed.k31.hapmer-0000199
dam_compressed.k31.hapmer-0000020
dam_compressed.k31.hapmer-0000180
dam_compressed.k31.hapmer-0000198

# lets check to see if any of the hapmers without chromosomal annotations are still in the assembly
while read -r line; do
  if grep -q "$line" ../../assembly.fasta; then
    echo "FOUND: $line"
  else
    echo "NOT FOUND: $line"
  fi
done < rDNA-noCHR-hapmers-RM_hap1.list
# all 5 of the hapmers are currently found in the assembly
# need to decide which ones to keep and which ones to not!

# check lengths of the contigs in the assembly
grep dam_compressed.k31.hapmer-0000050 assembly.fasta.fai 
grep dam_compressed.k31.hapmer-0000199 assembly.fasta.fai 
grep dam_compressed.k31.hapmer-0000020 assembly.fasta.fai 
grep dam_compressed.k31.hapmer-0000180 assembly.fasta.fai 
grep dam_compressed.k31.hapmer-0000198 assembly.fasta.fai 
# > dam_compressed.k31.hapmer-0000050	126994	2615115680	126994	126995
# > dam_compressed.k31.hapmer-0000199	259298	2617036615	259298	259299
# > dam_compressed.k31.hapmer-0000020	4662002	2605559701	4662002	4662003
# > dam_compressed.k31.hapmer-0000180	167612	2616143370	167612	167613
# > dam_compressed.k31.hapmer-0000198	176978	2616859601	176978	176979

# check utig conversions
grep dam_compressed.k31.hapmer-0000050 assembly.scfmap 
grep dam_compressed.k31.hapmer-0000199 assembly.scfmap
grep dam_compressed.k31.hapmer-0000020 assembly.scfmap
grep dam_compressed.k31.hapmer-0000180 assembly.scfmap
grep dam_compressed.k31.hapmer-0000198 assembly.scfmap
# > path dam_compressed.k31.hapmer-0000050 dam_compressed.k31.hapmer_unused_utig4-1784
# > path dam_compressed.k31.hapmer-0000199 dam_compressed.k31.hapmer_unused_utig4-746
# > path dam_compressed.k31.hapmer-0000020 dam_compressed.k31.hapmer_from_utig4-971
# > path dam_compressed.k31.hapmer-0000180 dam_compressed.k31.hapmer_unused_utig4-344
# > path dam_compressed.k31.hapmer-0000198 dam_compressed.k31.hapmer_unused_utig4-729
grep dam_compressed.k31.hapmer_unused_utig4-1784 assembly.paths.tsv 
grep dam_compressed.k31.hapmer_unused_utig4-746 assembly.paths.tsv
grep dam_compressed.k31.hapmer_from_utig4-971 assembly.paths.tsv
grep dam_compressed.k31.hapmer_unused_utig4-344 assembly.paths.tsv
grep dam_compressed.k31.hapmer_unused_utig4-729 assembly.paths.tsv
# > dam_compressed.k31.hapmer_unused_utig4-1784	>utig4-1784	DAM_COMPRESSED.K31.HAPMER
# > dam_compressed.k31.hapmer_unused_utig4-746	>utig4-746	DAM_COMPRESSED.K31.HAPMER
# > dam_compressed.k31.hapmer_from_utig4-971	>utig4-967<utig4-966>utig4-971	DAM_COMPRESSED.K31.HAPMER
# > dam_compressed.k31.hapmer_unused_utig4-344	>utig4-344	DAM_COMPRESSED.K31.HAPMER
# > dam_compressed.k31.hapmer_unused_utig4-729	>utig4-729	DAM_COMPRESSED.K31.HAPMER

# evaluate repeat masker output to see if the rDNA runs the length of the contig or not
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/RepeatMasker/RM_hap1
grep dam_compressed.k31.hapmer-0000050 assembly.haplotype1.fasta.out.rRNA | less
grep dam_compressed.k31.hapmer-0000199 assembly.haplotype1.fasta.out.rRNA | less
grep dam_compressed.k31.hapmer-0000020 assembly.haplotype1.fasta.out.rRNA | less
grep dam_compressed.k31.hapmer-0000180 assembly.haplotype1.fasta.out.rRNA | less
grep dam_compressed.k31.hapmer-0000198 assembly.haplotype1.fasta.out.rRNA | less

# decisions
dam_compressed.k31.hapmer-0000050 dam_compressed.k31.hapmer_unused_utig4-1784	>utig4-1784
# > unused node from the chr10 rDNA ball, only 126kb, half annotate - can delete
dam_compressed.k31.hapmer-0000199 dam_compressed.k31.hapmer_unused_utig4-746	>utig4-746
# > unused node from the chr8 rDNA ball, only 260kb, full annotate - can delete
dam_compressed.k31.hapmer-0000020 dam_compressed.k31.hapmer_from_utig4-971		>utig4-967<utig4-966>utig4-971
# > this is the breakpoint in the sire chr14, but had some dam annotations - can delete since these 4.5mb are used in sire already. Odd situation, but Ben agrees it is reasonable to remove.
dam_compressed.k31.hapmer-0000180 dam_compressed.k31.hapmer_unused_utig4-344	>utig4-344
# > unused node from the chr8 rDNA ball, only 167kb, full annotate - can delete
dam_compressed.k31.hapmer-0000198 dam_compressed.k31.hapmer_unused_utig4-729	>utig4-729
# > unused node from the chr8 rDNA ball, only 176kb, full annotate - can delete


# lets check out the verkko screen output (both haps) files too:
grep '^>' assembly.pig_rDNA.fasta | sed 's/^>//' | while read -r line; do
  if grep -q "$line" assembly.fasta.fai; then
     echo "FOUND: $line"
  else
     echo "NOT FOUND: $line"
  fi
done
# > NONE FOUND

# check the exemplar too 
grep '^>' assembly.pig_rDNA.exemplar.fasta | sed 's/^>//' | while read -r line; do
  if grep -q "$line" assembly.fasta.fai; then
     echo "FOUND: $line"
  else
     echo "NOT FOUND: $line"
  fi
done
# > NOT FOUND


# remove rDNA and mtDNA
# --------------------------------------
# no mtDNA needs to be removed
# rDNA contig contaminants to remove (contigs2rmv.txt)
dam_compressed.k31.hapmer-0000050
dam_compressed.k31.hapmer-0000199
dam_compressed.k31.hapmer-0000020
dam_compressed.k31.hapmer-0000180
dam_compressed.k31.hapmer-0000198

# remove rDNA 
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm
mkdir clean-rDNA && cd clean-rDNA
micromamba activate verkko-v2.2

# for combined assembly
samtools faidx ../assembly.fasta
comm -23 <(cut -f 1 ../assembly.fasta.fai | sort) <(sort contigs2rmv.txt) > retained-hapmers-matpat.lst
seqtk subseq ../assembly.fasta retained-hapmers-matpat.lst > assembly.cleaned.fasta
samtools faidx assembly.cleaned.fasta

# for maternal assembly
samtools faidx ../assembly.haplotype1.fasta
comm -23 <(cut -f 1 ../assembly.haplotype1.fasta.fai | sort) <(sort contigs2rmv.txt) > retained-hapmers-mat.lst
seqtk subseq ../assembly.haplotype1.fasta retained-hapmers-mat.lst > assembly.haplotype1.cleaned.fasta
samtools faidx assembly.haplotype1.cleaned.fasta

# no need for paternal assembly in this case (dam hapmer only).
cp ../assembly.haplotype2.fasta ./assembly.haplotype2.cleaned.fasta
samtools faidx assembly.haplotype2.cleaned.fasta


# 5. Add in mtDNA contig to assembly
# -----------------------------------------------------------------------------------------#	
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/clean-rDNA
micromamba activate verkko-v2.2

# exemplar needs to be reformatted so that the multiline file is the same as the standard assembly.fasta
seqtk seq -l0 ../assembly.pig_MT.exemplar.fasta > assembly.pig_MT.exemplar.reformatted.fasta

# add exemplar to the cleaned assembly and the maternal assembly
cat assembly.cleaned.fasta assembly.pig_MT.exemplar.reformatted.fasta > assembly.cleaned.plusMT.fasta
cat assembly.haplotype1.cleaned.fasta assembly.pig_MT.exemplar.reformatted.fasta > assembly.haplotype1.cleaned.plusMT.fasta
samtools faidx assembly.cleaned.plusMT.fasta
samtools faidx assembly.haplotype1.cleaned.plusMT.fasta

# Note: the three assemblies to use at this point are:
# 1. assembly.cleaned.plusMT.fasta
# 2. assembly.haplotype1.cleaned.plusMT.fasta
# 3. assembly.haplotype2.cleaned.fasta


# 6. Screen for contaminants: FCS-Adaptor 
# -----------------------------------------------------------------------------------------#	
# set up env
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/
mkdir FCS && cd FCS
micromamba activate verkko-v2.2
curl -LO https://github.com/ncbi/fcs/raw/main/dist/run_fcsadaptor.sh
chmod 755 run_fcsadaptor.sh
curl https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/releases/latest/fcs-adaptor.sif -Lo fcs-adaptor.sif
curl -LO https://github.com/ncbi/fcs/raw/main/dist/fcs.py
curl https://ftp.ncbi.nlm.nih.gov/genomes/TOOLS/FCS/releases/latest/fcs-gx.sif -Lo fcs-gx.sif
export FCS_DEFAULT_IMAGE=fcs-gx.sif

# FCS-adaptor requires the hapmer names to be shorter than verkko outputs
# make a file with old fasta header names and desired new ones (hapmerNamesTranslation.key):
# only need dam/sire - unassigned is already short enough
grep dam ../clean-rDNA/assembly.cleaned.plusMT.fasta.fai > hapmers.lst
grep sire ../clean-rDNA/assembly.cleaned.plusMT.fasta.fai >> hapmers.lst
python trimHapmerNames.py <(awk '{print $1}' hapmers.lst) hapmerNameTranslation.key

# trimHapmerNames.py
'''
import sys

def main():
    if len(sys.argv) != 3:
        print("Usage: python trimHapmerNames.py <input_file> <output_file>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]

    with open(input_file, "r") as infile, open(output_file, "w") as outfile:
        for line in infile:
            line = line.strip()
            if not line:
                continue

            prefix = line.split("_")[0]
            number = int(line.split("-")[-1])  # removes leading zeros
            label = f"{prefix}_{number}"

            outfile.write(f"{line}\t{label}\n")

if __name__ == "__main__":
    main()
'''

# run this script to generate new combined fasta with updated headers:
awk '
BEGIN {
    while ((getline < "hapmerNameTranslation.key") > 0) map[$1] = $2
}
/^>/ {
    name = substr($0, 2)
    if (name in map) {
        print ">" map[name]
    } else {
        print $0  # leave header unchanged if not in map
    }
    next
}
{ print }
' ../clean-rDNA/assembly.cleaned.plusMT.fasta > assembly.cleaned.plusMT.renamed.fasta

samtools faidx assembly.cleaned.plusMT.renamed.fasta

# run FCS-adaptor
sbatch runFCSadaptor.sh assembly.cleaned.plusMT.renamed.fasta
'''
#!/bin/bash
#SBATCH -o out_%j.out
#SBATCH -e err_%j.err
#SBATCH --cpus-per-task=30
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4096
#SBATCH --account=cattle_genome_assemblies

date

module load singularityCE/1.3.1

inputGenome=$1

pathToScript=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/FCS
pathToContainer=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/FCS

dir=`pwd`
outDir=${dir}/fcs-adaptor.HxYL
mkdir -p $outDir


${pathToScript}/run_fcsadaptor.sh \
 --fasta-input $inputGenome \
 --output-dir $outDir \
 --euk --container-engine singularity \
 --image ${pathToContainer}/fcs-adaptor.sif

date
'''

# output {fcs_adaptor_report.txt}
# -------------------------------
#accession      length  action  range   name
dam_15  70902474        ACTION_TRIM     1..33   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
dam_193 167851  ACTION_TRIM     167821..167851  CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
dam_1   164626715       ACTION_TRIM     1..32   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
dam_2   137246847       ACTION_TRIM     1..32   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
dam_38  172581  ACTION_TRIM     172551..172581  CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
dam_3   92097373        ACTION_TRIM     29654899..29654929      CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
sire_297        134536450       ACTION_TRIM     1..32   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
sire_349        265025  ACTION_TRIM     1..41   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000230      124768  ACTION_TRIM     124737..124768  CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000231      55786   ACTION_TRIM     55766..55786    CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000236      203576  ACTION_TRIM     1..31   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000253      252891  ACTION_TRIM     252857..252891  CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02001.1:Oxford Nanopore Technologies Ligation Adapter bottom (LA)
unassigned-0000258      60541   ACTION_TRIM     1..21   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000262      353771  ACTION_TRIM     1..32   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000286      126205  ACTION_TRIM     1..31   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
unassigned-0000288      147694  ACTION_TRIM     1..36   CONTAMINATION_SOURCE_TYPE_ADAPTOR:NGB02000.1:Oxford Nanopore Technologies Rapid Adapter (RA) Ligation Adapter top (LA) Native Adaptor top (NA) polyT masked
# -------------------------------
# Note: dam-3 is identical adaptor coordinates as past run, everything else is on the ends and cleaned already


# 7. Remove the adaptor found in the middle of contig dam_3	
# -----------------------------------------------------------------------------------------#	
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/
mkdir cleaned-assembly && cd cleaned-assembly

# grab the cleaned assembly, and move it to new working directory
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/FCS/fcs-adaptor.HxYL/cleaned_sequences/assembly.cleaned.plusMT.renamed.fasta .
samtools faidx assembly.cleaned.plusMT.renamed.fasta

# convert block line fasta to single line fasta
module load seqtk/1.3
seqtk seq -l0 assembly.cleaned.plusMT.renamed.fasta > assembly.cleaned.plusMT.renamed.oneline.fasta
samtools faidx assembly.cleaned.plusMT.renamed.oneline.fasta

# rename contigs to remove FCS-adaptor formatting
bash remove_lcl.sh assembly.cleaned.plusMT.renamed.oneline.fasta assembly.cleaned.plusMT.renamed.oneline.removeLCL.fasta
'''
#!/bin/bash
# Usage: bash remove_lcl.sh input.fasta output.fasta
input_file="$1"
output_file="$2"
sed 's/^>lcl|/>/' "$input_file" > "$output_file"
'''
samtools faidx assembly.cleaned.plusMT.renamed.oneline.removeLCL.fasta

# remove internal adaptor: 	dam_3	92097373	ACTION_TRIM	29654899..29654929
module load seqkit/2.4.0
	
# 1. extract the part before and after the adaptor
seqkit grep -n -p "dam_3" assembly.cleaned.plusMT.renamed.oneline.removeLCL.fasta | seqkit subseq -r 1:29654898 > part1_dam3.fasta
seqkit grep -n -p "dam_3" assembly.cleaned.plusMT.renamed.oneline.removeLCL.fasta | seqkit subseq -r 29654930:92097373 > part2_dam3.fasta

# 2. concatenate the two sequences into a new contig
echo ">dam_3" > dam3_modified.fasta
tail -n +2 part1_dam3.fasta | tr -d '\n' >> dam3_modified.fasta
tail -n +2 part2_dam3.fasta | tr -d '\n' >> dam3_modified.fasta
echo "" >> dam3_modified.fasta

# 3. extract all other contigs except one of interest
seqkit grep -v -n -p "dam_3" assembly.cleaned.plusMT.renamed.oneline.removeLCL.fasta > other_contigs.fasta

# 4. fix blocking into one line
seqtk seq -l0 dam3_modified.fasta > dam3_modified.oneline.fasta
seqtk seq -l0 other_contigs.fasta > other_contigs.oneline.fasta

# 5. combine everything into a new assembly
cat other_contigs.oneline.fasta dam3_modified.oneline.fasta > assembly.fixed.fasta


# generate final haplotype assemblies
mkdir final-assembly && cd final-assembly
cp ../assembly.fixed.fasta ./assembly.final.dip.fa
seqkit grep -n -r -p "^dam" assembly.final.dip.fa | seqkit seq -w 0 > assembly.final.mat.fa
seqkit grep -n -r -p "^sire" assembly.final.dip.fa | seqkit seq -w 0 > assembly.final.pat.fa

# validate 
samtools faidx assembly.final.dip.fa
samtools faidx assembly.final.mat.fa
samtools faidx assembly.final.pat.fa
diff -qs <(grep dam assembly.final.dip.fa.fai | wc -l) <(grep dam assembly.final.mat.fa.fai | wc -l)
diff -qs <(grep sire assembly.final.dip.fa.fai | wc -l) <(grep sire assembly.final.pat.fa.fai | wc -l)

# run FCS adaptor on new assembly for confirmation
sbatch runFCSadaptor-final.sh assembly.final.dip.fa
'''
#!/bin/bash
#SBATCH -o out_%j.out
#SBATCH -e err_%j.err
#SBATCH --cpus-per-task=30
#SBATCH --ntasks=1
#SBATCH --mem-per-cpu=4096
#SBATCH --account=cattle_genome_assemblies

module load singularityCE/1.3.1

inputGenome=$1

pathToScript=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/FCS
pathToContainer=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/FCS

dir=`pwd`
outDir=${dir}/fcs-adaptor.HxYL-final
mkdir -p $outDir


${pathToScript}/run_fcsadaptor.sh \
 --fasta-input $inputGenome \
 --output-dir $outDir \
 --euk --container-engine singularity \
 --image ${pathToContainer}/fcs-adaptor.sif
'''

# 8. Validate assembly is stucturally correct 
# -----------------------------------------------------------------------------------------#	
# since FCS-adaptor was identical, no need to load into IGV - trust last structural assesment				
								
								
# 9. Perform canu-binning & polishing with DeepVariant (iterative, Illumina then HiFi)
# -----------------------------------------------------------------------------------------#	
# don't need to re-bin the reads, but need to re-align them to the updated assembly
cd /90daydata/ruminant_t2t/Pig/assembly/
mkdir canu-bin-aligns.v2 && cd canu-bin-aligns.v2 
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/verkko_final_asm/cleaned-assembly/final-assembly/assembly.final.* .
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_canu-binning/haplotype/haplotype/haplotype-Hampshire.fasta.gz .
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_canu-binning/haplotype/haplotype/haplotype-unknown.fasta.gz . 
cp /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_canu-binning/haplotype/haplotype/haplotype-YorkshireLandrace.fasta.gz . 

# generate fastq files (with base quality scores) from the binned fasta files
zcat /project/ruminant_t2t/Pig/hifi_data/*DC_1.2.fastq.20k.fastq.gz > hifi_20k.fastq.gz

zcat haplotype-Hampshire.fasta.gz | grep '^>' | sed 's/^>//' > H.ids
seqtk subseq hifi_20k.fastq.gz H.ids > haplotype-Hampshire.fastq

zcat haplotype-unknown.fasta.gz | grep '^>' | sed 's/^>//' > U.ids
seqtk subseq hifi_20k.fastq.gz U.ids > haplotype-unknown.fastq

zcat haplotype-YorkshireLandrace.fasta.gz | grep '^>' | sed 's/^>//' > YL.ids
seqtk subseq hifi_20k.fastq.gz YL.ids > haplotype-YorkshireLandrace.fastq

sbatch gzip.fastq.sb # {3x; 1/file to compress}
#!/bin/bash
#SBATCH --job-name=gzip.fastq
#SBATCH --cpus-per-task=96
#SBATCH --ntasks=1
#SBATCH --partition=ceres
#SBATCH --qos=memlimit
#SBATCH --mem-per-cpu=3968
#SBATCH --time=1-00:00:00
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2
#SBATCH --output=gzip__%j.std
#SBATCH --error=gzip__%j.err
#SBATCH --account=cattle_genome_assemblies

date

gzip haplotype-Hampshire.fastq
gzip haplotype-unknown.fastq
gzip haplotype-YorkshireLandrace.fastq

date


# Hampshire 
# -------------------------
# generate HiFi aligns
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# for Hampshire Bin
	# NA - last time this bin resulted in lower QV

# for Hampshire + Uknown Bin
export tools=/project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/polish/software 
micromamba activate verkko-v2.2

cd /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2
ls /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/haplotype-Hampshire.fastq.gz > HiFi-HU.fofn
ls /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/haplotype-unknown.fastq.gz >> HiFi-HU.fofn

mkdir -p HiFi_to_HU && cd HiFi_to_HU
ln -s ../HiFi-HU.fofn input.fofn

$tools/T2T-Polish/winnowmap/_submit.sh /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/assembly.final.pat.fa HiFi_to_HU map-pb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Yorkshire Landrace
# -------------------------
# generate HiFi aligns
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# for YorkshirexLandrace Bin
	# NA - last time this bin resulted in lower QV

# for YorkshirexLandrace + Unknown Bin
export tools=/project/ruminant_t2t/Pig/assembly/verkko2.2_hifi-duplex_trio/relaunch-verkko2.2-patch-phase/verkko_final_asm/polish/software 
micromamba activate verkko-v2.2

cd /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2
ls /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/haplotype-YorkshireLandrace.fastq.gz > HiFi-YLU.fofn
ls /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/haplotype-unknown.fastq.gz >> HiFi-YLU.fofn

mkdir -p HiFi_to_YLU && cd HiFi_to_YLU
ln -s ../HiFi-YLU.fofn input.fofn

$tools/T2T-Polish/winnowmap/_submit.sh /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/assembly.final.mat.fa HiFi_to_YLU map-pb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# DeepVariant HiFi
# =====================================================
cd /mnt/gs21/scratch/ackers24
mkdir -p deep-variant.HxYL.v2 && cd deep-variant.HxYL.v2
#module load apptainer
singularity pull docker://google/deepvariant:1.6.0

# move data to MSU 
# grab aligns from CERES
# rsync -rvupt /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/assembly.final.* ackers24@rsync.hpcc.msu.edu:/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/.
# rsync -rvupt /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/HiFi_to_*/*.pri.bam* ackers24@rsync.hpcc.msu.edu:/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/.


micromamba activate verkko
samtools faidx assembly.final.pat.fa
samtools faidx assembly.final.mat.fa

cd /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2
mkdir -p deep-variant.HU && cd deep-variant.HU
cp ../assembly.final.pat.fa* .
cp ../HiFi_to_HU.pri.bam* .

sbatch deepvariant.HU
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=HU-deepvariant
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=6:00:00
#SBATCH --output=logs/deepvariant_%j.out
#SBATCH --error=logs/deepvariant_%j.err

date

# inputs
SIF=/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deepvariant_1.6.0.sif
DATADIR=/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deep-variant.HU/
ref=assembly.final.pat.fa
reads=HiFi_to_HU.pri.bam

# outputs
outVCF=f1.vcf.gz
outGVCF=f1.g.vcf.gz

# launch script
singularity exec \
  --bind $DATADIR:/mnt \
  $SIF \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type=PACBIO \
  --ref=/mnt/$ref \
  --reads=/mnt/$reads \
  --output_vcf=/mnt/$outVCF \
  --output_gvcf=/mnt/$outGVCF \
  --num_shards=64

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2
mkdir -p deep-variant.YLU && cd deep-variant.YLU
cp ../assembly.final.mat.fa* .
cp ../HiFi_to_YLU.pri.bam* .

sbatch deepvariant.YLU
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=YLU-deepvariant
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=6:00:00
#SBATCH --output=logs/deepvariant_%j.out
#SBATCH --error=logs/deepvariant_%j.err

date

# inputs
SIF=//mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deepvariant_1.6.0.sif
DATADIR=/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deep-variant.YLU/
ref=assembly.final.mat.fa
reads=HiFi_to_YLU.pri.bam

# outputs
outVCF=f1.vcf.gz
outGVCF=f1.g.vcf.gz

# launch script
singularity exec \
  --bind $DATADIR:/mnt \
  $SIF \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type=PACBIO \
  --ref=/mnt/$ref \
  --reads=/mnt/$reads \
  --output_vcf=/mnt/$outVCF \
  --output_gvcf=/mnt/$outGVCF \
  --num_shards=64

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Genomescope
# =====================================================
micromamba activate genomescope2
cd /mnt/gs21/scratch/ackers24/
mkdir -p merfin-bcftools.HxYL.v2 && cd merfin-bcftools.HxYL.v2

# rsync -rvupt /90daydata/ruminant_t2t/Pig/assembly/canu-bin-aligns.v2/hap*fastq.gz ackers24@rsync.hpcc.msu.edu:/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/.

cd /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2
mkdir -p merfin-bcftools.HU && cd merfin-bcftools.HU
sbatch jfish-HU.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=jfish-HU
#SBATCH --cpus-per-task=25
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/jfish-hifi_%j.out
#SBATCH --error=logs/jfish-hifi_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.HU/

date

module load Jellyfish

jellyfish count -C -m 21 -s 1000000000 -t 25 <(zcat /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/haplotype-Hampshire.fastq.gz /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/haplotype-unknown.fastq.gz) -o hifi-HU.jf
jellyfish histo -t 10 hifi-HU.jf > hifi-HU.histo

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# move files into place 
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl f1.k31.meryl
# launch genomescope
/mnt/research/qgg/software/genomescope2.0/genomescope.R \
	-i hifi-HU.histo \
	-k 21 \
	-o genomescope_output \
	-p 2 --fitted_hist


cd /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2
mkdir -p merfin-bcftools.YLU && cd merfin-bcftools.YLU
sbatch jfish-YLU.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=jfish-YLU
#SBATCH --cpus-per-task=25
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/jfish-hifi_%j.out
#SBATCH --error=logs/jfish-hifi_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.YLU/

date

module load Jellyfish

jellyfish count -C -m 21 -s 1000000000 -t 25 <(zcat /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/haplotype-YorkshireLandrace.fastq.gz /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/haplotype-unknown.fastq.gz) -o hifi-YLU.jf
jellyfish histo -t 10 hifi-YLU.jf > hifi-YLU.histo

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# move files into place 
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl f1.k31.meryl
# launch genomescope
/mnt/research/qgg/software/genomescope2.0/genomescope.R \
	-i hifi-YLU.histo \
	-k 21 \
	-o genomescope_output \
	-p 2 --fitted_hist


# Merfin
# =====================================================
cd /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2
cd merfin-bcftools.HU
sbatch merfin-HU.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=merfin.HU
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=3:00:00
#SBATCH --output=logs/merfin_%j.out
#SBATCH --error=logs/merfin_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.HU

date

micromamba activate merfin

merfin -polish -sequence /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/assembly.final.pat.fa -readmers f1.k31.meryl -peak 15 -prob genomescope_output/lookup_table.txt -vcf /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deep-variant.HU/f1.vcf.gz -output HU_merfin_polish -threads 28

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2
cd merfin-bcftools.YLU
sbatch merfin-YLU.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=merfin.YLU
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=3:00:00
#SBATCH --output=logs/merfin_%j.out
#SBATCH --error=logs/merfin_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.YLU

date

micromamba activate merfin

merfin -polish -sequence /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/assembly.final.mat.fa -readmers f1.k31.meryl -peak 15 -prob genomescope_output/lookup_table.txt -vcf /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deep-variant.YLU/f1.vcf.gz -output YLU_merfin_polish -threads 28

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# BCFtools
# =====================================================
cd /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2
cd merfin-bcftools.HU 
sbatch bcftools-HU.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=bcftools.HU
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=2:00:00
#SBATCH --output=logs/bcftools_%j.out
#SBATCH --error=logs/bcftools_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.HU/

date

module load BCFtools

bcftools view -Oz HU_merfin_polish.polish.vcf > HU_merfin_polish.polish.vcf.gz
bcftools index HU_merfin_polish.polish.vcf.gz
bcftools consensus HU_merfin_polish.polish.vcf.gz \
	-f /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/assembly.final.pat.fa \
	-H 1 > assembly.final.sire.polished-HU.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2
cd merfin-bcftools.YLU
sbatch bcftools-YLU.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=bcftools.YLU
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=2:00:00
#SBATCH --output=logs/bcftools_%j.out
#SBATCH --error=logs/bcftools_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.YLU/

date

module load BCFtools

bcftools view -Oz YLU_merfin_polish.polish.vcf > YLU_merfin_polish.polish.vcf.gz
bcftools index YLU_merfin_polish.polish.vcf.gz
bcftools consensus YLU_merfin_polish.polish.vcf.gz \
	-f /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/assembly.final.mat.fa \
	-H 1 > assembly.final.dam.polished-YLU.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Illumina Polishing
# =====================================================

# launch alignment on input assembly
cd /mnt/gs21/scratch/ackers24
mkdir -p illuminaAlign-HUxYLU.v2 && cd illuminaAlign-HUxYLU.v2
cp /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.HU/assembly.final.sire.polished-HU.fasta .
cp /mnt/gs21/scratch/ackers24/merfin-bcftools.HxYL.v2/merfin-bcftools.YLU/assembly.final.dam.polished-YLU.fasta .

# index and reformat necessary files
micromamba activate verkko
seqtk seq -l0 assembly.final.sire.polished-HU.fasta > assembly.final.sire.polished-HU.formatted.fasta
seqtk seq -l0 assembly.final.dam.polished-YLU.fasta > assembly.final.dam.polished-YLU.formatted.fasta
#module load SAMtools
samtools faidx assembly.final.sire.polished-HU.formatted.fasta
samtools faidx assembly.final.dam.polished-YLU.formatted.fasta

# illumina align pipleine for sire
# --------------------------------
cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2
mkdir -p sire && cd sire

sbatch bwa-idx.sire.sb
sbatch bwa-mem.sire.sb
sbatch fixmate.sire.sb
sbatch srt.idx.sire.sb
sbatch mark-dup.sire.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=bwa-idx.sire
#SBATCH --cpus-per-task=64
#SBATCH --mem=200G
#SBATCH --time=4:00:00
#SBATCH --output=logs/bwa-idx_%j.out
#SBATCH --error=logs/bwa-idx_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/

date

/mnt/research/qgg/software/bwa-0.7.17/bwa index ../assembly.final.sire.polished-HU.formatted.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=bwa-mem.sire
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4-00:00:00
#SBATCH --output=logs/bwa-f1_%j.out
#SBATCH --error=logs/bwa-f1_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/

date

/mnt/research/qgg/software/bwa-0.7.17/bwa mem -t 64 \
	../assembly.final.sire.polished-HU.formatted.fasta \
	/mnt/research/qgg/pigT2T/HxYL/rawData/illumina_data/F1/Fetus-AM1-PigT2T_S4_L004_R1_001.fastq.gz \
	/mnt/research/qgg/pigT2T/HxYL/rawData/illumina_data/F1/Fetus-AM1-PigT2T_S4_L004_R2_001.fastq.gz \
	> f1.illumina2hifi-sire.sam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=fixmate.sire
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/fixmate_%j.out
#SBATCH --error=logs/fixmate_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/

date

module load SAMtools

samtools fixmate -m -@ 64 f1.illumina2hifi-sire.sam f1.illumina2hifi-sire.fix.bam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=srt.idx.sire
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/srt.idx_%j.out
#SBATCH --error=logs/srt.idx_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/

date

module load SAMtools

samtools sort -@ 64 -O bam -o f1.illumina2hifi-sire.fix.sort.bam f1.illumina2hifi-sire.fix.bam
samtools index f1.illumina2hifi-sire.fix.sort.bam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=mark-dup.sire
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/mark-dup_%j.out
#SBATCH --error=logs/mark-dup_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/

date

module load SAMtools

samtools markdup -r -@ 64 \
	f1.illumina2hifi-sire.fix.sort.bam \
	f1.illumina2hifi-sire.dedup.bam

samtools index f1.illumina2hifi-sire.dedup.bam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# illumina align pipleine for dam
# --------------------------------
cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2
mkdir -p dam && cd dam

sbatch bwa-idx.dam.sb
sbatch bwa-mem.dam.sb
sbatch fixmate.dam.sb
sbatch srt.idx.dam.sb
sbatch mark-dup.dam.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=bwa-idx.dam
#SBATCH --cpus-per-task=64
#SBATCH --mem=200G
#SBATCH --time=4:00:00
#SBATCH --output=logs/bwa-idx_%j.out
#SBATCH --error=logs/bwa-idx_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/

date

/mnt/research/qgg/software/bwa-0.7.17/bwa index ../assembly.final.dam.polished-YLU.formatted.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=bwa-mem.dam
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4-00:00:00
#SBATCH --output=logs/bwa-f1_%j.out
#SBATCH --error=logs/bwa-f1_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/

date

/mnt/research/qgg/software/bwa-0.7.17/bwa mem -t 64 \
	../assembly.final.dam.polished-YLU.formatted.fasta \
	/mnt/research/qgg/pigT2T/HxYL/rawData/illumina_data/F1/Fetus-AM1-PigT2T_S4_L004_R1_001.fastq.gz \
	/mnt/research/qgg/pigT2T/HxYL/rawData/illumina_data/F1/Fetus-AM1-PigT2T_S4_L004_R2_001.fastq.gz \
	> f1.illumina2hifi-dam.sam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=fixmate.dam
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/fixmate_%j.out
#SBATCH --error=logs/fixmate_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/

date

module load SAMtools

samtools fixmate -m -@ 64 f1.illumina2hifi-dam.sam f1.illumina2hifi-dam.fix.bam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=srt.idx.dam
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/srt.idx_%j.out
#SBATCH --error=logs/srt.idx_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/

date

module load SAMtools

samtools sort -@ 64 -O bam -o f1.illumina2hifi-dam.fix.sort.bam f1.illumina2hifi-dam.fix.bam
samtools index f1.illumina2hifi-dam.fix.sort.bam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=mark-dup.dam
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=4:00:00
#SBATCH --output=logs/mark-dup_%j.out
#SBATCH --error=logs/mark-dup_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/

date

module load SAMtools

samtools markdup -r -@ 64 \
	f1.illumina2hifi-dam.fix.sort.bam \
	f1.illumina2hifi-dam.dedup.bam

samtools index f1.illumina2hifi-dam.dedup.bam
	
date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# launch illumina deepvariant 
# ------------------------------------------
cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/
mkdir -p deepvar && cd deepvar
cp ../f1.illumina2hifi-sire.dedup.bam* .
cp /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/assembly.final.sire.polished-HU.formatted.fasta* .

sbatch deepvar.sire.sb
# launch DeepVariant
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=sire-deepvar
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=12:00:00
#SBATCH --output=logs/deepvariant_%j.out
#SBATCH --error=logs/deepvariant_%j.err

#module load singularity

date

# inputs
SIF=/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deepvariant_1.6.0.sif
DATADIR=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/deepvar
ref=assembly.final.sire.polished-HU.formatted.fasta
reads=f1.illumina2hifi-sire.dedup.bam
outVCF=f1.sire.vcf.gz
outGVCF=f1.sire.g.vcf.gz

# launch script
singularity exec \
  --bind $DATADIR:/mnt \
  $SIF \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type=WGS \
  --ref=/mnt/$ref \
  --reads=/mnt/$reads \
  --output_vcf=/mnt/$outVCF \
  --output_gvcf=/mnt/$outGVCF \
  --num_shards=64

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/
mkdir -p deepvar && cd deepvar
cp ../f1.illumina2hifi-dam.dedup.bam* .
cp /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/assembly.final.dam.polished-YLU.formatted.fasta* . 

sbatch deepvar.dam.sb
# launch DeepVariant
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=dam-deepvar
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=12:00:00
#SBATCH --output=logs/deepvariant_%j.out
#SBATCH --error=logs/deepvariant_%j.err

#module load singularity

date

# inputs
SIF=/mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/deepvariant_1.6.0.sif
DATADIR=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/deepvar
ref=assembly.final.dam.polished-YLU.formatted.fasta
reads=f1.illumina2hifi-dam.dedup.bam
outVCF=f1.dam.vcf.gz
outGVCF=f1.dam.g.vcf.gz

# launch script
singularity exec \
  --bind $DATADIR:/mnt \
  $SIF \
  /opt/deepvariant/bin/run_deepvariant \
  --model_type=WGS \
  --ref=/mnt/$ref \
  --reads=/mnt/$reads \
  --output_vcf=/mnt/$outVCF \
  --output_gvcf=/mnt/$outGVCF \
  --num_shards=64

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# generate parental kmers
# ------------------------------------------
cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire
mkdir -p kmers && cd kmers
micromamba activate merqury

sbatch kmer.sire.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=sire-kmer
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=6:00:00
#SBATCH --output=logs/sire-kmer_%j.out
#SBATCH --error=logs/sire-kmer_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/kmers/

date

micromamba activate merqury

meryl count k=21 \
  threads=16 \
  output paternal.meryl \
  /mnt/research/qgg/pigT2T/HxYL/rawData/illumina_data/boar/Boar-PigT2T_S2_L004_R*_001.fastq.gz

meryl print paternal.meryl > paternal.kmers.txt

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam
mkdir -p kmers && cd kmers
micromamba activate merqury

sbatch kmer.dam.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=dam-kmer
#SBATCH --cpus-per-task=64
#SBATCH --mem=512G
#SBATCH --time=6:00:00
#SBATCH --output=logs/dam-kmer_%j.out
#SBATCH --error=logs/dam-kmer_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/kmers/

date

micromamba activate merqury

meryl count k=21 \
  threads=16 \
  output maternal.meryl \
  /mnt/research/qgg/pigT2T/HxYL/rawData/illumina_data/sow/Sow-PigT2T_S3_L004_R*_001.fastq.gz

meryl print maternal.meryl > maternal.kmers.txt

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# filter F1 variants with parental kmers
# ------------------------------------------
cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire
mkdir -p vars && cd vars

sbatch vars.sire.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=sire.merfin
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=3:30:00
#SBATCH --output=logs/merfin_%j.out
#SBATCH --error=logs/merfin_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/vars/

date

micromamba activate merfin

merfin -filter \
	-vcf /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/deepvar/f1.sire.vcf.gz \
	-sequence /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/deepvar/assembly.final.sire.polished-HU.formatted.fasta \
	-readmers /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/kmers/paternal.meryl \
	-output f1.sire.paternal_support

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam
mkdir -p vars && cd vars

sbatch vars.dam.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=dam.merfin
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=3:30:00
#SBATCH --output=logs/merfin_%j.out
#SBATCH --error=logs/merfin_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/vars/

date

micromamba activate merfin

merfin -filter \
	-vcf /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/deepvar/f1.dam.vcf.gz \
	-sequence /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/deepvar/assembly.final.dam.polished-YLU.formatted.fasta \
	-readmers /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/kmers/maternal.meryl \
	-output f1.dam.maternal_support

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# generate consensus with variants
# ------------------------------------------
cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire
mkdir -p asm && cd asm

sbatch asm.sire.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=sire.bcftools
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=2:00:00
#SBATCH --output=logs/bcftools_%j.out
#SBATCH --error=logs/bcftools_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/asm/

date

module load BCFtools

bcftools view -Oz ../vars/f1.sire.paternal_support.filter.vcf > f1.sire.paternal_support.filter.vcf.gz
bcftools index f1.sire.paternal_support.filter.vcf.gz
bcftools consensus f1.sire.paternal_support.filter.vcf.gz \
	-f /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/deepvar/assembly.final.sire.polished-HU.formatted.fasta \
	-H 1 > assembly.final.sire.polished-HU.illumina-polished.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

cd /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam
mkdir -p asm && cd asm

sbatch asm.dam.sb
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=dam.bcftools
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=2:00:00
#SBATCH --output=logs/bcftools_%j.out
#SBATCH --error=logs/bcftools_%j.err
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/asm/

date

module load BCFtools

bcftools view -Oz ../vars/f1.dam.maternal_support.filter.vcf > f1.dam.maternal_support.filter.vcf.gz
bcftools index f1.dam.maternal_support.filter.vcf.gz
bcftools consensus f1.dam.maternal_support.filter.vcf.gz \
	-f /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/deepvar/assembly.final.dam.polished-YLU.formatted.fasta \
	-H 1 > assembly.final.dam.polished-YLU.illumina-polished.fasta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Move final assemblies into position
# -----------------------------------
micromamba activate verkko
cd /mnt/research/qgg/pigT2T/HxYL
mkdir -p final-assembly.v2 && cd final-assembly.v2
cp /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/dam/asm/assembly.final.dam.polished-YLU.illumina-polished.fasta assembly.YL.blocked.fasta
cp /mnt/gs21/scratch/ackers24/illuminaAlign-HUxYLU.v2/sire/asm/assembly.final.sire.polished-HU.illumina-polished.fasta assembly.H.blocked.fasta
# format assemblies
seqtk seq -l0 assembly.YL.blocked.fasta > assembly.YL.fixed.fasta
seqtk seq -l0 assembly.H.blocked.fasta > assembly.H.fixed.fasta
samtools faidx assembly.YL.fixed.fasta
samtools faidx assembly.H.fixed.fasta


# Annotate Mat and Pat Chromosomes (change hapmer names)
# ------------------------------------------------------
# build key for H chromosomal annotation
cd /mnt/research/qgg/pigT2T/HxYL/final-assembly.v2
mkdir -p getChrH && cd getChrH
cp ../assembly.H.fixed.fasta .
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/003/025/GCF_000003025.6_Sscrofa11.1/GCF_000003025.6_Sscrofa11.1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/003/025/GCF_000003025.6_Sscrofa11.1/GCF_000003025.6_Sscrofa11.1_genomic.gff.gz
gunzip GCF_000003025.6_Sscrofa11.1_genomic.fna.gz
gunzip GCF_000003025.6_Sscrofa11.1_genomic.gff.gz
echo -e "NC_010443.5\tchr1_H\nNC_010444.4\tchr2_H\nNC_010445.4\tchr3_H\nNC_010446.5\tchr4_H\nNC_010447.5\tchr5_H\nNC_010448.4\tchr6_H\nNC_010449.5\tchr7_H\nNC_010450.4\tchr8_H\nNC_010451.4\tchr9_H\nNC_010452.4\tchr10_H\nNC_010453.5\tchr11_H\nNC_010454.4\tchr12_H\nNC_010455.5\tchr13_H\nNC_010456.5\tchr14_H\nNC_010457.5\tchr15_H\nNC_010458.4\tchr16_H\nNC_010459.5\tchr17_H\nNC_010460.4\tchr18_H\nNC_010461.5\tchrX_H\nNC_010462.3\tchrY_H" > H.chromosome.map

sbatch liftoff.H.sb
# run liftoff on H hap
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=H.liftoff
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=4:00:00
#SBATCH --output=H.liftoff%j.out
#SBATCH --error=H.liftoff%j.out
#SBATCH --chdir=/mnt/research/qgg/pigT2T/HxYL/final-assembly.v2/getChrH/

date

micromamba activate liftoff

liftoff assembly.H.fixed.fasta GCF_000003025.6_Sscrofa11.1_genomic.fna -g GCF_000003025.6_Sscrofa11.1_genomic.gff -o assembly.H.fixed.gff3 -p 28

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# generate H chromosome map
zgrep -P "\tgene\t" GCF_000003025.6_Sscrofa11.1_genomic.gff | \
awk -F'\t' '{
  match($9, /GeneID:[0-9]+/, arr);
  split(arr[0], id, ":");
  print id[2] "\t" $1
}' > reference_gene_chromosome_map.tsv
awk '$3 == "gene" && $9 ~ /GeneID:/ {
  match($9, /GeneID:([0-9]+)/, arr);
  print arr[1] "\t" $1
}' assembly.H.fixed.gff3 > H.liftoff_gene_contig.tsv
join -t $'\t' <(sort reference_gene_chromosome_map.tsv) <(sort H.liftoff_gene_contig.tsv) > H.joined_gene_chr_contig.tsv
cut -f2,3 H.joined_gene_chr_contig.tsv | sort | uniq -c | sort -nr > H.contig_chromosome_summary.tsv
awk 'FNR==NR {map[$1]=$2; next} {if ($2 in map) $2=map[$2]; print}' H.chromosome.map H.contig_chromosome_summary.tsv > H.contig_chromosome_summary.named.tsv


# rename H hapmer names
echo -e "sire_297\tchr7_H
sire_298\tchr16_H
sire_299\tchr2_H
sire_300\tchr10_H
sire_301\tchr12_H
sire_302\tchr15_H
sire_303\tchr8_H
sire_304\tchr11_H
sire_305\tchr18_H
sire_306\tchr13_H
sire_307\tchrY_H
sire_308\tchr9_H
sire_309\tchr6_H
sire_310\tchr17_H
sire_311\tchr4_H
sire_312\tchr1_H
sire_313\tchr5_H
sire_314\tchr3_H
sire_315\tchr14_H" > H.chrs.newnames.key

# liftover evidence for chr-names
2550 chr6_H sire_309	6
2418 chr2_H sire_299	2
2154 chr1_H sire_312	1
1825 chr7_H sire_297	7
1692 chr3_H sire_314	3
1633 chr13_H sire_306	13
1540 chr4_H sire_311	4
1525 chr14_H sire_315	14
1511 chr9_H sire_308	9
1403 chr12_H sire_301	12
1343 chr5_H sire_313	5
988 chr15_H sire_302	15
985 chr8_H sire_303		8
769 chr17_H sire_310	17
617 chr18_H sire_305	18
610 chr10_H sire_300	10
536 chr16_H sire_298	16
511 chr11_H sire_304	11
88 chrY_H sire_307		Y
38 chrX_H sire_307		X

awk '
BEGIN {
    while ((getline < "H.chrs.newnames.key") > 0) map[$1] = $2
}
/^>/ {
    name = substr($0, 2)
    if (name in map) {
        print ">" map[name]
    } else {
        print $0  # leave header unchanged if not in map
    }
    next
}
{ print }
' assembly.H.fixed.fasta > assembly.H.fixed.renamed.fasta

# confirm changes
samtools faidx assembly.H.fixed.renamed.fasta



# build key for YL chromosomal annotation
cd /mnt/research/qgg/pigT2T/HxYL/final-assembly.v2
mkdir -p getChrYL && cd getChrYL
cp ../assembly.YL.fixed.fasta .
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/003/025/GCF_000003025.6_Sscrofa11.1/GCF_000003025.6_Sscrofa11.1_genomic.fna.gz
wget https://ftp.ncbi.nlm.nih.gov/genomes/all/GCF/000/003/025/GCF_000003025.6_Sscrofa11.1/GCF_000003025.6_Sscrofa11.1_genomic.gff.gz
gunzip GCF_000003025.6_Sscrofa11.1_genomic.fna.gz
gunzip GCF_000003025.6_Sscrofa11.1_genomic.gff.gz
echo -e "NC_010443.5\tchr1_YL\nNC_010444.4\tchr2_YL\nNC_010445.4\tchr3_YL\nNC_010446.5\tchr4_YL\nNC_010447.5\tchr5_YL\nNC_010448.4\tchr6_YL\nNC_010449.5\tchr7_YL\nNC_010450.4\tchr8_YL\nNC_010451.4\tchr9_YL\nNC_010452.4\tchr10_YL\nNC_010453.5\tchr11_YL\nNC_010454.4\tchr12_YL\nNC_010455.5\tchr13_YL\nNC_010456.5\tchr14_YL\nNC_010457.5\tchr15_YL\nNC_010458.4\tchr16_YL\nNC_010459.5\tchr17_YL\nNC_010460.4\tchr18_YL\nNC_010461.5\tchrX_YL\nNC_010462.3\tchrY_YL" > YL.chromosome.map

sbatch liftoff.YL.sb
# run liftoff on YL hap
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --job-name=YL.liftoff
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=4:00:00
#SBATCH --output=YL.liftoff%j.out
#SBATCH --error=YL.liftoff%j.out
#SBATCH --chdir=/mnt/research/qgg/pigT2T/HxYL/final-assembly.v2/getChrYL/

date

micromamba activate liftoff

liftoff assembly.YL.fixed.fasta GCF_000003025.6_Sscrofa11.1_genomic.fna -g GCF_000003025.6_Sscrofa11.1_genomic.gff -o assembly.YL.fixed.gff3 -p 28

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# generate YL chromosome map
zgrep -P "\tgene\t" GCF_000003025.6_Sscrofa11.1_genomic.gff | \
awk -F'\t' '{
  match($9, /GeneID:[0-9]+/, arr);
  split(arr[0], id, ":");
  print id[2] "\t" $1
}' > reference_gene_chromosome_map.tsv
awk '$3 == "gene" && $9 ~ /GeneID:/ {
  match($9, /GeneID:([0-9]+)/, arr);
  print arr[1] "\t" $1
}' assembly.YL.fixed.gff3 > YL.liftoff_gene_contig.tsv
join -t $'\t' <(sort reference_gene_chromosome_map.tsv) <(sort YL.liftoff_gene_contig.tsv) > YL.joined_gene_chr_contig.tsv
cut -f2,3 YL.joined_gene_chr_contig.tsv | sort | uniq -c | sort -nr > YL.contig_chromosome_summary.tsv
awk 'FNR==NR {map[$1]=$2; next} {if ($2 in map) $2=map[$2]; print}' YL.chromosome.map YL.contig_chromosome_summary.tsv > YL.contig_chromosome_summary.named.tsv

# rename and sort YL hapmer names
echo -e "dam_1\tchr14_YL
dam_2\tchr7_YL
dam_3\tchr16_YL
dam_4\tchr2_YL
dam_5\tchr12_YL
dam_6\tchr15_YL
dam_7\tchr8_YL
dam_8\tchr11_YL
dam_9\tchrX_YL
dam_10\tchr18_YL
dam_11\tchr13_YL
dam_12\tchr9_YL
dam_13\tchr10_YL
dam_14\tchr6_YL
dam_15\tchr17_YL
dam_16\tchr4_YL
dam_17\tchr1_YL
dam_18\tchr5_YL
dam_19\tchr3_YL
dam_32\tmtDNA_YL" > YL.chrs.newnames.key

# liftover evidence for chr-names
2550 chr6_YL dam_14		6
2416 chr2_YL dam_4		2
2157 chr1_YL dam_17		1
1821 chr7_YL dam_2		7
1691 chr3_YL dam_19		3
1632 chr13_YL dam_11	13
1542 chr4_YL dam_16		4
1526 chr14_YL dam_1		14
1516 chr9_YL dam_12		9
1400 chr12_YL dam_5		12
1342 chr5_YL dam_18		5
996 chrX_YL dam_9		X
988 chr15_YL dam_6		15
983 chr8_YL dam_7		8
773 chr17_YL dam_15		17
617 chr18_YL dam_10		18
610 chr10_YL dam_13		10
532 chr16_YL dam_3		16
510 chr11_YL dam_8		11



awk '
BEGIN {
    while ((getline < "YL.chrs.newnames.key") > 0) map[$1] = $2
}
/^>/ {
    name = substr($0, 2)
    if (name in map) {
        print ">" map[name]
    } else {
        print $0  # leave header unchanged if not in map
    }
    next
}
{ print }
' assembly.YL.fixed.fasta > assembly.YL.fixed.renamed.fasta


# confirm changes
samtools faidx assembly.YL.fixed.renamed.fasta


# grab and rename the unassigned contigs (from original input assembly right before HiFi polishing)
cd /mnt/research/qgg/pigT2T/HxYL/final-assembly.v2
cp /mnt/gs21/scratch/ackers24/deep-variant.HxYL.v2/assembly.final.dip* .
awk '$1 ~ /unassigned/' assembly.final.dip.fa.fai | cut -f1 > unassigned.ids
seqtk subseq assembly.final.dip.fa unassigned.ids > assembly.unpolished.unassigned.fasta
samtools faidx assembly.unpolished.unassigned.fasta
awk '/^>/ {sub(/^>unassigned-0*/, ">na_"); print; next} 1' assembly.unpolished.unassigned.fasta > assembly.unpolished.unassigned.renamed.fasta
samtools faidx assembly.unpolished.unassigned.renamed.fasta
#clean up
rm assembly.final.dip.fa*


# Collect all the intermediate & renamed .fasta's
# --------------------------------------------------
cd /mnt/research/qgg/pigT2T/HxYL/final-assembly.v2/
mkdir -p renamed-assemblies && cd renamed-assemblies

# grab sire (H) chromosomes
cut -f1,1 ../getChrH/assembly.H.fixed.renamed.fasta.fai | grep H > ids.H.chr
awk '
function chr_order(chr) {
    if (chr ~ /^chr[0-9]+_H$/) {
        match(chr, /^chr([0-9]+)_H$/, m)
        return m[1]
    } else if (chr == "chrX_H") {
        return 1000
    } else if (chr == "chrY_H") {
        return 1001
    } else if (chr ~ /mtDNA/i) {
        return 1002
    }
    return 9999
}
{ print chr_order($0), $0 }
' ids.H.chr | sort -n | cut -d' ' -f2- > ids.H.chr.sorted
xargs samtools faidx ../getChrH/assembly.H.fixed.renamed.fasta < ids.H.chr.sorted > assembly.H.chromosomal.fasta

# grab dam (YL) chromosomes
cut -f1,1 ../getChrYL/assembly.YL.fixed.renamed.fasta.fai | grep YL > ids.YL.chr
awk '
function chr_order(chr) {
    if (chr ~ /^chr[0-9]+_YL$/) {
        match(chr, /^chr([0-9]+)_YL$/, m)
        return m[1]
    } else if (chr == "chrX_YL") {
        return 1000
    } else if (chr == "chrY_YL") {
        return 1001
    } else if (chr ~ /mtDNA/i) {
        return 1002
    }
    return 9999
}
{ print chr_order($0), $0 }
' ids.YL.chr | sort -n | cut -d' ' -f2- > ids.YL.chr.sorted
xargs samtools faidx ../getChrYL/assembly.YL.fixed.renamed.fasta < ids.YL.chr.sorted > assembly.YL.chromosomal.fasta

# grab sire (H) contigs
cut -f1,1 ../getChrH/assembly.H.fixed.renamed.fasta.fai | grep sire > ids.H.contigs
seqtk subseq ../getChrH/assembly.H.fixed.renamed.fasta ids.H.contigs > assembly.H.contigs.fasta

# grab dam (YL) contigs
cut -f1,1 ../getChrYL/assembly.YL.fixed.renamed.fasta.fai | grep dam > ids.YL.contigs
seqtk subseq ../getChrYL/assembly.YL.fixed.renamed.fasta ids.YL.contigs > assembly.YL.contigs.fasta

# grab unassigned contigs
cut -f1,1 ../assembly.unpolished.unassigned.renamed.fasta.fai | grep na > ids.na.contigs
seqtk subseq ../assembly.unpolished.unassigned.renamed.fasta ids.na.contigs > assembly.na.contigs.fasta

# grab paternal Y chromosome
cut -f1,1 ../getChrH/assembly.H.fixed.renamed.fasta.fai | grep Y > ids.chrY
seqtk subseq ../getChrH/assembly.H.fixed.renamed.fasta ids.chrY > assembly.chrY.fasta


# Generate final assemblies w/ updated contig names
# --------------------------------------------------
cd /mnt/research/qgg/pigT2T/HxYL/final-assembly.v2
mkdir -p HxYL-finalASM && cd HxYL-finalASM

# HxYL diploid assembly (Mat + Pat + ambig, i.e. everything)
cat ../renamed-assemblies/assembly.H.chromosomal.fasta ../renamed-assemblies/assembly.YL.chromosomal.fasta ../renamed-assemblies/assembly.H.contigs.fasta ../renamed-assemblies/assembly.YL.contigs.fasta ../renamed-assemblies/assembly.na.contigs.fasta > assembly.HxYL.dip.fasta
samtools faidx assembly.HxYL.dip.fasta

# HxYL chromosomal level diploid assembly (Mat + Pat chromosomes)
cat ../renamed-assemblies/assembly.H.chromosomal.fasta ../renamed-assemblies/assembly.YL.chromosomal.fasta > assembly.HxYL.dip.chromosomal.fasta
samtools faidx assembly.HxYL.dip.chromosomal.fasta

# Maternal (YL) w/ Paternal ChrY haploid assembly (Mat + chrY + MT)
cat ../renamed-assemblies/assembly.YL.chromosomal.fasta ../renamed-assemblies/assembly.chrY.fasta  > assembly.HxYL.mat-plusY.fasta
samtools faidx assembly.HxYL.mat-plusY.fasta

# Copy in chromosome level Maternal only and Paternal only assemblies 
cp ../renamed-assemblies/assembly.H.chromosomal.fasta .
cp ../renamed-assemblies/assembly.YL.chromosomal.fasta .
samtools faidx assembly.H.chromosomal.fasta
samtools faidx assembly.YL.chromosomal.fasta

# Maternal resolved chromosomes and contigs
cat ../renamed-assemblies/assembly.YL.chromosomal.fasta ../renamed-assemblies/assembly.YL.contigs.fasta > assembly.YL.chrs-contigs.fasta
samtools faidx assembly.YL.chrs-contigs.fasta

# Paternal resolved chromosomes and contigs
cat ../renamed-assemblies/assembly.H.chromosomal.fasta ../renamed-assemblies/assembly.H.contigs.fasta > assembly.H.chrs-contigs.fasta
samtools faidx assembly.H.chrs-contigs.fasta

sbatch asm.gzip.sb
# gzip files
# ---------------------------------------------------------------------
#!/bin/bash --login
#SBATCH --job-name=gzip-files
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=4:00:00
#SBATCH --output=zipped_%j.out
#SBATCH --error=zipped_%j.out
#SBATCH --chdir=/mnt/research/qgg/pigT2T/HxYL/final-assembly.v2/HxYL-finalASM/

date 

gzip assembly.HxYL.dip.fasta
gzip assembly.HxYL.dip.chromosomal.fasta
gzip assembly.HxYL.mat-plusY.fasta
gzip assembly.H.chromosomal.fasta
gzip assembly.YL.chromosomal.fasta
gzip assembly.YL.chrs-contigs.fasta
gzip assembly.H.chrs-contigs.fasta

date
# ---------------------------------------------------------------------


# Check and re-orient the chromosomes that need to be flipped
# -----------------------------------------------------------
# move to CERES since mummer has issues on MSU HPCC
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2
mkdir HxYL-finalASM.v2 && cd HxYL-finalASM.v2
rsync -rvupt ackers24@rsync.hpcc.msu.edu:/mnt/research/qgg/pigT2T/HxYL/final-assembly.v2/HxYL-finalASM ./after-polishing.ASM
cd after-polishing.ASM/HxYL-finalASM/
mv * ../.
cd ..
rm -rf HxYL-finalASM
rm *.zip*
cd ..
mkdir orient && cd orient
wget ftp://ftp.ensembl.org/pub/release-110/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
gunzip Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz
#gunzip ../after-polishing.ASM/assembly.HxYL.dip.fasta.gz

sbatch launch_mummer.chr.orient.sb
# < launch_mummer.chr.orient.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=4:00:00             
#SBATCH --cpus-per-task=164
#SBATCH --mem-per-cpu=8G   
#SBATCH --job-name chr.orient
#SBATCH --output=HxYL.v2_%j.out
#SBATCH --error=HxYL.v2_%j.err     
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/orient
#SBATCH --account=cattle_genome_assemblies

date

module load mummer/4.0.0rc1

nucmer -l 100 -c 500 -p ref_vs_HxYL.v2 Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa ../after-polishing.ASM/assembly.HxYL.dip.fasta

delta-filter -i 90 -l 10000 ref_vs_HxYL.v2.delta > ref_vs_HxYL.v2.filtered.delta

mummerplot --png --large -p ref_vs_HxYL.v2 ref_vs_HxYL.v2.filtered.delta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# based on MUMmer whole genome alignment, we have to flip the following chromosomes:
## Sire: H1,H7,H9,H10,H12,H14,H15,H16,H18
## Dam: YL1,YL7,YL9,YL12,YL14,YL16,YL18


# delete any last second duplicate utigs that are residing in the assembly (think utig4-1640 issue w/ Wen Script)
# wen checked this issue, and has fixed the script accordingly. 
# however, we do have a few instanances of utigs being used in a chrosome, while also being listed as unused.
# this means that the utig appears twice, and we need to delete the unused version of the utig from the assembly.
# here is a list of chromosomes which need deleted (all on chr16):
dam_compressed.k31.hapmer_unused_utig4-1640 >utig4-1640 DAM_COMPRESSED.K31.HAPMER
dam_compressed.k31.hapmer_unused_utig4-1836 >utig4-1836 DAM_COMPRESSED.K31.HAPMER
dam_compressed.k31.hapmer_unused_utig4-760 >utig4-760 DAM_COMPRESSED.K31.HAPMER
sire_compressed.k31.hapmer_unused_utig4-1836 >utig4-1836 SIRE_COMPRESSED.K31.HAPMER
sire_compressed.k31.hapmer_unused_utig4-540 >utig4-540 SIRE_COMPRESSED.K31.HAPMER
sire_compressed.k31.hapmer_unused_utig4-760 >utig4-760 SIRE_COMPRESSED.K31.HAPMER

# subset the earlier assemblies to not include these contigs (hapmer conversions below):
path dam_compressed.k31.hapmer-0000039 dam_compressed.k31.hapmer_unused_utig4-1640
path dam_compressed.k31.hapmer-0000070 dam_compressed.k31.hapmer_unused_utig4-1836
path dam_compressed.k31.hapmer-0000201 dam_compressed.k31.hapmer_unused_utig4-760
path sire_compressed.k31.hapmer-0000332 sire_compressed.k31.hapmer_unused_utig4-1836
path sire_compressed.k31.hapmer-0000361 sire_compressed.k31.hapmer_unused_utig4-540
path sire_compressed.k31.hapmer-0000363 sire_compressed.k31.hapmer_unused_utig4-760

cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2
mkdir rm-repeat-asm && cd rm-repeat-asm
module load seqkit
echo -e "dam_39\ndam_70\ndam_201\nsire_332\nsire_361\nsire_363" > remove.ids

# for assembly.HxYL.dip.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.HxYL.dip.fasta > assembly.HxYL.dip.filtered.fasta

# for assembly.HxYL.dip.chromosomal.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.HxYL.dip.chromosomal.fasta > assembly.HxYL.dip.chromosomal.filtered.fasta

# for assembly.HxYL.mat-plusY.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.HxYL.mat-plusY.fasta > assembly.HxYL.mat-plusY.filtered.fasta

# for assembly.H.chromosomal.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.H.chromosomal.fasta > assembly.H.chromosomal.filtered.fasta

# for assembly.YL.chromosomal.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.YL.chromosomal.fasta > assembly.YL.chromosomal.filtered.fasta

# for assembly.YL.chrs-contigs.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.YL.chrs-contigs.fasta > assembly.YL.chrs-contigs.filtered.fasta

# for assembly.H.chrs-contigs.fasta
seqkit grep -v -f remove.ids ../after-polishing.ASM/assembly.H.chrs-contigs.fasta > assembly.H.chrs-contigs.filtered.fasta

# index and validate the updated assemblies
module load samtools
samtools faidx assembly.HxYL.dip.filtered.fasta
samtools faidx assembly.HxYL.dip.chromosomal.filtered.fasta
samtools faidx assembly.HxYL.mat-plusY.filtered.fasta
samtools faidx assembly.H.chromosomal.filtered.fasta
samtools faidx assembly.YL.chromosomal.filtered.fasta
samtools faidx assembly.YL.chrs-contigs.filtered.fasta
samtools faidx assembly.H.chrs-contigs.filtered.fasta

diff <(wc -l ../after-polishing.ASM/assembly.HxYL.dip.fasta.fai) <(wc -l assembly.HxYL.dip.filtered.fasta.fai)
diff <(wc -l ../after-polishing.ASM/assembly.HxYL.dip.chromosomal.fasta.fai) <(wc -l assembly.HxYL.dip.chromosomal.filtered.fasta.fai)

# do the same for the components
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/after-polishing.ASM
mkdir components && cd components
rsync -rvupt ackers24@rsync.hpcc.msu.edu:/mnt/research/qgg/pigT2T/HxYL/final-assembly.v2/renamed-assemblies/*fasta .

# fix the components
# for assembly.H.chromosomal.fasta
seqkit grep -v -f ../../rm-repeat-asm/remove.ids assembly.H.chromosomal.fasta > assembly.H.filtered.fasta

# for assembly.YL.chromosomal.fasta
seqkit grep -v -f ../../rm-repeat-asm/remove.ids assembly.YL.chromosomal.fasta > assembly.YL.chromosomal.filtered.fasta

# for assembly.H.contigs.fasta
seqkit grep -v -f ../../rm-repeat-asm/remove.ids assembly.H.contigs.fasta > assembly.H.contigs.filtered.fasta

# for assembly.YL.contigs.fasta
seqkit grep -v -f ../../rm-repeat-asm/remove.ids assembly.YL.contigs.fasta > assembly.YL.contigs.filtered.fasta

# for assembly.na.contigs.fasta
seqkit grep -v -f ../../rm-repeat-asm/remove.ids assembly.na.contigs.fasta > assembly.na.contigs.filtered.fasta

# for assembly.chrY.fasta
seqkit grep -v -f ../../rm-repeat-asm/remove.ids assembly.chrY.fasta > assembly.chrY.filtered.fasta


# generate new assemblies with flipped contigs but in proper order
# ----------------------------------------------------------------
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2
mkdir reorient && cd reorient

awk '{print $1}' ../rm-repeat-asm/assembly.H.chromosomal.filtered.fasta.fai > flip_list.pat.txt
awk '{print $1}' ../rm-repeat-asm/assembly.YL.chromosomal.filtered.fasta.fai > flip_list.mat.txt
# keep chromosomes:
## Sire: H1,H7,H9,H10,H12,H14,H15,H16,H18
## Dam: YL1,YL7,YL9,YL12,YL14,YL16,YL18
# edit flip_lists to include only chromosomes needing flipped, then perform the flips:
# edit flip_lists to include only chromosomes needing flipped, then perform the flips:
module load seqkit
cat \
    <(seqkit grep -v -f flip_list.pat.txt ../rm-repeat-asm/assembly.H.chromosomal.filtered.fasta) \
    <(seqkit grep -f flip_list.pat.txt ../rm-repeat-asm/assembly.H.chromosomal.filtered.fasta | seqkit seq -r -p) \
    > assembly.H.chromosomal.blocked.flipped.fasta
seqkit seq -w 0 assembly.H.chromosomal.blocked.flipped.fasta > assembly.H.chromosomal.flipped.fasta

cat \
    <(seqkit grep -v -f flip_list.mat.txt ../rm-repeat-asm/assembly.YL.chromosomal.filtered.fasta) \
    <(seqkit grep -f flip_list.mat.txt ../rm-repeat-asm/assembly.YL.chromosomal.filtered.fasta | seqkit seq -r -p) \
    > assembly.YL.chromosomal.blocked.flipped.fasta
seqkit seq -w 0 assembly.YL.chromosomal.blocked.flipped.fasta > assembly.YL.chromosomal.flipped.fasta

samtools faidx assembly.H.chromosomal.flipped.fasta
samtools faidx assembly.YL.chromosomal.flipped.fasta

cp /90daydata/ruminant_t2t/Pig/assembly/orient.chr/reorient/renamed-assemblies/ids.H.chr.sorted .
cp /90daydata/ruminant_t2t/Pig/assembly/orient.chr/reorient/renamed-assemblies/ids.YL.chr.sorted . 
xargs samtools faidx assembly.H.chromosomal.flipped.fasta < ids.H.chr.sorted > assembly.H.chromosomal.flipped.sorted.fasta
xargs samtools faidx assembly.YL.chromosomal.flipped.fasta < ids.YL.chr.sorted > assembly.YL.chromosomal.flipped.sorted.fasta

samtools faidx assembly.H.chromosomal.flipped.sorted.fasta
samtools faidx assembly.YL.chromosomal.flipped.sorted.fasta


# generate final assemblies
# ----------------------------------------------------------------
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient
mkdir final-assemblies.sep8 && cd final-assemblies.sep8

# HxYL diploid assembly (Mat + Pat + ambig, i.e. everything)
cat ../assembly.H.chromosomal.flipped.sorted.fasta ../assembly.YL.chromosomal.flipped.sorted.fasta ../../after-polishing.ASM/components/assembly.H.contigs.filtered.fasta ../../after-polishing.ASM/components/assembly.YL.contigs.filtered.fasta ../../after-polishing.ASM/components/assembly.na.contigs.filtered.fasta > assembly.HxYL.dip.fasta
samtools faidx assembly.HxYL.dip.fasta

# HxYL chromosomal level diploid assembly (Mat + Pat chromosomes)
cat ../assembly.H.chromosomal.flipped.sorted.fasta ../assembly.YL.chromosomal.flipped.sorted.fasta > assembly.HxYL.dip.chromosomal.fasta
samtools faidx assembly.HxYL.dip.chromosomal.fasta

# Maternal (YL) w/ Paternal ChrY haploid assembly (Mat + chrY + MT)
cat ../assembly.YL.chromosomal.flipped.sorted.fasta ../../after-polishing.ASM/components/assembly.chrY.filtered.fasta > assembly.HxYL.mat-plusY.fasta
samtools faidx assembly.HxYL.mat-plusY.fasta

# Copy in chromosome level Maternal only and Paternal only assemblies 
cp ../assembly.H.chromosomal.flipped.sorted.fasta ./assembly.H.chromosomal.fasta
cp ../assembly.YL.chromosomal.flipped.sorted.fasta ./assembly.YL.chromosomal.fasta
samtools faidx assembly.H.chromosomal.fasta
samtools faidx assembly.YL.chromosomal.fasta

# Maternal resolved chromosomes and contigs
cat ../assembly.YL.chromosomal.flipped.sorted.fasta ../../after-polishing.ASM/components/assembly.YL.contigs.filtered.fasta > assembly.YL.chrs-contigs.fasta
samtools faidx assembly.YL.chrs-contigs.fasta

# Paternal resolved chromosomes and contigs
cat ../assembly.H.chromosomal.flipped.sorted.fasta ../../after-polishing.ASM/components/assembly.H.contigs.filtered.fasta > assembly.H.chrs-contigs.fasta
samtools faidx assembly.H.chrs-contigs.fasta


# validate new assembly
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient
mkdir validate-asm && cd validate-asm

sbatch launch_mummer.chr.orient.sb
# < launch_mummer.chr.orient.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=4:00:00             
#SBATCH --cpus-per-task=164
#SBATCH --mem-per-cpu=8G   
#SBATCH --job-name chr.orient
#SBATCH --output=HxYL.v2_%j.out
#SBATCH --error=HxYL.v2_%j.err     
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/validate-asm
#SBATCH --account=cattle_genome_assemblies

date

module load mummer/4.0.0rc1

nucmer -l 100 -c 500 -p ref_vs_HxYL.v2.flip /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/orient/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa ../final-assemblies.sep8/assembly.HxYL.dip.fasta

delta-filter -i 90 -l 10000 ref_vs_HxYL.v2.flip.delta > ref_vs_HxYL.v2.flip.filtered.delta

mummerplot --png --large -p ref_vs_HxYL.v2.flip ref_vs_HxYL.v2.flip.filtered.delta

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# zip up files in another directory to prepare for transport:
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.sep8/
mkdir final.zipped.asm && cd final.zipped.asm
cp ../assembly* .

sbatch asm.gzip.sb
# gzip files
# ---------------------------------------------------------------------
#!/bin/bash --login
#SBATCH --job-name=gzip-files
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=4:00:00
#SBATCH --output=zipped_%j.out
#SBATCH --error=zipped_%j.out
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.sep8/final.zipped.asm/
#SBATCH --account=cattle_genome_assemblies

date 

gzip assembly.HxYL.dip.fasta
gzip assembly.HxYL.dip.chromosomal.fasta
gzip assembly.HxYL.mat-plusY.fasta
gzip assembly.H.chromosomal.fasta
gzip assembly.YL.chromosomal.fasta
gzip assembly.YL.chrs-contigs.fasta
gzip assembly.H.chrs-contigs.fasta

date
# ---------------------------------------------------------------------


# move final files to local, then upload to drive
#cd ~/Documents/OneDrive - Michigan State University/Documents/Graduate School PhD/Research/T2T_Detangling/HxYL-finalASM
#rsync -rvupt lee.ackerson@ceres.scinet.usda.gov:'/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.sep8/final.zipped.asm/*' .



# ###################################### #
# Final QC Analysis - HxYL.v2 Assemblies # 
# ###################################### #

cd /mnt/gs21/scratch/ackers24
mkdir -p HxYL-finalQC.v2 && cd HxYL-finalQC.v2

# move data to MSU HPC
rsync -rvupt lee.ackerson@ceres.scinet.usda.gov:/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.sep8 .


# QV Estimates
# ------------------------------------
# set up env
cd /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2
mkdir -p qv-metrics && cd qv-metrics

# assembly.HxYL.dip.fasta
micromamba activate merqury
mkdir -p HxYL.dip && cd HxYL.dip
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.dip.fasta \
	HxYL.dip
cd ../

# assembly.HxYL.dip.chromosomal.fasta
micromamba activate merqury
mkdir -p HxYL.dip.chromosomal && cd HxYL.dip.chromosomal
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.dip.chromosomal.fasta \
	HxYL.dip.chromosomal
cd ../

# assembly.H.chromosomal.fasta
micromamba activate merqury
mkdir -p H.chromosomal && cd H.chromosomal
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.H.chromosomal.fasta \
	H.chromosomal
cd ../

# assembly.YL.chromosomal.fasta
micromamba activate merqury
mkdir -p YL.chromosomal && cd YL.chromosomal
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.YL.chromosomal.fasta \
	YL.chromosomal
cd ../

# assembly.HxYL.mat-plusY.fasta
micromamba activate merqury
mkdir -p HxYL.mat-plusY && cd HxYL.mat-plusY
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.mat-plusY.fasta \
	HxYL.mat-plusY
cd ../

# assembly.H.chrs-contigs.fasta
micromamba activate merqury
mkdir -p H.chrs-contigs && cd H.chrs-contigs
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.H.chrs-contigs.fasta \
	H.chrs-contigs
cd ../

# assembly.YL.chrs-contigs.fasta
micromamba activate merqury
mkdir -p YL.chrs-contigs && cd YL.chrs-contigs
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/illumina/f1/illumina.f1.k31.meryl illumina.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.sow.k31.inherited.gt4.meryl mat.meryl
ln -s /mnt/research/qgg/LeeAckerson/merqury-QV/hapmers/illumina.boar.k31.inherited.gt9.meryl pat.meryl
$MERQURY/_submit_merqury.sh \
	illumina.meryl \
	mat.meryl \
	pat.meryl \
	/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.YL.chrs-contigs.fasta \
	YL.chrs-contigs
cd ../

# get max and mins:
sort -k4,4n qv_file.txt | awk 'NR==1{print "Min:", $1, $4} END{print "Max:", $1, $4}'


# BUSCO Scores
# ------------------------------------
# set up env
micromamba activate verkko
cd /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2
mkdir -p BUSCO && cd BUSCO 

# launch jobs
sbatch launch_busco_HxYL.dip.sb
sbatch launch_busco_HxYL.dip.chr.sb
sbatch launch_busco_H.chr.sb
sbatch launch_busco_YL.chr.sb
sbatch launch_busco_matY.sb
sbatch launch_busco_H.chr-contigs.sb
sbatch launch_busco_YL.chr-contigs.sb

# < launch_busco_HxYL.dip.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_dip     
#SBATCH --output=logs/BUSCO_HxYL.dip_%j.out
#SBATCH --error=logs/BUSCO_HxYL.dip_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.dip.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.HxYL.dip
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_busco_HxYL.dip.chr.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_dip.chr     
#SBATCH --output=logs/BUSCO_HxYL.dip.chr_%j.out
#SBATCH --error=logs/BUSCO_HxYL.dip.chr_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.dip.chromosomal.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.HxYL.dip.chr
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_busco_H.chr.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_H.chr     
#SBATCH --output=logs/BUSCO_HxYL.H.chr_%j.out
#SBATCH --error=logs/BUSCO_HxYL.H.chr_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.H.chromosomal.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.HxYL.H.chr
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_busco_YL.chr.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_YL.chr     
#SBATCH --output=logs/BUSCO_HxYL.YL.chr_%j.out
#SBATCH --error=logs/BUSCO_HxYL.YL.chr_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.YL.chromosomal.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.HxYL.YL.chr
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_busco_matY.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_matY     
#SBATCH --output=logs/BUSCO_HxYL.matY_%j.out
#SBATCH --error=logs/BUSCO_HxYL.matY_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.mat-plusY.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.matY
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_busco_H.chr-contigs.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_H.chr-contigs  
#SBATCH --output=logs/BUSCO_H.chr-contigs_%j.out
#SBATCH --error=logs/BUSCO_H.chr-contigs_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.H.chrs-contigs.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.H.chr-contigs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_busco_YL.chr-contigs.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=8:00:00            
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=16           
#SBATCH --mem=350G         
#SBATCH --job-name BUSCO_YL.chr-contigs  
#SBATCH --output=logs/BUSCO_YL.chr-contigs_%j.out
#SBATCH --error=logs/BUSCO_YL.chr-contigs_%j.err  
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/BUSCO

module load BUSCO/5.8.2-foss-2023a # MSU
#module load busco5/5.7.1 # CERES

busco --in /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.YL.chrs-contigs.fasta \
	--mode genome \
	--lineage_dataset cetartiodactyla_odb10 \
	--cpu 16 \
	--out busco.YL.chr-contigs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~







# N50 Metrics
# ------------------------------------
# set up env
cd /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2
mkdir -p N50 && cd N50 
wget ftp://ftp.ensembl.org/pub/release-110/fasta/sus_scrofa/dna/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

# launch jobs
sbatch launch_quast_HxYL.dip.sb
sbatch launch_quast_HxYL.dip.chr.sb
sbatch launch_quast_H.chr.sb
sbatch launch_quast_YL.chr.sb
sbatch launch_quast_matY.sb
sbatch launch_quast_H.chr-contigs.sb
sbatch launch_quast_YL.chr-contigs.sb

# < launch_quast_HxYL.dip.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_HxYL.dip
#SBATCH --output=logs/quast_HxYL.dip_%j.out
#SBATCH --error=logs/quast_HxYL.dip_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o HxYL.dip /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.dip.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_quast_HxYL.dip.chr.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_HxYL.dip.chr
#SBATCH --output=logs/quast_HxYL.dip.chr_%j.out
#SBATCH --error=logs/quast_HxYL.dip.chr_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o HxYL.dip.chr /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.dip.chromosomal.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_quast_H.chr.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_H.chr
#SBATCH --output=logs/quast_H.chr_%j.out
#SBATCH --error=logs/quast_H.chr_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o H.chr /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.H.chromosomal.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_quast_YL.chr.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_YL.chr
#SBATCH --output=logs/quast_YL.chr_%j.out
#SBATCH --error=logs/quast_YL.chr_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o YL.chr /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.YL.chromosomal.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_quast_matY.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_matY
#SBATCH --output=logs/quast_matY_%j.out
#SBATCH --error=logs/quast_matY_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o matY /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.HxYL.mat-plusY.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_quast_H.chr-contigs.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_H.chr-contigs
#SBATCH --output=logs/quast_H.chr-contigs_%j.out
#SBATCH --error=logs/quast_H.chr-contigs_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o H.chr-contigs /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.H.chrs-contigs.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# < launch_quast_YL.chr-contigs.sb >
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#!/bin/bash --login
#SBATCH --time=2:00:00             
#SBATCH --nodes=1      
#SBATCH --ntasks=1                  
#SBATCH --cpus-per-task=8          
#SBATCH --mem=256G         
#SBATCH --job-name quast_YL.chr-contigs
#SBATCH --output=logs/quast_YL.chr-contigs_%j.out
#SBATCH --error=logs/quast_YL.chr-contigs_%j.err     
#SBATCH --chdir=/mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50

date

module load QUAST/5.2.0 #MSU
# module load quast/5.2.0 # CERES

quast -o YL.chr-contigs /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/final-assemblies.sep8/assembly.YL.chrs-contigs.fasta -r /mnt/gs21/scratch/ackers24/HxYL-finalQC.v2/N50/Sus_scrofa.Sscrofa11.1.dna_sm.toplevel.fa.gz

date
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~



# Reorient MT contig, such that it starts and stops at correct spot:
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient
mkdir final-assemblies.dec12 && cd mkdir final-assemblies.dec12

# generate new MTcontig - oriented in accordance with MitoHiFi (on MSU)
~/qgg/software/bedtools-2.29.2/bin/bedtools getfasta -fi mtDNA_YL.fasta -bed <(echo -e "mtDNA_YL\t11659\t16739\nmtDNA_YL\t0\t11659") -tab | perl -we '$seq = ""; while (<>) { chomp $_; @line = split /\t/, $_; $seq .= $line[1]; } $rev = reverse $seq; $rev =~ tr/ATGCatgcNn/TACGtacgNn/; print ">mtDNA_YL\n", $rev, "\n";' > mtDNA_YL_tRNA_Phe.fa

# copy in new contig to USDA-CERES
scp -r mtDNA_YL_tRNA_Phe.fa lee.ackerson@ceres.scinet.usda.gov:/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.dec12/.

# pull off old MT contig, add new one
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient
head -n -2 assembly.YL.chromosomal.flipped.sorted.fasta >final-assemblies.dec12/assembly.YL.chromosomal.flipped.sorted.noMTdna.fasta
cat assembly.YL.chromosomal.flipped.sorted.noMTdna.fasta mtDNA_YL_tRNA_Phe.fa > assembly.YL.chromosomal.flipped.sorted.newMTdna.fasta

# remake final assemblies from component assemblies using new mtDNA
cd final-assemblies.dec12

# HxYL diploid assembly (Mat + Pat + ambig, i.e. everything)
cat ../assembly.H.chromosomal.flipped.sorted.fasta assembly.YL.chromosomal.flipped.sorted.newMTdna.fasta ../../after-polishing.ASM/components/assembly.H.contigs.filtered.fasta ../../after-polishing.ASM/components/assembly.YL.contigs.filtered.fasta ../../after-polishing.ASM/components/assembly.na.contigs.filtered.fasta > assembly.HxYL.dip.fasta
samtools faidx assembly.HxYL.dip.fasta

# HxYL chromosomal level diploid assembly (Mat + Pat chromosomes)
cat ../assembly.H.chromosomal.flipped.sorted.fasta assembly.YL.chromosomal.flipped.sorted.newMTdna.fasta > assembly.HxYL.dip.chromosomal.fasta
samtools faidx assembly.HxYL.dip.chromosomal.fasta

# Maternal (YL) w/ Paternal ChrY haploid assembly (Mat + chrY + MT)
cat assembly.YL.chromosomal.flipped.sorted.newMTdna.fasta ../../after-polishing.ASM/components/assembly.chrY.filtered.fasta > assembly.HxYL.mat-plusY.fasta
samtools faidx assembly.HxYL.mat-plusY.fasta

# Copy in chromosome level Maternal only and Paternal only assemblies 
cp ../assembly.H.chromosomal.flipped.sorted.fasta ./assembly.H.chromosomal.fasta
cp assembly.YL.chromosomal.flipped.sorted.newMTdna.fasta ./assembly.YL.chromosomal.fasta
samtools faidx assembly.H.chromosomal.fasta
samtools faidx assembly.YL.chromosomal.fasta

# Maternal resolved chromosomes and contigs
cat assembly.YL.chromosomal.flipped.sorted.newMTdna.fasta ../../after-polishing.ASM/components/assembly.YL.contigs.filtered.fasta > assembly.YL.chrs-contigs.fasta
samtools faidx assembly.YL.chrs-contigs.fasta

# Paternal resolved chromosomes and contigs
cat ../assembly.H.chromosomal.flipped.sorted.fasta ../../after-polishing.ASM/components/assembly.H.contigs.filtered.fasta > assembly.H.chrs-contigs.fasta
samtools faidx assembly.H.chrs-contigs.fasta



# zip up files in another directory to prepare for transport:
cd /90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.dec12/
mkdir final.zipped.asm && cd final.zipped.asm
cp ../*.fa .
rm *MTdna*

sbatch asm.gzip.sb
# gzip files
# ---------------------------------------------------------------------
#!/bin/bash --login
#SBATCH --job-name=gzip-files
#SBATCH --cpus-per-task=28
#SBATCH --mem=800G
#SBATCH --time=4:00:00
#SBATCH --output=zipped_%j.out
#SBATCH --error=zipped_%j.out
#SBATCH --chdir=/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.dec12/final.zipped.asm/
#SBATCH --account=cattle_genome_assemblies

date 

gzip assembly.HxYL.dip.fasta
gzip assembly.HxYL.dip.chromosomal.fasta
gzip assembly.HxYL.mat-plusY.fasta
gzip assembly.H.chromosomal.fasta
gzip assembly.YL.chromosomal.fasta
gzip assembly.YL.chrs-contigs.fasta
gzip assembly.H.chrs-contigs.fasta

date
# ---------------------------------------------------------------------

# move to MSU for storage
cd /mnt/research/qgg/pigT2T/HxYL/final-assembly.v2
mkdir HxYL-finalASM.postMTchange && cd HxYL-finalASM.postMTchange
rsync -rvupt lee.ackerson@ceres.scinet.usda.gov:'/90daydata/ruminant_t2t/Pig/assembly/verkko2.2_fixChr14-17.v2/HxYL-finalASM.v2/reorient/final-assemblies.dec12/final.zipped.asm/*' .







