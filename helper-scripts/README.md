# Small Helper Scripts to Expedite Manual Curation

`RelaunchVerkko-example.sh` — Example workflow for how to relaunch Verkko and patch tangles with determined solutions.

`addPatch.pl` — Perl script to automatically produce an updated assembly paths file (including detangled and untouched hapmer paths) in .gaf format.  
- Execute the script as `perl ~/scripts/addPatch.pl --gaf original.paths.gaf --patch HxYL-Assembly-CollatedPatches.tsv > new.paths.gaf`; where `--gaf` is `yourOriginalAssembly/6-rukki/unitig-unrolled-unitig-unrolled-popped-unitig-normal-connected-tip.paths.gaf` and `--patch` is a `.tsv` file with hapmer name (`dam_compressed.k31.hapmer_from_utig4-1479`) and your fixed path for that entire hapmer (`>/<` format) as columns 1 and 2, respectively. If you have an instance where you are consolidating two hapmers into one, then column 1 should have both hapmer names separated by a semicolon (sire_compressed.k31.hapmer_from_utig4-1448;sire_compressed.k31.hapmer_from_utig4-801), the hapmer named first will be the retained nomenclature for the combined hapmer.

`asm-path-flipper.py` — Flips the utig4 path orientation. E.g. from `utig4-1+,utig4-2+,utig4-3+` to `utig4-3-,utig4-2-,utig4-1-`.

`asm-path-translate.py` — Translates the Verkko `assembly.paths.tsv` `+/-` syntax to the patch `>/<` syntax.

`rDNA-morph2patch.py` — Produces an rDNA patch "ONT" sequence by multiplying the `morph consensus.fa` by the estimated CNV.


