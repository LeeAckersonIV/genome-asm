# Assembly Methodology  
## HxYL Verkko2.2 Genome Assembly

### 1. Identify available input data
- Illumina
- PacBio HiFi: DeepConsensus v1.2
- ONT Duplex 
- ONT UL
	- R9.4.1 flow cells: dorado v0.3.4 (dna_r9.4.1_e8_sup@v3.6)
	- R10.4.1 flow cells: dorado v0.3.4 (dna_r10.4.1_e8.2_400bps_sup@v4.1.0) and 0.4.1 (dna_r10.4.1_e8.2_400bps_sup@v4.2.0)
- Omni-C
- Reference sequences (rDNA, mitochondial DNA, etc.)

### 2. Quality control input data
- Illumina: No filtering
- PacBio HiFi: Filtered; not used.
- ONT Duplex: Filtered
- ONT UL: Filtered
- Omni-C: No filtering

### 3. Generate hapmer / k-mer databases 
- `$MERQURY/_submit_meryl.sh -c 31 input.fofn out_prefix`
	- NOTE: `_submit_meryl.sh` is no longer suppoprted by merqury, use `_submit_build.sh` instead.
- `$MERQURY/trio/hapmers.sh dam_compressed.k31.meryl sire_compressed.k31.meryl f1_compressed.k31.meryl`

### 4. Launch genome assembly software 
- Verkko2.2: HiFi-Duplex Trio Assembly
- Verkko2.2: HiFi-Duplex HiC Assembly

### 5. Relaunch and Patch Genome Assembly
- After all detangling and structural resolution is completed, but prior to polishing.
