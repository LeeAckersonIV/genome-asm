# Small Helper Scripts to Expedite Manual Curation

`RelaunchVerkko-example.sh` — Example workflow for how to relaunch Verkko and patch tangles with determined solutions.

`addPatch/addPatch.pl` — Perl script to automatically produce an updated assembly paths file (including detangled and untouched hapmer paths) in .gaf format.  

`asm-path-flipper.py` — Flips the utig4 path orientation. E.g. from `utig4-1+,utig4-2+,utig4-3+` to `utig4-3-,utig4-2-,utig4-1-`.

`asm-path-translate.py` — Translates the Verkko `assembly.paths.tsv` `+/-` syntax to the patch `>/<` syntax.

`rDNA-morph2patch.py` — Produces an rDNA patch "ONT" sequence by multiplying the `morph consensus.fa` by the estimated CNV.


