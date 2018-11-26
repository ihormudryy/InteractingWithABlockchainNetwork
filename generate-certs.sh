#!/bin/bash
#set -e

if [ -z "$CHANNEL_NAME" ]; then
    export CHANNEL_NAME="marketplace"
fi

if [ -z "$ORDERER" ]; then
    export ORDERER="here"
fi
organizations=("consumer" "provider")

PROJPATH=$(pwd)
export FABRIC_CFG_PATH=$PROJPATH/templates
CLIPATH=$PROJPATH/templates/cli
ORDERERS=$CLIPATH/peers/ordererOrganizations
PEERS=$CLIPATH/peers/peerOrganizations

ORDERER_DOMAIN="example.com"

if [[ $(uname) = 'Darwin' ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

WEBCERTS=$PROJPATH/configuration/certs
rm -rf $WEBCERTS && mkdir -p $WEBCERTS

rm -rf $CLIPATH

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/cryptogen generate \
    --config=$FABRIC_CFG_PATH/cryptogen.yaml \
    --output=$CLIPATH/peers

echo
echo "##########################################################"
echo "#########  Generating Orderer Genesis block ##############"
echo "##########################################################"
$PROJPATH/generators/$PLATFORM/configtxgen \
    -profile TwoOrgsOrdererGenesis \
    -outputBlock $CLIPATH/peers/genesis.block \
    -channelID=${channel_name}

echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen \
    -profile TwoOrgsChannel \
    -outputCreateChannelTx $CLIPATH/peers/${channel_name}.tx \
    -channelID $CHANNEL_NAME

rm -rf $CLIPATH/$ORDERER && mkdir -p $CLIPATH/$ORDERER/{tls,msp}
cp -r $ORDERERS/${ORDERER_DOMAIN}/msp/* $CLIPATH/$ORDERER/msp
cp $ORDERERS/${ORDERER_DOMAIN}/tlsca/*_sk $CLIPATH/$ORDERER/tls/key.pem
cp $ORDERERS/${ORDERER_DOMAIN}/tlsca/*-cert.pem $CLIPATH/$ORDERER/tls/cert.pem

cp $CLIPATH/peers/genesis.block $CLIPATH/$ORDERER

for org in "${organizations[@]}"
do
    echo
    echo "#################################################################"
    echo "########    Generating anchor peer update for ${org}   ##########"
    echo "#################################################################"
    ORG_NAME_LOWERCASE=$(echo "$org" | awk '{print tolower($0)}')

    $PROJPATH/generators/$PLATFORM/configtxgen \
    -profile TwoOrgsChannel \
    -outputAnchorPeersUpdate $CLIPATH/peers/${org}Anchors.tx \
    -channelID $CHANNEL_NAME \
    -asOrg ${org}

    rm -rf $CLIPATH/${org}
    mkdir -p $CLIPATH/${org}/CA/{ca,tls}
    mkdir -p $CLIPATH/${org}/peer/{msp,tls}

    ORG_DOMAIN="${ORG_NAME_LOWERCASE}.${ORDERER_DOMAIN}"
    ORG_CA_PATH="$CLIPATH/${org}/CA"
    ORG_PEER_PATH="$CLIPATH/${org}/peer"

    cp $PEERS/${ORG_DOMAIN}/ca/*_sk $ORG_CA_PATH/ca/key.pem
    cp $PEERS/${ORG_DOMAIN}/ca/*-cert.pem $ORG_CA_PATH/ca/cert.pem
    cp $PEERS/${ORG_DOMAIN}/tlsca/*_sk $ORG_CA_PATH/tls/key.pem
    cp $PEERS/${ORG_DOMAIN}/tlsca/*-cert.pem $ORG_CA_PATH/tls/cert.pem

    cp -r $PEERS/${ORG_DOMAIN}/msp/* $ORG_PEER_PATH/msp
    cp $PEERS/${ORG_DOMAIN}/tlsca/*_sk $ORG_PEER_PATH/tls/key.pem
    cp $PEERS/${ORG_DOMAIN}/tlsca/*-cert.pem $ORG_PEER_PATH/tls/cert.pem
    cp $PEERS/${ORG_DOMAIN}/users/Admin@${ORG_DOMAIN}/msp/keystore/*_sk $ORG_PEER_PATH/server_key.pem
    
    cp -r $FABRIC_CFG_PATH/fabric-ca-server-configs/$ORG_NAME_LOWERCASE/*.yaml $CLIPATH/${org}/CA
done