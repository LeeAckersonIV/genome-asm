# YAK

# Validating the F1 assembly using F1 reads
./yak qv -t32 -p f1_reads.yak f1_assembly.fasta > f1_validation.qv.txt

# This checks for "switch errors" and hamming distance
./yak trioeval -t32 pat.yak mat.yak f1_assembly.fasta > trio_eval.txt


# MERQURY

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