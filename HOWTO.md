# ACTIVATE IPFS TW STORAGE

* 1/ CREATE KEY
```
keygen -t ipfs -o /tmp/coucou.key.ipfs "coucou" "coucou"
```

* 2/ IMPORT INTO ipfs
```
ipfs key import coucou -f pem-pkcs8-cleartext /tmp/coucou.key.ipfs
ipfs key list -l | grep coucou
```

* 3/ ADD TW to IPFS

```
TW=$(ipfs add -q ./tiddlywiki/TW/twuplanet.html)
echo $TW
```

* 4/ OPEN TW through IPFS gateway

```
xdg-open http://127.0.0.1:8080/ipfs/$TW
```

* 5/ ADD tiddler

...

# GET G1 WALLET

* 1/ CONVERT KEY

```
# Private key /tmp/coucou.dunikey
keygen -t duniter -o /tmp/coucou.dunikey "coucou" "coucou"
G1PUB=$(keygen -t duniter "coucou" "coucou")

```

* 2/ CHECK WALLET

```
jaklis balance -p $G1PUB

```

# ENCRYPT / DECRYPT

* 3/ ENCRYPT KEY

```
echo "message" > /tmp/message

natools encrypt \
    -p ${G1PUB} \
    -i /tmp/message \
    -o /tmp/message.enc

natools decrypt \
    -f pubsec \
    -k /tmp/coucou.dunikey \
    -i /tmp/message.enc \
    -o /tmp/message.decrypted

diff /tmp/message /tmp/message.decrypted


```

