#!/bin/bash
set -e

CHANNEL_NAME="mychannel"
PROJPATH=$(pwd)
CLIPATH=$PROJPATH/crypto-config/cli/peers
ORDERERS=$CLIPATH/ordererOrganizations
PEERS=$CLIPATH/peerOrganizations
FABRIC_CFG_PATH="$PROJPATH/crypto-config"
if [[ $(uname) = 'Darwin' ]]; then
    PLATFORM="mac"
else
    PLATFORM="ubuntu"
fi

rm -rf $CLIPATH

echo
echo "#################################################################"
echo "#######        Generating cryptographic material       ##########"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/cryptogen generate --config=$PROJPATH/crypto-config/crypto-config.yaml --output=$CLIPATH

echo
echo "##########################################################"
echo "#########  Generating Orderer Genesis block ##############"
echo "##########################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsGenesis -outputBlock $CLIPATH/genesis.block

echo
echo "#################################################################"
echo "### Generating channel configuration transaction 'channel.tx' ###"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsChannel -outputCreateChannelTx $CLIPATH/channel.tx -channelID $CHANNEL_NAME
cp $CLIPATH/channel.tx $PROJPATH/crypto-config/configuration/channel.tx

echo
echo "#################################################################"
echo "#######    Generating anchor peer update for ShopOrg   ##########"
echo "#################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $CLIPATH/ShopOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg ShopOrgMSP

echo
echo "##################################################################"
echo "####### Generating anchor peer update for RepairShopOrg ##########"
echo "##################################################################"
$PROJPATH/generators/$PLATFORM/configtxgen -profile TwoOrgsChannel -outputAnchorPeersUpdate $CLIPATH/CryptocurrencyOrgMSPAnchors.tx -channelID $CHANNEL_NAME -asOrg CryptocurrencyOrgMSP

rm -rf $PROJPATH/crypto-config/{orderer,shopPeer,cryptocurrencyPeer}
mkdir $PROJPATH/crypto-config/{orderer,shopPeer,cryptocurrencyPeer}
cp -r $ORDERERS/orderer-org/orderers/orderer0/{msp,tls} $PROJPATH/crypto-config/orderer
cp -r $PEERS/shop-org/peers/shop-peer/{msp,tls} $PROJPATH/crypto-config/shopPeer
cp -r $PEERS/cryptocurrency-org/peers/cryptocurrency-peer/{msp,tls} $PROJPATH/crypto-config/cryptocurrencyPeer
cp $CLIPATH/genesis.block $PROJPATH/crypto-config/orderer

SHOPCAPATH=$PROJPATH/crypto-config/shopCA
COIN_NAME_CA_PATH=$PROJPATH/crypto-config/cryptocurrencyCA

rm -rf {$SHOPCAPATH,${COIN_NAME_CA_PATH}}/{ca,tlsca}
mkdir -p {$SHOPCAPATH,${COIN_NAME_CA_PATH}}/{ca,tlsca}

cp -r $PEERS/shop-org/ca/ $SHOPCAPATH/ca
cp -r $PEERS/shop-org/tlsca/ $SHOPCAPATH/tls
mv $SHOPCAPATH/ca/*_sk $SHOPCAPATH/ca/key.pem
mv $SHOPCAPATH/ca/*-cert.pem $SHOPCAPATH/ca/cert.pem
mv $SHOPCAPATH/tls/*_sk $SHOPCAPATH/tls/key.pem
mv $SHOPCAPATH/tls/*-cert.pem $SHOPCAPATH/tls/cert.pem
rm -rf $PEERS/shop-org/tlsca

cp -r $PEERS/cryptocurrency-org/ca/ ${COIN_NAME_CA_PATH}/ca
cp -r $PEERS/cryptocurrency-org/tlsca/ ${COIN_NAME_CA_PATH}/tls
mv ${COIN_NAME_CA_PATH}/ca/*_sk ${COIN_NAME_CA_PATH}/ca/key.pem
mv ${COIN_NAME_CA_PATH}/ca/*-cert.pem ${COIN_NAME_CA_PATH}/ca/cert.pem
mv ${COIN_NAME_CA_PATH}/tls/*_sk ${COIN_NAME_CA_PATH}/tls/key.pem
mv ${COIN_NAME_CA_PATH}/tls/*-cert.pem ${COIN_NAME_CA_PATH}/tls/cert.pem
rm -rf $PEERS/cryptocurrency-org/tlsca

WEBCERTS=$PROJPATH/crypto-config/configuration/certs
rm -rf $WEBCERTS
mkdir -p $WEBCERTS
cp $PROJPATH/crypto-config/orderer/tls/ca.crt $WEBCERTS/ordererOrg.pem
cp $PROJPATH/crypto-config/shopPeer/tls/ca.crt $WEBCERTS/shopOrg.pem
cp $PROJPATH/crypto-config/cryptocurrencyPeer/tls/ca.crt $WEBCERTS/cryptocurrencyOrg.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/keystore/* $WEBCERTS/Admin@shop-org-key.pem
cp $PEERS/shop-org/users/Admin@shop-org/msp/signcerts/* $WEBCERTS/
cp $PEERS/cryptocurrency-org/users/Admin@cryptocurrency-org/msp/keystore/* $WEBCERTS/Admin@cryptocurrency-org-key.pem
cp $PEERS/cryptocurrency-org/users/Admin@cryptocurrency-org/msp/signcerts/* $WEBCERTS/

WEBCERTS=$PROJPATH/blockchainNetwork

BACKEND=$PROJPATH/backend
rm -rf $BACKEND/set-up
mkdir -p $BACKEND/set-up
cp -r $WEBCERTS/set-up/* $BACKEND/set-up/

cd $PROJPATH/crypto-config/configuration
npm install
node config.js
cd $PROJPATH
rm -rf $PROJPATH/crypto-config/cli
