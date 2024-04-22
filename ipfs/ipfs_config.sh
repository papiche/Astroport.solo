#!/bin/bash
# Version: 0.1
# License: AGPL-3.0 (https://choosealicense.com/licenses/agpl-3.0/)
################################################################################
myIP=$(hostname -I | awk '{print $1}')
isLAN=$(sudo route -n | awk '$1 == "0.0.0.0" {print $2}' | grep -E "/(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)|(^::1$)|(^[fF][cCdD])/")

sudo systemctl stop ipfs

###########################################
### IMPORTANT !!!!!!! IMPORTANT !!!!!!
###########################################
# DHT PUBSUB mode
# ipfs config Pubsub.Router gossipsub ## DEPRECATED
ipfs config --json Ipns.UsePubsub true

# MAXSTORAGE = 1/2 full
availableDiskSize=$(df -P ~/ | awk 'NR>1{sum+=$4}END{print sum}')
fullDiskSize=$(df -P ~/ | awk 'NR>1{sum+=$2}END{print sum}')
diskSize="$((fullDiskSize / 2))"
ipfs config Datastore.StorageMax $diskSize

## Activate Rapid "ipfs p2p"
ipfs config --json Experimental.Libp2pStreamMounting true
ipfs config --json Experimental.P2pHttpProxy true

#~ ## Activate Experimental.AcceleratedDHTClient
#~ ipfs config Reprovider.Interval '42s'
#~ ipfs config Reprovider.Strategy "roots"
#~ ipfs config Routing.Routers.WanDHT --json '{
  #~ "Type": "dht",
  #~ "Parameters": {
    #~ "Mode": "auto",
    #~ "PublicIPNetwork": true,
    #~ "AcceleratedDHTClient": true
  #~ }
#~ }'

ipfs config --json Swarm.ConnMgr.LowWater 20
ipfs config --json Swarm.ConnMgr.HighWater 40

[ ! $isLAN ] && ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://'$myIP':8080", "http://'$(hostname)'.localhost:8080", "http://ipfs.localhost:8080", "http://127.0.0.1:8080", "http://127.0.1.1:8080", "https://ipfs.'$(hostname)'", "https://ipfs.copylaradio.com" ]' \
            ||   ipfs config --json API.HTTPHeaders.Access-Control-Allow-Origin '["http://'$myIP':8080", "http://'$(hostname)'.local:8080","http://'$(hostname)':8080", "http://'$(hostname)'.localhost:8080", "http://127.0.0.1:8080", "http://ipfs.localhost:8080", "http://127.0.1.1:8080" ]'

ipfs config --json API.HTTPHeaders.Access-Control-Allow-Methods '["PUT", "GET", "POST"]'
ipfs config --json API.HTTPHeaders.Access-Control-Allow-Credentials '["true"]'

## For ipfs.js = https://github.com/ipfs/js-ipfs/blob/master/docs/DELEGATE_ROUTERS.md
#~ ipfs config --json Addresses.Swarm | jq '. += ["/ip4/0.0.0.0/tcp/30215/ws"]' > /tmp/30215.ws
#~ ipfs config --json Addresses.Swarm "$(cat /tmp/30215.ws)"

ipfs config Addresses.API "/ip4/0.0.0.0/tcp/5001"
ipfs config Addresses.Gateway "/ip4/0.0.0.0/tcp/8080"

######### CLEAN DEFAULT BOOSTRAP ###########
ipfs bootstrap rm --all

sudo systemctl start ipfs
