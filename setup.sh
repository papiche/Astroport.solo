#!/bin/bash
MY_PATH="`dirname \"$0\"`"              # relative
MY_PATH="`( cd \"$MY_PATH\" && pwd )`"  # absolutized and normalized
hasError=0

## CREATES ~/.astro PYTHON ENV
if [[ ! -s ~/.astro/bin/activate ]]; then
    PYTHON=$(which python)
    cd $HOME
    $PYTHON -m venv .astro
    source ~/.astro/bin/activate
    cd -
fi
ME="${0##*/}"

# Activation de l'environnement virtuel Python (si existant)
if [ -s "$HOME/.astro/bin/activate" ]; then
    source $HOME/.astro/bin/activate       # Active l'environnement Python s'il existe pour les outils Python.
fi

## INSTALL PYTHON + CRYPTO LAYER
$MY_PATH/install.sh

[[ ! $(which ipfs) ]] && echo "INSTALL ipfs" && cd "$MY_PATH/ipfs" && exit 0
[[ ! $(which keygen) ]] && echo "INSTALL keygen" && cd "$MY_PATH/keygen" && exit 0
[[ ! $(which jaklis) ]] && echo "INSTALL jaklis" && cd "$MY_PATH/jaklis" && exit 0
[[ ! $(which natools) ]] && echo "INSTALL natools" && cd "$MY_PATH/natools" && exit 0
[[ ! $(which tiddlywiki) ]] && echo "INSTALL keygen" && cd "$MY_PATH/tiddlywiki" && exit 0

# Création du répertoire pour les données du jeu
mkdir -p ~/.zen/solo

