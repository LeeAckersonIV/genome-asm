Test-Case Workflow Runs

# ==================================================== SRP 1 ==================================================== #
# This example has several LibraryIDs for individuals, as well as several files within a single LibraryID.

# Move to scratch space with plenty of storage space
cd /mnt/gs21/scratch/ackers24/srp-sandbox

# Run initialize.sh {paternal has seveal illumina runs within one library ID; terminal HiFi has several LIBIDs }
"${SRP_WORKFLOW}/initialize.sh" --projectROOT SRP_1 \
    --illumina.terminal.lib LIB212039 \
    --illumina.maternal.lib LIB212038 \
    --illumina.paternal.lib LIB212041 \
    --illumina.MGS.lib LIB212046 \
    --illumina.MGD.lib LIB212044 \
    --hifi.terminal.lib "LIB212031,LIB215030" \
    --hifi.maternal.lib "LIB212951,LIB215570"


	
# ====================================================  END  ==================================================== #
	