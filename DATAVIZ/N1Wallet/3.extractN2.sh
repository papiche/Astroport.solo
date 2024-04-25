#!/bin/bash

mkdir -p tmp/N2

# Extract unique public keys from tmp/N1 files
unique_pubkeys=($(jq -r '.[].pubkey' tmp/N1.outcomes.json | sort -u))

cp 1.extractN1.sh tmp/N2/
cp 2.visualize_N1.py tmp/N2/
cp tmp/N1.incomes.json tmp/N2/
cp tmp/N1.outcomes.json tmp/N2/

cd tmp/N2
echo "### ${#unique_pubkeys[@]} wallets found"
# Loop through each unique pubkey
for pubkey in "${unique_pubkeys[@]}"; do
    echo "Processing $pubkey..."
    ./1.extractN1.sh "$pubkey"  # Run 1.extractN1.sh for each pubkey
    echo "---------------------------------------------"

    sleep 5
done

rm ./1.extractN1.sh
echo "All tmp/N2 files created.
Visualize : ./2.visualize_N1.py"

