#!/bin/bash

mkdir -p tmp/
# Wallet public key
WalletPublicKey="$1"
[[ -z $WalletPublicKey ]] \
  && WalletPublicKey="TENGx7WtzFsTXwnbrPEvb6odX2WnqYcnnrjiiLvp1mS"

howmuch="$2"
[[ -z $howmuch ]] \
  && howmuch="10"

# Get history JSON
jaklis history -p $WalletPublicKey -j -n $howmuch > T0.history.json
cat T0.history.json | jq -c .[] | jq -c 'del(.comment)' | jq -c 'del(.amountUD)' > tmp/N0.history.json && rm T0.history.json

# Function to check if a transaction is an income or outcome
is_income() {
    local amount=$1
    if (( $(echo "$amount > 0" | bc -l) )); then
        return 0  # true
    else
        return 1  # false
    fi
}

# Function to update existing entry or add new entry
update_or_add_entry() {
    local pubkey=$1
    local amount=$2
    local file=$3
    # echo "$pubkey : $amount -> $file"


    # Check if pubkey exists in file
    if grep -q "$pubkey" "$file"; then
        echo "# Update existing entry by adding $amount"
        jq --arg pubkey "$pubkey" --argjson amount "$amount" \
            'map(if .pubkey == $pubkey then .amount += $amount else . end)' \
            "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    else
        echo "# Add new entry : [{pubkey: $pubkey, amount: $amount}]"
        jq --arg pubkey "$pubkey" --argjson amount "$amount" \
            '. += [{pubkey: $pubkey, amount: $amount}]' \
            "$file" > "$file.tmp" && mv "$file.tmp" "$file"
    fi
}

# Initialize arrays for incomes and outcomes with empty arrays
echo "[]" > tmp/N1.incomes.json
echo "[]" > tmp/N1.outcomes.json

# Loop through each transaction
for row in $(cat tmp/N0.history.json); do
    echo Treating $row
    pubkey=$(echo ${row} | jq -r '.pubkey')
    amount=$(echo ${row} | jq -r '.amount')

    # Check if amount is a valid number
    if ! [[ "$amount" =~ ^[0-9.eE+-]+$ ]]; then
        echo "Skipping invalid amount: $amount"
        continue
    fi

    # Check if it's an income or outcome
    if is_income $amount; then
        # If income, update or add to incomes array
        update_or_add_entry "$pubkey" "$amount" "tmp/N1.incomes.json"
    else
        # If outcome, update or add to outcomes array
        update_or_add_entry "$pubkey" "$amount" "tmp/N1.outcomes.json"
    fi
done

echo "Incomes updated in tmp/N1.incomes.json"
echo "Outcomes updated in tmp/N1.outcomes.json"

