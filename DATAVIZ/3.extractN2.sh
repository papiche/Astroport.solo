#!/bin/bash

mkdir -p tmp/N2

# Extract unique public keys from tmp/N1 files
unique_pubkeys=($(jq -r '.[].pubkey' tmp/N1.outcomes.json | sort -u))

cp extractN1.sh tmp/N2/
cp tmp/N1.incomes.json tmp/N2/
cp tmp/N1.outcomes.json tmp/N2/

cd tmp/N2
echo "### ${#unique_pubkeys[@]} wallets found"
# Loop through each unique pubkey
for pubkey in "${unique_pubkeys[@]}"; do
    echo "Processing $pubkey..."
    ./extractN1.sh "$pubkey"  # Run extractN1.sh for each pubkey
    echo "---------------------------------------------"

    sleep 5
done

echo "All tmp/N2 files created."
cd ..

