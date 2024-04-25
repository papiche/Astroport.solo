# N1(/N2) explorator

Web3 makes data centered on "public keys"

In Astroport, a key is assigned to each "PLAYER" (MULTIPASS)

It has a TW and a Wallet...

This a a dirty way to explore transaction circles...

## 1.extractN1.sh KEY N

Passing a public key (and a max transactions number) as parameter, this script analyze payment history

it makes  ```tmp/N1.incomes.json``` and ```N1.outcomes.json``` files

## 2.visualize_N1.py

From "N1" files, previoulsy created json, it makes a network graph.

## 3.extractN2.sh

Each public keys found in "N1" files is given to ```extractN1.sh```, it makes new N1 files in ```tmp/N2/```


---

Try. Explore and make it better