# Début de la transmutation de la clé SSH
echo "<(''<)  <( ' SSH TRANSMUTATION ' )>  (> '')>"
echo "ENTER 'SALT & PEPPER' :"
echo "Salt ?"
read SECRET1
echo "Pepper ?"
read SECRET2
echo ">>> Resulting G1PUB :"
$MY_PATH/keygen/keygen "$SECRET1" "$SECRET2"
echo "Is it your key ? Enter to Confirm / Ctrl+C if wrong !"
read # Attends la confirmation de l'utilisateur.

    echo "
    <(''<)  <( ' ' )>  (> '')>
    ACTIVATING IPFS NODE Y LEVEL"
    echo "SALT=$SECRET1; PEPPER=$SECRET2" > ~/.zen/solo/secret.june # Sauvegarde les secrets.
    chmod 600 ~/.zen/solo/secret.june # Met des droits d'accès stricts.
    ## supprimer les anciennes clef de SWARM
    rm ~/.zen/solo/myswarm_secret.* # Supprime les anciennes clés IPFS.

    ## Creating IPNSNODEID from SECRETS
    keygen -t ipfs -o ~/.zen/solo/secret.ipns "$SECRET1" "$SECRET2" # Génère la clé IPNS.
    ## Convert IPFS key to Duniter key (G1 Wallet)
    keygen -i ~/.zen/solo/secret.ipns -t duniter -o ~/.zen/solo/secret.dunikey # Génère une clé Duniter à partir de la clé IPNS.

    ## Creating SSH from SECRETS
    keygen -t ssh -o ~/.zen/solo/id_ssh "$SECRET1" "$SECRET2" # Génère une clé SSH à partir des secrets.

    ## BitCOIN key reveal (BONUS)
    keygen -t bitcoin "$SECRET1" "$SECRET2" # Génère une clé Bitcoin.

    ##### IPFSNODEID UPGRADE
    ## EXTRACT PUB/PRIV KEY
    PeerID=$(~/.zen/Astroport.ONE/tools/keygen -i ~/.zen/solo/secret.ipns -t ipfs) # Extraire l'id IPFS de la clé
    echo $PeerID # Affiche l'id IPFS.
    PrivKey=$(~/.zen/Astroport.ONE/tools/keygen -i ~/.zen/solo/secret.ipns -t ipfs -s) # Extraire la clef privée
    echo $PrivKey # Affiche la clé privée

    # Backup actual Node ID
    cat ~/.ipfs/config | jq -r '.Identity.PeerID' \ # Sauvegarde de l'ID IPFS actuel.
        > ~/.zen/solo/ipfsnodeid.bkp
    cat ~/.ipfs/config | jq -r '.Identity.PrivKey' \ # Sauvegarde de la clé privée IPFS actuelle.
        >> ~/.zen/solo/ipfsnodeid.bkp

    # Insert new Node ID
    cp ~/.ipfs/config ~/.ipfs/config.bkp # Backup le fichier config IPFS.
    jq '.Identity.PeerID="'$PeerID'"' ~/.ipfs/config > ~/.ipfs/config.tmp # Ajoute le nouvel id IPFS.
    jq '.Identity.PrivKey="'$PrivKey'"' ~/.ipfs/config.tmp > ~/.ipfs/config && rm ~/.ipfs/config.tmp  # Ajoute la nouvelle clé privée et supprime le fichier tmp

    # Verify & restart IPFS daemon
    [[ "$(cat ~/.ipfs/config | jq -r '.Identity.PrivKey' )" != "$PrivKey" ]] \ # Test si l'opération s'est bien déroulée.
        && blurp="ERROR" \
        || blurp="SUCCESS"

    echo "##############################################################"


    ## Réactivation Astroport.ONE
    ~/.zen/Astroport.ONE/start.sh # Relance le service Astroport.

    echo "##############################################################"
    echo ">>> SSH LINK ACTIVATION ~/.zen/solo/id_ssh == ~/.ssh/id_ed25519"
    echo "##############################################################" # Affiche un séparateur.
    [[ ! -s ~/.ssh/origin.key ]] && mv ~/.ssh/id_ed25519 ~/.ssh/origin.key # Backup de l'ancienne clé.
    [[ ! -s ~/.ssh/origin.pub ]] && mv ~/.ssh/id_ed25519.pub ~/.ssh/origin.pub # Backup de l'ancienne clé.
    cat ~/.zen/solo/id_ssh > ~/.ssh/id_ed25519 && chmod 600 ~/.ssh/id_ed25519 # Création de la nouvelle clé SSH.
    cat ~/.zen/solo/id_ssh.pub > ~/.ssh/id_ed25519.pub && chmod 644 ~/.ssh/id_ed25519.pub # Création de la nouvelle clé SSH publique.

    ## SUCCESS
    echo "YOUR PREVIOUS SSH KEY IS ~/.ssh/origin.key"
    echo "\(^-^)/ ASTROPORT "
    echo "SECRET1=$SECRET1" # Affiche le sel.
    echo "SECRET2=$SECRET2" # Affiche le poivre.
# Configuration de l'environnement
    echo "ENTER SWARM DOMAIN ? (default 'copylaradio.com')" # Invite l'utilisateur à saisir le nom de domaine.
    read MYDOMAIN # Enregistre le nom de domaine saisi.
    [[ -z $MYDOMAIN ]] && MYDOMAIN="copylaradio.com" # Si rien n'a été saisi, une valeur par défaut est mise en place.
    echo "#########################################
myIPFS=https://ipfs.$MYDOMAIN # Variable pour IPFS
myASTROPORT=https://astroport.$MYDOMAIN # Variable pour Astroport
###################################
" > ~/.zen/Astroport.ONE/.env # Enregistre la valeur dans un fichier d'environnement.
    cat ~/.zen/Astroport.ONE/.env # Affiche le fichier de configuration
else # Si les ID IPFS sont les mêmes.
    echo "Y LEVEL ALREADY ACTIVATED : $IPFSNODEID " # Affiche un message d'information
fi

NODEG1PUB=$(cat ~/.zen/solo/secret.dunikey | grep 'pub:' | cut -d ' ' -f 2) # Affiche la clef publique G1 liée à cette clé IPFS
echo "NODEG1PUB=${NODEG1PUB}" # Affiche la clé


exit 0
